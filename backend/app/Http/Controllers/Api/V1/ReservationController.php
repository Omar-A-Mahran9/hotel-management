<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Inventory\Services\RoomTypeService;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Reservation\Services\ReservationService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Reservation\StoreReservationRequest;
use App\Http\Resources\V1\ReservationResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReservationController extends Controller
{
    public function __construct(
        private readonly ReservationService $reservations,
        private readonly RoomTypeService $roomTypes,
    ) {}

    /**
     * Reservations visible here are always resolved from the
     * authenticated user's own hotel access — a client cannot widen this
     * by passing any request parameter.
     */
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Reservation::class);

        return $this->success(ReservationResource::collection(
            $this->reservations->listAccessibleBy($request->user())
        ));
    }

    /**
     * The Room Type is resolved first (via the existing Inventory
     * RoomTypeService, not a direct query) purely to authorize against
     * its hotel — there is no route-bound Hotel for a Reservation
     * (Phase 3C decision D3). ReservationService::create() independently
     * re-resolves Room Type/Room/Guest and re-derives hotel_id as the
     * authoritative business-invariant check; this lookup only feeds the
     * Policy.
     */
    public function store(StoreReservationRequest $request): JsonResponse
    {
        $roomType = $this->roomTypes->find($request->validated('room_type_id'));

        if (! $roomType) {
            abort(404);
        }

        $this->authorize('create', [Reservation::class, $roomType->hotel]);

        $reservation = $this->reservations->create($request->validated(), $request->user());

        return $this->success(new ReservationResource($reservation), __('api.created'), 201);
    }

    /**
     * Scoped through ReservationService::findAccessibleBy() rather than
     * implicit route-model binding (Phase 3C decision D1) — a reservation
     * that does not exist and one that exists but belongs to a hotel the
     * user cannot access are both a plain 404, never a 403 that would
     * leak its existence.
     */
    public function show(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservations->findAccessibleBy($request->user(), $reservation);

        if (! $found) {
            abort(404);
        }

        $this->authorize('view', $found);

        return $this->success(new ReservationResource($found));
    }
}
