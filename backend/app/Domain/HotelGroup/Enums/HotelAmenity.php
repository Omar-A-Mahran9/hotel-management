<?php

namespace App\Domain\HotelGroup\Enums;

/**
 * The guest-facing hotel amenity vocabulary. A fixed set so the dashboard
 * multi-select and the guest Discovery contract stay stable — mirrors the
 * amenity chips the Figma hotel-detail screen renders. Stored as a JSON
 * array of these string values on `hotels.amenities`.
 */
enum HotelAmenity: string
{
    case FreeWifi = 'free_wifi';
    case Breakfast = 'breakfast';
    case Parking = 'parking';
    case Pool = 'pool';
    case Gym = 'gym';
    case FamilyRooms = 'family_rooms';
    case AirportShuttle = 'airport_shuttle';
    case RoomService = 'room_service';
    case AirConditioning = 'air_conditioning';
    case Restaurant = 'restaurant';
    case Spa = 'spa';
    case BusinessCenter = 'business_center';

    /** @return list<string> */
    public static function values(): array
    {
        return array_map(static fn (self $c) => $c->value, self::cases());
    }
}
