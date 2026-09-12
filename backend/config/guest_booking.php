<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Guest booking API
    |--------------------------------------------------------------------------
    |
    | The authenticated guest surface for the booking funnel
    | (/api/v1/guest/reservations, /api/v1/guest/reservations/{id}/payment).
    | These endpoints reuse the shared ReservationService /
    | PaymentWorkflowService — nothing here is a business rule, only
    | transport concerns (pagination, rate limiting).
    |
    */

    'pagination' => [
        'per_page' => (int) env('GUEST_BOOKING_PER_PAGE', 15),
        'max_per_page' => (int) env('GUEST_BOOKING_MAX_PER_PAGE', 50),
    ],

    'rate_limits' => [
        'write' => [
            'per_minute' => (int) env('GUEST_BOOKING_WRITE_RATE_LIMIT', 20),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Deposit amount rule
    |--------------------------------------------------------------------------
    |
    | PaymentWorkflowService::initiateHold() requires an approved deposit
    | amount. The approved rule is "percentage": the hold is a percentage of
    | the reservation's `price_snapshot`. GuestPaymentController resolves the
    | amount from this config only — it never invents or hardcodes a figure.
    |
    | The 20% default below is a placeholder so the endpoint is functional;
    | the exact percentage still needs explicit product/business sign-off
    | before this goes to production. Set GUEST_BOOKING_DEPOSIT_RULE=null (or
    | unset it) to fall back to the previous behaviour — the endpoint refuses
    | with a machine-readable `deposit_amount_rule_undefined` reason.
    |
    */

    'deposit' => [
        'rule' => env('GUEST_BOOKING_DEPOSIT_RULE', 'percentage'), // 'percentage' | null
        'amount' => env('GUEST_BOOKING_DEPOSIT_AMOUNT'), // unused by the 'percentage' rule; reserved for a future 'flat' rule
        'percentage' => env('GUEST_BOOKING_DEPOSIT_PERCENTAGE', 20), // % of price_snapshot — PLACEHOLDER pending business sign-off
    ],

];
