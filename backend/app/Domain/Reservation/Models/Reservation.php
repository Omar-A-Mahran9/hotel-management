<?php

namespace App\Domain\Reservation\Models;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Inventory\Models\Room;
use App\Domain\Inventory\Models\RoomType;
use Database\Factories\ReservationFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * A Guest's confirmed or in-progress intent to occupy inventory for a date
 * range (Phase 0 §6.1). Schema and status set only — the state-transition
 * engine, availability/concurrency checks, and cancellation logic are later
 * phases (§6.3, §8, §12).
 */
class Reservation extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';

    public const STATUS_DEPOSIT_HELD = 'deposit_held';

    public const STATUS_VERIFIED = 'verified';

    public const STATUS_CHECKED_IN = 'checked_in';

    public const STATUS_IN_STAY = 'in_stay';

    public const STATUS_CHECKOUT_IN_PROGRESS = 'checkout_in_progress';

    public const STATUS_CHECKOUT_BLOCKED = 'checkout_blocked';

    public const STATUS_CHECKED_OUT = 'checked_out';

    public const STATUS_INVOICED = 'invoiced';

    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'hotel_id',
        'room_type_id',
        'room_id',
        'guest_id',
        'check_in',
        'check_out',
        'status',
        'price_snapshot',
        'created_by_staff_id',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected function casts(): array
    {
        return [
            'check_in' => 'date',
            'check_out' => 'date',
            'price_snapshot' => 'decimal:2',
            'cancelled_at' => 'datetime',
        ];
    }

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }

    public function roomType(): BelongsTo
    {
        return $this->belongsTo(RoomType::class);
    }

    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class);
    }

    public function guest(): BelongsTo
    {
        return $this->belongsTo(Guest::class);
    }

    public function reservationGuests(): HasMany
    {
        return $this->hasMany(ReservationGuest::class);
    }

    protected static function newFactory(): ReservationFactory
    {
        return ReservationFactory::new();
    }
}
