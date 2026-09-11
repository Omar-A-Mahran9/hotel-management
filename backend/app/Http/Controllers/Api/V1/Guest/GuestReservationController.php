<?php

namespace App\Http\Controllers\Api\V1\Guest;

use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Reservation\Services\ReservationService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Guest\StoreGuestReservationRequest;
use App\Http\Resources\V1\Guest\GuestReservationResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * The authenticated guest's own reservations (`/api/v1/guest/reservations`).
 *
 * Architecture: this is a dedicated GUEST controller/resource. It reuses the
 * shared ReservationService for every business decision (availability, the
 * price snapshot, the state machine, the audit entry) — no reservation
 * business logic is implemented or duplicated here. The staff dashboard
 * keeps using ReservationController; a guest-created reservation shows up
 * there with no dashboard change.
 *
 * Authorization is ownership: the guest identity comes from the `guest`
 * Sanctum token, and every read is scoped to `guest_id === token guest` by
 * the service/repository, so a reservation that does not exist and one that
 * belongs to another guest are an identical plain 404.
 */
class GuestReservationController extends Controller
{
    public function __construct(private readonly ReservationService $reservations) {}

    public function index(Request $request): JsonResponse
    {
        $guest = $this->guest($request);

        $perPage = min(
            max((int) $request->query('per_page', (int) config('guest_booking.pagination.per_page', 15)), 1),
            (int) config('guest_booking.pagination.max_per_page', 50),
        );

        return $this->success(GuestReservationResource::collection(
            $this->reservations->listOwnedByGuest($guest, $perPage)
        ));
    }

    public function store(StoreGuestReservationRequest $request): JsonResponse
    {
        $guest = $this->guest($request);

        // actor: null — a guest-initiated booking has no staff creator.
        // ReservationService independently re-resolves the room type, derives
        // hotel_id, runs the approved availability/concurrency checks and
        // takes the price snapshot.
        $reservation = $this->reservations->create(
            $request->reservationData($guest->id),
            actor: null,
        );

        $reservation->load(['hotel', 'roomType']);

        return $this->success(
            new GuestReservationResource($reservation),
            __('api.created'),
            201,
        );
    }

    public function show(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservations->findOwnedByGuest($this->guest($request), $reservation);

        if (! $found) {
            abort(404);
        }

        $found->load(['hotel', 'roomType', 'payment']);

        return $this->success(new GuestReservationResource($found));
    }

    /**
     * Cancel a reservation the guest still may cancel. The permitted
     * transitions (pending / deposit_held / verified → cancelled) are
     * enforced by ReservationStateMachine via ReservationService — an
     * out-of-window cancel surfaces as the standard 422.
     */
    public function cancel(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservations->findOwnedByGuest($this->guest($request), $reservation);

        if (! $found) {
            abort(404);
        }

        $updated = $this->reservations->transitionTo(
            $found,
            Reservation::STATUS_CANCELLED,
            actor: null,
        );

        $updated->load(['hotel', 'roomType', 'payment']);

        return $this->success(
            new GuestReservationResource($updated),
            __('api.updated'),
        );
    }

    private function guest(Request $request): Guest
    {
        /** @var Guest $guest */
        $guest = $request->user();

        return $guest;
    }
}
