<?php

namespace App\Http\Requests\Api\V1\Review;

use Illuminate\Foundation\Http\FormRequest;

/**
 * POST .../review. The client supplies only the rating + optional text —
 * eligibility, ownership, the one-review-per-stay rule and the moderation
 * state are all resolved server-side (mobile/docs/mobile-phase-10-loyalty-reviews.md).
 */
class SubmitReviewRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'text' => [
                'nullable', 'string', 'max:2000',
                function (string $attribute, mixed $value, \Closure $fail): void {
                    if ($value !== null && trim($value) === '') {
                        $fail(__('api.validation_failed'));
                    }
                },
            ],
        ];
    }

    public function rating(): int
    {
        return (int) $this->validated('rating');
    }

    public function text(): ?string
    {
        $text = $this->validated('text');

        return $text === null ? null : trim($text);
    }
}
