<?php

namespace App\Domain\StayServices\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\StayServices\Models\FolioCharge;
use App\Domain\StayServices\Repositories\Contracts\FolioChargeRepositoryInterface;
use Illuminate\Database\UniqueConstraintViolationException;

/**
 * Phase 9 (review fix) — posts folio charges that do not originate from a
 * service order. Currently the reservation accommodation charge.
 *
 * Follows the Phase 8 folio-charge architecture (`ServiceOrderService`
 * posts service-order charges the same way): idempotent via the
 * `folio_charges (source_type, source_id)` UNIQUE plus a pre-check,
 * audited, decimal-safe.
 *
 * Every method MUST be called from within the caller's DB transaction (the
 * reservation row is already locked). It opens no transaction of its own
 * and calls no external provider.
 */
class FolioChargeService
{
    public function __construct(
        private readonly FolioChargeRepositoryInterface $charges,
        private readonly AuditLogger $auditLogger,
    ) {}

    /**
     * Post (once) the reservation accommodation charge. The amount is
     * `reservation.price_snapshot` used EXACTLY — no nights maths, no tax,
     * no second pricing calculation (Phase 9 review requirement).
     *
     * Idempotent: `source_type = accommodation`, `source_id = reservation.id`,
     * so a checkout retry always reuses the same row and never duplicates it.
     *
     * Returns null when there is no accommodation amount to bill
     * (`price_snapshot` null or not > 0) — nothing to post, exactly like a
     * folio with no service orders has no service lines.
     */
    public function postAccommodationCharge(Reservation $reservation, ?string $currency, ?User $actor): ?FolioCharge
    {
        $existing = $this->charges->findBySourceForUpdate(
            FolioCharge::SOURCE_ACCOMMODATION,
            $reservation->id,
        );

        if ($existing !== null) {
            return $existing;
        }

        $amount = $reservation->price_snapshot === null
            ? null
            : bcadd((string) $reservation->price_snapshot, '0', 2);

        if ($amount === null || bccomp($amount, '0.00', 2) <= 0) {
            return null;
        }

        try {
            $charge = $this->charges->create([
                'reservation_id' => $reservation->id,
                'hotel_id' => $reservation->hotel_id,
                'source_type' => FolioCharge::SOURCE_ACCOMMODATION,
                'source_id' => $reservation->id,
                'description' => 'Accommodation',
                'quantity' => 1,
                'unit_amount' => $amount,
                'total_amount' => $amount,
                'currency' => $currency,
                'status' => FolioCharge::STATUS_POSTED,
                'charged_at' => now(),
                'created_by_user_id' => $actor?->id,
            ]);
        } catch (UniqueConstraintViolationException) {
            // A concurrent checkout posted it first — the UNIQUE constraint
            // is authoritative. Re-read and return the winner.
            return $this->charges->findBySource(FolioCharge::SOURCE_ACCOMMODATION, $reservation->id);
        }

        $this->auditLogger->record(
            $actor,
            'folio_charge.created',
            $charge,
            after: array_filter([
                'folio_charge_status' => $charge->status,
                'source_type' => $charge->source_type,
                'source_id' => $charge->source_id,
                'total_amount' => $charge->total_amount,
                'currency' => $charge->currency,
                'charged_at' => $charge->charged_at?->toIso8601String(),
            ], fn ($value) => $value !== null),
            hotelId: $charge->hotel_id,
        );

        return $charge;
    }
}
