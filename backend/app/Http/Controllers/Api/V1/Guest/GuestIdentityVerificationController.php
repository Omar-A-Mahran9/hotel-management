<?php

namespace App\Http\Controllers\Api\V1\Guest;

use App\Domain\IdentityVerification\Models\IdentityVerificationSession;
use App\Domain\IdentityVerification\Services\IdentityVerificationService;
use App\Domain\Reservation\Models\Guest;
use App\Domain\Reservation\Services\ReservationService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\IdentityVerification\SubmitIdentityDocumentRequest;
use App\Http\Requests\Api\V1\IdentityVerification\SubmitIdentitySelfieRequest;
use App\Http\Resources\V1\IdentityVerificationResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * The authenticated guest's own identity verification session
 * (`/api/v1/guest/reservations/{reservation}/identity/*`).
 *
 * Dedicated GUEST controller — no business logic here. Reuses the shared
 * IdentityVerificationService unchanged (same as
 * IdentityVerificationController); the request classes are guard-agnostic
 * and are reused as-is. Ownership is enforced via
 * ReservationService::findOwnedByGuest — a non-owned or missing reservation
 * is an identical plain 404. There is no guest equivalent of the staff
 * `review` action (manual approve/reject stays staff-only).
 */
class GuestIdentityVerificationController extends Controller
{
    public function __construct(
        private readonly ReservationService $reservations,
        private readonly IdentityVerificationService $verification,
    ) {}

    public function documents(SubmitIdentityDocumentRequest $request, int $reservation): JsonResponse
    {
        $found = $this->reservationFor($request, $reservation);

        $session = $this->verification->submitDocument(
            reservation: $found,
            document: $request->file('document'),
            documentType: $request->documentType(),
            actor: null,
        );

        return $this->success(
            $this->resource($session),
            __('api.identity_verification.document_submitted'),
            201,
        );
    }

    public function selfie(SubmitIdentitySelfieRequest $request, int $reservation): JsonResponse
    {
        $found = $this->reservationFor($request, $reservation);

        $session = $this->verification->submitSelfie(
            reservation: $found,
            selfie: $request->file('selfie'),
            idempotencyKey: $request->idempotencyKey(),
            directive: $request->simulationDirective(),
            actor: null,
        );

        return $this->success(
            $this->resource($session),
            __('api.identity_verification.'.$session->status),
        );
    }

    public function status(Request $request, int $reservation): JsonResponse
    {
        $found = $this->reservationFor($request, $reservation);

        $session = $this->verification->statusFor($found);

        return $this->success($this->resource($session), __('api.identity_verification.status'));
    }

    private function reservationFor(Request $request, int $reservation)
    {
        $found = $this->reservations->findOwnedByGuest($this->guest($request), $reservation);

        if (! $found) {
            abort(404);
        }

        return $found;
    }

    private function resource(IdentityVerificationSession $session): IdentityVerificationResource
    {
        return (new IdentityVerificationResource($session))
            ->withLatestDecision($this->verification->latestDecision($session));
    }

    private function guest(Request $request): Guest
    {
        /** @var Guest $guest */
        $guest = $request->user();

        return $guest;
    }
}
