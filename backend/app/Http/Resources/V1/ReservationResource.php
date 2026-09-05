<?php

namespace App\Http\Resources\V1;

use App\Domain\Reservation\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Reservation
 */
class ReservationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'hotel_id' => $this->hotel_id,
            'room_type_id' => $this->room_type_id,
            'room_id' => $this->room_id,
            'guest_id' => $this->guest_id,
            'check_in' => $this->check_in,
            'check_out' => $this->check_out,
            'status' => $this->status,
            'price_snapshot' => $this->price_snapshot,
            'created_by_staff_id' => $this->created_by_staff_id,
            'cancelled_at' => $this->cancelled_at,
            'cancellation_reason' => $this->cancellation_reason,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
