<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Reservation\Services\ReservationService;
use App\Domain\StayServices\Services\Folio;
use App\Domain\StayServices\Services\FolioService;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\FolioResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Phase 8 — the reservation folio surface (Phase 0 §16:
 * /api/v1/reservations/{reservation}/folio). Read-only. {reservation} is an
 * int id resolved through ReservationService, so a cross-hotel or missing
 * id is an identical plain 404.
 */
class FolioController extends Controller
{
    public function __construct(
        private readonly ReservationService $reservations,
        private readonly FolioService $folios,
    ) {}

    public function show(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservations->findAccessibleBy($request->user(), $reservation);

        if (! $found) {
            abort(404);
        }

        $this->authorize('view', [Folio::class, $found]);

        return $this->success(
            new FolioResource($this->folios->folioFor($found)),
            __('api.stay_services.folio'),
        );
    }
}
