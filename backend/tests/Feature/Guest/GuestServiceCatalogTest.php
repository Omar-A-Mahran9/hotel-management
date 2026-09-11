<?php

namespace Tests\Feature\Guest;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\StayServices\Models\HotelService;
use App\Domain\StayServices\Models\ServiceCategory;
use Tests\TestCase;

class GuestServiceCatalogTest extends TestCase
{
    public function test_anonymous_read_lists_only_active_categories_and_services(): void
    {
        $hotel = Hotel::factory()->create();
        ServiceCategory::factory()->create(['hotel_id' => $hotel->id, 'is_active' => true]);
        ServiceCategory::factory()->create(['hotel_id' => $hotel->id, 'is_active' => false]);
        HotelService::factory()->create(['hotel_id' => $hotel->id, 'is_active' => true]);
        HotelService::factory()->create(['hotel_id' => $hotel->id, 'is_active' => false]);

        $this->getJson("/api/v1/guest/hotels/{$hotel->id}/service-categories")
            ->assertOk()->assertJsonCount(1, 'data');

        $this->getJson("/api/v1/guest/hotels/{$hotel->id}/services")
            ->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_an_inactive_hotel_is_a_plain_404(): void
    {
        $hotel = Hotel::factory()->create(['is_active' => false]);

        $this->getJson("/api/v1/guest/hotels/{$hotel->id}/services")->assertStatus(404);
        $this->getJson("/api/v1/guest/hotels/{$hotel->id}/service-categories")->assertStatus(404);
    }

    public function test_a_missing_hotel_is_a_plain_404(): void
    {
        $this->getJson('/api/v1/guest/hotels/999999/services')->assertStatus(404);
    }
}
