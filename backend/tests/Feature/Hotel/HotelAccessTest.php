<?php

namespace Tests\Feature\Hotel;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\HotelGroup\Models\HotelGroup;
use App\Domain\IdentityAccess\Models\User;
use Tests\TestCase;

class HotelAccessTest extends TestCase
{
    public function test_group_owner_sees_every_hotel_without_explicit_assignment(): void
    {
        $owner = User::factory()->groupOwner()->create();
        $group = HotelGroup::factory()->create();
        Hotel::factory()->count(3)->create(['hotel_group_id' => $group->id]);

        $response = $this->actingAs($owner, 'sanctum')->getJson('/api/v1/hotels');

        $response->assertOk();
        $this->assertCount(3, $response->json('data'));
    }

    public function test_hotel_manager_only_sees_assigned_hotels(): void
    {
        $group = HotelGroup::factory()->create();
        $hotelA = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $hotelB = Hotel::factory()->create(['hotel_group_id' => $group->id]);

        $manager = User::factory()->hotelManager()->create();
        $manager->hotels()->attach($hotelA);

        $response = $this->actingAs($manager, 'sanctum')->getJson('/api/v1/hotels');

        $response->assertOk();
        $ids = array_column($response->json('data'), 'id');
        $this->assertSame([$hotelA->id], $ids);
        $this->assertNotContains($hotelB->id, $ids);
    }

    public function test_hotel_manager_can_view_an_assigned_hotel(): void
    {
        $group = HotelGroup::factory()->create();
        $hotel = Hotel::factory()->create(['hotel_group_id' => $group->id]);

        $manager = User::factory()->hotelManager()->create();
        $manager->hotels()->attach($hotel);

        $this->actingAs($manager, 'sanctum')
            ->getJson("/api/v1/hotels/{$hotel->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $hotel->id);
    }

    public function test_hotel_manager_is_denied_access_to_an_unassigned_hotel(): void
    {
        $group = HotelGroup::factory()->create();
        $hotelA = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $hotelB = Hotel::factory()->create(['hotel_group_id' => $group->id]);

        $manager = User::factory()->hotelManager()->create();
        $manager->hotels()->attach($hotelA);

        // Cross-hotel access denial: a manager's token must never read
        // another hotel's data, even one owned by the same group.
        $this->actingAs($manager, 'sanctum')
            ->getJson("/api/v1/hotels/{$hotelB->id}")
            ->assertStatus(403);
    }

    public function test_hotel_manager_may_be_assigned_to_multiple_hotels(): void
    {
        $group = HotelGroup::factory()->create();
        $hotelA = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $hotelB = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $hotelC = Hotel::factory()->create(['hotel_group_id' => $group->id]);

        $manager = User::factory()->hotelManager()->create();
        $manager->hotels()->attach([$hotelA->id, $hotelB->id]);

        $response = $this->actingAs($manager, 'sanctum')->getJson('/api/v1/hotels');

        $ids = array_column($response->json('data'), 'id');
        sort($ids);
        $this->assertSame([$hotelA->id, $hotelB->id], $ids);

        $this->actingAs($manager, 'sanctum')->getJson("/api/v1/hotels/{$hotelC->id}")->assertStatus(403);
    }

    public function test_hotel_manager_cannot_create_or_update_hotels(): void
    {
        $group = HotelGroup::factory()->create();
        $hotel = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $manager = User::factory()->hotelManager()->create();
        $manager->hotels()->attach($hotel);

        $this->actingAs($manager, 'sanctum')
            ->postJson('/api/v1/hotels', [
                'hotel_group_id' => $group->id,
                'name' => 'New Hotel',
                'slug' => 'new-hotel',
            ])
            ->assertStatus(403);

        $this->actingAs($manager, 'sanctum')
            ->putJson("/api/v1/hotels/{$hotel->id}", ['name' => 'Renamed'])
            ->assertStatus(403);
    }

    public function test_reception_can_view_only_their_assigned_hotel(): void
    {
        $group = HotelGroup::factory()->create();
        $hotelA = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $hotelB = Hotel::factory()->create(['hotel_group_id' => $group->id]);

        $reception = User::factory()->reception()->create();
        $reception->hotels()->attach($hotelA);

        $this->actingAs($reception, 'sanctum')
            ->getJson("/api/v1/hotels/{$hotelA->id}")
            ->assertOk();

        $this->actingAs($reception, 'sanctum')
            ->getJson("/api/v1/hotels/{$hotelB->id}")
            ->assertStatus(403);
    }

    public function test_reception_cannot_create_or_update_hotels(): void
    {
        $group = HotelGroup::factory()->create();
        $hotel = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $reception = User::factory()->reception()->create();
        $reception->hotels()->attach($hotel);

        $this->actingAs($reception, 'sanctum')
            ->postJson('/api/v1/hotels', [
                'hotel_group_id' => $group->id,
                'name' => 'New Hotel',
                'slug' => 'new-hotel-2',
            ])
            ->assertStatus(403);

        $this->actingAs($reception, 'sanctum')
            ->putJson("/api/v1/hotels/{$hotel->id}", ['name' => 'Renamed'])
            ->assertStatus(403);
    }

    public function test_guest_role_has_no_hotel_access(): void
    {
        $group = HotelGroup::factory()->create();
        $hotel = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $guest = User::factory()->guest()->create();

        $this->actingAs($guest, 'sanctum')->getJson('/api/v1/hotels')->assertStatus(403);
        $this->actingAs($guest, 'sanctum')->getJson("/api/v1/hotels/{$hotel->id}")->assertStatus(403);
    }

    public function test_hotel_id_supplied_in_the_request_body_cannot_widen_access(): void
    {
        $group = HotelGroup::factory()->create();
        $hotelA = Hotel::factory()->create(['hotel_group_id' => $group->id]);
        $hotelB = Hotel::factory()->create(['hotel_group_id' => $group->id]);

        $manager = User::factory()->hotelManager()->create();
        $manager->hotels()->attach($hotelA);

        // Attempting to view Hotel B directly by id is denied regardless
        // of any hotel_id the client might otherwise try to smuggle in —
        // scope is resolved only from the manager's own stored access.
        $this->actingAs($manager, 'sanctum')
            ->getJson("/api/v1/hotels/{$hotelB->id}?hotel_id={$hotelA->id}")
            ->assertStatus(403);
    }

    public function test_viewing_a_nonexistent_hotel_returns_not_found(): void
    {
        $owner = User::factory()->groupOwner()->create();

        $this->actingAs($owner, 'sanctum')
            ->getJson('/api/v1/hotels/999999')
            ->assertStatus(404)
            ->assertJson(['success' => false]);
    }
}
