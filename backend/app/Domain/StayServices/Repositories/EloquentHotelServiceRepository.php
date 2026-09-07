<?php

namespace App\Domain\StayServices\Repositories;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\StayServices\Models\HotelService;
use App\Domain\StayServices\Repositories\Contracts\HotelServiceRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentHotelServiceRepository implements HotelServiceRepositoryInterface
{
    public function paginateForHotel(User $user, Hotel $hotel, ?bool $onlyActive = null, int $perPage = 15): LengthAwarePaginator
    {
        return HotelService::query()
            ->accessibleBy($user)
            ->where('hotel_id', $hotel->id)
            ->when($onlyActive !== null, fn ($query) => $query->where('is_active', $onlyActive))
            ->orderBy('name')
            ->paginate($perPage);
    }

    public function find(int $id): ?HotelService
    {
        return HotelService::query()->find($id);
    }

    public function findForUpdate(int $id): ?HotelService
    {
        return HotelService::query()->lockForUpdate()->find($id);
    }

    public function create(array $data): HotelService
    {
        return HotelService::create($data)->refresh();
    }

    public function update(HotelService $service, array $data): HotelService
    {
        $service->update($data);

        return $service->refresh();
    }
}
