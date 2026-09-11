import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { describe, expect, it } from 'vitest'
import { amenityLabelKey, HOTEL_AMENITIES } from '../app/utils/hotelAmenities'

// Paths are resolved from the dashboard package root (vitest cwd).
const root = process.cwd()

// The dashboard amenity list is a mirror of the backend enum
// (App\Domain\HotelGroup\Enums\HotelAmenity) — the backend validates
// `amenities.*` against exactly that set. Keep them in lock-step.
function backendAmenityValues(): string[] {
  const php = readFileSync(
    resolve(root, '../backend/app/Domain/HotelGroup/Enums/HotelAmenity.php'),
    'utf8',
  )
  return [...php.matchAll(/case\s+\w+\s*=\s*'([a-z_]+)'/g)].map(m => m[1]!)
}

const en = JSON.parse(readFileSync(resolve(root, 'i18n/locales/en.json'), 'utf8'))
const ar = JSON.parse(readFileSync(resolve(root, 'i18n/locales/ar.json'), 'utf8'))

function get(obj: Record<string, unknown>, path: string): unknown {
  return path.split('.').reduce<unknown>((acc, k) => (acc as Record<string, unknown>)?.[k], obj)
}

describe('hotel amenities', () => {
  it('exactly mirrors the backend HotelAmenity enum', () => {
    expect([...HOTEL_AMENITIES].sort()).toEqual(backendAmenityValues().sort())
  })

  it('has an en + ar label for every amenity', () => {
    for (const slug of HOTEL_AMENITIES) {
      const key = amenityLabelKey(slug)
      expect(get(en, key), `${key} missing in en`).toBeTypeOf('string')
      expect(get(ar, key), `${key} missing in ar`).toBeTypeOf('string')
    }
  })

  it('has en + ar strings for the media uploader keys', () => {
    for (const key of [
      'hotels.media.logo',
      'hotels.media.cover',
      'hotels.media.gallery',
      'hotels.media.upload',
      'hotels.media.replace',
      'hotels.media.removeConfirm',
      'hotels.mediaAfterCreate',
      'hotels.starRatingValue',
      'common.moveUp',
      'common.remove',
    ]) {
      expect(get(en, key), `${key} missing in en`).toBeTypeOf('string')
      expect(get(ar, key), `${key} missing in ar`).toBeTypeOf('string')
    }
  })
})
