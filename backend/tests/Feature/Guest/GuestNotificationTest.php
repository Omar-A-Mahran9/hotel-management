<?php

namespace Tests\Feature\Guest;

use App\Domain\Notification\Enums\NotificationChannel;
use App\Domain\Notification\Models\Notification;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Models\Reservation;
use Tests\TestCase;

class GuestNotificationTest extends TestCase
{
    private function actingGuest(): Guest
    {
        $guest = Guest::factory()->create();
        $this->withToken($guest->createToken('guest-api')->plainTextToken);

        return $guest;
    }

    public function test_unauthenticated_is_401(): void
    {
        $reservation = Reservation::factory()->create();

        $this->getJson("/api/v1/guest/reservations/{$reservation->id}/notifications")->assertStatus(401);
    }

    public function test_guest_reads_only_the_in_app_feed_for_their_own_reservation(): void
    {
        $guest = $this->actingGuest();
        $reservation = Reservation::factory()->create(['guest_id' => $guest->id]);
        Notification::factory()->count(2)->forReservation($reservation)
            ->channel(NotificationChannel::InApp)->create();
        Notification::factory()->count(1)->forReservation($reservation)
            ->channel(NotificationChannel::Email)->create();

        $this->getJson("/api/v1/guest/reservations/{$reservation->id}/notifications")
            ->assertOk()
            ->assertJsonCount(2, 'data');
    }

    public function test_guest_marks_one_and_all_read(): void
    {
        $guest = $this->actingGuest();
        $reservation = Reservation::factory()->create(['guest_id' => $guest->id]);
        $notification = Notification::factory()->forReservation($reservation)
            ->channel(NotificationChannel::InApp)->create();

        $this->patchJson("/api/v1/guest/reservations/{$reservation->id}/notifications/{$notification->id}/read")
            ->assertOk()
            ->assertJsonPath('data.is_read', true);

        $this->postJson("/api/v1/guest/reservations/{$reservation->id}/notifications/read-all")
            ->assertOk();
    }

    public function test_guest_cannot_reach_another_guests_or_staff_wide_notifications(): void
    {
        $this->actingGuest();
        $other = Reservation::factory()->create();
        Notification::factory()->forReservation($other)->channel(NotificationChannel::InApp)->create();

        $this->getJson("/api/v1/guest/reservations/{$other->id}/notifications")->assertStatus(404);
    }
}
