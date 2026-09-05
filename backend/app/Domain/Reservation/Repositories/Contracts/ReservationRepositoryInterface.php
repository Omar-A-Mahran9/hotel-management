<?php

namespace App\Domain\Reservation\Repositories\Contracts;

use App\Domain\IdentityAccess\Models\User;
use App\Domain\Reservation\Models\Reservation;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ReservationRepositoryInterface
{
    /**
     * Reservations filtered through $user's own hotel access (Group Owner
     * bypass or assigned hotels only) — never from a client-supplied
     * hotel_id. Not nested under a single Hotel, unlike Phase 2's
     * Room/RoomType listings: a Reservation route has not been designed
     * yet (Phase 3C), so this returns everything the user may see across
     * all their accessible hotels.
     */
    public function paginateAccessibleBy(User $user, int $perPage = 15): LengthAwarePaginator;

    /**
     * Lookup by id, scoped to $user's own hotel access — returns null both
     * when the reservation does not exist and when it exists but belongs
     * to a hotel the user cannot access, so a caller can never distinguish
     * the two from this method alone.
     */
    public function findAccessibleBy(User $user, int $id): ?Reservation;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): Reservation;
}
