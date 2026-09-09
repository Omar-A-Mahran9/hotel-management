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
            'identity-verification.view' => 'View identity verification status within authorized scope',
            'identity-verification.submit' => 'Submit identity document/selfie for a reservation within authorized scope',
            'identity-verification.review' => 'Decide a pending identity verification manual review within authorized scope',
            'check-in.perform' => 'Perform reservation check-in within authorized scope',
            'digital-access.view' => 'View digital access status within authorized scope',
            'digital-access.revoke' => 'Revoke a reservation digital access credential within authorized scope',
            'services.view' => 'View the hotel service catalog within authorized scope',
            'services.manage' => 'Create, update, activate/deactivate hotel services and categories within authorized scope',
            'service-orders.view' => 'View reservation service orders within authorized scope',
            'service-orders.manage' => 'Record and transition reservation service orders within authorized scope',
            'folio.view' => 'View a reservation folio within authorized scope',
            'checkout.perform' => 'Perform reservation checkout and final settlement within authorized scope',
            'invoice.view' => 'View a reservation invoice within authorized scope',
            'loyalty.view' => 'View a guest loyalty account and ledger within authorized scope',
            'loyalty.manage' => 'Accrue and redeem loyalty points against a reservation within authorized scope',
            'loyalty.rules.manage' => 'Configure a hotel group loyalty rule',
            'notifications.view' => 'View and mark read a reservation notification feed within authorized scope',
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
                'permissions' => ['hotels.view', 'inventory.view', 'inventory.manage', 'reservations.view', 'reservations.manage', 'payments.manage', 'identity-verification.view', 'identity-verification.submit', 'identity-verification.review', 'check-in.perform', 'digital-access.view', 'digital-access.revoke', 'services.view', 'services.manage', 'service-orders.view', 'service-orders.manage', 'folio.view', 'checkout.perform', 'invoice.view', 'loyalty.view', 'loyalty.manage', 'notifications.view'],
            ],
            Role::RECEPTION => [
                'name' => 'Reception',
                'description' => 'Front-desk support/fallback for a single assigned hotel.',
                // Phase 0 §7: Reception may review/decide a pending verification
                // (✅), assists with check-in processing (R7, R33), and may
                // issue/revoke digital access as "manual-assist, logged" — but
                // holds no financial capability. Phase 8: Reception may view
                // the service catalog and record/transition in-stay service
                // orders (operational, R7/R14-R19) and read a folio, but NOT
                // configure the catalog (services.manage = pricing config,
                // §32 "no financial edit"). Phase 9: Reception may perform the
                // operational one-tap checkout (R7/R14-R19 — every checkout is
                // audited) and read the resulting invoice. Phase 10: Reception
                // may view a guest's loyalty balance/history (operational) but
                // NOT accrue/redeem points (loyalty.manage has a monetary
                // effect on a booking — §32 "no financial edit"). Phase 11:
                // Reception may read a reservation's notification feed and
                // clear its unread markers (operational, R7 — no financial
                // effect).
                'permissions' => ['hotels.view', 'inventory.view', 'reservations.view', 'identity-verification.view', 'identity-verification.submit', 'identity-verification.review', 'check-in.perform', 'digital-access.view', 'digital-access.revoke', 'services.view', 'service-orders.view', 'service-orders.manage', 'folio.view', 'checkout.perform', 'invoice.view', 'loyalty.view', 'notifications.view'],
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
