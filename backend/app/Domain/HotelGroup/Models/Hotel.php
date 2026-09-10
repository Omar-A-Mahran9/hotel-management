<?php

namespace App\Domain\HotelGroup\Models;

use App\Domain\IdentityAccess\Models\User;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Location\Models\City;
use App\Domain\Location\Models\Country;
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
        'country_id',
        'city_id',
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

    /**
     * Normalized location references onto the global Country/City master
     * data. Nullable for legacy rows created before normalization; new and
     * updated hotels are validated so the City belongs to the Country.
     *
     * Named `*Ref` because `country` / `city` are still real string columns
     * on this table (the legacy free-text values, kept in sync) — so the
     * bare `$hotel->country` accessor must keep returning that string.
     */
    public function countryRef(): BelongsTo
    {
        return $this->belongsTo(Country::class, 'country_id');
    }

    public function cityRef(): BelongsTo
    {
        return $this->belongsTo(City::class, 'city_id');
    }

    public function staff(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_hotel_access')->withTimestamps();
    }

    public function reservations(): HasMany
    {
        return $this->hasMany(Reservation::class);
    }

    public function roomTypes(): HasMany
    {
        return $this->hasMany(RoomType::class);
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
