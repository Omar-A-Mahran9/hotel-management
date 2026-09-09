import { describe, expect, it } from 'vitest'
import {
  canReviewIdentity,
  PAYMENT_STATUS_TONE,
  SERVICE_ORDER_STATUS_TONE,
  SERVICE_ORDER_TRANSITIONS,
} from '~/utils/statusMeta'

describe('service order transitions (UI mirror)', () => {
  it('offers only forward + cancel from requested', () => {
    expect(SERVICE_ORDER_TRANSITIONS.requested).toEqual(['confirmed', 'cancelled'])
  })
  it('offers fulfil + cancel from confirmed', () => {
    expect(SERVICE_ORDER_TRANSITIONS.confirmed).toEqual(['fulfilled', 'cancelled'])
  })
  it('has no transition out of the terminal states', () => {
    expect(SERVICE_ORDER_TRANSITIONS.fulfilled).toEqual([])
    expect(SERVICE_ORDER_TRANSITIONS.cancelled).toEqual([])
  })
  it('every service-order status has a tone', () => {
    for (const s of Object.keys(SERVICE_ORDER_TRANSITIONS)) {
      expect(SERVICE_ORDER_STATUS_TONE[s as keyof typeof SERVICE_ORDER_STATUS_TONE]).toBeDefined()
    }
  })
})

describe('canReviewIdentity', () => {
  it('is true only for a pending manual review', () => {
    expect(canReviewIdentity('pending_manual_review')).toBe(true)
    expect(canReviewIdentity('auto_approved')).toBe(false)
    expect(canReviewIdentity('staff_approved')).toBe(false)
  })
})

describe('payment tones', () => {
  it('maps captured / settled to success and failures to destructive', () => {
    expect(PAYMENT_STATUS_TONE.captured).toBe('success')
    expect(PAYMENT_STATUS_TONE.settled).toBe('success')
    expect(PAYMENT_STATUS_TONE.hold_failed).toBe('destructive')
    expect(PAYMENT_STATUS_TONE.settlement_failed).toBe('destructive')
  })
})
