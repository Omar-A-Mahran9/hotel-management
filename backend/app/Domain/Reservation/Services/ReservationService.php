<?php

namespace App\Domain\Reservation\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\Inventory\Models\Room;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Inventory\Repositories\Contracts\RoomRepositoryInterface;
use App\Domain\Inventory\Repositories\Contracts\RoomTypeRepositoryInterface;
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
 * Phase 3B business foundation only. Deliberately does NOT implement:
 * date-range availability, overlap/capacity checks, concurrency locking,
 * room allocation, the status-transition engine, cancellation, or payment
 * — all explicitly deferred (see create()).
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
     * the Room Type's current base_price.
     *
     * IMPORTANT — explicitly deferred to a later phase (§6.3's dedicated
     * concurrency/date-range work): no overlap/capacity check is
     * performed, no row is locked, and availability is not revalidated. A
     * Reservation may therefore be persisted here with no guarantee the
     * requested dates are actually free.
     *
     * hotel_id is never accepted from $data — it is always derived from
     * the resolved Room Type, so a caller cannot widen authorization by
     * supplying an arbitrary hotel_id. Whether the acting user is even
     * allowed to create a reservation for that hotel is a Policy/Controller
     * concern for a later phase — this Service trusts its caller exactly as
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
     */
    public function create(array $data, ?User $actor): Reservation
    {
        return DB::transaction(function () use ($data, $actor) {
            $roomType = $this->roomTypes->find((int) ($data['room_type_id'] ?? 0));

            if (! $roomType) {
                throw (new ModelNotFoundException)->setModel(RoomType::class, [$data['room_type_id'] ?? null]);
            }

            $hotelId = $roomType->hotel_id;
            $requestedRoomId = $data['room_id'] ?? null;
            $room = null;

            if ($requestedRoomId !== null) {
                $room = $this->rooms->find((int) $requestedRoomId);

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
