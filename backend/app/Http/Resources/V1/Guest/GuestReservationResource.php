<?php

namespace App\Http\Resources\V1\Guest;

use App\Domain\Reservation\Models\Reservation;
use App\Support\LocalizedContent;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Reservation
 *
 * The guest's own view of a reservation. Narrower than the staff
 * ReservationResource: no `created_by_staff_id`, no `room_id` (internal
 * allocation), no `guest_id` (it is always the caller). `status` is the raw
 * state-machine value — the client mirrors the enum and must render every
 * state.
 *
 * `hotel` / `room_type` light summaries appear only when eager-loaded.
 * `currency` is the configured booking currency (same source the
 * availability endpoint uses) — not a stored column.
 */
class GuestReservationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $nights = CarbonImmutable::parse($this->check_in)
            ->diffInDays(CarbonImmutable::parse($this->check_out));

        return [
            'id' => $this->id,
            'hotel_id' => $this->hotel_id,
            'room_type_id' => $this->room_type_id,
            'status' => $this->status,
            'check_in' => optional($this->check_in)->toDateString(),
            'check_out' => optional($this->check_out)->toDateString(),
            'nights' => $nights,
            'adults' => $this->adults,
            'children' => $this->children,
            'price_snapshot' => $this->price_snapshot,
            'currency' => config('payment.currency') ?: 'SAR',
            'cancelled_at' => $this->cancelled_at,
            'cancellation_reason' => $this->cancellation_reason,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'hotel' => $this->whenLoaded('hotel', fn () => [
                'id' => $this->hotel->id,
                'name' => LocalizedContent::resolve($this->hotel->name_i18n, $this->hotel->name),
                'city' => $this->hotel->city,
            ]),
            'room_type' => $this->whenLoaded('roomType', fn () => [
                'id' => $this->roomType->id,
                'name' => $this->roomType->name,
                'capacity' => $this->roomType->capacity,
            ]),
            'payment' => $this->whenLoaded('payment', fn () => $this->payment
                ? new GuestPaymentResource($this->payment)
                : null),
        ];
    }
}
