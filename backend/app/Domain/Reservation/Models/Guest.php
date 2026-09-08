<?php

namespace App\Domain\Reservation\Models;

use App\Domain\Loyalty\Models\LoyaltyAccount;
use Database\Factories\GuestFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

/**
 * The person-account making bookings — distinct from staff `Users`
 * (Phase 0 §6.1). Deliberately minimal: no authentication, no profile
 * fields. Not hotel-scoped — a Guest may have reservations across multiple
 * hotels. Phase 10 adds an optional group-wide loyalty account (created on
 * first use, not at guest creation).
 */
class Guest extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'email',
        'phone',
    ];

    public function reservations(): HasMany
    {
        return $this->hasMany(Reservation::class);
    }

    public function loyaltyAccount(): HasOne
    {
        return $this->hasOne(LoyaltyAccount::class);
    }

    protected static function newFactory(): GuestFactory
    {
        return GuestFactory::new();
    }
}
