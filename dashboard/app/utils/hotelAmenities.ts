// Mirrors the backend App\Domain\HotelGroup\Enums\HotelAmenity vocabulary.
// The backend validates `amenities.*` against exactly this set — keep in sync.
// Labels are i18n keys (hotels.amenity.<slug>), never hardcoded strings.

export const HOTEL_AMENITIES = [
  'free_wifi',
  'breakfast',
  'parking',
  'pool',
  'gym',
  'family_rooms',
  'airport_shuttle',
  'room_service',
  'air_conditioning',
  'restaurant',
  'spa',
  'business_center',
] as const

export type HotelAmenity = (typeof HOTEL_AMENITIES)[number]

export function amenityLabelKey(slug: string): string {
  return `hotels.amenity.${slug}`
}
