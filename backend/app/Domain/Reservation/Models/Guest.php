<?php

namespace App\Domain\Reservation\Models;

use App\Domain\Loyalty\Models\LoyaltyAccount;
use Database\Factories\GuestFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * The person-account making bookings — distinct from staff `Users`
 * (Phase 0 §6.1). Authenticates via phone + OTP through its own Sanctum
 * guard (`auth:guest`, provider `guests`); it has no password. Not
 * hotel-scoped — a Guest may have reservations across multiple hotels.
 * A group-wide loyalty account is created on first use, not at guest creation.
 */
class Guest extends Authenticatable
{
    /** @use HasFactory<GuestFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'phone_verified_at',
        'profile_completed_at',
    ];

    protected function casts(): array
    {
        return [
            'phone_verified_at' => 'datetime',
            'profile_completed_at' => 'datetime',
        ];
    }

    /**
     * The Guest has no password — authentication is phone + OTP only. An
     * empty string ensures any accidental credential guard comparison
     * fails closed rather than throwing.
     */
    public function getAuthPassword(): string
    {
        return '';
    }

    /**
     * A guest may act (create reservations, pay, verify identity) the
     * moment their phone is proven; the name/email step can follow. This
     * flag only gates UI copy, never authorization.
     */
    public function isProfileComplete(): bool
    {
        return $this->profile_completed_at !== null
            && filled($this->name)
            && filled($this->email);
    }

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
