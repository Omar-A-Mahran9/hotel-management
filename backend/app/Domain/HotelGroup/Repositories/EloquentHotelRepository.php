<?php

namespace App\Domain\HotelGroup\Repositories;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\HotelGroup\Repositories\Contracts\HotelRepositoryInterface;
use App\Domain\IdentityAccess\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentHotelRepository implements HotelRepositoryInterface
{
    public function paginateAccessibleBy(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return Hotel::query()
            ->accessibleBy($user)
            ->with(['hotelGroup', 'countryRef', 'cityRef'])
            ->paginate($perPage);
    }

    public function find(int $id): ?Hotel
    {
        return Hotel::query()->with(['hotelGroup', 'countryRef', 'cityRef'])->find($id);
    }

    public function create(array $data): Hotel
    {
        return Hotel::create($data)->refresh();
    }

    public function update(Hotel $hotel, array $data): Hotel
    {
        $hotel->update($data);

        return $hotel->refresh();
    }
}
