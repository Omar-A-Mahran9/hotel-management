<?php

namespace Database\Factories;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Inventory\Models\RoomType;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RoomType>
 */
class RoomTypeFactory extends Factory
{
    protected $model = RoomType::class;

    public function definition(): array
    {
        $qualifiers = ['Standard', 'Superior', 'Deluxe', 'Executive', 'Premium', 'Classic'];
        $categories = ['Single', 'Double', 'Twin', 'Suite', 'Room'];

        // The qualifier/category pair alone only has 30 combinations and
        // room_types has a UNIQUE(hotel_id, name) constraint, so two
        // random picks can collide when several Room Types are created
        // for the same hotel. Appending a number that Faker guarantees
        // is unique for the life of the test process — not merely
        // unlikely to repeat — makes every generated name unique
        // outright, while staying a realistic, readable room type label
        // (e.g. "Deluxe Double 4821").
        $name = fake()->randomElement($qualifiers).' '.fake()->randomElement($categories).' '.fake()->unique()->numberBetween(1000, 9999);

        return [
            'hotel_id' => Hotel::factory(),
            'name' => $name,
            'base_price' => fake()->randomFloat(2, 50, 500),
            'capacity' => fake()->numberBetween(1, 6),
            'amenities' => fake()->randomElements(
                ['wifi', 'air_conditioning', 'tv', 'minibar', 'balcony', 'sea_view', 'safe'],
                fake()->numberBetween(2, 5)
            ),
            'description' => fake()->sentence(),
            'is_active' => true,
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }
}
