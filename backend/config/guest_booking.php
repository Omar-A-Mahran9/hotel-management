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
    | Deposit amount rule — GENUINELY UNRESOLVED
    |--------------------------------------------------------------------------
    |
    | PaymentWorkflowService::initiateHold() requires an approved deposit
    | amount. There is no approved business rule for what a guest deposit is
    | (a flat amount? first night? a percentage of the stay total? nothing?).
    | No value is invented here — it stays null, and the guest
    | POST /payment/hold endpoint refuses with a machine-readable
    | `deposit_amount_rule_undefined` reason until a rule is approved. The
    | full reservation price is explicitly NOT used as a stand-in.
    |
    */

    'deposit' => [
        'rule' => env('GUEST_BOOKING_DEPOSIT_RULE'), // e.g. 'first_night' | 'flat' | 'percentage'
        'amount' => env('GUEST_BOOKING_DEPOSIT_AMOUNT'),
        'percentage' => env('GUEST_BOOKING_DEPOSIT_PERCENTAGE'),
    ],

];
