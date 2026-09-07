<?php

namespace App\Http\Requests\Api\V1\IdentityVerification;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Phase 6 — validation for
 * POST /api/v1/identity-verification/{reservation}/documents.
 *
 * Carries the ID document image only. Identity (user/hotel/role) is never
 * read from the body. The uploaded file is validated to a safe shape here;
 * it is stored on a PRIVATE disk by the domain and never served back.
 */
class SubmitIdentityDocumentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $maxKb = (int) config('verification.storage.max_file_kb', 8192);

        return [
            'document' => ['required', 'file', 'mimes:jpg,jpeg,png,pdf', "max:{$maxKb}"],

            // A short, non-PII label only. Never a document number.
            'document_type' => ['sometimes', 'nullable', 'string', 'max:40', 'regex:/^[A-Za-z0-9 _-]+$/'],
        ];
    }

    public function messages(): array
    {
        return [
            'document.mimes' => 'The identity document must be a JPG, PNG, or PDF file.',
            'document_type.regex' => 'The document type may only contain letters, numbers, spaces, hyphens and underscores.',
        ];
    }

    public function documentType(): ?string
    {
        $value = $this->validated('document_type');

        return is_string($value) && $value !== '' ? $value : null;
    }
}
