<?php

namespace App\Domain\Loyalty\Repositories;

use App\Domain\Loyalty\Models\LoyaltyTransaction;
use App\Domain\Loyalty\Repositories\Contracts\LoyaltyTransactionRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentLoyaltyTransactionRepository implements LoyaltyTransactionRepositoryInterface
{
    public function paginateForAccount(int $accountId, int $perPage = 20): LengthAwarePaginator
    {
        return LoyaltyTransaction::query()
            ->where('loyalty_account_id', $accountId)
            ->orderByDesc('id')
            ->paginate($perPage);
    }

    public function findByAccountTypeAndSource(int $accountId, string $type, string $sourceType, int $sourceId): ?LoyaltyTransaction
    {
        return LoyaltyTransaction::query()
            ->where('loyalty_account_id', $accountId)
            ->where('type', $type)
            ->where('source_type', $sourceType)
            ->where('source_id', $sourceId)
            ->first();
    }

    public function sumPointsForAccount(int $accountId): int
    {
        // The database sums the signed integer column — deterministic, no
        // float arithmetic.
        return (int) LoyaltyTransaction::query()
            ->where('loyalty_account_id', $accountId)
            ->sum('points');
    }

    public function create(array $data): LoyaltyTransaction
    {
        return LoyaltyTransaction::create($data)->refresh();
    }
}
