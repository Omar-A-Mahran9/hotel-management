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
}
