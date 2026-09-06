<?php

namespace App\Domain\Payment\Repositories;

use App\Domain\Payment\Models\Payment;
use App\Domain\Payment\Repositories\Contracts\PaymentRepositoryInterface;

class EloquentPaymentRepository implements PaymentRepositoryInterface
{
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
