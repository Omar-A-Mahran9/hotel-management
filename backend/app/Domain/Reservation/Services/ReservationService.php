<?php

namespace App\Domain\Reservation\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\Inventory\Models\Room;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Inventory\Repositories\Contracts\RoomRepositoryInterface;
use App\Domain\Inventory\Repositories\Contracts\RoomTypeRepositoryInterface;
use App\Domain\Reservation\Exceptions\ReservationNotAvailableException;
use App\Domain\Reservation\Exceptions\RoomHotelMismatchException;
use App\Domain\Reservation\Exceptions\RoomTypeMismatchException;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Reservation\Repositories\Contracts\GuestRepositoryInterface;
use App\Domain\Reservation\Repositories\Contracts\ReservationRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Facades\DB;

/**
 * Phase 3B foundation plus Phase 3D availability/concurrency protection.
 * Still deliberately does NOT implement: room allocation strategy, the
 * status-transition engine, cancellation, or payment — all explicitly
 * deferred.
 */
class ReservationService
{
    public function __construct(
        private readonly ReservationRepositoryInterface $reservations,
        private readonly RoomTypeRepositoryInterface $roomTypes,
        private readonly RoomRepositoryInterface $rooms,
        private readonly GuestRepositoryInterface $guests,
        private readonly AuditLogger $auditLogger,
    ) {}

    /**
     * Reservations resolved from $user's own hotel access — never from a
     * request parameter.
     */
    public function listAccessibleBy(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->reservations->paginateAccessibleBy($user, $perPage);
    }

    /**
     * Scoped the same way as the list above — returns null both when the
     * reservation does not exist and when the user cannot access it.
     */
    public function findAccessibleBy(User $user, int $id): ?Reservation
    {
        return $this->reservations->findAccessibleBy($user, $id);
    }

    /**
     * Creates a Reservation in PENDING with a price snapshot taken from
     * the Room Type's current base_price, protected by the approved
     * Phase 3D availability/concurrency design.
     *
     * Locking (approved order, always Room Type first): the Room Type row
     * is locked first (`findForUpdate`), and — only if room_id is
     * supplied — the specific Room row is locked second. Both locks are
     * acquired before any availability count is read, and both are held
     * until the reservation is inserted and the transaction commits. The
     * Room Type lock is acquired even for a specific-room request: a
     * named Room being physically free is not by itself sufficient to
     * guarantee the Room Type's shared capacity (Option A, aggregate
     * across assigned and unassigned reservations) isn't exceeded by a
     * concurrent unassigned request racing on the same Room Type — only a
     * shared lock closes that race.
     *
     * Availability (approved rules):
     * - If room_id is supplied: reject if any blocking reservation for
     *   that exact Room overlaps the requested range (canonical
     *   checkout-exclusive predicate).
     * - Always (Option A): reject if the Room Type's blocking-reservation
     *   count for the range (assigned + unassigned) is not strictly less
     *   than its total physical Room count.
     * Both counts are read only after the relevant lock is held, and the
     * reservation is inserted only after both checks pass — never before.
     *
     * hotel_id is never accepted from $data — it is always derived from
     * the resolved Room Type, so a caller cannot widen authorization by
     * supplying an arbitrary hotel_id. Whether the acting user is even
     * allowed to create a reservation for that hotel is a Policy/Controller
     * concern — this Service trusts its caller exactly as
     * RoomTypeService/RoomService already do.
     *
     * @param  array<string, mixed>  $data
     *
     * @throws ModelNotFoundException if room_type_id, room_id, or guest_id
     *                                does not resolve to an existing record.
     * @throws RoomHotelMismatchException if room_id is supplied and does
     *                                    not belong to the same hotel as the resolved Room Type.
     * @throws RoomTypeMismatchException if room_id is supplied and does
     *                                   not belong to the selected Room Type.
     * @throws ReservationNotAvailableException if the requested range is
     *                                          not available for the specific Room or the Room Type's capacity.
     */
    public function create(array $data, ?User $actor): Reservation
    {
        return DB::transaction(function () use ($data, $actor) {
            $roomType = $this->roomTypes->findForUpdate((int) ($data['room_type_id'] ?? 0));

            if (! $roomType) {
                throw (new ModelNotFoundException)->setModel(RoomType::class, [$data['room_type_id'] ?? null]);
            }

            $hotelId = $roomType->hotel_id;
            $requestedRoomId = $data['room_id'] ?? null;
            $room = null;

            if ($requestedRoomId !== null) {
                $room = $this->rooms->findForUpdate((int) $requestedRoomId);

                if (! $room) {
                    throw (new ModelNotFoundException)->setModel(Room::class, [$requestedRoomId]);
                }

                if ($room->hotel_id !== $hotelId) {
                    throw new RoomHotelMismatchException;
                }

                if ($room->room_type_id !== $roomType->id) {
                    throw new RoomTypeMismatchException;
                }
            }

            $guest = $this->guests->find((int) ($data['guest_id'] ?? 0));

            if (! $guest) {
                throw (new ModelNotFoundException)->setModel(Guest::class, [$data['guest_id'] ?? null]);
            }

            $checkIn = $data['check_in'];
            $checkOut = $data['check_out'];

            if ($room) {
                $overlappingForRoom = $this->reservations->countOverlappingForRoom($room->id, $checkIn, $checkOut);

                if ($overlappingForRoom > 0) {
                    throw new ReservationNotAvailableException;
                }
            }

            $blockingCount = $this->reservations->countOverlappingForRoomType($roomType->id, $checkIn, $checkOut);
            $physicalRoomCount = $this->rooms->countByRoomType($roomType->id);

            if ($blockingCount >= $physicalRoomCount) {
                throw new ReservationNotAvailableException;
            }

            $data['hotel_id'] = $hotelId;
            $data['room_type_id'] = $roomType->id;
            $data['room_id'] = $room?->id;
            $data['guest_id'] = $guest->id;
            $data['status'] = Reservation::STATUS_PENDING;
            $data['price_snapshot'] = $roomType->base_price;
            $data['created_by_staff_id'] = $actor?->id;
            $data['cancelled_at'] = null;
            $data['cancellation_reason'] = null;

            $reservation = $this->reservations->create($data);

            $this->auditLogger->record(
                $actor,
                'reservation.created',
                $reservation,
                after: $reservation->toArray(),
                hotelId: $hotelId,
            );

            return $reservation;
        });
    }
}
