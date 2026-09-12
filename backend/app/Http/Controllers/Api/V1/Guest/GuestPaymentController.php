<?php

namespace App\Http\Controllers\Api\V1\Guest;

use App\Domain\Payment\Models\Payment;
use App\Domain\Payment\Services\PaymentWorkflowService;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Reservation\Services\ReservationService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Guest\InitiateGuestPaymentHoldRequest;
use App\Http\Resources\V1\Guest\GuestPaymentResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * The authenticated guest's view of, and write path into, their
 * reservation's deposit payment (`/api/v1/guest/reservations/{reservation}/payment`).
 *
 * Architecture: dedicated GUEST controller/resource, thin over the shared
 * PaymentWorkflowService — mirrors the staff PaymentController::hold()
 * response mapping exactly. Authorization is ownership (guest_id === token
 * guest); a non-owned or missing reservation is an identical plain 404.
 *
 * ─────────────────────────────────────────────────────────────────────────
 * DEPOSIT AMOUNT
 * ─────────────────────────────────────────────────────────────────────────
 * PaymentWorkflowService::initiateHold() requires an approved deposit
 * amount. The approved rule (config/guest_booking.php -> deposit.rule) is
 * "percentage": the hold is `deposit.percentage`% of the reservation's
 * price_snapshot — resolved here, never invented inline. If the rule
 * config is unset, hold() refuses with a machine-readable
 * `deposit_amount_rule_undefined` reason, unchanged from before.
 */
class GuestPaymentController extends Controller
{
    public function __construct(
        private readonly ReservationService $reservations,
        private readonly PaymentWorkflowService $payments,
    ) {}

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

        $rule = config('guest_booking.deposit.rule');

        if ($rule === null) {
            return $this->error(
                __('api.guest_booking.deposit_rule_undefined'),
                422,
                ['reason' => 'deposit_amount_rule_undefined'],
            );
        }

        $payment = $this->payments->initiateHold(
            reservation: $found,
            amount: $this->resolveDepositAmount($rule, $found),
            idempotencyKey: $request->idempotencyKey(),
        );

        return $this->respond($payment);
    }

    private function resolveDepositAmount(string $rule, Reservation $reservation): string
    {
        return match ($rule) {
            'percentage' => $this->percentageOfTotal($reservation),
            default => throw new \RuntimeException("Unsupported guest deposit rule [{$rule}]."),
        };
    }

    private function percentageOfTotal(Reservation $reservation): string
    {
        $percentage = (string) config('guest_booking.deposit.percentage');

        return bcdiv(bcmul((string) $reservation->price_snapshot, $percentage, 4), '100', 2);
    }

    private function respond(Payment $payment): JsonResponse
    {
        return match ($payment->status) {
            Payment::STATUS_HOLD_ACTIVE => $this->success(
                new GuestPaymentResource($payment), __('api.payment.hold_placed'), 201,
            ),
            Payment::STATUS_HOLD_REQUESTED => $this->success(
                new GuestPaymentResource($payment), __('api.payment.hold_pending'), 200,
            ),
            Payment::STATUS_HOLD_FAILED => $this->error(
                __('api.payment.hold_failed'), 422, ['status' => $payment->status],
            ),
            Payment::STATUS_CANCELLED => $this->error(
                __('api.payment.hold_cancelled'), 422, ['status' => $payment->status],
            ),
            Payment::STATUS_EXPIRED => $this->error(
                __('api.payment.hold_expired'), 422, ['status' => $payment->status],
            ),
            default => $this->success(new GuestPaymentResource($payment), __('api.payment.hold_state')),
        };
    }

    private function guest(Request $request): Guest
    {
        /** @var Guest $guest */
        $guest = $request->user();

        return $guest;
    }
}
