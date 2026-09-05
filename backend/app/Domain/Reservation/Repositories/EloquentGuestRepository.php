<?php

namespace App\Domain\Reservation\Repositories;

use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Repositories\Contracts\GuestRepositoryInterface;

class EloquentGuestRepository implements GuestRepositoryInterface
{
    public function find(int $id): ?Guest
    {
        return Guest::query()->find($id);
    }
}
