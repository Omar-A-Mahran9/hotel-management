<?php

namespace App\Domain\Review\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\Loyalty\Services\LoyaltyService;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Review\Exceptions\ReviewNotAllowedException;
use App\Domain\Review\Models\Review;
use App\Domain\Review\Repositories\Contracts\ReviewRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\UniqueConstraintViolationException;

/**
 * Post-stay review workflow (mobile/docs/mobile-phase-10-loyalty-reviews.md
 * "Review domain"). Eligibility mirrors the loyalty-earn definition of a
 * "completed/stayed" reservation exactly — both are the same Phase 0 §14
 * concept, so the statuses are not duplicated here.
 *
 * ── Invariants ──
 * - One review per reservation — the `reviews.reservation_id` UNIQUE is
 *   authoritative; a second submit for the same reservation is an idempotent
 *   no-op that returns the existing review, never a duplicate or an error.
 * - The client never sets guest_id, hotel_id, or the moderation state —
 *   all server-derived from the reservation / the acting staff user.
 * - No rating sub-categories, no editing/deleting a submitted review, no
 *   arbitrary (non-stay) reviews — none of that is approved (§ Explicitly
 *   NOT built in the mobile doc).
 */
class ReviewService
{
    public function __construct(
        private readonly ReviewRepositoryInterface $reviews,
        private readonly AuditLogger $auditLogger,
    ) {}

    public function reviewFor(Reservation $reservation): ?Review
    {
        return $this->reviews->findByReservation($reservation->id);
    }

    public function publishedForHotel(int $hotelId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->reviews->paginatePublishedForHotel($hotelId, $perPage);
    }

    public function allForHotel(int $hotelId, ?string $status, int $perPage = 15): LengthAwarePaginator
    {
        return $this->reviews->paginateForHotel($hotelId, $status, $perPage);
    }

    /**
     * Submit a review for a completed reservation. Idempotent: a second
     * submit for the same reservation returns the existing review with
     * `created: false` rather than raising an error or writing a duplicate
     * (the project's API has no 409/conflict convention — the controller
     * signals "already existed" via a 200 instead of 201, not an exception).
     *
     * @return array{review: Review, created: bool}
     *
     * @throws ReviewNotAllowedException if the reservation is not completed
     */
    public function submitForReservation(Reservation $reservation, int $rating, ?string $text, ?User $actor = null): array
    {
        $existing = $this->reviews->findByReservation($reservation->id);

        if ($existing !== null) {
            return ['review' => $existing, 'created' => false];
        }

        if (! in_array($reservation->status, LoyaltyService::COMPLETED_RESERVATION_STATUSES, true)) {
            throw ReviewNotAllowedException::reservationNotCompleted($reservation->status);
        }

        try {
            $review = $this->reviews->create([
                'reservation_id' => $reservation->id,
                'guest_id' => $reservation->guest_id,
                'hotel_id' => $reservation->hotel_id,
                'rating' => $rating,
                'text' => $text,
                'status' => Review::STATUS_PENDING,
            ]);
        } catch (UniqueConstraintViolationException) {
            // A concurrent submit for the same reservation won the race —
            // the UNIQUE constraint is authoritative.
            return [
                'review' => $this->reviews->findByReservation($reservation->id)
                    ?? throw new ReviewNotAllowedException('review_write_race'),
                'created' => false,
            ];
        }

        $this->auditLogger->record(
            $actor, 'review.submitted', $review,
            after: ['rating' => $review->rating, 'status' => $review->status],
            hotelId: $reservation->hotel_id,
        );

        return ['review' => $review, 'created' => true];
    }

    /**
     * Staff moderation decision. `$decision` is validated by the caller's
     * FormRequest to `published`|`rejected` before this is ever called.
     */
    public function moderate(Review $review, string $decision, ?User $actor = null): Review
    {
        $updated = $this->reviews->update($review, [
            'status' => $decision,
            'moderated_by_user_id' => $actor?->id,
            'moderated_at' => now(),
        ]);

        $this->auditLogger->record(
            $actor, 'review.moderated', $updated,
            after: ['status' => $updated->status],
            hotelId: $updated->hotel_id,
        );

        return $updated;
    }
}
