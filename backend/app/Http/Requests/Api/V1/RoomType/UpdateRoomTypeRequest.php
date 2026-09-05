<?php

namespace App\Http\Requests\Api\V1\RoomType;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateRoomTypeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * hotel_id and is_active are intentionally absent — hotel_id is
     * never an authority-changing field (the route hotel always wins),
     * and is_active only ever changes via the dedicated activate/
     * deactivate endpoints. Any such keys in the request body are simply
     * not present in validated() and are additionally stripped again by
     * RoomTypeService::update() as defense in depth.
     */
    public function rules(): array
    {
        $hotel = $this->route('hotel');
        $roomType = $this->route('roomType');

        return [
            'name' => ['sometimes', 'string', 'max:255', Rule::unique('room_types', 'name')->where('hotel_id', $hotel->id)->ignore($roomType)],
            'base_price' => ['sometimes', 'numeric', 'min:0'],
            'capacity' => ['sometimes', 'integer', 'min:1'],
            'amenities' => ['sometimes', 'nullable', 'array'],
            'amenities.*' => ['string'],
            'description' => ['sometimes', 'nullable', 'string'],
        ];
    }
}
