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

    public function findByPhone(string $phone): ?Guest
    {
        return Guest::query()->where('phone', $phone)->first();
    }

    public function create(array $data): Guest
    {
        return Guest::create($data);
    }

    public function update(Guest $guest, array $data): Guest
    {
        $guest->update($data);

        return $guest->refresh();
    }
}
