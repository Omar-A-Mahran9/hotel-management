<?php

namespace App\Http\Requests\Api\V1\Hotel;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Location\Models\City;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class StoreHotelRequest extends FormRequest
{
    /**
     * Authorize before validation so an unauthorized caller gets a clean
     * 403 and never sees which fields are required.
     */
    public function authorize(): bool
    {
        return $this->user()?->can('create', Hotel::class) ?? false;
    }

    public function rules(): array
    {
        return [
            'hotel_group_id' => ['required', 'integer', 'exists:hotel_groups,id'],
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['required', 'string', 'max:255', 'alpha_dash', 'unique:hotels,slug'],
            // Normalized location. country_id is required; city_id is
            // required and must belong to that country (checked below).
            'country_id' => ['required', 'integer', 'exists:countries,id'],
            'city_id' => ['required', 'integer', 'exists:cities,id'],
            // Legacy free-text — still accepted for backward compatibility
            // but overwritten from the referenced City/Country by the service.
            'country' => ['sometimes', 'nullable', 'string', 'max:255'],
            'city' => ['sometimes', 'nullable', 'string', 'max:255'],
            'timezone' => ['sometimes', 'string', 'max:64'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            $countryId = $this->input('country_id');
            $cityId = $this->input('city_id');

            if (! $countryId || ! $cityId) {
                return;
            }

            $belongs = City::query()->whereKey($cityId)->where('country_id', $countryId)->exists();

            if (! $belongs) {
                $validator->errors()->add('city_id', __('api.location.city_country_mismatch'));
            }
        });
    }
}
