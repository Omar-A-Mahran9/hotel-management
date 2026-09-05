<?php

namespace App\Domain\IdentityAccess\Repositories;

use App\Domain\IdentityAccess\Models\Role;
use App\Domain\IdentityAccess\Repositories\Contracts\RoleRepositoryInterface;
use Illuminate\Support\Collection;

class EloquentRoleRepository implements RoleRepositoryInterface
{
    public function all(): Collection
    {
        return Role::with('permissions')->get();
    }

    public function findBySlug(string $slug): ?Role
    {
        return Role::where('slug', $slug)->first();
    }
}
