<?php

namespace App\Domain\HotelGroup\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\HotelGroup\Repositories\Contracts\HotelRepositoryInterface;
use App\Domain\IdentityAccess\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class HotelService
{
    public function __construct(
        private readonly HotelRepositoryInterface $hotels,
        private readonly AuditLogger $auditLogger,
    ) {}

    /**
     * Hotels visible to $user, resolved from their own stored hotel
     * access / Group Owner bypass — never from a request parameter.
     */
    public function listAccessibleBy(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->hotels->paginateAccessibleBy($user, $perPage);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data, ?User $actor): Hotel
    {
        return DB::transaction(function () use ($data, $actor) {
            $hotel = $this->hotels->create($data);

            $this->auditLogger->record($actor, 'hotel.created', $hotel, after: $hotel->toArray(), hotelId: $hotel->id);

            return $hotel;
        });
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Hotel $hotel, array $data, ?User $actor): Hotel
    {
        return DB::transaction(function () use ($hotel, $data, $actor) {
            $before = $hotel->toArray();

            $this->hotels->update($hotel, $data);

            $this->auditLogger->record($actor, 'hotel.updated', $hotel, before: $before, after: $hotel->toArray(), hotelId: $hotel->id);

            return $hotel;
        });
    }
}
