<?php

namespace App\Domain\HotelGroup\Models;

use App\Domain\IdentityAccess\Models\User;
use App\Domain\Reservation\Models\HotelCancellationPolicy;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Shared\Concerns\HotelScoped;
use Database\Factories\HotelFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Hotel extends Model
{
    use HasFactory, HotelScoped;

    protected $fillable = [
        'hotel_group_id',
        'name',
        'slug',
        'country',
        'city',
        'timezone',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function hotelGroup(): BelongsTo
    {
        return $this->belongsTo(HotelGroup::class);
    }

    public function staff(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_hotel_access')->withTimestamps();
    }

    public function reservations(): HasMany
    {
        return $this->hasMany(Reservation::class);
    }

    /**
     * Cancellation policy cardinality is intentionally left open pending
     * an explicit business decision.
     */
    public function cancellationPolicies(): HasMany
    {
        return $this->hasMany(HotelCancellationPolicy::class);
    }

    /**
     * A Hotel row *is* the hotel-scope boundary, so it is scoped by its
     * own primary key rather than a `hotel_id` foreign key.
     */
    public function hotelScopeColumn(): string
    {
        return 'id';
    }

    protected static function newFactory(): HotelFactory
    {
        return HotelFactory::new();
    }
}
