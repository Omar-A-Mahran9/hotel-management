<?php

namespace App\Domain\Reservation\Models;

use Database\Factories\GuestFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * The person-account making bookings — distinct from staff `Users`
 * (Phase 0 §6.1). Deliberately minimal for Phase 3-Pre: no
 * authentication, no loyalty, no profile fields. Not hotel-scoped — a
 * Guest may have reservations across multiple hotels.
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

    protected static function newFactory(): GuestFactory
    {
        return GuestFactory::new();
    }
}
