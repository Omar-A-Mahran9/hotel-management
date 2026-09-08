<?php

namespace App\Domain\Loyalty\Repositories\Contracts;

use App\Domain\Loyalty\Models\LoyaltyTransaction;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface LoyaltyTransactionRepositoryInterface
{
    /**
     * The account's ledger, newest first.
     *
     * @return LengthAwarePaginator<LoyaltyTransaction>
     */
    public function paginateForAccount(int $accountId, int $perPage = 20): LengthAwarePaginator;

    /**
     * The one ledger entry of a given type tied to a source, or null. Used
     * alongside the `(loyalty_account_id, type, source_type, source_id)`
     * UNIQUE to keep earn/redeem idempotent.
     */
    public function findByAccountTypeAndSource(int $accountId, string $type, string $sourceType, int $sourceId): ?LoyaltyTransaction;

    /**
     * The decimal-string SUM of `points` for an account — the authoritative
     * balance, used to (re)compute the cache. Returns "0" when empty.
     */
    public function sumPointsForAccount(int $accountId): int;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): LoyaltyTransaction;
}
