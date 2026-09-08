<?php

namespace App\Domain\Checkout\Repositories\Contracts;

use App\Domain\Checkout\Models\Checkout;

interface CheckoutRepositoryInterface
{
    public function find(int $id): ?Checkout;

    /**
     * The single checkout for a reservation (approved 1:1), or null.
     */
    public function findByReservation(int $reservationId): ?Checkout;

    /**
     * `findByReservation()` under a `SELECT ... FOR UPDATE` row lock — so two
     * concurrent checkouts cannot both create or advance the record. Call
     * only from within an active DB::transaction().
     */
    public function findByReservationForUpdate(int $reservationId): ?Checkout;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): Checkout;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Checkout $checkout, array $data): Checkout;
}
