<?php

namespace App\Http\Resources\V1;

use App\Domain\Discovery\Services\RoomAvailability;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin RoomAvailability
 */
class RoomAvailabilityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'room_type_id' => $this->roomType->id,
            'name' => $this->roomType->name,
            'base_price' => $this->roomType->base_price,
            'capacity' => $this->roomType->capacity,
            'amenities' => $this->roomType->amenities ?? [],
            'description' => $this->roomType->description,
            'rooms_total' => $this->roomsTotal,
            'rooms_available' => $this->roomsAvailable,
            'is_available' => $this->isAvailable(),
            'nights' => $this->nights,
            'estimated_total' => $this->estimatedTotal,
        ];
    }
}
