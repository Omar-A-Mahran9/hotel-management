<?php

namespace App\Http\Requests\Api\V1\Hotel;

use App\Domain\Location\Models\City;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateHotelRequest extends FormRequest
{
    public function authorize(): bool
    {
        $hotel = $this->route('hotel');

        return $hotel !== null && ($this->user()?->can('update', $hotel) ?? false);
    }

    public function rules(): array
    {
        $hotel = $this->route('hotel');

        return [
            'hotel_group_id' => ['sometimes', 'integer', 'exists:hotel_groups,id'],
            'name' => ['sometimes', 'string', 'max:255'],
            'slug' => ['sometimes', 'string', 'max:255', 'alpha_dash', Rule::unique('hotels', 'slug')->ignore($hotel)],
            'country_id' => ['sometimes', 'required', 'integer', 'exists:countries,id'],
            'city_id' => ['sometimes', 'required', 'integer', 'exists:cities,id'],
            'country' => ['sometimes', 'nullable', 'string', 'max:255'],
            'city' => ['sometimes', 'nullable', 'string', 'max:255'],
            'timezone' => ['sometimes', 'string', 'max:64'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            $hotel = $this->route('hotel');

            // Resolve the effective country/city after this update: a value
            // sent in the request wins, otherwise the hotel's current one.
            $countryId = $this->input('country_id', $hotel?->country_id);
            $cityId = $this->input('city_id', $hotel?->city_id);

            if (! $countryId || ! $cityId) {
                return;
            }

            if (! $this->has('country_id') && ! $this->has('city_id')) {
                return; // location untouched
            }

            $belongs = City::query()->whereKey($cityId)->where('country_id', $countryId)->exists();

            if (! $belongs) {
                $validator->errors()->add('city_id', __('api.location.city_country_mismatch'));
            }
        });
    }
}
