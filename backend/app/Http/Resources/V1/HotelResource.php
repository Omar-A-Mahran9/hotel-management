<?php

namespace App\Http\Resources\V1;

use App\Domain\HotelGroup\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Resources\MissingValue;

/**
 * @mixin Hotel
 *
 * `country` / `city` are the legacy free-text strings, kept for backward
 * compatibility (and still what the guest Discovery API filters on). The
 * normalized relationship is exposed as `country_id` / `city_id` plus, when
 * the relations are eager-loaded, the `country_summary` / `city_summary`
 * objects.
 */
class HotelResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'hotel_group_id' => $this->hotel_group_id,
            'name' => $this->name,
            'slug' => $this->slug,
            'country_id' => $this->country_id,
            'city_id' => $this->city_id,
            'country' => $this->country,
            'city' => $this->city,
            'country_summary' => $this->summaryFor('countryRef'),
            'city_summary' => $this->summaryFor('cityRef'),
            'timezone' => $this->timezone,
            'is_active' => $this->is_active,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

    /**
     * @return array{id: int, name_en: string, name_ar: string}|null|MissingValue
     */
    private function summaryFor(string $relation)
    {
        return $this->when($this->resource->relationLoaded($relation), function () use ($relation) {
            $model = $this->resource->getRelation($relation);

            return $model === null ? null : [
                'id' => $model->id,
                'name_en' => $model->name_en,
                'name_ar' => $model->name_ar,
            ];
        });
    }
}
