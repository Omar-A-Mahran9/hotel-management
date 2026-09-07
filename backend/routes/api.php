<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CheckInController;
use App\Http\Controllers\Api\V1\DigitalAccessController;
use App\Http\Controllers\Api\V1\HotelController;
use App\Http\Controllers\Api\V1\HotelGroupController;
use App\Http\Controllers\Api\V1\IdentityVerificationController;
use App\Http\Controllers\Api\V1\PaymentController;
use App\Http\Controllers\Api\V1\PaymentWebhookController;
use App\Http\Controllers\Api\V1\PermissionController;
use App\Http\Controllers\Api\V1\ReservationController;
use App\Http\Controllers\Api\V1\RoleController;
use App\Http\Controllers\Api\V1\RoomController;
use App\Http\Controllers\Api\V1\RoomTypeController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);

    // Provider webhook — machine-to-machine, unauthenticated: the HMAC
    // signature is the credential (Phase 5E). Rate limited per Phase 0 §17,
    // keyed by IP and set high for legitimate provider retries (Phase 5F).
    Route::post('/payments/webhooks/{provider}', [PaymentWebhookController::class, 'handle'])
        ->middleware('throttle:payments.webhook');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/auth/me', [AuthController::class, 'me']);

        Route::get('/roles', [RoleController::class, 'index']);
        Route::get('/permissions', [PermissionController::class, 'index']);

        Route::get('/hotel-groups', [HotelGroupController::class, 'index']);
        Route::post('/hotel-groups', [HotelGroupController::class, 'store']);
        Route::get('/hotel-groups/{hotel_group}', [HotelGroupController::class, 'show']);
        Route::put('/hotel-groups/{hotel_group}', [HotelGroupController::class, 'update']);

        Route::get('/hotels', [HotelController::class, 'index']);
        Route::post('/hotels', [HotelController::class, 'store']);
        Route::get('/hotels/{hotel}', [HotelController::class, 'show']);
        Route::put('/hotels/{hotel}', [HotelController::class, 'update']);

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
        });
    });
});
