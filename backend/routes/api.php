<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\HotelController;
use App\Http\Controllers\Api\V1\HotelGroupController;
use App\Http\Controllers\Api\V1\PermissionController;
use App\Http\Controllers\Api\V1\RoleController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);

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
    });
});
