<?php

namespace App\Domain\StayServices\Services;

use App\Domain\Payment\Models\Payment;
use App\Domain\Payment\Repositories\Contracts\PaymentRepositoryInterface;
use App\Domain\Payment\Repositories\Contracts\PaymentTransactionRepositoryInterface;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\StayServices\Models\FolioCharge;
use App\Domain\StayServices\Repositories\Contracts\FolioChargeRepositoryInterface;
use Illuminate\Support\Collection;

/**
 * Phase 8D — read-only folio maths for a reservation. Deterministic, all
 * DECIMAL-safe (bcmath, never float).
 *
 *   charges_total     = SUM(folio_charges.total_amount WHERE status = posted)
 *                       — includes the Phase 9 accommodation charge and every
 *                       posted service-order charge.
 *   payments_total    = SUM(payment_transactions.amount) over the payment's
 *                       SUCCEEDED capture + settlement transactions
 *                       (Phase 9 review fix). The payment history is the
 *                       source of truth; `payments.amount` (the deposit
 *                       requested at booking) is never used here and never
 *                       overwritten. A hold / pending / failed attempt
 *                       collects nothing and counts as zero.
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
        private readonly PaymentTransactionRepositoryInterface $paymentTransactions,
    ) {}

    public function folioFor(Reservation $reservation): Folio
    {
        $charges = $this->charges->allForReservation($reservation->id);
        $payment = $this->payments->findByReservation($reservation->id);

        $chargesTotal = $this->charges->sumTotalForReservation(
            $reservation->id,
            FolioCharge::OWED_STATUSES,
        );

        $paymentsTotal = $payment === null
            ? '0.00'
            : $this->paymentTransactions->sumCollectedForPayment($payment->id);
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
