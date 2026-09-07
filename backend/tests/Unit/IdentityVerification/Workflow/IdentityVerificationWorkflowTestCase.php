<?php

namespace Tests\Unit\IdentityVerification\Workflow;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\IdentityVerification\Provider\Contracts\IdentityVerificationProviderInterface;
use App\Domain\IdentityVerification\Repositories\EloquentIdentityVerificationAttemptRepository;
use App\Domain\IdentityVerification\Repositories\EloquentIdentityVerificationDecisionRepository;
use App\Domain\IdentityVerification\Repositories\EloquentIdentityVerificationSessionRepository;
use App\Domain\IdentityVerification\Services\IdentityVerificationService;
use App\Domain\IdentityVerification\Support\IdentityFileStore;
use App\Domain\Inventory\Models\RoomType;
use App\Domain\Inventory\Repositories\EloquentRoomRepository;
use App\Domain\Inventory\Repositories\EloquentRoomTypeRepository;
use App\Domain\Reservation\Models\Reservation;
use App\Domain\Reservation\Repositories\EloquentGuestRepository;
use App\Domain\Reservation\Repositories\EloquentReservationRepository;
use App\Domain\Reservation\Services\ReservationService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

abstract class IdentityVerificationWorkflowTestCase extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('local');
    }

    protected function makeService(
        ?IdentityVerificationProviderInterface $provider = null,
        ?AuditLogger $auditLogger = null,
    ): IdentityVerificationService {
        $auditLogger ??= app(AuditLogger::class);

        return new IdentityVerificationService(
            $provider ?? app(IdentityVerificationProviderInterface::class),
            new EloquentIdentityVerificationSessionRepository,
            new EloquentIdentityVerificationAttemptRepository,
            new EloquentIdentityVerificationDecisionRepository,
            new EloquentReservationRepository,
            new ReservationService(
                new EloquentReservationRepository,
                new EloquentRoomTypeRepository,
                new EloquentRoomRepository,
                new EloquentGuestRepository,
                $auditLogger,
            ),
            new IdentityFileStore,
            $auditLogger,
        );
    }

    protected function reservation(
        string $status = Reservation::STATUS_DEPOSIT_HELD,
        ?Hotel $hotel = null,
    ): Reservation {
        $hotel ??= Hotel::factory()->create();
        $roomType = RoomType::factory()->create(['hotel_id' => $hotel->id]);

        return Reservation::factory()->create([
            'hotel_id' => $hotel->id,
            'room_type_id' => $roomType->id,
            'status' => $status,
        ]);
    }

    protected function image(string $name = 'x.jpg'): UploadedFile
    {
        return UploadedFile::fake()->image($name, 20, 20);
    }
}
