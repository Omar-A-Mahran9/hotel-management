<?php

namespace App\Http\Resources\V1;

use App\Domain\IdentityVerification\Models\IdentityVerificationDecision;
use App\Domain\IdentityVerification\Models\IdentityVerificationSession;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Phase 6 — the safe HTTP representation of an identity verification
 * session.
 *
 * Only application-level status fields are exposed. Document/selfie storage
 * paths, provider references, attempt `metadata`, raw provider responses and
 * any other internal/PII detail are deliberately absent (Phase 0 §17,
 * Phase 6 "do not return sensitive data from API resources").
 *
 * The `latest_decision` block, when present, carries only the decision
 * result, band, the optional staff reason, and who/when — no identity data.
 *
 * @mixin IdentityVerificationSession
 */
class IdentityVerificationResource extends JsonResource
{
    private ?IdentityVerificationDecision $latestDecision = null;

    private bool $decisionLoaded = false;

    public function withLatestDecision(?IdentityVerificationDecision $decision): self
    {
        $this->latestDecision = $decision;
        $this->decisionLoaded = true;

        return $this;
    }

    public function toArray(Request $request): array
    {
        return [
            'reservation_id' => $this->reservation_id,
            'hotel_id' => $this->hotel_id,
            'guest_id' => $this->guest_id,
            'status' => $this->status,
            'provider' => $this->provider,
            'attempts' => (int) ($this->attempts ?? 0),
            'latest_outcome' => $this->latest_outcome,
            'latest_score' => $this->latest_score,
            'decided_at' => $this->decided_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'latest_decision' => $this->when(
                $this->decisionLoaded && $this->latestDecision !== null,
                fn () => [
                    'type' => $this->latestDecision->type,
                    'result' => $this->latestDecision->result,
                    'band' => $this->latestDecision->band,
                    'reason' => $this->latestDecision->reason,
                    'decided_by_user_id' => $this->latestDecision->decided_by_user_id,
                    'decided_at' => $this->latestDecision->created_at,
                ],
            ),
        ];
    }
}
