<?php

namespace App\Domain\StayServices\Services;

use App\Domain\Payment\Models\Payment;
use App\Domain\Payment\Repositories\Contracts\PaymentRepositoryInterface;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\StayServices\Models\FolioCharge;
use App\Domain\StayServices\Repositories\Contracts\FolioChargeRepositoryInterface;
use Illuminate\Support\Collection;

/**
 * Phase 8D — read-only folio maths for a reservation. Deterministic, all
 * DECIMAL-safe (bcmath, never float).
 *
 *   charges_total     = SUM(folio_charges.total_amount WHERE status = posted)
 *   payments_total    = the reservation Payment's amount, but ONLY when the
 *                       Payment is CAPTURED / SETTLED (Phase 0 §9). A hold
 *                       (HOLD_ACTIVE), a pending or a failed payment counts
 *                       as zero — a deposit authorization is not money in.
 *   outstanding_total = charges_total - payments_total
 *
 * This phase does NOT implement checkout, settlement, capture or invoicing;
 * it only exposes the clean data those later phases consume.
 */
class FolioService
{
    public function __construct(
        private readonly FolioChargeRepositoryInterface $charges,
        private readonly PaymentRepositoryInterface $payments,
    ) {}

    public function folioFor(Reservation $reservation): Folio
    {
        $charges = $this->charges->allForReservation($reservation->id);
        $payment = $this->payments->findByReservation($reservation->id);

        $chargesTotal = $this->charges->sumTotalForReservation(
            $reservation->id,
            FolioCharge::OWED_STATUSES,
        );

        $paymentsTotal = $this->capturedPaymentAmount($payment);
        $outstanding = bcsub($chargesTotal, $paymentsTotal, 2);

        return new Folio(
            reservation: $reservation,
            charges: $charges,
            payment: $payment,
            chargesTotal: $chargesTotal,
            paymentsTotal: $paymentsTotal,
            outstandingTotal: $outstanding,
            currency: $this->resolveCurrency($charges, $payment),
        );
    }

    /**
     * The captured/settled amount for a reservation's payment, as a
     * canonical decimal string. Anything that is not CAPTURED / SETTLED —
     * including a live deposit hold, a pending capture, or a failed
     * payment — contributes 0.00.
     */
    private function capturedPaymentAmount(?Payment $payment): string
    {
        if ($payment === null
            || ! in_array($payment->status, Payment::CAPTURED_STATUSES, true)
            || $payment->amount === null) {
            return '0.00';
        }

        return bcadd((string) $payment->amount, '0', 2);
    }

    /**
     * Best-effort display currency: the payment's, else the first charge's.
     * Never invented — null when nothing on the folio carries one.
     *
     * @param  Collection<int, FolioCharge>  $charges
     */
    private function resolveCurrency($charges, ?Payment $payment): ?string
    {
        if ($payment?->currency !== null && $payment->currency !== '') {
            return $payment->currency;
        }

        foreach ($charges as $charge) {
            if ($charge->currency !== null && $charge->currency !== '') {
                return $charge->currency;
            }
        }

        return null;
    }
}
