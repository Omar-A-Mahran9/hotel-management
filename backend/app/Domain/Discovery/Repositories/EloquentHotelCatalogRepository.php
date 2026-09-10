<?php

namespace App\Domain\Discovery\Repositories;

use App\Domain\Discovery\Repositories\Contracts\HotelCatalogRepositoryInterface;
use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Inventory\Models\RoomType;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;

class EloquentHotelCatalogRepository implements HotelCatalogRepositoryInterface
{
    public function paginateActiveHotels(?string $city, ?string $search, int $perPage): LengthAwarePaginator
    {
        return Hotel::query()
            ->where('is_active', true)
            ->when($city !== null && $city !== '', fn (Builder $q) => $q->where('city', $city))
            ->when($search !== null && $search !== '', fn (Builder $q) => $q->where(function (Builder $inner) use ($search): void {
                $inner->where('name', 'like', '%'.$search.'%')
                    ->orWhere('city', 'like', '%'.$search.'%');
            }))
            ->orderBy('name')
            ->paginate($perPage);
    }

    public function findActiveHotel(int $id): ?Hotel
    {
        return Hotel::query()->where('is_active', true)->find($id);
    }

    public function activeHotelCities(): array
    {
        return Hotel::query()
            ->where('is_active', true)
            ->selectRaw('city, count(*) as hotel_count')
            ->groupBy('city')
            ->orderBy('city')
            ->get()
            ->map(fn ($row) => ['city' => (string) $row->city, 'hotel_count' => (int) $row->hotel_count])
            ->all();
    }

    public function activeRoomTypesForHotel(int $hotelId): Collection
    {
        return RoomType::query()
            ->withCount([
                'rooms',
                'rooms as available_rooms_count' => fn (Builder $query) => $query->where('status', 'available'),
                'rooms as maintenance_rooms_count' => fn (Builder $query) => $query->where('status', 'under_maintenance'),
            ])
            ->where('hotel_id', $hotelId)
            ->where('is_active', true)
            ->orderBy('base_price')
            ->get();
    }
}
