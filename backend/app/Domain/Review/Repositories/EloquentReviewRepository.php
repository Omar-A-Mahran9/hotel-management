<?php

namespace App\Domain\Review\Repositories;

use App\Domain\Review\Models\Review;
use App\Domain\Review\Repositories\Contracts\ReviewRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentReviewRepository implements ReviewRepositoryInterface
{
    public function find(int $id): ?Review
    {
        return Review::query()->find($id);
    }

    public function findByReservation(int $reservationId): ?Review
    {
        return Review::query()->where('reservation_id', $reservationId)->first();
    }

    public function create(array $data): Review
    {
        return Review::create($data)->refresh();
    }

    public function update(Review $review, array $data): Review
    {
        $review->update($data);

        return $review->refresh();
    }

    public function paginatePublishedForHotel(int $hotelId, int $perPage = 15): LengthAwarePaginator
    {
        return Review::query()
            ->where('hotel_id', $hotelId)
            ->where('status', Review::STATUS_PUBLISHED)
            ->latest()
            ->paginate($perPage);
    }

    public function paginateForHotel(int $hotelId, ?string $status, int $perPage = 15): LengthAwarePaginator
    {
        return Review::query()
            ->where('hotel_id', $hotelId)
            ->when($status !== null, fn ($query) => $query->where('status', $status))
            ->latest()
            ->paginate($perPage);
    }
}
