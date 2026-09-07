<?php

namespace App\Domain\StayServices\Repositories;

use App\Domain\StayServices\Models\ServiceOrder;
use App\Domain\StayServices\Repositories\Contracts\ServiceOrderRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class EloquentServiceOrderRepository implements ServiceOrderRepositoryInterface
{
    public function paginateForReservation(int $reservationId, int $perPage = 15): LengthAwarePaginator
    {
        return ServiceOrder::query()
            ->where('reservation_id', $reservationId)
            ->orderByDesc('id')
            ->paginate($perPage);
    }

    public function allForReservation(int $reservationId): Collection
    {
        return ServiceOrder::query()
            ->where('reservation_id', $reservationId)
            ->orderByDesc('id')
            ->get();
    }

    public function find(int $id): ?ServiceOrder
    {
        return ServiceOrder::query()->find($id);
    }

    public function findForUpdate(int $id): ?ServiceOrder
    {
        return ServiceOrder::query()->lockForUpdate()->find($id);
    }

    public function create(array $data): ServiceOrder
    {
        return ServiceOrder::create($data)->refresh();
    }

    public function update(ServiceOrder $order, array $data): ServiceOrder
    {
        $order->update($data);

        return $order->refresh();
    }
}
