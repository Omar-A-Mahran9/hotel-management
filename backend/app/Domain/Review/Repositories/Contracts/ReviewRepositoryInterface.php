<?php

namespace App\Domain\Review\Repositories\Contracts;

use App\Domain\Review\Models\Review;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ReviewRepositoryInterface
{
    public function find(int $id): ?Review;

    public function findByReservation(int $reservationId): ?Review;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): Review;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Review $review, array $data): Review;

    /**
     * Guest-facing: published reviews only, newest first.
     *
     * @return LengthAwarePaginator<Review>
     */
    public function paginatePublishedForHotel(int $hotelId, int $perPage = 15): LengthAwarePaginator;

    /**
     * Staff-facing: every moderation state, optionally filtered.
     *
     * @return LengthAwarePaginator<Review>
     */
    public function paginateForHotel(int $hotelId, ?string $status, int $perPage = 15): LengthAwarePaginator;
}
