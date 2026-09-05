<?php

namespace Database\Factories;

use App\Domain\HotelGroup\Models\Hotel;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Hotel>
 */
class HotelFactory extends Factory
{
    protected $model = Hotel::class;

    public function definition(): array
    {
        $name = fake()->unique()->company().' Hotel';

        return [
            'hotel_group_id' => HotelGroupFactory::new(),
            'name' => $name,
            'slug' => Str::slug($name).'-'.fake()->unique()->numberBetween(1000, 999999),
            'country' => fake()->country(),
            'city' => fake()->city(),
            'timezone' => 'UTC',
            'is_active' => true,
        ];
    }
}
