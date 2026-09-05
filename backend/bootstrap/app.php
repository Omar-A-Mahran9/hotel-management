<?php

use App\Domain\IdentityAccess\Exceptions\AccountInactiveException;
use App\Domain\IdentityAccess\Exceptions\InvalidCredentialsException;
use App\Http\Middleware\ForceJsonResponse;
use App\Http\Middleware\SetLocale;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->api(prepend: [
            ForceJsonResponse::class,
            SetLocale::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $envelope = function (string $message, int $status, mixed $errors = null): JsonResponse {
            $payload = ['success' => false, 'message' => $message];

            if ($errors !== null) {
                $payload['errors'] = $errors;
            }

            return response()->json($payload, $status);
        };

        $exceptions->renderable(function (ValidationException $e, Request $request) use ($envelope) {
            if ($request->is('api/*')) {
                return $envelope(__('api.validation_failed'), 422, $e->errors());
            }
        });

        $exceptions->renderable(function (AuthenticationException $e, Request $request) use ($envelope) {
            if ($request->is('api/*')) {
                return $envelope(__('api.unauthenticated'), 401);
            }
        });

        $exceptions->renderable(function (AuthorizationException $e, Request $request) use ($envelope) {
            if ($request->is('api/*')) {
                return $envelope(__('api.forbidden'), 403);
            }
        });

        $exceptions->renderable(function (ModelNotFoundException $e, Request $request) use ($envelope) {
            if ($request->is('api/*')) {
                return $envelope(__('api.not_found'), 404);
            }
        });

        $exceptions->renderable(function (InvalidCredentialsException $e, Request $request) use ($envelope) {
            if ($request->is('api/*')) {
                return $envelope(__('api.invalid_credentials'), 401);
            }
        });

        $exceptions->renderable(function (AccountInactiveException $e, Request $request) use ($envelope) {
            if ($request->is('api/*')) {
                return $envelope(__('api.account_inactive'), 403);
            }
        });

        $exceptions->renderable(function (HttpExceptionInterface $e, Request $request) use ($envelope) {
            if ($request->is('api/*')) {
                return $envelope($e->getMessage() ?: __('api.not_found'), $e->getStatusCode());
            }
        });

        $exceptions->renderable(function (Throwable $e, Request $request) use ($envelope) {
            if (! $request->is('api/*')) {
                return null;
            }

            if (app()->hasDebugModeEnabled()) {
                return response()->json([
                    'success' => false,
                    'message' => $e->getMessage() ?: __('api.server_error'),
                    'exception' => get_class($e),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                ], 500);
            }

            return $envelope(__('api.server_error'), 500);
        });
    })->create();
