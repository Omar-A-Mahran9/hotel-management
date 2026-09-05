<?php

namespace App\Providers;

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
use Illuminate\Support\Facades\Gate;
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
    ];

    /**
     * @var array<class-string, class-string>
     */
    public array $policies = [
        HotelGroup::class => HotelGroupPolicy::class,
        Hotel::class => HotelPolicy::class,
        User::class => UserPolicy::class,
    ];

    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        foreach ($this->policies as $model => $policy) {
            Gate::policy($model, $policy);
        }

        Gate::define('roles.view', fn (User $user) => $user->hasPermission('roles.view'));
        Gate::define('permissions.view', fn (User $user) => $user->hasPermission('permissions.view'));
    }
}
