import { describe, expect, it } from 'vitest'
import en from '../i18n/locales/en.json'
import ar from '../i18n/locales/ar.json'

// Guards against future en/ar drift — every key path present in one locale
// must be present in the other (values may of course differ).
function flattenKeys(obj: unknown, prefix = ''): string[] {
  if (obj === null || typeof obj !== 'object') return [prefix]
  return Object.entries(obj as Record<string, unknown>).flatMap(([key, value]) =>
    flattenKeys(value, prefix ? `${prefix}.${key}` : key),
  )
}

describe('i18n en/ar key parity', () => {
  it('has no keys present in English but missing in Arabic', () => {
    const enKeys = new Set(flattenKeys(en))
    const arKeys = new Set(flattenKeys(ar))
    const missingInAr = [...enKeys].filter(k => !arKeys.has(k))
    expect(missingInAr).toEqual([])
  })

  it('has no keys present in Arabic but missing in English', () => {
    const enKeys = new Set(flattenKeys(en))
    const arKeys = new Set(flattenKeys(ar))
    const missingInEn = [...arKeys].filter(k => !enKeys.has(k))
    expect(missingInEn).toEqual([])
  })
})
