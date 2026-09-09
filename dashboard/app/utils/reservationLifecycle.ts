import type { ReservationStatus } from '~/types/api'
import type { TimelineStage } from '~/components/AppTimeline.vue'

// The approved guest journey (Phase 0 §R20), rendered as a progress
// timeline. Order of the milestones and which reservation status marks each
// "reached" mirror the backend ReservationStateMachine — this is a
// read-only visualisation, never a control.
const ORDER: ReservationStatus[] = [
  'pending',
  'deposit_held',
  'verified',
  'checked_in',
  'in_stay',
  'checkout_in_progress',
  'checked_out',
  'invoiced',
]

interface StageDef {
  key: string
  labelKey: string
  /** The first reservation status at which this stage is considered reached. */
  reachedAt: ReservationStatus
}

const STAGES: StageDef[] = [
  { key: 'reservation', labelKey: 'lifecycle.reservation', reachedAt: 'pending' },
  { key: 'payment', labelKey: 'lifecycle.payment', reachedAt: 'deposit_held' },
  { key: 'identity', labelKey: 'lifecycle.identity', reachedAt: 'verified' },
  { key: 'checkin', labelKey: 'lifecycle.checkin', reachedAt: 'checked_in' },
  { key: 'stay', labelKey: 'lifecycle.stay', reachedAt: 'in_stay' },
  { key: 'checkout', labelKey: 'lifecycle.checkout', reachedAt: 'checkout_in_progress' },
  { key: 'invoice', labelKey: 'lifecycle.invoice', reachedAt: 'checked_out' },
  { key: 'loyalty', labelKey: 'lifecycle.loyalty', reachedAt: 'invoiced' },
]

export function reservationLifecycle(
  status: ReservationStatus,
  translate: (key: string) => string,
): TimelineStage[] {
  if (status === 'cancelled') {
    return STAGES.map((s, i) => ({
      key: s.key,
      label: translate(s.labelKey),
      state: i === 0 ? 'done' : 'blocked',
    }))
  }

  const currentRank = status === 'checkout_blocked'
    ? ORDER.indexOf('checkout_in_progress')
    : ORDER.indexOf(status)

  return STAGES.map((s) => {
    const rank = ORDER.indexOf(s.reachedAt)
    let state: TimelineStage['state']
    if (status === 'checkout_blocked' && s.key === 'checkout') state = 'blocked'
    else if (rank < currentRank) state = 'done'
    else if (rank === currentRank) state = 'current'
    else state = 'upcoming'
    return { key: s.key, label: translate(s.labelKey), state }
  })
}
