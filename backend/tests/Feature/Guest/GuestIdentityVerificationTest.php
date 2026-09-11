<?php

namespace Tests\Feature\Guest;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\IdentityVerification\Models\IdentityVerificationSession;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Models\Reservation;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class GuestIdentityVerificationTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('local');
    }

    private function actingGuest(): Guest
    {
        $guest = Guest::factory()->create();
        $this->withToken($guest->createToken('guest-api')->plainTextToken);

        return $guest;
    }

    private function reservationFor(Guest $guest, string $status = Reservation::STATUS_DEPOSIT_HELD): Reservation
    {
        $hotel = Hotel::factory()->create();
        $roomType = RoomType::factory()->create(['hotel_id' => $hotel->id]);

        return Reservation::factory()->create([
            'guest_id' => $guest->id, 'hotel_id' => $hotel->id, 'room_type_id' => $roomType->id, 'status' => $status,
        ]);
    }

    private function image(string $name = 'x.jpg'): UploadedFile
    {
        return UploadedFile::fake()->image($name, 15, 15);
    }

    public function test_unauthenticated_is_401(): void
    {
        $reservation = Reservation::factory()->create();

        $this->getJson("/api/v1/guest/reservations/{$reservation->id}/identity")->assertStatus(401);
    }

    public function test_guest_submits_a_document_for_their_own_reservation(): void
    {
        $guest = $this->actingGuest();
        $reservation = $this->reservationFor($guest);

        $this->post("/api/v1/guest/reservations/{$reservation->id}/identity/documents", [
            'document' => $this->image('doc.jpg'),
        ])->assertStatus(201)
            ->assertJsonPath('data.status', IdentityVerificationSession::STATUS_DOCUMENT_UPLOADED);
    }

    public function test_status_reflects_the_reservations_session(): void
    {
        $guest = $this->actingGuest();
        $reservation = $this->reservationFor($guest);
        IdentityVerificationSession::factory()->autoApproved()->create(['reservation_id' => $reservation->id]);

        $this->getJson("/api/v1/guest/reservations/{$reservation->id}/identity")
            ->assertOk()
            ->assertJsonPath('data.status', IdentityVerificationSession::STATUS_AUTO_APPROVED);
    }

    public function test_guest_cannot_reach_another_guests_reservation_identity(): void
    {
        $this->actingGuest();
        $other = Reservation::factory()->create();

        $this->getJson("/api/v1/guest/reservations/{$other->id}/identity")->assertStatus(404);
        $this->post("/api/v1/guest/reservations/{$other->id}/identity/documents", [
            'document' => $this->image(),
        ])->assertStatus(404);
    }

    public function test_guest_cannot_reach_the_staff_review_action(): void
    {
        $guest = $this->actingGuest();
        $reservation = $this->reservationFor($guest);

        // There is no guest route for review — only the staff surface exists.
        $this->postJson("/api/v1/identity-verification/{$reservation->id}/review", ['decision' => 'approved'])
            ->assertStatus(401);
    }
}
