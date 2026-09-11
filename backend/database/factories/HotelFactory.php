<?php

namespace Database\Factories;

use App\Domain\HotelGroup\Enums\HotelAmenity;
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
            // Discovery enrichment fields are null by default so the legacy
            // `name` fallback keeps every existing discovery assertion valid.
            'name_i18n' => null,
            'tagline_i18n' => null,
            'description_i18n' => null,
            'star_rating' => null,
            'amenities' => null,
        ];
    }

    /**
     * Populates the guest-facing discovery fields with deterministic,
     * non-duplicated bilingual demo content (for tests + the demo seeder).
     */
    public function withDiscoveryContent(): static
    {
        return $this->state(function (array $attributes): array {
            $en = $attributes['name'] ?? (fake()->company().' Hotel');

            return [
                'name_i18n' => ['en' => $en, 'ar' => 'فندق '.fake()->firstName()],
                'tagline_i18n' => [
                    'en' => 'A calm stay in the heart of the city',
                    'ar' => 'إقامة هادئة في قلب المدينة',
                ],
                'description_i18n' => [
                    'en' => 'Contemporary rooms, attentive service and an easy walk to everything that matters.',
                    'ar' => 'غرف عصرية وخدمة مهتمة وقربٌ سهل من كل ما يهم.',
                ],
                'star_rating' => fake()->numberBetween(3, 5),
                'amenities' => fake()->randomElements(HotelAmenity::values(), fake()->numberBetween(3, 6)),
            ];
        });
    }
}
