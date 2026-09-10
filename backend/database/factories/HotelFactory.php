<?php

namespace Database\Factories;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Location\Models\City;
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
        $city = City::factory()->create();

        return [
            'hotel_group_id' => HotelGroupFactory::new(),
            'name' => $name,
            'slug' => Str::slug($name).'-'.fake()->unique()->numberBetween(1000, 999999),
            'country_id' => $city->country_id,
            'city_id' => $city->id,
            // Legacy free-text columns kept in sync with the normalized
            // relationship (the guest Discovery API still exposes `city`).
            'country' => $city->country->name_en,
            'city' => $city->name_en,
            'timezone' => 'UTC',
            'is_active' => true,
        ];
    }
}
