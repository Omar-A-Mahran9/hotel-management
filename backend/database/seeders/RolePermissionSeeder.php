<?php

namespace Database\Seeders;

use App\Domain\IdentityAccess\Models\Permission;
use App\Domain\IdentityAccess\Models\Role;
use Illuminate\Database\Seeder;

/**
 * Seeds the fixed Phase 1 RBAC foundation: the four approved roles
 * (Group Owner, Hotel Manager, Reception, Guest) and the minimal set of
 * permissions technically necessary for the Identity & Access / Hotel
 * Group / Hotels foundation, mapped per the approved Phase 0 matrix (§7).
 */
class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permissions = [
            'hotel-groups.manage' => 'Create and update hotel groups',
            'hotels.view' => 'View hotels within authorized scope',
            'hotels.manage' => 'Create and update hotels',
            'users.view' => 'View staff users',
            'users.manage' => 'Create, update, and delete staff users',
            'roles.view' => 'View roles',
            'permissions.view' => 'View permissions',
            'inventory.view' => 'View room types and rooms within authorized scope',
            'inventory.manage' => 'Create, update, activate/deactivate room types and rooms',
            'reservations.view' => 'View reservations within authorized scope',
            'reservations.manage' => 'Create reservations within authorized scope',
            'payments.manage' => 'Initiate and manage reservation payments within authorized scope',
        ];

        foreach ($permissions as $slug => $name) {
            Permission::query()->firstOrCreate(
                ['slug' => $slug],
                ['name' => $name, 'description' => $name]
            );
        }

        $roles = [
            Role::GROUP_OWNER => [
                'name' => 'Group Owner',
                'description' => 'Group-wide oversight across all hotels.',
                'permissions' => array_keys($permissions),
            ],
            Role::HOTEL_MANAGER => [
                'name' => 'Hotel Manager',
                'description' => 'Manages one or more assigned hotels.',
                'permissions' => ['hotels.view', 'inventory.view', 'inventory.manage', 'reservations.view', 'reservations.manage', 'payments.manage'],
            ],
            Role::RECEPTION => [
                'name' => 'Reception',
                'description' => 'Front-desk support/fallback for a single assigned hotel.',
                'permissions' => ['hotels.view', 'inventory.view', 'reservations.view'],
            ],
            Role::GUEST => [
                'name' => 'Guest',
                'description' => 'Guest-facing identity foundation. No staff capabilities.',
                'permissions' => [],
            ],
        ];

        foreach ($roles as $slug => $definition) {
            $role = Role::query()->firstOrCreate(
                ['slug' => $slug],
                ['name' => $definition['name'], 'description' => $definition['description']]
            );

            $permissionIds = Permission::query()
                ->whereIn('slug', $definition['permissions'])
                ->pluck('id');

            $role->permissions()->sync($permissionIds);
        }
    }
}
