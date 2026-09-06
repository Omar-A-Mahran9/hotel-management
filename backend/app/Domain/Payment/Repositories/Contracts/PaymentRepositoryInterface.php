<?php

namespace App\Domain\Payment\Repositories\Contracts;

use App\Domain\Payment\Models\Payment;

interface PaymentRepositoryInterface
{
    /**
     * Plain lookup by id — no authorization decision is made here, that is
     * the Policy's responsibility (added in a later sub-phase).
     */
    public function find(int $id): ?Payment;

    /**
     * The single Payment belonging to a Reservation (approved 1:1
     * relationship), or null if none has been started yet.
     */
    public function findByReservation(int $reservationId): ?Payment;

    /**
     * `find()` under a `SELECT ... FOR UPDATE` row lock. Must be called only
     * from within an active DB::transaction() — the lock the Phase 5C
     * payment workflow relies on for its Step C re-read.
     */
    public function findForUpdate(int $id): ?Payment;

    /**
     * `findByReservation()` under a row lock — used in Phase 5C Step A so a
     * concurrent initiation cannot both discover "no Payment" and both
     * insert. Must be called only from within an active DB::transaction().
     */
    public function findByReservationForUpdate(int $reservationId): ?Payment;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): Payment;

    /**
     * Persist $data onto $payment and return the refreshed model. Pure
     * persistence — the caller (PaymentWorkflowService) owns every workflow
     * decision, including the PaymentStateMachine guard.
     *
     * @param  array<string, mixed>  $data
     */
    public function update(Payment $payment, array $data): Payment;
}
