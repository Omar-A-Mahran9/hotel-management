<?php

namespace Database\Seeders;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\HotelGroup\Models\HotelGroup;
use App\Domain\IdentityAccess\Models\Role;
use App\Domain\IdentityAccess\Models\User;
use Illuminate\Database\Seeder;

/**
 * Phase 1 development/demo dataset for manually exercising the Phase 1
 * API (e.g. via the Postman collection under postman/) against a local
 * `php artisan serve`.
 *
 * DEVELOPMENT/DEMO DATA ONLY:
 * - Refuses to run when APP_ENV=production.
 * - All demo accounts use the reserved `.test` email TLD (RFC 2606) and
 *   the single documented development password below — never real
 *   credentials. See README.md "Phase 1 demo data".
 * - Hotel Group/Hotel records use a `demo-` slug prefix so they are easy
 *   to identify and never collide with real data entered later.
 *
 * Idempotent: every record is looked up by a stable natural key (slug for
 * Hotel Groups/Hotels, email for Users) via firstOrCreate/updateOrCreate,
 * and hotel access is granted with syncWithoutDetaching. Re-running this
 * seeder any number of times never creates duplicates and never deletes
 * or detaches unrelated existing data.
 */
class Phase1DemoSeeder extends Seeder
{
    private const DEMO_PASSWORD = 'Password123!';

    public function run(): void
    {
        if (app()->environment('production')) {
            $this->command?->warn('Phase1DemoSeeder: skipped — refusing to seed demo data in production.');

            return;
        }

        // Demo users reference roles/permissions seeded here; safe to call
        // repeatedly since RolePermissionSeeder is itself idempotent.
        $this->call(RolePermissionSeeder::class);

        $group = HotelGroup::query()->firstOrCreate(
            ['slug' => 'demo-hotel-group'],
            [
                'name' => 'Demo Hotel Group',
                'is_active' => true,
            ]
        );

        $cairo = Hotel::query()->firstOrCreate(
            ['slug' => 'demo-cairo-hotel'],
            [
                'hotel_group_id' => $group->id,
                'name' => 'Cairo Hotel',
                'country' => 'Egypt',
                'city' => 'Cairo',
                'timezone' => 'Africa/Cairo',
                'is_active' => true,
            ]
        );

        $hurghada = Hotel::query()->firstOrCreate(
            ['slug' => 'demo-hurghada-hotel'],
            [
                'hotel_group_id' => $group->id,
                'name' => 'Hurghada Hotel',
                'country' => 'Egypt',
                'city' => 'Hurghada',
                'timezone' => 'Africa/Cairo',
                'is_active' => true,
            ]
        );

        Hotel::query()->firstOrCreate(
            ['slug' => 'demo-luxor-hotel'],
            [
                'hotel_group_id' => $group->id,
                'name' => 'Luxor Hotel',
                'country' => 'Egypt',
                'city' => 'Luxor',
                'timezone' => 'Africa/Cairo',
                'is_active' => true,
            ]
        );

        $roleIdBySlug = Role::query()->pluck('id', 'slug');

        $owner = $this->demoUser('owner@hotel.test', 'Demo Group Owner', $roleIdBySlug[Role::GROUP_OWNER]);
        $manager = $this->demoUser('manager@hotel.test', 'Demo Hotel Manager', $roleIdBySlug[Role::HOTEL_MANAGER]);
        $receptionCairo = $this->demoUser('reception.cairo@hotel.test', 'Demo Reception (Cairo)', $roleIdBySlug[Role::RECEPTION]);
        $receptionHurghada = $this->demoUser('reception.hurghada@hotel.test', 'Demo Reception (Hurghada)', $roleIdBySlug[Role::RECEPTION]);
        $this->demoUser('guest@hotel.test', 'Demo Guest', $roleIdBySlug[Role::GUEST]);

        // Group Owner needs no explicit hotel_access row — all-hotels
        // access is an explicit policy bypass (see HotelAccessService),
        // not a pivot assignment.
        $manager->hotels()->syncWithoutDetaching([$cairo->id, $hurghada->id]);
        $receptionCairo->hotels()->syncWithoutDetaching([$cairo->id]);
        $receptionHurghada->hotels()->syncWithoutDetaching([$hurghada->id]);

        $this->command?->info('Phase 1 demo data seeded/verified — see README.md "Phase 1 demo data" for accounts.');
        $this->command?->line("  {$owner->email} — Group Owner (all hotels)");
        $this->command?->line("  {$manager->email} — Hotel Manager (Cairo, Hurghada)");
        $this->command?->line("  {$receptionCairo->email} — Reception (Cairo)");
        $this->command?->line("  {$receptionHurghada->email} — Reception (Hurghada)");
        $this->command?->line('  guest@hotel.test — Guest (no staff access)');
        $this->command?->line('  Password for all demo accounts: '.self::DEMO_PASSWORD);
    }

    private function demoUser(string $email, string $name, int $roleId): User
    {
        return User::query()->updateOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'role_id' => $roleId,
                'password' => self::DEMO_PASSWORD,
                'is_active' => true,
            ]
        );
    }
}
