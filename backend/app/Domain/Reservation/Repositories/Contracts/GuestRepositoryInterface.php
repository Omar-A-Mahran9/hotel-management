<?php

namespace App\Domain\Reservation\Repositories\Contracts;

use App\Domain\Reservation\Models\Guest;

interface GuestRepositoryInterface
{
    /**
     * Plain lookup by id — no authorization decision is made here, that
     * is the caller's responsibility.
     */
    public function find(int $id): ?Guest;

    /**
     * Lookup by the canonical E.164 phone (the guest login identifier).
     */
    public function findByPhone(string $phone): ?Guest;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): Guest;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Guest $guest, array $data): Guest;
}
