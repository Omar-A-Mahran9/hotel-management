<?php

namespace Database\Seeders;

use App\Domain\IdentityAccess\Models\Permission;
use App\Domain\IdentityAccess\Models\Role;
use Illuminate\Database\Seeder;

/**
 * Seeds the fixed Phase 1 RBAC foundation: the four approved system roles
 * (Group Owner, Hotel Manager, Reception, Guest) and the permission catalog
 * technically necessary for the Identity & Access / Hotel Group / Hotels
 * foundation, mapped per the approved Phase 0 matrix (§7), plus the
 * `roles.manage` permission added for dynamic role management.
 *
 * Permissions stay a fixed, code-controlled catalog — each slug corresponds
 * to a real Gate/policy check baked into the code — but now carry bilingual
 * (EN/AR) display metadata. Roles are dynamically manageable (create/update/
 * delete via the API); the four seeded here are marked `is_system` and
 * cannot be deleted.
 */
class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permissions = [
            'hotel-groups.manage' => ['Manage hotel groups', 'إدارة مجموعات الفنادق', 'Create and update hotel groups', 'إنشاء مجموعات الفنادق وتحديثها'],
            'hotels.view' => ['View hotels', 'عرض الفنادق', 'View hotels within authorized scope', 'عرض الفنادق ضمن النطاق المصرح به'],
            'hotels.manage' => ['Manage hotels', 'إدارة الفنادق', 'Create and update hotels', 'إنشاء الفنادق وتحديثها'],
            'facilities.view' => ['View facilities', 'عرض المرافق', 'View the hotel facility catalog', 'عرض كتالوج مرافق الفندق'],
            'facilities.manage' => ['Manage facilities', 'إدارة المرافق', 'Create, update, delete, activate/deactivate hotel facilities', 'إنشاء مرافق الفندق وتحديثها وحذفها وتفعيلها/تعطيلها'],
            'locations.view' => ['View locations', 'عرض المواقع', 'View country and city master data', 'عرض بيانات الدول والمدن الأساسية'],
            'locations.manage' => ['Manage locations', 'إدارة المواقع', 'Create, update, delete, activate/deactivate countries and cities', 'إنشاء الدول والمدن وتحديثها وحذفها وتفعيلها/تعطيلها'],
            'users.view' => ['View users', 'عرض المستخدمين', 'View staff users', 'عرض مستخدمي الطاقم'],
            'users.manage' => ['Manage users', 'إدارة المستخدمين', 'Create, update, and delete staff users', 'إنشاء مستخدمي الطاقم وتحديثهم وحذفهم'],
            'roles.view' => ['View roles', 'عرض الأدوار', 'View roles', 'عرض الأدوار'],
            'roles.manage' => ['Manage roles', 'إدارة الأدوار', 'Create, update, and delete roles, and manage their permission assignments', 'إنشاء الأدوار وتحديثها وحذفها، وإدارة الصلاحيات المسندة إليها'],
            'permissions.view' => ['View permissions', 'عرض الصلاحيات', 'View permissions', 'عرض الصلاحيات'],
            'inventory.view' => ['View inventory', 'عرض المخزون', 'View room types and rooms within authorized scope', 'عرض أنواع الغرف والغرف ضمن النطاق المصرح به'],
            'inventory.manage' => ['Manage inventory', 'إدارة المخزون', 'Create, update, activate/deactivate room types and rooms', 'إنشاء أنواع الغرف والغرف وتحديثها وتفعيلها/تعطيلها'],
            'reservations.view' => ['View reservations', 'عرض الحجوزات', 'View reservations within authorized scope', 'عرض الحجوزات ضمن النطاق المصرح به'],
            'reservations.manage' => ['Manage reservations', 'إدارة الحجوزات', 'Create reservations within authorized scope', 'إنشاء الحجوزات ضمن النطاق المصرح به'],
            'payments.manage' => ['Manage payments', 'إدارة المدفوعات', 'Initiate and manage reservation payments within authorized scope', 'بدء وإدارة مدفوعات الحجوزات ضمن النطاق المصرح به'],
            'identity-verification.view' => ['View identity verification', 'عرض التحقق من الهوية', 'View identity verification status within authorized scope', 'عرض حالة التحقق من الهوية ضمن النطاق المصرح به'],
            'identity-verification.submit' => ['Submit identity verification', 'إرسال التحقق من الهوية', 'Submit identity document/selfie for a reservation within authorized scope', 'إرسال وثيقة الهوية/الصورة الشخصية لحجز ضمن النطاق المصرح به'],
            'identity-verification.review' => ['Review identity verification', 'مراجعة التحقق من الهوية', 'Decide a pending identity verification manual review within authorized scope', 'البت في مراجعة يدوية معلّقة للتحقق من الهوية ضمن النطاق المصرح به'],
            'check-in.perform' => ['Perform check-in', 'تنفيذ تسجيل الوصول', 'Perform reservation check-in within authorized scope', 'تنفيذ تسجيل وصول الحجز ضمن النطاق المصرح به'],
            'digital-access.view' => ['View digital access', 'عرض الوصول الرقمي', 'View digital access status within authorized scope', 'عرض حالة الوصول الرقمي ضمن النطاق المصرح به'],
            'digital-access.revoke' => ['Revoke digital access', 'إلغاء الوصول الرقمي', 'Revoke a reservation digital access credential within authorized scope', 'إلغاء بيانات اعتماد الوصول الرقمي لحجز ضمن النطاق المصرح به'],
            'services.view' => ['View services', 'عرض الخدمات', 'View the hotel service catalog within authorized scope', 'عرض كتالوج خدمات الفندق ضمن النطاق المصرح به'],
            'services.manage' => ['Manage services', 'إدارة الخدمات', 'Create, update, activate/deactivate hotel services and categories within authorized scope', 'إنشاء خدمات الفندق وفئاتها وتحديثها وتفعيلها/تعطيلها ضمن النطاق المصرح به'],
            'service-orders.view' => ['View service orders', 'عرض طلبات الخدمة', 'View reservation service orders within authorized scope', 'عرض طلبات خدمة الحجوزات ضمن النطاق المصرح به'],
            'service-orders.manage' => ['Manage service orders', 'إدارة طلبات الخدمة', 'Record and transition reservation service orders within authorized scope', 'تسجيل طلبات خدمة الحجوزات ونقل حالتها ضمن النطاق المصرح به'],
            'folio.view' => ['View folio', 'عرض الفاتورة الجارية', 'View a reservation folio within authorized scope', 'عرض الفاتورة الجارية لحجز ضمن النطاق المصرح به'],
            'checkout.perform' => ['Perform checkout', 'تنفيذ المغادرة', 'Perform reservation checkout and final settlement within authorized scope', 'تنفيذ مغادرة الحجز والتسوية النهائية ضمن النطاق المصرح به'],
            'invoice.view' => ['View invoice', 'عرض الفاتورة', 'View a reservation invoice within authorized scope', 'عرض فاتورة حجز ضمن النطاق المصرح به'],
            'loyalty.view' => ['View loyalty', 'عرض الولاء', 'View a guest loyalty account and ledger within authorized scope', 'عرض حساب وسجل ولاء النزيل ضمن النطاق المصرح به'],
            'loyalty.manage' => ['Manage loyalty', 'إدارة الولاء', 'Accrue and redeem loyalty points against a reservation within authorized scope', 'استحقاق واسترداد نقاط الولاء مقابل حجز ضمن النطاق المصرح به'],
            'loyalty.rules.manage' => ['Manage loyalty rules', 'إدارة قواعد الولاء', 'Configure a hotel group loyalty rule', 'ضبط قاعدة الولاء الخاصة بمجموعة الفنادق'],
            'notifications.view' => ['View notifications', 'عرض الإشعارات', 'View and mark read a reservation notification feed within authorized scope', 'عرض قائمة إشعارات الحجز وتحديدها كمقروءة ضمن النطاق المصرح به'],
        ];

        // A single bulk upsert instead of one firstOrCreate() round trip per
        // permission — every test in the suite reseeds this table in its
        // own transaction (see Tests\TestCase), and 30+ sequential
        // check-then-insert statements against the same small table proved
        // deadlock-prone under sustained load. One statement is also
        // atomic, so a partial seed can never happen.
        $now = now();
        Permission::query()->upsert(
            array_map(
                fn (string $slug, array $t) => [
                    'slug' => $slug,
                    'name_en' => $t[0],
                    'name_ar' => $t[1],
                    'description_en' => $t[2],
                    'description_ar' => $t[3],
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                array_keys($permissions),
                array_values($permissions),
            ),
            uniqueBy: ['slug'],
            update: ['name_en', 'name_ar', 'description_en', 'description_ar', 'updated_at'],
        );

        $roles = [
            Role::GROUP_OWNER => [
                'name_en' => 'Group Owner',
                'name_ar' => 'مالك المجموعة',
                'description_en' => 'Group-wide oversight across all hotels.',
                'description_ar' => 'إشراف على مستوى المجموعة عبر جميع الفنادق.',
                'permissions' => array_keys($permissions),
            ],
            Role::HOTEL_MANAGER => [
                'name_en' => 'Hotel Manager',
                'name_ar' => 'مدير الفندق',
                'description_en' => 'Manages one or more assigned hotels.',
                'description_ar' => 'يدير فندقًا واحدًا أو أكثر من الفنادق المسندة إليه.',
                'permissions' => ['hotels.view', 'locations.view', 'inventory.view', 'inventory.manage', 'reservations.view', 'reservations.manage', 'payments.manage', 'identity-verification.view', 'identity-verification.submit', 'identity-verification.review', 'check-in.perform', 'digital-access.view', 'digital-access.revoke', 'services.view', 'services.manage', 'service-orders.view', 'service-orders.manage', 'folio.view', 'checkout.perform', 'invoice.view', 'loyalty.view', 'loyalty.manage', 'notifications.view'],
            ],
            Role::RECEPTION => [
                'name_en' => 'Reception',
                'name_ar' => 'الاستقبال',
                'description_en' => 'Front-desk support/fallback for a single assigned hotel.',
                'description_ar' => 'دعم مكتب الاستقبال لفندق واحد مسند إليه.',
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
                'permissions' => ['hotels.view', 'locations.view', 'inventory.view', 'reservations.view', 'identity-verification.view', 'identity-verification.submit', 'identity-verification.review', 'check-in.perform', 'digital-access.view', 'digital-access.revoke', 'services.view', 'service-orders.view', 'service-orders.manage', 'folio.view', 'checkout.perform', 'invoice.view', 'loyalty.view', 'notifications.view'],
            ],
            Role::GUEST => [
                'name_en' => 'Guest',
                'name_ar' => 'نزيل',
                'description_en' => 'Guest-facing identity foundation. No staff capabilities.',
                'description_ar' => 'هوية خاصة بالنزلاء فقط. لا تملك أي صلاحيات إدارية في لوحة التحكم.',
                'permissions' => [],
            ],
        ];

        foreach ($roles as $slug => $definition) {
            $role = Role::query()->firstOrCreate(
                ['slug' => $slug],
                [
                    'name_en' => $definition['name_en'],
                    'name_ar' => $definition['name_ar'],
                    'description_en' => $definition['description_en'],
                    'description_ar' => $definition['description_ar'],
                    'is_system' => true,
                ]
            );

            $permissionIds = Permission::query()
                ->whereIn('slug', $definition['permissions'])
                ->pluck('id');

            $role->permissions()->sync($permissionIds);
        }
    }
}
