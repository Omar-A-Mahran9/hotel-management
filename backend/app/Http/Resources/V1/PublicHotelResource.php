<?php

namespace App\Http\Resources\V1;

use App\Domain\HotelGroup\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Hotel
 *
 * Anonymous guest view of a hotel (Slice 1). Deliberately narrower than the
 * staff HotelResource: no `hotel_group_id`, no `is_active` (always true here).
 * `room_types` is present only when the relation is loaded (detail endpoint).
 *
 * `city` / `country` remain plain strings for backward compatibility;
 * `country_id` / `city_id` expose the normalized reference.
 */
class PublicHotelResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'city' => $this->city,
            'country' => $this->country,
            'country_id' => $this->country_id,
            'city_id' => $this->city_id,
            'timezone' => $this->timezone,
            'room_types' => PublicRoomTypeResource::collection($this->whenLoaded('roomTypes')),
        ];
    }
}
