<?php

namespace App\Http\Resources\V1;

use App\Domain\HotelGroup\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Hotel
 */
class HotelResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'hotel_group_id' => $this->hotel_group_id,
            'name' => $this->name,
            'slug' => $this->slug,
            'country' => $this->country,
            'city' => $this->city,
            'timezone' => $this->timezone,
            'is_active' => $this->is_active,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
