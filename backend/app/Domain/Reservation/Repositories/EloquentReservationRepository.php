<?php

namespace App\Domain\Reservation\Repositories;

use App\Domain\IdentityAccess\Models\User;
use App\Domain\Reservation\Models\Guest;
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

    public function paginateOwnedByGuest(Guest $guest, int $perPage = 15): LengthAwarePaginator
    {
        return Reservation::query()
            ->where('guest_id', $guest->id)
            ->latest('id')
            ->paginate($perPage);
    }

    public function findOwnedByGuest(Guest $guest, int $id): ?Reservation
    {
        return Reservation::query()
            ->where('guest_id', $guest->id)
            ->find($id);
    }

    public function create(array $data): Reservation
    {
        return Reservation::create($data);
    }

    public function findForUpdate(int $id): ?Reservation
    {
        return Reservation::query()->lockForUpdate()->find($id);
    }

    public function update(Reservation $reservation, array $data): Reservation
    {
        $reservation->update($data);

        return $reservation->refresh();
    }

    public function countOverlappingForRoom(int $roomId, string $checkIn, string $checkOut): int
    {
        return $this->overlapQuery($checkIn, $checkOut)
            ->where('room_id', $roomId)
            ->count();
    }

    public function countOverlappingForRoomType(int $roomTypeId, string $checkIn, string $checkOut): int
    {
        return $this->overlapQuery($checkIn, $checkOut)
            ->where('room_type_id', $roomTypeId)
            ->count();
    }

    /**
     * Canonical, checkout-exclusive overlap predicate (approved Phase 3D):
     * existing.check_in < $checkOut AND $checkIn < existing.check_out.
     * Strict `<` on both sides is what allows adjacent stays through.
     * Scoped to Reservation::BLOCKING_STATUSES as an explicit positive
     * list — never `status != cancelled` — so an unrecognized future
     * status can never silently become inventory-blocking.
     */
    private function overlapQuery(string $checkIn, string $checkOut): Builder
    {
        return Reservation::query()
            ->whereIn('status', Reservation::BLOCKING_STATUSES)
            ->where('check_in', '<', $checkOut)
            ->where('check_out', '>', $checkIn);
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
