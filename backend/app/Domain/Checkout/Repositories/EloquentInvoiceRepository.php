<?php

namespace App\Domain\Checkout\Repositories;

use App\Domain\Checkout\Models\Invoice;
use App\Domain\Checkout\Models\InvoiceItem;
use App\Domain\Checkout\Repositories\Contracts\InvoiceRepositoryInterface;

class EloquentInvoiceRepository implements InvoiceRepositoryInterface
{
    public function find(int $id): ?Invoice
    {
        return Invoice::query()->with('items')->find($id);
    }

    public function findByReservation(int $reservationId): ?Invoice
    {
        return Invoice::query()->with('items')->where('reservation_id', $reservationId)->first();
    }

    public function findByReservationForUpdate(int $reservationId): ?Invoice
    {
        return Invoice::query()
            ->where('reservation_id', $reservationId)
            ->lockForUpdate()
            ->first();
    }

    public function create(array $data): Invoice
    {
        return Invoice::create($data)->refresh();
    }

    public function update(Invoice $invoice, array $data): Invoice
    {
        $invoice->update($data);

        return $invoice->refresh()->load('items');
    }

    public function addItem(Invoice $invoice, array $data): InvoiceItem
    {
        return $invoice->items()->create($data)->refresh();
    }
}
