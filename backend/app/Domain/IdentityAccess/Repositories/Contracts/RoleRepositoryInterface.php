<?php

namespace App\Domain\IdentityAccess\Repositories\Contracts;

use App\Domain\IdentityAccess\Models\Role;
use Illuminate\Support\Collection;

interface RoleRepositoryInterface
{
    public function all(): Collection;

    public function findBySlug(string $slug): ?Role;
}
