<?php

namespace App\Domain\IdentityVerification\Models;

use Database\Factories\IdentityVerificationAttemptFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Phase 6 — one attempt cycle against a verification session
 * (Phase 0 §6.4: `verification_attempts`). Retry granularity + where the
 * private document/selfie references, the provider reference, and the
 * match-operation idempotency key live.
 *
 * An attempt's own `status` is independent of the session's status.
 *
 * Sensitive columns: `document_path` / `selfie_path` are PRIVATE-disk
 * relative paths only — never a URL, never a public path, never the file
 * bytes. `metadata` holds only the allow-listed, sensitive-key-free result
 * context (no document number, no raw provider payload).
 */
class IdentityVerificationAttempt extends Model
{
    use HasFactory;

    public const STATUS_DOCUMENT_UPLOADED = 'document_uploaded';

    public const STATUS_SELFIE_CAPTURED = 'selfie_captured';

    public const STATUS_MATCHING_IN_PROGRESS = 'matching_in_progress';

    public const STATUS_COMPLETED = 'completed';

    /**
     * @var array<int, string>
     */
    public const STATUSES = [
        self::STATUS_DOCUMENT_UPLOADED,
        self::STATUS_SELFIE_CAPTURED,
        self::STATUS_MATCHING_IN_PROGRESS,
        self::STATUS_COMPLETED,
    ];

    protected $fillable = [
        'session_id',
        'attempt_number',
        'status',
        'provider',
        'provider_reference',
        'idempotency_key',
        'document_type',
        'document_path',
        'selfie_path',
        'outcome',
        'score',
        'metadata',
        'submitted_at',
        'completed_at',
    ];

    protected $hidden = [
        'document_path',
        'selfie_path',
    ];

    protected function casts(): array
    {
        return [
            'attempt_number' => 'integer',
            'score' => 'integer',
            'metadata' => 'array',
            'submitted_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function session(): BelongsTo
    {
        return $this->belongsTo(IdentityVerificationSession::class, 'session_id');
    }

    protected static function newFactory(): IdentityVerificationAttemptFactory
    {
        return IdentityVerificationAttemptFactory::new();
    }
}
