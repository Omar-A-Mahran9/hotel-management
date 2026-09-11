<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CheckInController;
use App\Http\Controllers\Api\V1\CheckoutController;
use App\Http\Controllers\Api\V1\CityController;
use App\Http\Controllers\Api\V1\CountryController;
use App\Http\Controllers\Api\V1\DigitalAccessController;
use App\Http\Controllers\Api\V1\FacilityController;
use App\Http\Controllers\Api\V1\FolioController;
use App\Http\Controllers\Api\V1\Guest\GuestAuthController;
use App\Http\Controllers\Api\V1\Guest\GuestDiscoveryController;
use App\Http\Controllers\Api\V1\Guest\GuestPaymentController;
use App\Http\Controllers\Api\V1\Guest\GuestReservationController;
use App\Http\Controllers\Api\V1\HotelController;
use App\Http\Controllers\Api\V1\HotelGroupController;
use App\Http\Controllers\Api\V1\HotelMediaController;
use App\Http\Controllers\Api\V1\IdentityVerificationController;
use App\Http\Controllers\Api\V1\InvoiceController;
use App\Http\Controllers\Api\V1\LoyaltyController;
use App\Http\Controllers\Api\V1\LoyaltyRuleController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\PaymentController;
use App\Http\Controllers\Api\V1\PaymentWebhookController;
use App\Http\Controllers\Api\V1\PermissionController;
use App\Http\Controllers\Api\V1\ReservationController;
use App\Http\Controllers\Api\V1\RoleController;
use App\Http\Controllers\Api\V1\RoomController;
use App\Http\Controllers\Api\V1\RoomTypeController;
use App\Http\Controllers\Api\V1\ServiceCategoryController;
use App\Http\Controllers\Api\V1\ServiceController;
use App\Http\Controllers\Api\V1\ServiceOrderController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);

    /*
     * Slice 0 — Guest authentication (phone + OTP). Separate Sanctum guard
     * (`auth:guest`, provider `guests`) from the staff surface. OTP endpoints
     * are unauthenticated (the code is the credential) and rate limited per
     * Phase 0 §17. Wrong-code / lock-out are 200 outcomes, not errors.
     */
    Route::prefix('guest')->group(function () {
        Route::prefix('auth')->group(function () {
            Route::post('/otp/request', [GuestAuthController::class, 'requestOtp'])
                ->middleware('throttle:guest.otp.request');
            Route::post('/otp/resend', [GuestAuthController::class, 'resendOtp'])
                ->middleware('throttle:guest.otp.request');
            Route::post('/otp/verify', [GuestAuthController::class, 'verifyOtp'])
                ->middleware('throttle:guest.otp.verify');

            Route::middleware('auth:guest')->group(function () {
                Route::get('/me', [GuestAuthController::class, 'me']);
                Route::post('/logout', [GuestAuthController::class, 'logout']);
            });
        });

        Route::middleware('auth:guest')->group(function () {
            Route::match(['put', 'patch'], '/profile', [GuestAuthController::class, 'updateProfile']);

            /*
             * Booking funnel — the guest's own reservations + the read view
             * of their deposit payment. Dedicated guest controllers/resources
             * that reuse the shared ReservationService / PaymentWorkflowService
             * (no business logic here). Every row is scoped to the token
             * guest's ownership: a non-owned or missing id is an identical
             * plain 404. Writes are rate limited (guest.booking.write).
             *
             * POST /reservations/{id}/payment/hold is registered for contract
             * completeness but currently refuses (no approved deposit-amount
             * rule — see GuestPaymentController).
             */
            Route::get('/reservations', [GuestReservationController::class, 'index']);
            Route::post('/reservations', [GuestReservationController::class, 'store'])
                ->middleware('throttle:guest.booking.write');
            Route::get('/reservations/{reservation}', [GuestReservationController::class, 'show'])
                ->whereNumber('reservation');
            Route::post('/reservations/{reservation}/cancel', [GuestReservationController::class, 'cancel'])
                ->whereNumber('reservation')
                ->middleware('throttle:guest.booking.write');

            Route::get('/reservations/{reservation}/payment', [GuestPaymentController::class, 'show'])
                ->whereNumber('reservation');
            Route::post('/reservations/{reservation}/payment/hold', [GuestPaymentController::class, 'hold'])
                ->whereNumber('reservation')
                ->middleware('throttle:guest.booking.write');
        });

        /*
         * Slice 1 — anonymous discovery. Active hotels / active room types
         * only; no caller identity, so no hotel scope. Availability reuses
         * ReservationService's overlap math as a non-locking preview.
         */
        Route::get('/hotels', [GuestDiscoveryController::class, 'hotels']);
        Route::get('/hotels/cities', [GuestDiscoveryController::class, 'cities']);
        Route::get('/hotels/{hotel}', [GuestDiscoveryController::class, 'show'])->whereNumber('hotel');
        Route::get('/hotels/{hotel}/availability', [GuestDiscoveryController::class, 'availability'])->whereNumber('hotel');
    });

    // Provider webhook — machine-to-machine, unauthenticated: the HMAC
    // signature is the credential (Phase 5E). Rate limited per Phase 0 §17,
    // keyed by IP and set high for legitimate provider retries (Phase 5F).
    Route::post('/payments/webhooks/{provider}', [PaymentWebhookController::class, 'handle'])
        ->middleware('throttle:payments.webhook');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/auth/me', [AuthController::class, 'me']);

        Route::get('/roles', [RoleController::class, 'index']);
        Route::post('/roles', [RoleController::class, 'store']);
        Route::get('/roles/{role}', [RoleController::class, 'show']);
        Route::match(['put', 'patch'], '/roles/{role}', [RoleController::class, 'update']);
        Route::delete('/roles/{role}', [RoleController::class, 'destroy']);

        Route::get('/permissions', [PermissionController::class, 'index']);

        Route::get('/hotel-groups', [HotelGroupController::class, 'index']);
        Route::post('/hotel-groups', [HotelGroupController::class, 'store']);
        Route::get('/hotel-groups/{hotel_group}', [HotelGroupController::class, 'show']);
        Route::put('/hotel-groups/{hotel_group}', [HotelGroupController::class, 'update']);

        // Phase 10 — Loyalty rule configuration (Phase 0 §7/§13). Group
        // Owner only; the rule is created inactive/unconfigured on first read.
        Route::get('/hotel-groups/{hotel_group}/loyalty-rule', [LoyaltyRuleController::class, 'show']);
        Route::match(['put', 'patch'], '/hotel-groups/{hotel_group}/loyalty-rule', [LoyaltyRuleController::class, 'update']);

        Route::get('/hotels', [HotelController::class, 'index']);
        Route::post('/hotels', [HotelController::class, 'store']);
        Route::get('/hotels/{hotel}', [HotelController::class, 'show']);
        Route::put('/hotels/{hotel}', [HotelController::class, 'update']);

        /*
         * Facility catalog — global reference data (NOT hotel-scoped),
         * mirrors the Country/City pattern. facilities.view for read,
         * facilities.manage for every write. `GET /facilities?all=1`
         * returns every active facility unpaginated for the Hotel
         * create/edit picker.
         */
        Route::get('/facilities', [FacilityController::class, 'index']);
        Route::post('/facilities', [FacilityController::class, 'store']);
        Route::get('/facilities/{facility}', [FacilityController::class, 'show'])->whereNumber('facility');
        Route::match(['put', 'patch'], '/facilities/{facility}', [FacilityController::class, 'update'])->whereNumber('facility');
        Route::delete('/facilities/{facility}', [FacilityController::class, 'destroy'])->whereNumber('facility');
        Route::patch('/facilities/{facility}/activate', [FacilityController::class, 'activate'])->whereNumber('facility');
        Route::patch('/facilities/{facility}/deactivate', [FacilityController::class, 'deactivate'])->whereNumber('facility');

        /*
         * Country + City master data (global reference data — NOT
         * hotel-scoped). Permission-driven: locations.view for read,
         * locations.manage for every write. `/countries/{country}/cities`
         * powers the dependent Country -> City select in the dashboard.
         */
        Route::get('/countries', [CountryController::class, 'index']);
        Route::post('/countries', [CountryController::class, 'store']);
        Route::get('/countries/{country}', [CountryController::class, 'show'])->whereNumber('country');
        Route::match(['put', 'patch'], '/countries/{country}', [CountryController::class, 'update'])->whereNumber('country');
        Route::delete('/countries/{country}', [CountryController::class, 'destroy'])->whereNumber('country');
        Route::patch('/countries/{country}/activate', [CountryController::class, 'activate'])->whereNumber('country');
        Route::patch('/countries/{country}/deactivate', [CountryController::class, 'deactivate'])->whereNumber('country');
        Route::get('/countries/{country}/cities', [CityController::class, 'forCountry'])->whereNumber('country');

        Route::get('/cities', [CityController::class, 'index']);
        Route::post('/cities', [CityController::class, 'store']);
        Route::get('/cities/{city}', [CityController::class, 'show'])->whereNumber('city');
        Route::match(['put', 'patch'], '/cities/{city}', [CityController::class, 'update'])->whereNumber('city');
        Route::delete('/cities/{city}', [CityController::class, 'destroy'])->whereNumber('city');
        Route::patch('/cities/{city}/activate', [CityController::class, 'activate'])->whereNumber('city');
        Route::patch('/cities/{city}/deactivate', [CityController::class, 'deactivate'])->whereNumber('city');

        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{user}', [UserController::class, 'show']);
        Route::put('/users/{user}', [UserController::class, 'update']);
        Route::delete('/users/{user}', [UserController::class, 'destroy']);

        Route::get('/reservations', [ReservationController::class, 'index']);
        Route::post('/reservations', [ReservationController::class, 'store']);
        Route::get('/reservations/{reservation}', [ReservationController::class, 'show']);
        Route::post('/reservations/{reservation}/transition', [ReservationController::class, 'transition']);
        Route::post('/reservations/{reservation}/payment/hold', [PaymentController::class, 'hold'])
            ->middleware('throttle:payments.hold');

        // Phase 8 — Stay Services + Folio (Phase 0 §16). {reservation} is an
        // int id resolved through ReservationService (not route-model
        // binding), so a cross-hotel or missing id is an identical plain
        // 404. Service orders accrue folio charges; the folio is read-only.
        Route::prefix('/reservations/{reservation}')->group(function () {
            Route::get('/service-orders', [ServiceOrderController::class, 'index']);
            Route::post('/service-orders', [ServiceOrderController::class, 'store']);
            Route::get('/service-orders/{serviceOrder}', [ServiceOrderController::class, 'show']);
            Route::post('/service-orders/{serviceOrder}/transition', [ServiceOrderController::class, 'transition']);

            Route::get('/folio', [FolioController::class, 'show']);

            // Phase 9 — Checkout + Final Settlement + Invoice (Phase 0 §12/§16).
            // {reservation} is an int id resolved through ReservationService,
            // so a cross-hotel or missing id is an identical plain 404.
            // Checkout is financially sensitive — rate limited like the
            // payment endpoints (Phase 0 §17). `Idempotency-Key` header.
            Route::post('/checkout', [CheckoutController::class, 'store'])
                ->middleware('throttle:checkout.perform');

            Route::get('/invoice', [InvoiceController::class, 'show']);

            // Phase 10 — Loyalty (Phase 0 §13/§16). Reservation-scoped so
            // hotel scope + guest identity are resolved server-side (no guest
            // auth in the MVP). `earn` accrues for a completed booking;
            // `redeem` spends against an eligible (non-terminal) booking.
            Route::get('/loyalty', [LoyaltyController::class, 'show']);
            Route::get('/loyalty/transactions', [LoyaltyController::class, 'transactions']);
            Route::post('/loyalty/earn', [LoyaltyController::class, 'earn']);
            Route::post('/loyalty/redeem', [LoyaltyController::class, 'redeem']);

            // Phase 11 — Notifications (Phase 0 §4/§15/§16). Reservation-scoped
            // so hotel scope + the guest recipient are resolved server-side
            // (no guest auth in the MVP). Read-only feed of the `in_app`
            // channel plus its unread markers; notifications are produced by
            // the approved Reservation lifecycle, never created over HTTP.
            // Rate limited per Phase 0 §17.
            Route::middleware('throttle:notifications.read')->group(function () {
                Route::get('/notifications', [NotificationController::class, 'index']);
                Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
                Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);
            });
        });

        // Phase 6 — Identity Verification (Phase 0 §16). {reservation} is an
        // int id resolved through ReservationService (not route-model
        // binding), so a cross-hotel or missing id is an identical plain
        // 404. The upload endpoints are rate limited per Phase 0 §17.
        Route::prefix('/identity-verification/{reservation}')->group(function () {
            Route::post('/documents', [IdentityVerificationController::class, 'documents'])
                ->middleware('throttle:identity-verification.submit');
            Route::post('/selfie', [IdentityVerificationController::class, 'selfie'])
                ->middleware('throttle:identity-verification.submit');
            Route::get('/status', [IdentityVerificationController::class, 'status']);
            Route::post('/review', [IdentityVerificationController::class, 'review']);
        });

        // Phase 7 — Check-in + Digital Access (Phase 0 §16). {reservation} is
        // an int id resolved through ReservationService (not route-model
        // binding), so a cross-hotel or missing id is an identical plain
        // 404. Check-in issues the digital access credential and, on success,
        // drives VERIFIED -> CHECKED_IN via ReservationService.
        Route::post('/check-in/{reservation}', [CheckInController::class, 'store'])
            ->middleware('throttle:check-in');

        Route::get('/access/{reservation}', [DigitalAccessController::class, 'show']);
        Route::post('/access/{reservation}/revoke', [DigitalAccessController::class, 'revoke'])
            ->middleware('throttle:digital-access.revoke');

        Route::prefix('/hotels/{hotel}')->group(function () {
            // Hotel media (logo / cover / gallery). Staff-only —
            // `hotels.manage` + hotel scope (HotelPolicy::manageMedia). The
            // guest app never calls these; it reads the resolved URLs off
            // the public hotel resource. `reorder` is declared before the
            // `{media}` param route so it is not shadowed.
            Route::patch('/media/reorder', [HotelMediaController::class, 'reorder']);
            Route::post('/media', [HotelMediaController::class, 'store'])
                ->middleware('throttle:hotel-media.upload');
            Route::delete('/media/{media}', [HotelMediaController::class, 'destroy'])
                ->whereNumber('media');

            Route::get('/room-types', [RoomTypeController::class, 'index']);
            Route::post('/room-types', [RoomTypeController::class, 'store']);
            Route::get('/room-types/{roomType}', [RoomTypeController::class, 'show']);
            Route::match(['put', 'patch'], '/room-types/{roomType}', [RoomTypeController::class, 'update']);
            Route::patch('/room-types/{roomType}/activate', [RoomTypeController::class, 'activate']);
            Route::patch('/room-types/{roomType}/deactivate', [RoomTypeController::class, 'deactivate']);

            Route::get('/rooms', [RoomController::class, 'index']);
            Route::post('/rooms', [RoomController::class, 'store']);
            Route::get('/rooms/{room}', [RoomController::class, 'show']);
            Route::match(['put', 'patch'], '/rooms/{room}', [RoomController::class, 'update']);
            Route::patch('/rooms/{room}/status', [RoomController::class, 'updateStatus']);

            // Phase 8 — hotel service catalog (Phase 0 §16). Categories are
            // an optional grouping; services carry the price. No delete —
            // deactivation preserves historical references.
            Route::get('/service-categories', [ServiceCategoryController::class, 'index']);
            Route::post('/service-categories', [ServiceCategoryController::class, 'store']);
            Route::match(['put', 'patch'], '/service-categories/{serviceCategory}', [ServiceCategoryController::class, 'update']);
            Route::patch('/service-categories/{serviceCategory}/activate', [ServiceCategoryController::class, 'activate']);
            Route::patch('/service-categories/{serviceCategory}/deactivate', [ServiceCategoryController::class, 'deactivate']);

            Route::get('/services', [ServiceController::class, 'index']);
            Route::post('/services', [ServiceController::class, 'store']);
            Route::get('/services/{service}', [ServiceController::class, 'show']);
            Route::match(['put', 'patch'], '/services/{service}', [ServiceController::class, 'update']);
            Route::patch('/services/{service}/activate', [ServiceController::class, 'activate']);
            Route::patch('/services/{service}/deactivate', [ServiceController::class, 'deactivate']);
        });
    });
});
