<?php

return [
    'login_success' => 'Logged in successfully.',
    'logout_success' => 'Logged out successfully.',
    'created' => 'Created successfully.',
    'updated' => 'Updated successfully.',
    'deleted' => 'Deleted successfully.',
    'unauthenticated' => 'Unauthenticated.',
    'forbidden' => 'This action is unauthorized.',
    'not_found' => 'The requested resource was not found.',
    'validation_failed' => 'The given data was invalid.',
    'invalid_credentials' => 'The provided credentials are incorrect.',
    'account_inactive' => 'This account has been deactivated.',
    'server_error' => 'Something went wrong. Please try again later.',

    'payment' => [
        'hold_placed' => 'The deposit hold was placed successfully.',
        'hold_pending' => 'The deposit hold is awaiting confirmation from the payment provider.',
        'hold_failed' => 'The payment hold was declined by the provider.',
        'hold_cancelled' => 'The payment hold was cancelled by the provider.',
        'hold_expired' => 'The payment hold expired before it could be confirmed.',
        'hold_state' => 'The current payment state is returned.',

        'webhook_processed' => 'The webhook was processed.',
        'webhook_duplicate_ignored' => 'The webhook was a duplicate and was ignored.',
        'webhook_unmatched' => 'The webhook was received but no matching payment was found.',
        'webhook_invalid_signature' => 'The webhook signature is invalid.',
        'webhook_malformed' => 'The webhook payload could not be processed.',
    ],
];
