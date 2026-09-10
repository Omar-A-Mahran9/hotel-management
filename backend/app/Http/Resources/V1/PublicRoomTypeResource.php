<?php

namespace App\Http\Resources\V1;

use App\Domain\Inventory\Models\RoomType;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin RoomType
 *
 * Anonymous guest view of a room type (Slice 1). No `is_active` (always true
 * here) and no raw inventory counts — availability for a stay comes from the
 * availability endpoint.
 */
class PublicRoomTypeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'hotel_id' => $this->hotel_id,
            'name' => $this->name,
            'base_price' => $this->base_price,
            'capacity' => $this->capacity,
            'amenities' => $this->amenities ?? [],
            'description' => $this->description,
        ];
    }
}
