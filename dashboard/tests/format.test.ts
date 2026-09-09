import { describe, expect, it } from 'vitest'
import { date, dateTime, money } from '~/utils/format'

describe('money', () => {
  it('formats a decimal string with a currency code', () => {
    expect(money('120.5', 'EGP')).toBe('120.50 EGP')
  })
  it('formats without a currency', () => {
    expect(money('1000')).toBe('1,000.00')
  })
  it('shows a dash for null / empty', () => {
    expect(money(null)).toBe('—')
    expect(money('')).toBe('—')
  })
  it('never does arithmetic — passes an unparseable value straight through', () => {
    expect(money('not-a-number', 'USD')).toBe('not-a-number')
  })
})

describe('date', () => {
  it('keeps a plain date stable (no timezone shift)', () => {
    expect(date('2026-09-09T00:00:00.000000Z')).toBe('2026-09-09')
    expect(date('2026-09-09')).toBe('2026-09-09')
  })
  it('shows a dash for null', () => {
    expect(date(null)).toBe('—')
  })
})

describe('dateTime', () => {
  it('shows a dash for null', () => {
    expect(dateTime(null)).toBe('—')
  })
  it('returns the raw string when unparseable', () => {
    expect(dateTime('nonsense')).toBe('nonsense')
  })
})
