<?php

namespace App\Domain\HotelGroup\Repositories\Contracts;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\IdentityAccess\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface HotelRepositoryInterface
{
    public function paginateAccessibleBy(User $user, int $perPage = 15): LengthAwarePaginator;

    public function find(int $id): ?Hotel;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): Hotel;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Hotel $hotel, array $data): Hotel;
}
