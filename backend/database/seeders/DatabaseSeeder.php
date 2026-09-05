<?php

namespace Database\Seeders;

use App\Domain\IdentityAccess\Models\Role;
use App\Domain\IdentityAccess\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(RolePermissionSeeder::class);

        if ($this->command?->getLaravel()->environment('local')) {
            $email = env('GROUP_OWNER_EMAIL', 'owner@example.com');
            $password = env('GROUP_OWNER_PASSWORD', 'password');

            if (! User::where('email', $email)->exists()) {
                User::factory()->create([
                    'name' => 'Group Owner',
                    'email' => $email,
                    'password' => $password,
                    'role_id' => Role::where('slug', Role::GROUP_OWNER)->value('id'),
                ]);

                $this->command?->info("Seeded local Group Owner: {$email} / {$password}");
            }
        }
    }
}
