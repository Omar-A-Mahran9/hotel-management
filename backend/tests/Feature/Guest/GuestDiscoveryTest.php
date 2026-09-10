<?php

namespace Tests\Feature\Guest;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Inventory\Models\Room;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Reservation\Models\Reservation;
use Tests\TestCase;

class GuestDiscoveryTest extends TestCase
{
    public function test_hotel_list_is_public_and_active_only(): void
    {
        $active = Hotel::factory()->create(['name' => 'Oasis', 'city' => 'Riyadh']);
        Hotel::factory()->create(['is_active' => false, 'name' => 'Closed Inn']);

        $res = $this->getJson('/api/v1/guest/hotels');

        $res->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $active->id)
            ->assertJsonPath('data.0.name', 'Oasis')
            ->assertJsonMissingPath('data.0.is_active');
    }

    public function test_hotel_list_filters_by_city_and_query(): void
    {
        Hotel::factory()->create(['name' => 'Red Sea Resort', 'city' => 'Jeddah']);
        Hotel::factory()->create(['name' => 'Mountain Lodge', 'city' => 'Abha']);

        $this->getJson('/api/v1/guest/hotels?city=Jeddah')
            ->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.name', 'Red Sea Resort');

        $this->getJson('/api/v1/guest/hotels?q=Mountain')
            ->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.name', 'Mountain Lodge');
    }

    public function test_cities_endpoint_counts_active_hotels(): void
    {
        Hotel::factory()->count(2)->create(['city' => 'Riyadh']);
        Hotel::factory()->create(['city' => 'Dammam']);
        Hotel::factory()->create(['city' => 'Riyadh', 'is_active' => false]);

        $this->getJson('/api/v1/guest/hotels/cities')
            ->assertOk()
            ->assertJsonFragment(['city' => 'Riyadh', 'hotel_count' => 2])
            ->assertJsonFragment(['city' => 'Dammam', 'hotel_count' => 1]);
    }

    public function test_hotel_detail_returns_active_room_types_only(): void
    {
        $hotel = Hotel::factory()->create();
        $rt = RoomType::factory()->create(['hotel_id' => $hotel->id, 'name' => 'Deluxe', 'base_price' => 400]);
        RoomType::factory()->inactive()->create(['hotel_id' => $hotel->id, 'name' => 'Old Wing']);

        $this->getJson("/api/v1/guest/hotels/{$hotel->id}")
            ->assertOk()
            ->assertJsonCount(1, 'data.room_types')
            ->assertJsonPath('data.room_types.0.id', $rt->id)
            ->assertJsonPath('data.room_types.0.name', 'Deluxe');
    }

    public function test_inactive_or_missing_hotel_is_404(): void
    {
        $inactive = Hotel::factory()->create(['is_active' => false]);

        $this->getJson("/api/v1/guest/hotels/{$inactive->id}")->assertStatus(404);
        $this->getJson('/api/v1/guest/hotels/999999')->assertStatus(404);
        $this->getJson("/api/v1/guest/hotels/{$inactive->id}/availability?check_in=".now()->addDay()->toDateString().'&check_out='.now()->addDays(3)->toDateString())
            ->assertStatus(404);
    }

    public function test_availability_reflects_overlapping_reservations(): void
    {
        $hotel = Hotel::factory()->create();
        $rt = RoomType::factory()->create(['hotel_id' => $hotel->id, 'base_price' => 200, 'capacity' => 2]);
        Room::factory()->count(2)->create(['hotel_id' => $hotel->id, 'room_type_id' => $rt->id]);

        $checkIn = now()->addDays(5)->toDateString();
        $checkOut = now()->addDays(8)->toDateString();

        // One overlapping blocking reservation -> 1 of 2 rooms left.
        Reservation::factory()->create([
            'hotel_id' => $hotel->id,
            'room_type_id' => $rt->id,
            'check_in' => now()->addDays(6)->toDateString(),
            'check_out' => now()->addDays(7)->toDateString(),
            'status' => Reservation::STATUS_DEPOSIT_HELD,
        ]);

        $res = $this->getJson("/api/v1/guest/hotels/{$hotel->id}/availability?check_in={$checkIn}&check_out={$checkOut}&adults=2");

        $res->assertOk()
            ->assertJsonPath('data.nights', 3)
            ->assertJsonPath('data.rooms.0.rooms_total', 2)
            ->assertJsonPath('data.rooms.0.rooms_available', 1)
            ->assertJsonPath('data.rooms.0.is_available', true)
            ->assertJsonPath('data.rooms.0.estimated_total', '600.00');
    }

    public function test_availability_greys_out_a_room_type_that_cannot_seat_the_party(): void
    {
        $hotel = Hotel::factory()->create();
        $rt = RoomType::factory()->create(['hotel_id' => $hotel->id, 'capacity' => 2]);
        Room::factory()->create(['hotel_id' => $hotel->id, 'room_type_id' => $rt->id]);

        $res = $this->getJson("/api/v1/guest/hotels/{$hotel->id}/availability?check_in=".now()->addDay()->toDateString().'&check_out='.now()->addDays(2)->toDateString().'&adults=4');

        $res->assertOk()
            ->assertJsonPath('data.rooms.0.rooms_available', 0)
            ->assertJsonPath('data.rooms.0.is_available', false);
    }

    public function test_availability_validates_the_date_range(): void
    {
        $hotel = Hotel::factory()->create();

        $this->getJson("/api/v1/guest/hotels/{$hotel->id}/availability?check_in=2000-01-01&check_out=2000-01-05")
            ->assertStatus(422)->assertJsonValidationErrors('check_in');

        $this->getJson("/api/v1/guest/hotels/{$hotel->id}/availability?check_in=".now()->addDays(3)->toDateString().'&check_out='.now()->addDay()->toDateString())
            ->assertStatus(422)->assertJsonValidationErrors('check_out');
    }

    public function test_discovery_needs_no_authentication(): void
    {
        Hotel::factory()->create();

        $this->getJson('/api/v1/guest/hotels')->assertOk();
    }
}
