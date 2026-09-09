import { describe, expect, it } from 'vitest'
import {
  allowedTransitions,
  isTerminal,
  RESERVATION_STATUSES,
  RESERVATION_TRANSITIONS,
} from '~/utils/reservationStateMachine'

// The UI mirror must stay in lock-step with the backend state machine
// (App\Domain\Reservation\StateMachine\ReservationStateMachine).
describe('reservation state machine (UI mirror)', () => {
  it('exposes the 10 approved statuses', () => {
    expect(RESERVATION_STATUSES).toHaveLength(10)
    expect(RESERVATION_STATUSES).toContain('pending')
    expect(RESERVATION_STATUSES).toContain('invoiced')
  })

  it('matches the approved transition table', () => {
    expect(RESERVATION_TRANSITIONS.pending).toEqual(['deposit_held', 'cancelled'])
    expect(RESERVATION_TRANSITIONS.checked_in).toEqual(['in_stay'])
    expect(RESERVATION_TRANSITIONS.checkout_in_progress).toEqual(['checked_out', 'checkout_blocked'])
  })

  it('treats cancelled / invoiced / checkout_blocked as terminal', () => {
    expect(isTerminal('cancelled')).toBe(true)
    expect(isTerminal('invoiced')).toBe(true)
    expect(isTerminal('checkout_blocked')).toBe(true)
    expect(isTerminal('pending')).toBe(false)
  })

  it('never allows a self-transition', () => {
    for (const status of RESERVATION_STATUSES) {
      expect(allowedTransitions(status)).not.toContain(status)
    }
  })
})
