<?php

namespace App\Domain\Payment\Repositories;

use App\Domain\Payment\Models\PaymentTransaction;
use App\Domain\Payment\Repositories\Contracts\PaymentTransactionRepositoryInterface;

class EloquentPaymentTransactionRepository implements PaymentTransactionRepositoryInterface
{
    public function find(int $id): ?PaymentTransaction
    {
        return PaymentTransaction::query()->find($id);
    }

    public function findByIdempotencyKey(string $idempotencyKey): ?PaymentTransaction
    {
        return PaymentTransaction::query()->where('idempotency_key', $idempotencyKey)->first();
    }

    public function findForUpdate(int $id): ?PaymentTransaction
    {
        return PaymentTransaction::query()->lockForUpdate()->find($id);
    }

    public function findByProviderReference(string $provider, string $providerReference): ?PaymentTransaction
    {
        return PaymentTransaction::query()
            ->where('provider', $provider)
            ->where('provider_reference', $providerReference)
            ->first();
    }

    public function create(array $data): PaymentTransaction
    {
        return PaymentTransaction::create($data)->refresh();
    }

    public function update(PaymentTransaction $transaction, array $data): PaymentTransaction
    {
        $transaction->update($data);

        return $transaction->refresh();
    }
}
