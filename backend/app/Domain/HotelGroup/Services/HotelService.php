<?php

namespace App\Domain\HotelGroup\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\HotelGroup\Repositories\Contracts\HotelRepositoryInterface;
use App\Domain\IdentityAccess\Models\User;
use App\Domain\Location\Models\City;
use App\Domain\Location\Services\CityService;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class HotelService
{
    public function __construct(
        private readonly HotelRepositoryInterface $hotels,
        private readonly AuditLogger $auditLogger,
        private readonly CityService $cities,
    ) {}

    /**
     * Hotels visible to $user, resolved from their own stored hotel
     * access / Group Owner bypass — never from a request parameter.
     */
    public function listAccessibleBy(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->hotels->paginateAccessibleBy($user, $perPage);
    }

    public function find(int $id): ?Hotel
    {
        return $this->hotels->find($id);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data, ?User $actor): Hotel
    {
        return DB::transaction(function () use ($data, $actor) {
            $data = $this->normalizeLocation($data);

            $hotel = $this->hotels->create($data);

            $this->auditLogger->record($actor, 'hotel.created', $hotel, after: $hotel->toArray(), hotelId: $hotel->id);

            return $hotel->load('countryRef', 'cityRef', 'hotelGroup');
        });
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Hotel $hotel, array $data, ?User $actor): Hotel
    {
        return DB::transaction(function () use ($hotel, $data, $actor) {
            $before = $hotel->toArray();

            $data = $this->normalizeLocation($data, $hotel);

            $this->hotels->update($hotel, $data);

            $this->auditLogger->record($actor, 'hotel.updated', $hotel, before: $before, after: $hotel->toArray(), hotelId: $hotel->id);

            return $hotel->load('countryRef', 'cityRef', 'hotelGroup');
        });
    }

    /**
     * Server-side relationship integrity: the selected City must belong to
     * the selected Country (never trust the frontend). The legacy
     * free-text `country` / `city` columns are then kept in sync from the
     * referenced records so the guest Discovery API keeps working.
     *
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function normalizeLocation(array $data, ?Hotel $hotel = null): array
    {
        $countryId = $data['country_id'] ?? $hotel?->country_id;
        $cityId = $data['city_id'] ?? $hotel?->city_id;

        if ($countryId && $cityId) {
            $this->cities->assertCityBelongsToCountry((int) $cityId, (int) $countryId);
        }

        if ($cityId) {
            $city = City::query()->with('country')->find($cityId);
            if ($city) {
                $data['city'] = $city->name_en;
                $data['country'] = $city->country?->name_en;
            }
        }

        return $data;
    }
}
