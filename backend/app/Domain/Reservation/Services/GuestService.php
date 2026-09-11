<?php

namespace App\Domain\Reservation\Services;

use App\Domain\IdentityAccess\Models\User;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Repositories\Contracts\GuestRepositoryInterface;
use App\Domain\Reservation\Repositories\Contracts\ReservationRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

/**
 * Staff-facing guest directory — read-only. Guests are created/updated
 * only through the guest app's own auth/profile flow (GuestAuthService);
 * this service never mutates a Guest.
 */
class GuestService
{
    public function __construct(
        private readonly GuestRepositoryInterface $guests,
        private readonly ReservationRepositoryInterface $reservations,
    ) {}

    /**
     * @param  array{search?: string|null}  $filters
     */
    public function list(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        return $this->guests->paginate($filters, $this->clampPerPage($perPage));
    }

    public function find(int $id): ?Guest
    {
        return $this->guests->find($id);
    }

    public function reservationsFor(User $user, Guest $guest, int $perPage = 15): LengthAwarePaginator
    {
        return $this->reservations->paginateForGuestAccessibleBy($user, $guest, $this->clampPerPage($perPage));
    }

    private function clampPerPage(int $perPage): int
    {
        return min(max($perPage, 1), 100);
    }
}
