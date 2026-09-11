<?php

namespace App\Domain\HotelGroup\Policies;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\IdentityAccess\Services\HotelAccessService;

class HotelPolicy
{
    public function __construct(private readonly HotelAccessService $hotelAccess) {}

    public function viewAny(User $user): bool
    {
        return $user->hasPermission('hotels.view');
    }

    /**
     * The hotel scope check here is resolved from the authenticated
     * user's own stored access records via HotelAccessService — the
     * route-bound $hotel only selects *which* hotel is being viewed,
     * it is never itself treated as proof of authorization.
     */
    public function view(User $user, Hotel $hotel): bool
    {
        return $user->hasPermission('hotels.view')
            && $this->hotelAccess->canAccessHotel($user, $hotel->id);
    }

    public function create(User $user): bool
    {
        return $user->hasPermission('hotels.manage');
    }

    public function update(User $user, Hotel $hotel): bool
    {
        return $user->hasPermission('hotels.manage');
    }

    /**
     * Managing a hotel's images is a hotel-edit action: the same
     * `hotels.manage` permission as update, plus the hotel-scope check
     * resolved from the user's own stored access records (a Group Owner
     * passes it by bypass) — never a client-supplied hotel_id.
     */
    public function manageMedia(User $user, Hotel $hotel): bool
    {
        return $user->hasPermission('hotels.manage')
            && $this->hotelAccess->canAccessHotel($user, $hotel->id);
    }
}
