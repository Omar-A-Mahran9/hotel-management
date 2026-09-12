// UI badge tones for every backend status enum the dashboard renders.
// Mirrors the backend model constants (App\Domain\*). These map a status to
// a colour only — they are never a state machine and never a security check.
import type {
  AccessGrantStatus,
  CheckoutStatus,
  IdentityVerificationStatus,
  NotificationDeliveryStatus,
  PaymentStatus,
  ProblemReportStatus,
  ProblemReportUrgency,
  ReviewStatus,
  ServiceOrderStatus,
} from '~/types/api'

export type BadgeTone = 'neutral' | 'info' | 'primary' | 'success' | 'warning' | 'destructive'

export const PAYMENT_STATUS_TONE: Record<PaymentStatus, BadgeTone> = {
  not_started: 'neutral',
  hold_requested: 'info',
  hold_active: 'primary',
  hold_failed: 'destructive',
  capture_requested: 'info',
  captured: 'success',
  capture_failed: 'destructive',
  final_settlement_requested: 'info',
  settled: 'success',
  settlement_failed: 'destructive',
  cancelled: 'neutral',
  expired: 'warning',
  refund_requested: 'info',
  refunded: 'neutral',
  refund_failed: 'destructive',
}

export const SERVICE_ORDER_STATUS_TONE: Record<ServiceOrderStatus, BadgeTone> = {
  requested: 'info',
  confirmed: 'primary',
  fulfilled: 'success',
  cancelled: 'neutral',
}

// Valid forward transitions offered in the UI. The backend re-validates and
// rejects an illegal one with 422 — this is only which buttons to show.
export const SERVICE_ORDER_TRANSITIONS: Record<ServiceOrderStatus, Array<'confirmed' | 'fulfilled' | 'cancelled'>> = {
  requested: ['confirmed', 'cancelled'],
  confirmed: ['fulfilled', 'cancelled'],
  fulfilled: [],
  cancelled: [],
}

export const IDENTITY_STATUS_TONE: Record<IdentityVerificationStatus, BadgeTone> = {
  not_started: 'neutral',
  document_uploaded: 'info',
  selfie_captured: 'info',
  matching_in_progress: 'info',
  auto_approved: 'success',
  pending_manual_review: 'warning',
  staff_approved: 'success',
  staff_rejected: 'destructive',
  retry_allowed: 'warning',
}

export const ACCESS_STATUS_TONE: Record<AccessGrantStatus, BadgeTone> = {
  not_issued: 'neutral',
  issue_requested: 'info',
  active: 'success',
  failed: 'destructive',
  revoke_requested: 'warning',
  revoked: 'neutral',
  expired: 'warning',
}

export const CHECKOUT_STATUS_TONE: Record<CheckoutStatus, BadgeTone> = {
  in_progress: 'info',
  awaiting_settlement: 'warning',
  settlement_failed: 'destructive',
  completed: 'success',
}

export const NOTIFICATION_STATUS_TONE: Record<NotificationDeliveryStatus, BadgeTone> = {
  pending: 'neutral',
  sending: 'info',
  sent: 'success',
  failed: 'destructive',
}

export const INVOICE_STATUS_TONE: Record<string, BadgeTone> = {
  draft: 'neutral',
  issued: 'success',
}

export const REVIEW_STATUS_TONE: Record<ReviewStatus, BadgeTone> = {
  pending: 'warning',
  published: 'success',
  rejected: 'destructive',
}

export const PROBLEM_STATUS_TONE: Record<ProblemReportStatus, BadgeTone> = {
  open: 'warning',
  in_progress: 'info',
  resolved: 'success',
}

export const PROBLEM_URGENCY_TONE: Record<ProblemReportUrgency, BadgeTone> = {
  normal: 'neutral',
  important: 'warning',
  urgent: 'destructive',
}

// Valid forward transitions offered in the UI (open -> in_progress|resolved,
// in_progress -> resolved, resolved is terminal). The backend
// (App\Domain\Problems) re-validates and rejects an illegal one with 422 —
// this is only which buttons to show.
export const PROBLEM_STATUS_TRANSITIONS: Record<ProblemReportStatus, Array<'in_progress' | 'resolved'>> = {
  open: ['in_progress', 'resolved'],
  in_progress: ['resolved'],
  resolved: [],
}

/** A pending-manual-review session is the only state a staff review acts on. */
export function canReviewIdentity(status: IdentityVerificationStatus): boolean {
  return status === 'pending_manual_review'
}
