<?php

namespace Tests\Unit\Models;

use App\Domain\Reservation\Models\Guest;
use Illuminate\Database\QueryException;
use Tests\TestCase;

class GuestTest extends TestCase
{
    public function test_guest_can_be_created(): void
    {
        $guest = Guest::create([
            'name' => 'Jane Doe',
            'email' => 'jane.doe@example.com',
            'phone' => '+1-555-0100',
        ]);

        $this->assertDatabaseHas('guests', [
            'id' => $guest->id,
            'name' => 'Jane Doe',
            'email' => 'jane.doe@example.com',
            'phone' => '+1-555-0100',
        ]);
    }

    public function test_name_is_required(): void
    {
        $this->expectException(QueryException::class);

        Guest::factory()->create(['name' => null]);
    }

    public function test_email_is_required(): void
    {
        $this->expectException(QueryException::class);

        Guest::factory()->create(['email' => null]);
    }

    public function test_phone_is_nullable(): void
    {
        $guest = Guest::factory()->create(['phone' => null]);

        $this->assertNull($guest->fresh()->phone);
    }

    public function test_phone_can_also_be_provided(): void
    {
        $guest = Guest::factory()->create(['phone' => '+20-100-000-0000']);

        $this->assertSame('+20-100-000-0000', $guest->fresh()->phone);
    }

    /**
     * Deliberate: Phase 0 does not require Guest email to be unique
     * (unlike staff `users.email`, whose uniqueness is tied to
     * authentication — Guest has none in this phase). This test proves
     * the schema does not silently enforce a uniqueness rule that was
     * never approved.
     */
    public function test_email_is_not_required_to_be_unique(): void
    {
        Guest::factory()->create(['email' => 'shared@example.com']);
        $second = Guest::factory()->create(['email' => 'shared@example.com']);

        $this->assertDatabaseHas('guests', ['id' => $second->id, 'email' => 'shared@example.com']);
        $this->assertSame(2, Guest::where('email', 'shared@example.com')->count());
    }

    public function test_factory_creates_a_valid_guest(): void
    {
        $guest = Guest::factory()->create();

        $this->assertDatabaseHas('guests', ['id' => $guest->id]);
        $this->assertNotEmpty($guest->name);
        $this->assertNotEmpty($guest->email);
    }

    public function test_factory_without_phone_state_produces_a_null_phone(): void
    {
        $guest = Guest::factory()->withoutPhone()->create();

        $this->assertNull($guest->fresh()->phone);
    }

    public function test_multiple_factory_created_guests_are_all_persisted_and_distinct(): void
    {
        $guests = Guest::factory()->count(5)->create();

        $this->assertCount(5, $guests);
        $this->assertSame(5, Guest::count());
        $this->assertSame(5, $guests->pluck('id')->unique()->count());
    }
}
