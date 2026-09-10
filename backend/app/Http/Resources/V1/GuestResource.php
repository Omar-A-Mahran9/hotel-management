<?php

namespace App\Http\Resources\V1;

use App\Domain\Reservation\Models\Guest;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Guest
 *
 * The authoritative guest shape for the mobile app. Field name is `name`
 * (not `full_name`) — consistent with UserResource / ReservationResource.
 */
class GuestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'phone_verified_at' => $this->phone_verified_at,
            'profile_completed_at' => $this->profile_completed_at,
            'profile_complete' => $this->isProfileComplete(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
