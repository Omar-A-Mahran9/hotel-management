<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(RolePermissionSeeder::class);
        $this->call(LocationSeeder::class);

        if (! app()->environment('production')) {
            $this->call(Phase1DemoSeeder::class);
        }
    }
}
