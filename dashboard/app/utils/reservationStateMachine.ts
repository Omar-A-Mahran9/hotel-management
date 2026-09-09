import type { ReservationStatus } from '~/types/api'

// UI mirror of backend App\Domain\Reservation\StateMachine\ReservationStateMachine.
// Used ONLY to decide which transition buttons to offer. The backend
// re-validates every transition and rejects an illegal one with 422 —
// this map is never a security boundary.
export const RESERVATION_TRANSITIONS: Record<ReservationStatus, ReservationStatus[]> = {
  pending: ['deposit_held', 'cancelled'],
  deposit_held: ['verified', 'cancelled'],
  verified: ['checked_in', 'cancelled'],
  checked_in: ['in_stay'],
  in_stay: ['checkout_in_progress'],
  checkout_in_progress: ['checked_out', 'checkout_blocked'],
  checkout_blocked: [],
  checked_out: ['invoiced'],
  invoiced: [],
  cancelled: [],
}

export function allowedTransitions(status: ReservationStatus): ReservationStatus[] {
  return RESERVATION_TRANSITIONS[status] ?? []
}

export function isTerminal(status: ReservationStatus): boolean {
  return (RESERVATION_TRANSITIONS[status] ?? []).length === 0
}

export const RESERVATION_STATUSES = Object.keys(RESERVATION_TRANSITIONS) as ReservationStatus[]

type BadgeTone = 'neutral' | 'info' | 'primary' | 'success' | 'warning' | 'destructive'

export const RESERVATION_STATUS_TONE: Record<ReservationStatus, BadgeTone> = {
  pending: 'neutral',
  deposit_held: 'info',
  verified: 'info',
  checked_in: 'primary',
  in_stay: 'primary',
  checkout_in_progress: 'warning',
  checkout_blocked: 'destructive',
  checked_out: 'success',
  invoiced: 'success',
  cancelled: 'destructive',
}

export const ROOM_STATUS_TONE: Record<string, BadgeTone> = {
  available: 'success',
  booked: 'primary',
  under_maintenance: 'warning',
}
