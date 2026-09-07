<?php

namespace App\Domain\StayServices\Repositories\Contracts;

use App\Domain\StayServices\Models\ServiceOrder;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface ServiceOrderRepositoryInterface
{
    /**
     * @return LengthAwarePaginator<ServiceOrder>
     */
    public function paginateForReservation(int $reservationId, int $perPage = 15): LengthAwarePaginator;

    /**
     * Every order for a reservation, newest first — used to build the folio
     * read model.
     *
     * @return Collection<int, ServiceOrder>
     */
    public function allForReservation(int $reservationId): Collection;

    public function find(int $id): ?ServiceOrder;

    /**
     * `find()` under a `SELECT ... FOR UPDATE` row lock. Call only from
     * within an active DB::transaction().
     */
    public function findForUpdate(int $id): ?ServiceOrder;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): ServiceOrder;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(ServiceOrder $order, array $data): ServiceOrder;
}
