<?php

namespace App\Domain\Inventory\Repositories\Contracts;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\Inventory\Models\RoomType;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface RoomTypeRepositoryInterface
{
    /**
     * Room Types belonging to $hotel, filtered through $user's own hotel
     * access (Group Owner bypass or assigned hotels only). Each result
     * carries the Phase 2 inventory snapshot counts (rooms_count,
     * available_rooms_count, maintenance_rooms_count).
     */
    public function paginateAccessibleBy(User $user, Hotel $hotel, int $perPage = 15): LengthAwarePaginator;

    /**
     * Plain lookup by id, snapshot counts included — no authorization
     * decision is made here, that is the Policy's responsibility.
     */
    public function find(int $id): ?RoomType;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): RoomType;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(RoomType $roomType, array $data): RoomType;
}
