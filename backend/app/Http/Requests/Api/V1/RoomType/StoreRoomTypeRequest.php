<?php

namespace App\Http\Requests\Api\V1\RoomType;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreRoomTypeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $hotel = $this->route('hotel');

        return [
            'name' => ['required', 'string', 'max:255', Rule::unique('room_types', 'name')->where('hotel_id', $hotel->id)],
            'base_price' => ['required', 'numeric', 'min:0'],
            'capacity' => ['required', 'integer', 'min:1'],
            'amenities' => ['sometimes', 'nullable', 'array'],
            'amenities.*' => ['string'],
            'description' => ['sometimes', 'nullable', 'string'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
