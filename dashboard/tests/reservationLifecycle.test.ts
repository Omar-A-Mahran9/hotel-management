import { describe, expect, it } from 'vitest'
import { reservationLifecycle } from '~/utils/reservationLifecycle'

const id = (k: string) => k

describe('reservationLifecycle', () => {
  it('marks the first stage current for a brand-new pending reservation', () => {
    const s = reservationLifecycle('pending', id)
    expect(s[0]!.state).toBe('current')
    expect(s.slice(1).every(x => x.state === 'upcoming')).toBe(true)
  })

  it('advances done/current/upcoming as the status progresses', () => {
    const s = reservationLifecycle('verified', id)
    expect(s.find(x => x.key === 'reservation')!.state).toBe('done')
    expect(s.find(x => x.key === 'payment')!.state).toBe('done')
    expect(s.find(x => x.key === 'identity')!.state).toBe('current')
    expect(s.find(x => x.key === 'checkin')!.state).toBe('upcoming')
  })

  it('marks every stage after the first as blocked when cancelled', () => {
    const s = reservationLifecycle('cancelled', id)
    expect(s[0]!.state).toBe('done')
    expect(s.slice(1).every(x => x.state === 'blocked')).toBe(true)
  })

  it('flags the checkout stage as blocked when checkout is blocked', () => {
    const s = reservationLifecycle('checkout_blocked', id)
    expect(s.find(x => x.key === 'checkout')!.state).toBe('blocked')
    expect(s.find(x => x.key === 'stay')!.state).toBe('done')
  })

  it('marks the final stage current once invoiced', () => {
    const s = reservationLifecycle('invoiced', id)
    expect(s.at(-1)!.state).toBe('current')
    expect(s.slice(0, -1).every(x => x.state === 'done')).toBe(true)
  })
})
