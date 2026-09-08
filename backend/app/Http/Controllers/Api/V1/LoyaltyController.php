<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Loyalty\Models\LoyaltyAccount;
use App\Domain\Loyalty\Services\LoyaltyService;
use App\Domain\Reservation\Services\ReservationService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Loyalty\RedeemLoyaltyRequest;
use App\Http\Resources\V1\LoyaltyAccountResource;
use App\Http\Resources\V1\LoyaltyTransactionResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Phase 10 — the reservation-scoped loyalty surface (Phase 0 §16:
 * /api/v1/loyalty/{account|transactions|redeem}, reached here via the
 * reservation so hotel scope + guest identity are resolved server-side —
 * guest authentication does not exist in this MVP).
 *
 * Thin, same conventions as CheckoutController / ServiceOrderController:
 * {reservation} is an int id resolved through ReservationService, so a
 * cross-hotel or missing id is an identical plain 404. The workflow lives
 * in LoyaltyService. The client never supplies guest_id / points_balance /
 * a ledger delta.
 */
class LoyaltyController extends Controller
{
    public function __construct(
        private readonly ReservationService $reservations,
        private readonly LoyaltyService $loyalty,
    ) {}

    /**
     * GET /api/v1/reservations/{reservation}/loyalty
     */
    public function show(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservationFor($request, $reservation, 'view');

        $account = $this->loyalty->accountFor($found->guest);

        return $this->success(new LoyaltyAccountResource($account), __('api.loyalty.account'));
    }

    /**
     * GET /api/v1/reservations/{reservation}/loyalty/transactions
     */
    public function transactions(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservationFor($request, $reservation, 'view');

        return $this->success(
            LoyaltyTransactionResource::collection($this->loyalty->ledgerFor($found->guest)),
            __('api.loyalty.transactions'),
        );
    }

    /**
     * POST /api/v1/reservations/{reservation}/loyalty/earn
     */
    public function earn(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservationFor($request, $reservation, 'manage');

        $transaction = $this->loyalty->earnForReservation($found, $request->user());

        return $this->success(new LoyaltyTransactionResource($transaction), __('api.loyalty.earned'), 201);
    }

    /**
     * POST /api/v1/reservations/{reservation}/loyalty/redeem
     */
    public function redeem(RedeemLoyaltyRequest $request, int $reservation): JsonResponse
    {
        $found = $this->reservationFor($request, $reservation, 'manage');

        $transaction = $this->loyalty->redeemForReservation($found, $request->points(), $request->user());

        return $this->success(new LoyaltyTransactionResource($transaction), __('api.loyalty.redeemed'), 201);
    }

    private function reservationFor(Request $request, int $reservation, string $ability)
    {
        $found = $this->reservations->findAccessibleBy($request->user(), $reservation);

        if (! $found) {
            abort(404);
        }

        $this->authorize($ability, [LoyaltyAccount::class, $found]);

        return $found;
    }
}
