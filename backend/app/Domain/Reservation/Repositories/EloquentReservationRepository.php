<?php

namespace App\Domain\Reservation\Repositories;

use App\Domain\IdentityAccess\Models\User;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Reservation\Repositories\Contracts\ReservationRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;

class EloquentReservationRepository implements ReservationRepositoryInterface
{
    public function paginateAccessibleBy(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->scopeToAccess(Reservation::query(), $user)->paginate($perPage);
    }

    public function findAccessibleBy(User $user, int $id): ?Reservation
    {
        return $this->scopeToAccess(Reservation::query(), $user)->find($id);
    }

    public function create(array $data): Reservation
    {
        return Reservation::create($data);
    }

    /**
     * Reservation deliberately does not use the HotelScoped trait (Phase
     * 3A decision) while its schema/model shape is still under review, so
     * the same Group-Owner-bypass / assigned-hotels-only rule the trait
     * applies elsewhere is reproduced here directly against the user's own
     * stored access records — never a client-supplied hotel_id.
     */
    private function scopeToAccess(Builder $query, User $user): Builder
    {
        if ($user->isGroupOwner()) {
            return $query;
        }

        return $query->whereIn('hotel_id', $user->authorizedHotelIds());
    }
}
