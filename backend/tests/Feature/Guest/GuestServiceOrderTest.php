<?php

namespace Tests\Feature\Guest;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\StayServices\Models\HotelService;
use App\Domain\StayServices\Models\ServiceOrder;
use Tests\TestCase;

class GuestServiceOrderTest extends TestCase
{
    private function actingGuest(): Guest
    {
        $guest = Guest::factory()->create();
        $this->withToken($guest->createToken('guest-api')->plainTextToken);

        return $guest;
    }

    private function reservationFor(Guest $guest, string $status = Reservation::STATUS_CHECKED_IN): array
    {
        $hotel = Hotel::factory()->create();
        $roomType = RoomType::factory()->create(['hotel_id' => $hotel->id]);
        $reservation = Reservation::factory()->create([
            'guest_id' => $guest->id, 'hotel_id' => $hotel->id, 'room_type_id' => $roomType->id, 'status' => $status,
        ]);

        return [$hotel, $reservation];
    }

    public function test_unauthenticated_is_401(): void
    {
        $reservation = Reservation::factory()->create();

        $this->getJson("/api/v1/guest/reservations/{$reservation->id}/service-orders")->assertStatus(401);
    }

    public function test_guest_creates_an_order_with_server_derived_price(): void
    {
        $guest = $this->actingGuest();
        [$hotel, $reservation] = $this->reservationFor($guest);
        $service = HotelService::factory()->create(['hotel_id' => $hotel->id, 'price' => '12.50', 'currency' => 'USD']);

        $this->postJson("/api/v1/guest/reservations/{$reservation->id}/service-orders", [
            'service_id' => $service->id,
            'quantity' => 3,
            'unit_price_snapshot' => '0.01',
            'total_amount' => '0.03',
            'hotel_id' => Hotel::factory()->create()->id,
            'status' => ServiceOrder::STATUS_FULFILLED,
        ])->assertStatus(201)
            ->assertJsonPath('data.unit_price_snapshot', '12.50')
            ->assertJsonPath('data.total_amount', '37.50')
            ->assertJsonPath('data.hotel_id', $hotel->id)
            ->assertJsonPath('data.status', ServiceOrder::STATUS_REQUESTED);
    }

    public function test_guest_lists_and_reads_only_their_own_orders(): void
    {
        $guest = $this->actingGuest();
        [$hotel, $reservation] = $this->reservationFor($guest);
        $service = HotelService::factory()->create(['hotel_id' => $hotel->id]);
        $order = ServiceOrder::factory()->create([
            'reservation_id' => $reservation->id, 'hotel_id' => $hotel->id, 'service_id' => $service->id,
        ]);

        $this->getJson("/api/v1/guest/reservations/{$reservation->id}/service-orders")
            ->assertOk()->assertJsonCount(1, 'data');

        $this->getJson("/api/v1/guest/reservations/{$reservation->id}/service-orders/{$order->id}")
            ->assertOk()->assertJsonPath('data.id', $order->id);
    }

    public function test_guest_cannot_reach_another_guests_service_orders(): void
    {
        $this->actingGuest();
        $other = Reservation::factory()->create();

        $this->getJson("/api/v1/guest/reservations/{$other->id}/service-orders")->assertStatus(404);
        $this->postJson("/api/v1/guest/reservations/{$other->id}/service-orders", ['service_id' => 1, 'quantity' => 1])
            ->assertStatus(404);
    }
}
