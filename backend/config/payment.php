<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Active Payment Provider
    |--------------------------------------------------------------------------
    |
    | The provider PaymentGatewayInterface resolves to. Phase 5B registers
    | exactly one implementation — "dummy" — and an unknown value fails
    | loudly rather than falling back (see AppServiceProvider).
    |
    */

    'provider' => env('PAYMENT_PROVIDER', 'dummy'),

    /*
    |--------------------------------------------------------------------------
    | Settlement Currency
    |--------------------------------------------------------------------------
    |
    | Genuinely unresolved (Phase 0 §20 item 7 / Phase 5 plan C1). No
    | business currency is chosen here; it stays null until an approved
    | requirement sets one. Domain code must treat null as "not configured",
    | never substitute a default.
    |
    */

    'currency' => env('PAYMENT_CURRENCY'),

    /*
    |--------------------------------------------------------------------------
    | Per-Provider Configuration
    |--------------------------------------------------------------------------
    |
    | Only the dummy provider exists in this phase.
    |
    | - webhook_secret: the shared secret the dummy provider's HMAC-SHA256
    |   signature is computed with. Empty by default (no real credentials in
    |   this phase); signature verification fails closed while it is empty.
    | - default_directive: the deterministic outcome the dummy gateway uses
    |   when a caller does not supply an explicit SimulationDirective. Must
    |   be one of: success, pending, failure, cancelled, expired.
    |
    */

    'providers' => [

        'dummy' => [
            'webhook_secret' => env('PAYMENT_DUMMY_WEBHOOK_SECRET', ''),
            'default_directive' => env('PAYMENT_DUMMY_DEFAULT_DIRECTIVE', 'success'),
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Rate Limits (Phase 0 §17, wired in Phase 5F)
    |--------------------------------------------------------------------------
    |
    | Per-minute request ceilings for the payment endpoints, registered as
    | the named limiters `payments.hold` / `payments.webhook` in
    | AppServiceProvider and applied by the route `throttle:` middleware.
    |
    | - hold: keyed by authenticated user id (IP fallback). Conservative —
    |   a staff member never legitimately fires this many holds a minute.
    | - webhook: keyed by client IP and deliberately high so a provider's
    |   legitimate retry storm across many reservations is never throttled.
    |
    */

    'rate_limits' => [
        'hold' => [
            'per_minute' => (int) env('PAYMENT_HOLD_RATE_LIMIT', 30),
        ],
        'webhook' => [
            'per_minute' => (int) env('PAYMENT_WEBHOOK_RATE_LIMIT', 300),
        ],
    ],

];
