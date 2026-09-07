<?php

namespace App\Providers;

use App\Domain\DigitalAccess\Models\AccessGrant;
use App\Domain\DigitalAccess\Policies\AccessGrantPolicy;
use App\Domain\DigitalAccess\Provider\Contracts\DigitalAccessProviderInterface;
use App\Domain\DigitalAccess\Provider\DummyDigitalAccessProvider;
use App\Domain\DigitalAccess\Provider\Exceptions\UnsupportedDigitalAccessProviderException;
use App\Domain\DigitalAccess\Provider\SimulationDirective as DigitalAccessSimulationDirective;
use App\Domain\DigitalAccess\Repositories\Contracts\AccessGrantRepositoryInterface;
use App\Domain\DigitalAccess\Repositories\EloquentAccessGrantRepository;
use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\HotelGroup\Models\HotelGroup;
use App\Domain\HotelGroup\Policies\HotelGroupPolicy;
use App\Domain\HotelGroup\Policies\HotelPolicy;
use App\Domain\HotelGroup\Repositories\Contracts\HotelGroupRepositoryInterface;
use App\Domain\HotelGroup\Repositories\Contracts\HotelRepositoryInterface;
use App\Domain\HotelGroup\Repositories\EloquentHotelGroupRepository;
use App\Domain\HotelGroup\Repositories\EloquentHotelRepository;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\IdentityAccess\Policies\UserPolicy;
use App\Domain\IdentityAccess\Repositories\Contracts\PermissionRepositoryInterface;
use App\Domain\IdentityAccess\Repositories\Contracts\RoleRepositoryInterface;
use App\Domain\IdentityAccess\Repositories\Contracts\UserRepositoryInterface;
use App\Domain\IdentityAccess\Repositories\EloquentPermissionRepository;
use App\Domain\IdentityAccess\Repositories\EloquentRoleRepository;
use App\Domain\IdentityAccess\Repositories\EloquentUserRepository;
use App\Domain\IdentityVerification\Models\IdentityVerificationSession;
use App\Domain\IdentityVerification\Policies\IdentityVerificationPolicy;
use App\Domain\IdentityVerification\Provider\Contracts\IdentityVerificationProviderInterface;
use App\Domain\IdentityVerification\Provider\DummyIdentityVerificationProvider;
use App\Domain\IdentityVerification\Provider\Exceptions\UnsupportedIdentityVerificationProviderException;
use App\Domain\IdentityVerification\Provider\SimulationDirective as IdentityVerificationSimulationDirective;
use App\Domain\IdentityVerification\Repositories\Contracts\IdentityVerificationAttemptRepositoryInterface;
use App\Domain\IdentityVerification\Repositories\Contracts\IdentityVerificationDecisionRepositoryInterface;
use App\Domain\IdentityVerification\Repositories\Contracts\IdentityVerificationSessionRepositoryInterface;
use App\Domain\IdentityVerification\Repositories\EloquentIdentityVerificationAttemptRepository;
use App\Domain\IdentityVerification\Repositories\EloquentIdentityVerificationDecisionRepository;
use App\Domain\IdentityVerification\Repositories\EloquentIdentityVerificationSessionRepository;
use App\Domain\Inventory\Models\Room;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Inventory\Policies\RoomPolicy;
use App\Domain\Inventory\Policies\RoomTypePolicy;
use App\Domain\Inventory\Repositories\Contracts\RoomRepositoryInterface;
use App\Domain\Inventory\Repositories\Contracts\RoomTypeRepositoryInterface;
use App\Domain\Inventory\Repositories\EloquentRoomRepository;
use App\Domain\Inventory\Repositories\EloquentRoomTypeRepository;
use App\Domain\Payment\Gateway\Contracts\PaymentGatewayInterface;
use App\Domain\Payment\Gateway\DummyPaymentGateway;
use App\Domain\Payment\Gateway\Exceptions\UnsupportedPaymentProviderException;
use App\Domain\Payment\Gateway\SimulationDirective;
use App\Domain\Payment\Models\Payment;
use App\Domain\Payment\Policies\PaymentPolicy;
use App\Domain\Payment\Repositories\Contracts\PaymentRepositoryInterface;
use App\Domain\Payment\Repositories\Contracts\PaymentTransactionRepositoryInterface;
use App\Domain\Payment\Repositories\Contracts\PaymentWebhookEventRepositoryInterface;
use App\Domain\Payment\Repositories\EloquentPaymentRepository;
use App\Domain\Payment\Repositories\EloquentPaymentTransactionRepository;
use App\Domain\Payment\Repositories\EloquentPaymentWebhookEventRepository;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Reservation\Policies\ReservationPolicy;
use App\Domain\Reservation\Repositories\Contracts\GuestRepositoryInterface;
use App\Domain\Reservation\Repositories\Contracts\ReservationRepositoryInterface;
use App\Domain\Reservation\Repositories\EloquentGuestRepository;
use App\Domain\Reservation\Repositories\EloquentReservationRepository;
use App\Domain\StayServices\Models\HotelService;
use App\Domain\StayServices\Models\ServiceCategory;
use App\Domain\StayServices\Models\ServiceOrder;
use App\Domain\StayServices\Policies\FolioPolicy;
use App\Domain\StayServices\Policies\HotelServicePolicy;
use App\Domain\StayServices\Policies\ServiceCategoryPolicy;
use App\Domain\StayServices\Policies\ServiceOrderPolicy;
use App\Domain\StayServices\Repositories\Contracts\FolioChargeRepositoryInterface;
use App\Domain\StayServices\Repositories\Contracts\HotelServiceRepositoryInterface;
use App\Domain\StayServices\Repositories\Contracts\ServiceCategoryRepositoryInterface;
use App\Domain\StayServices\Repositories\Contracts\ServiceOrderRepositoryInterface;
use App\Domain\StayServices\Repositories\EloquentFolioChargeRepository;
use App\Domain\StayServices\Repositories\EloquentHotelServiceRepository;
use App\Domain\StayServices\Repositories\EloquentServiceCategoryRepository;
use App\Domain\StayServices\Repositories\EloquentServiceOrderRepository;
use App\Domain\StayServices\Services\Folio;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * @var array<class-string, class-string>
     */
    public array $bindings = [
        UserRepositoryInterface::class => EloquentUserRepository::class,
        RoleRepositoryInterface::class => EloquentRoleRepository::class,
        PermissionRepositoryInterface::class => EloquentPermissionRepository::class,
        HotelGroupRepositoryInterface::class => EloquentHotelGroupRepository::class,
        HotelRepositoryInterface::class => EloquentHotelRepository::class,
        RoomTypeRepositoryInterface::class => EloquentRoomTypeRepository::class,
        RoomRepositoryInterface::class => EloquentRoomRepository::class,
        ReservationRepositoryInterface::class => EloquentReservationRepository::class,
        GuestRepositoryInterface::class => EloquentGuestRepository::class,
        PaymentRepositoryInterface::class => EloquentPaymentRepository::class,
        PaymentTransactionRepositoryInterface::class => EloquentPaymentTransactionRepository::class,
        PaymentWebhookEventRepositoryInterface::class => EloquentPaymentWebhookEventRepository::class,
        IdentityVerificationSessionRepositoryInterface::class => EloquentIdentityVerificationSessionRepository::class,
        IdentityVerificationAttemptRepositoryInterface::class => EloquentIdentityVerificationAttemptRepository::class,
        IdentityVerificationDecisionRepositoryInterface::class => EloquentIdentityVerificationDecisionRepository::class,
        AccessGrantRepositoryInterface::class => EloquentAccessGrantRepository::class,
        ServiceCategoryRepositoryInterface::class => EloquentServiceCategoryRepository::class,
        HotelServiceRepositoryInterface::class => EloquentHotelServiceRepository::class,
        ServiceOrderRepositoryInterface::class => EloquentServiceOrderRepository::class,
        FolioChargeRepositoryInterface::class => EloquentFolioChargeRepository::class,
    ];

    /**
     * @var array<class-string, class-string>
     */
    public array $policies = [
        HotelGroup::class => HotelGroupPolicy::class,
        Hotel::class => HotelPolicy::class,
        User::class => UserPolicy::class,
        RoomType::class => RoomTypePolicy::class,
        Room::class => RoomPolicy::class,
        Reservation::class => ReservationPolicy::class,
        Payment::class => PaymentPolicy::class,
        IdentityVerificationSession::class => IdentityVerificationPolicy::class,
        AccessGrant::class => AccessGrantPolicy::class,
        ServiceCategory::class => ServiceCategoryPolicy::class,
        HotelService::class => HotelServicePolicy::class,
        ServiceOrder::class => ServiceOrderPolicy::class,
        Folio::class => FolioPolicy::class,
    ];

    public function register(): void
    {
        // The payment provider boundary (Phase 5B). The rest of the app
        // depends only on PaymentGatewayInterface; the concrete provider is
        // chosen from config('payment.provider'). "dummy" is the only
        // implementation registered this phase — an explicitly configured
        // but unsupported provider fails loudly, never silently falls back.
        $this->app->singleton(PaymentGatewayInterface::class, function (): PaymentGatewayInterface {
            $provider = (string) config('payment.provider');

            return match ($provider) {
                'dummy' => new DummyPaymentGateway(
                    webhookSecret: (string) config('payment.providers.dummy.webhook_secret', ''),
                    defaultDirective: SimulationDirective::fromConfig(
                        config('payment.providers.dummy.default_directive'),
                    ),
                ),
                default => throw new UnsupportedPaymentProviderException($provider),
            };
        });

        // The identity verification provider boundary (Phase 6). The rest of
        // the app depends only on IdentityVerificationProviderInterface; the
        // concrete provider is chosen from config('verification.provider').
        // "dummy" is the only implementation registered this phase — an
        // explicitly configured but unsupported provider fails loudly, never
        // silently falls back.
        $this->app->singleton(IdentityVerificationProviderInterface::class, function (): IdentityVerificationProviderInterface {
            $provider = (string) config('verification.provider');

            return match ($provider) {
                'dummy' => new DummyIdentityVerificationProvider(
                    defaultDirective: IdentityVerificationSimulationDirective::fromConfig(
                        config('verification.providers.dummy.default_directive'),
                    ),
                ),
                default => throw new UnsupportedIdentityVerificationProviderException($provider),
            };
        });

        // The digital access provider boundary (Phase 7). The rest of the app
        // depends only on DigitalAccessProviderInterface; the concrete
        // provider is chosen from config('digital_access.provider'). "dummy"
        // is the only implementation registered this phase — an explicitly
        // configured but unsupported provider fails loudly, never silently
        // falls back.
        $this->app->singleton(DigitalAccessProviderInterface::class, function (): DigitalAccessProviderInterface {
            $provider = (string) config('digital_access.provider');

            return match ($provider) {
                'dummy' => new DummyDigitalAccessProvider(
                    defaultDirective: DigitalAccessSimulationDirective::fromConfig(
                        config('digital_access.providers.dummy.default_directive'),
                    ),
                ),
                default => throw new UnsupportedDigitalAccessProviderException($provider),
            };
        });
    }

    public function boot(): void
    {
        foreach ($this->policies as $model => $policy) {
            Gate::policy($model, $policy);
        }

        Gate::define('roles.view', fn (User $user) => $user->hasPermission('roles.view'));
        Gate::define('permissions.view', fn (User $user) => $user->hasPermission('permissions.view'));

        $this->registerPaymentRateLimiters();
        $this->registerIdentityVerificationRateLimiters();
        $this->registerDigitalAccessRateLimiters();
    }

    /**
     * Phase 0 §17 — rate limiting on the payment endpoints (Phase 5F).
     * Config-driven (config/payment.php), native RateLimiter, no package.
     */
    private function registerPaymentRateLimiters(): void
    {
        RateLimiter::for('payments.hold', fn (Request $request) => Limit::perMinute(
            (int) config('payment.rate_limits.hold.per_minute'),
        )->by((string) ($request->user()?->id ?? $request->ip())));

        RateLimiter::for('payments.webhook', fn (Request $request) => Limit::perMinute(
            (int) config('payment.rate_limits.webhook.per_minute'),
        )->by((string) $request->ip()));
    }

    /**
     * Phase 0 §17 — "rate limiting on ... verification-upload ... endpoints"
     * (Phase 6). Config-driven (config/verification.php), native
     * RateLimiter, no package. Keyed by authenticated user id (IP fallback).
     */
    private function registerIdentityVerificationRateLimiters(): void
    {
        RateLimiter::for('identity-verification.submit', fn (Request $request) => Limit::perMinute(
            (int) config('verification.rate_limits.submit.per_minute'),
        )->by((string) ($request->user()?->id ?? $request->ip())));
    }

    /**
     * Phase 0 §17 — rate limiting on the sensitive check-in / digital access
     * endpoints (Phase 7). Config-driven (config/digital_access.php), native
     * RateLimiter, no package. Keyed by authenticated user id (IP fallback).
     */
    private function registerDigitalAccessRateLimiters(): void
    {
        RateLimiter::for('check-in', fn (Request $request) => Limit::perMinute(
            (int) config('digital_access.rate_limits.check_in.per_minute'),
        )->by((string) ($request->user()?->id ?? $request->ip())));

        RateLimiter::for('digital-access.revoke', fn (Request $request) => Limit::perMinute(
            (int) config('digital_access.rate_limits.revoke.per_minute'),
        )->by((string) ($request->user()?->id ?? $request->ip())));
    }
}
