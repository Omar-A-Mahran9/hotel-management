<?php

namespace App\Http\Controllers\Api\V1\Guest;

use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Services\ReservationService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Guest\InitiateGuestPaymentHoldRequest;
use App\Http\Resources\V1\Guest\GuestPaymentResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * The authenticated guest's view of their reservation's deposit payment
 * (`/api/v1/guest/reservations/{reservation}/payment`).
 *
 * Architecture: dedicated GUEST controller/resource. Reads reuse the shared
 * reservation ownership scope; the write path is designed to reuse
 * PaymentWorkflowService unchanged — but see the deposit-amount block below.
 * Authorization is ownership (guest_id === token guest); a non-owned or
 * missing reservation is an identical plain 404.
 *
 * ─────────────────────────────────────────────────────────────────────────
 * DEPOSIT AMOUNT — EXPLICIT BUSINESS DECISION REQUIRED
 * ─────────────────────────────────────────────────────────────────────────
 * PaymentWorkflowService::initiateHold() requires an approved deposit
 * amount. There is NO approved rule for a guest deposit anywhere in the
 * codebase (flat? first night? a % of the stay? none?). This controller
 * therefore does NOT initiate a hold — `hold()` refuses with a
 * machine-readable `deposit_amount_rule_undefined` reason. The full
 * reservation price is explicitly NOT used as a stand-in. Once
 * config/guest_booking.php → `deposit.rule` is approved, `hold()` becomes a
 * thin call into the existing PaymentWorkflowService (structure, ownership,
 * idempotency and validation are already in place here).
 */
class GuestPaymentController extends Controller
{
    public function __construct(private readonly ReservationService $reservations) {}

    public function show(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservations->findOwnedByGuest($this->guest($request), $reservation);

        if (! $found) {
            abort(404);
        }

        $payment = $found->payment()->first();

        if ($payment === null) {
            return $this->success(null, __('api.guest_booking.no_payment'));
        }

        return $this->success(new GuestPaymentResource($payment));
    }

    public function hold(InitiateGuestPaymentHoldRequest $request, int $reservation): JsonResponse
    {
        $found = $this->reservations->findOwnedByGuest($this->guest($request), $reservation);

        if (! $found) {
            abort(404);
        }

        if (config('guest_booking.deposit.rule') === null) {
            return $this->error(
                __('api.guest_booking.deposit_rule_undefined'),
                422,
                ['reason' => 'deposit_amount_rule_undefined'],
            );
        }

        // Intentionally unreachable until a deposit rule is approved. When it
        // is, resolve the amount from the rule + reservation and delegate to
        // the shared PaymentWorkflowService::initiateHold(...) — do not
        // compute or transition anything here.
        abort(501); // @codeCoverageIgnore
    }

    private function guest(Request $request): Guest
    {
        /** @var Guest $guest */
        $guest = $request->user();

        return $guest;
    }
}
