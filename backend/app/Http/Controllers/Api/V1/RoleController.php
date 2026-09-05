<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\IdentityAccess\Repositories\Contracts\RoleRepositoryInterface;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\RoleResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class RoleController extends Controller
{
    public function __construct(private readonly RoleRepositoryInterface $roles) {}

    public function index(): JsonResponse
    {
        Gate::authorize('roles.view');

        return $this->success(RoleResource::collection($this->roles->all()));
    }
}
