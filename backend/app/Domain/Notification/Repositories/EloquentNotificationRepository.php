<?php

namespace App\Domain\Notification\Repositories;

use App\Domain\Notification\Enums\NotificationChannel;
use App\Domain\Notification\Models\Notification;
use App\Domain\Notification\Repositories\Contracts\NotificationRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentNotificationRepository implements NotificationRepositoryInterface
{
    public function find(int $id): ?Notification
    {
        return Notification::query()->find($id);
    }

    public function findForUpdate(int $id): ?Notification
    {
        return Notification::query()->lockForUpdate()->find($id);
    }

    public function findByIdempotencyKey(string $key): ?Notification
    {
        return Notification::query()->where('idempotency_key', $key)->first();
    }

    public function findByIdempotencyKeyForUpdate(string $key): ?Notification
    {
        return Notification::query()->where('idempotency_key', $key)->lockForUpdate()->first();
    }

    public function findForReservation(int $reservationId, int $notificationId): ?Notification
    {
        return Notification::query()
            ->where('reservation_id', $reservationId)
            ->whereKey($notificationId)
            ->first();
    }

    public function create(array $data): Notification
    {
        return Notification::create($data)->refresh();
    }

    public function update(Notification $notification, array $data): Notification
    {
        $notification->update($data);

        return $notification->refresh();
    }

    public function paginateForReservationChannel(
        int $reservationId,
        NotificationChannel $channel,
        bool $unreadOnly,
        int $perPage,
    ): LengthAwarePaginator {
        return Notification::query()
            ->where('reservation_id', $reservationId)
            ->where('channel', $channel->value)
            ->when($unreadOnly, fn ($query) => $query->whereNull('read_at'))
            ->orderByDesc('id')
            ->paginate($perPage);
    }

    public function markReadForReservationChannel(
        int $reservationId,
        NotificationChannel $channel,
        string $timestamp,
    ): int {
        return Notification::query()
            ->where('reservation_id', $reservationId)
            ->where('channel', $channel->value)
            ->whereNull('read_at')
            ->update(['read_at' => $timestamp]);
    }
}
