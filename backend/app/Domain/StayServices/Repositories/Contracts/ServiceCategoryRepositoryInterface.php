<?php

namespace App\Domain\StayServices\Repositories\Contracts;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\StayServices\Models\ServiceCategory;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ServiceCategoryRepositoryInterface
{
    /**
     * Categories for $hotel, restricted to what $user may access (Group
     * Owner bypass via the HotelScoped trait).
     */
    public function paginateForHotel(User $user, Hotel $hotel, int $perPage = 15): LengthAwarePaginator;

    public function find(int $id): ?ServiceCategory;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): ServiceCategory;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(ServiceCategory $category, array $data): ServiceCategory;
}
