<?php

namespace App\Domain\Reservation\Repositories\Contracts;

use App\Domain\IdentityAccess\Models\User;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Models\Reservation;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ReservationRepositoryInterface
{
    /**
     * Reservations belonging to $guest (guest_id === $guest->id), newest
     * first. The guest booking API's ownership boundary — a guest can only
     * ever see their own reservations. Data access only; no business rule.
     */
    public function paginateOwnedByGuest(Guest $guest, int $perPage = 15): LengthAwarePaginator;

    /**
     * Lookup by id scoped to $guest's ownership — returns null both when the
     * reservation does not exist and when it exists but belongs to another
     * guest, so the guest API answers an identical plain 404 for both and
     * never leaks existence.
     */
    public function findOwnedByGuest(Guest $guest, int $id): ?Reservation;

    /**
     * A guest's reservations, filtered through $user's own hotel access
     * (Group Owner bypass or assigned hotels only) — the staff-facing
     * counterpart to paginateOwnedByGuest, used by the Guests directory's
     * per-guest reservation history so a Hotel Manager only ever sees the
     * slice of a guest's history that belongs to their own hotel(s).
     */
    public function paginateForGuestAccessibleBy(User $user, Guest $guest, int $perPage = 15): LengthAwarePaginator;

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

    /**
     * Locks the Reservation row for the duration of the caller's
     * transaction (`SELECT ... FOR UPDATE`). Must only be called from
     * within an active DB::transaction(). This is the row lock the
     * status-transition workflow (Phase 4B) relies on so two concurrent
     * transitions cannot both act on stale state — the same
     * findForUpdate convention RoomRepository already exposes.
     */
    public function findForUpdate(int $id): ?Reservation;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Reservation $reservation, array $data): Reservation;

    /**
     * Count of blocking reservations (Reservation::BLOCKING_STATUSES) for
     * the exact physical Room $roomId whose date range overlaps
     * [$checkIn, $checkOut) under the canonical, checkout-exclusive
     * overlap predicate: existing.check_in < $checkOut AND $checkIn <
     * existing.check_out. Must be called only after the caller holds the
     * appropriate lock (approved Phase 3D concurrency design) — this
     * method performs a plain, non-locking read.
     */
    public function countOverlappingForRoom(int $roomId, string $checkIn, string $checkOut): int;

    /**
     * Count of blocking reservations (Reservation::BLOCKING_STATUSES) for
     * Room Type $roomTypeId whose date range overlaps [$checkIn,
     * $checkOut), regardless of whether each reservation has a room_id
     * assigned or not (approved Option A: assigned and unassigned
     * reservations both consume the Room Type's shared physical
     * capacity). Same overlap predicate and locking precondition as
     * countOverlappingForRoom().
     */
    public function countOverlappingForRoomType(int $roomTypeId, string $checkIn, string $checkOut): int;
}
