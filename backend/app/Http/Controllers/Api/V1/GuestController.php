<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Services\GuestService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Guests\IndexGuestRequest;
use App\Http\Resources\V1\GuestResource;
use App\Http\Resources\V1\ReservationResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Staff-facing guest directory — read-only (a Guest's own data is only
 * ever mutated through the guest app's own profile flow). Not hotel-scoped:
 * a Guest may hold reservations across multiple hotels, so `guests.view`
 * alone gates it; the reservations sub-list is still filtered through the
 * caller's own hotel access.
 */
class GuestController extends Controller
{
    public function __construct(private readonly GuestService $guests) {}

    public function index(IndexGuestRequest $request): JsonResponse
    {
        $this->authorize('viewAny', Guest::class);

        return $this->success(GuestResource::collection(
            $this->guests->list($request->filters(), $request->perPage())
        ));
    }

    public function show(Request $request, Guest $guest): JsonResponse
    {
        $this->authorize('view', $guest);

        return $this->success(new GuestResource($guest->load('loyaltyAccount')));
    }

    public function reservations(Request $request, Guest $guest): JsonResponse
    {
        $this->authorize('view', $guest);

        $perPage = (int) $request->query('per_page', 15);

        return $this->success(ReservationResource::collection(
            $this->guests->reservationsFor($request->user(), $guest, $perPage)
        ));
    }
}
