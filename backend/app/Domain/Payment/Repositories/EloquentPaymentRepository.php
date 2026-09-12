<?php

namespace App\Domain\Payment\Repositories;

use App\Domain\Payment\Models\Payment;
use App\Domain\Payment\Repositories\Contracts\PaymentRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class EloquentPaymentRepository implements PaymentRepositoryInterface
{
    public function paginateForHotel(int $hotelId, array $filters, int $perPage): LengthAwarePaginator
    {
        return Payment::query()
            ->where('hotel_id', $hotelId)
            ->when(($filters['status'] ?? null) !== null, fn ($q) => $q->where('status', $filters['status']))
            ->latest()
            ->paginate($perPage)
            ->withQueryString();
    }

    /**
     * `updated_at` is the closest available signal for "when this became
     * captured/settled" — Payment carries no dedicated captured_at column,
     * and a row's last update while in a captured status is that
     * transition (Payment never mutates again once settled).
     */
    public function sumCapturedForHotelByCurrency(int $hotelId, string $from, string $to): Collection
    {
        return Payment::query()
            ->where('hotel_id', $hotelId)
            ->whereIn('status', Payment::CAPTURED_STATUSES)
            ->whereBetween('updated_at', ["{$from} 00:00:00", "{$to} 23:59:59"])
            ->selectRaw('currency, SUM(amount) as total')
            ->groupBy('currency')
            ->get();
    }

    public function countsByStatusForHotel(int $hotelId, string $from, string $to): array
    {
        return Payment::query()
            ->where('hotel_id', $hotelId)
            ->whereBetween('created_at', ["{$from} 00:00:00", "{$to} 23:59:59"])
            ->groupBy('status')
            ->selectRaw('status, COUNT(*) as aggregate')
            ->pluck('aggregate', 'status')
            ->all();
    }

    public function find(int $id): ?Payment
    {
        return Payment::query()->find($id);
    }

    public function findByReservation(int $reservationId): ?Payment
    {
        return Payment::query()->where('reservation_id', $reservationId)->first();
    }

    public function findForUpdate(int $id): ?Payment
    {
        return Payment::query()->lockForUpdate()->find($id);
    }

    public function findByReservationForUpdate(int $reservationId): ?Payment
    {
        return Payment::query()->where('reservation_id', $reservationId)->lockForUpdate()->first();
    }

    public function create(array $data): Payment
    {
        return Payment::create($data)->refresh();
    }

    public function update(Payment $payment, array $data): Payment
    {
        $payment->update($data);

        return $payment->refresh();
    }
}
