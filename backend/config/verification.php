<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Active Identity Verification Provider
    |--------------------------------------------------------------------------
    |
    | The provider IdentityVerificationProviderInterface resolves to. Phase 6
    | registers exactly one implementation — "dummy" — and an unknown value
    | fails loudly rather than falling back (see AppServiceProvider), mirroring
    | the Phase 5 payment gateway binding.
    |
    */

    'provider' => env('IDENTITY_PROVIDER', 'dummy'),

    /*
    |--------------------------------------------------------------------------
    | Confidence Thresholds (Phase 0 §10, R57 — GENUINELY UNRESOLVED)
    |--------------------------------------------------------------------------
    |
    | Phase 0 §20 item 2: "Verification confidence threshold numeric values
    | ... actual default numbers are not [confirmed]". No number is invented
    | here. Both values stay null until an approved requirement sets them.
    |
    | Score scale is a provider-normalized integer 0..100 (technical
    | decision — the interface normalizes whatever a real provider returns
    | into this range).
    |
    | - auto_approve:  score >= this  -> AUTO_APPROVED. When null, the domain
    |   CANNOT classify a match and fails safe to PENDING_MANUAL_REVIEW
    |   (never auto-approve, never auto-reject) — Phase 0 §10 "manual review
    |   is always reachable".
    | - manual_review: only distinguishes the MEDIUM band from the LOW band
    |   for audit/reporting. Both bands route to PENDING_MANUAL_REVIEW, so a
    |   null here never changes the workflow outcome.
    |
    */

    'thresholds' => [
        'auto_approve' => env('IDENTITY_VERIFICATION_AUTO_APPROVE_THRESHOLD'),
        'manual_review' => env('IDENTITY_VERIFICATION_MANUAL_REVIEW_THRESHOLD'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Retry Limit (Phase 0 §10, R57 — GENUINELY UNRESOLVED)
    |--------------------------------------------------------------------------
    |
    | Phase 0 §20 item 3: "Verification retry-count numeric limit (confirmed
    | configurable; number not specified)". No number is invented.
    |
    | Interpreted as the maximum number of RETRY attempts allowed beyond the
    | initial attempt. When null the domain does not assume a number: a
    | RETRY_ALLOWED session is routed to PENDING_MANUAL_REVIEW (still
    | human-resolvable) rather than guessing a limit.
    |
    */

    'max_retries' => env('IDENTITY_VERIFICATION_MAX_RETRIES'),

    /*
    |--------------------------------------------------------------------------
    | Identity Data Retention (Phase 0 §17, R58 — GENUINELY UNRESOLVED)
    |--------------------------------------------------------------------------
    |
    | Phase 0 §20 item 5 / §17: "a scheduled cleanup job reads a
    | retention-period config value (currently unset/placeholder)". The value
    | stays null; no purge job is scheduled in Phase 6 (deferred — see the
    | Phase 6 report). Domain code must treat null as "not configured".
    |
    */

    'retention_days' => env('IDENTITY_VERIFICATION_RETENTION_DAYS'),

    /*
    |--------------------------------------------------------------------------
    | Per-Provider Configuration
    |--------------------------------------------------------------------------
    |
    | Only the dummy provider exists in this phase. No secrets, no endpoints —
    | the approved Phase 6 workflow has no verification callback/webhook
    | (Phase 0 §16 lists no identity-verification webhook route), so the
    | provider needs no signing secret.
    |
    | - default_directive: the deterministic outcome the dummy provider uses
    |   when a caller supplies no explicit simulation directive. One of:
    |   high_match, medium_match, low_match, error.
    |
    */

    'providers' => [

        'dummy' => [
            'default_directive' => env('IDENTITY_DUMMY_DEFAULT_DIRECTIVE', 'high_match'),
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Secure Identity Document Storage (Phase 0 §17, R38-R42)
    |--------------------------------------------------------------------------
    |
    | ID documents and live selfies are PII. They are written to a PRIVATE
    | disk only — never the "public" disk, never a public path. The approved
    | Phase 6 endpoint map (§16) has no document-download route, so the files
    | are write-only this phase: stored privately, referenced by the domain,
    | never served back.
    |
    */

    'storage' => [
        'disk' => env('IDENTITY_VERIFICATION_DISK', 'local'),
        'max_file_kb' => (int) env('IDENTITY_VERIFICATION_MAX_FILE_KB', 8192),
    ],

    /*
    |--------------------------------------------------------------------------
    | Rate Limits (Phase 0 §17 — "rate limiting on ... verification-upload")
    |--------------------------------------------------------------------------
    |
    | Per-minute ceiling for the verification-upload endpoints (documents /
    | selfie), registered as the named limiter `identity-verification.submit`
    | in AppServiceProvider and applied by the route `throttle:` middleware.
    | Keyed by authenticated user id (IP fallback).
    |
    */

    'rate_limits' => [
        'submit' => [
            'per_minute' => (int) env('IDENTITY_VERIFICATION_SUBMIT_RATE_LIMIT', 20),
        ],
    ],

];
