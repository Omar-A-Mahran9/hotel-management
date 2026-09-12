// Laravel /api/v1 response envelope + domain shapes.
// These mirror the backend API Resources exactly (see
// md/dashboard-foundation-audit.md §4 and app/Http/Resources/V1/*).
// Fields the backend does not return are not invented here. Money values
// are decimal strings ("120.00"); currency is a 3-letter code.

export interface ApiEnvelope<T> {
  success: boolean
  message: string
  data: T
  meta?: ApiMeta
}

export interface ApiMeta {
  current_page?: number
  last_page?: number
  per_page?: number
  total?: number
  from?: number
  to?: number
  [key: string]: unknown
}

export interface Paginated<T> {
  data: T[]
  meta: ApiMeta
}

export type ValidationErrors = Record<string, string[]>

// ---- RBAC ---------------------------------------------------------------
export interface Permission {
  id: number
  name_en: string
  name_ar: string
  slug: string
  description_en: string | null
  description_ar: string | null
  /** Module the permission belongs to, derived from the slug prefix (e.g. "hotels"). */
  group: string
  group_label_en: string
  group_label_ar: string
}

export interface Role {
  id: number
  name_en: string
  name_ar: string
  slug: string
  description_en: string | null
  description_ar: string | null
  /** true for the four protected roles (Group Owner/Hotel Manager/Reception/Guest) — cannot be deleted. */
  is_system: boolean
  /** Present on list/show; the number of permissions attached to the role. */
  permissions_count?: number
  /** Present on list/show; the number of users currently assigned this role. */
  users_count?: number
  permissions?: Permission[]
}

/** Body for POST/PUT /roles. */
export interface RoleWriteBody {
  name_en: string
  name_ar: string
  description_en?: string | null
  description_ar?: string | null
  permission_ids?: number[]
}

// ---- Locations (global reference data — CountryResource / CityResource) -
export interface Country {
  id: number
  name_en: string
  name_ar: string
  code: string
  is_active: boolean
  cities_count?: number
  created_at?: string
  updated_at?: string
}

export interface City {
  id: number
  country_id: number
  name_en: string
  name_ar: string
  is_active: boolean
  country?: { id: number, name_en: string, name_ar: string }
  created_at?: string
  updated_at?: string
}

/** Flat {id, name_en, name_ar} summary embedded in HotelResource. */
export interface LocationSummary {
  id: number
  name_en: string
  name_ar: string
}

// ---- Hotels / groups --------------------------------------------------

// A locale-keyed content map, e.g. { en: 'Nile View', ar: 'إطلالة النيل' }.
// The staff API returns the raw map so the form can edit every language;
// the guest API resolves it to one string per request locale.
export type LocalizedMap = Partial<Record<'en' | 'ar', string | null>>

export interface HotelMedia {
  id: number
  collection: 'logo' | 'cover' | 'gallery'
  url: string
  sort_order: number
  mime_type: string | null
  size: number | null
  created_at: string
}

// ---- Facility catalog (global reference data — FacilityResource) --------
export interface Facility {
  id: number
  key: string
  name_i18n: LocalizedMap
  icon: string | null
  is_active: boolean
  sort_order: number
  hotels_count?: number
  created_at?: string
  updated_at?: string
}

export interface Hotel {
  id: number
  hotel_group_id: number
  name: string
  // Discovery enrichment — raw i18n maps for editing; null on hotels not
  // yet localized (the `name` string is the fallback).
  name_i18n: LocalizedMap | null
  tagline_i18n: LocalizedMap | null
  description_i18n: LocalizedMap | null
  star_rating: number | null
  // Selected from the Facility catalog — present when the backend
  // eager-loads the relation (show / list / after write).
  facilities?: Facility[]
  slug: string
  country_id: number | null
  city_id: number | null
  // Legacy free-text strings, kept for backward compatibility.
  country: string | null
  city: string | null
  // Normalized summaries — present when the backend eager-loads the relations.
  country_summary?: LocationSummary | null
  city_summary?: LocationSummary | null
  timezone: string | null
  is_active: boolean
  // Bilingual SEO metadata — raw i18n maps for editing, same pattern as
  // tagline/description. seo_indexable is a robots index/noindex directive.
  meta_title_i18n: LocalizedMap | null
  meta_description_i18n: LocalizedMap | null
  seo_indexable: boolean
  // Present when the backend eager-loads them (show / after write).
  logo?: HotelMedia | null
  cover?: HotelMedia | null
  gallery?: HotelMedia[]
  created_at: string
  updated_at: string
}

export interface HotelGroup {
  id: number
  name: string
  slug: string
  is_active: boolean
  created_at: string
  updated_at: string
}

// ---- Auth ------------------------------------------------------------
export interface AuthUser {
  id: number
  name: string
  email: string
  is_active: boolean
  role: Role
  hotels: Hotel[]
  created_at: string
  updated_at: string
}

export interface LoginResponse {
  user: AuthUser
  token: string
}

// ---- Inventory -----------------------------------------------------
export interface RoomMedia {
  id: number
  collection: 'gallery'
  url: string
  sort_order: number
  mime_type: string | null
  size: number | null
  created_at: string
}

export interface RoomType {
  id: number
  hotel_id: number
  name: string
  base_price: string
  capacity: number
  amenities: string[] | null
  description: string | null
  is_active: boolean
  // Present when the backend eager-loads the relation (list / show).
  photos?: RoomMedia[]
  rooms_count?: number
  available_rooms_count?: number
  maintenance_rooms_count?: number
  created_at: string
  updated_at: string
}

export type RoomStatus = 'available' | 'booked' | 'under_maintenance'

export interface Room {
  id: number
  hotel_id: number
  room_type_id: number
  room_number: string
  status: RoomStatus
  // Present when the backend eager-loads the relation (list / show).
  photos?: RoomMedia[]
  created_at: string
  updated_at: string
}

// ---- Reservations -------------------------------------------------
export type ReservationStatus =
  | 'pending'
  | 'deposit_held'
  | 'verified'
  | 'checked_in'
  | 'in_stay'
  | 'checkout_in_progress'
  | 'checkout_blocked'
  | 'checked_out'
  | 'invoiced'
  | 'cancelled'

export interface Reservation {
  id: number
  hotel_id: number
  room_type_id: number
  room_id: number | null
  guest_id: number | null
  check_in: string
  check_out: string
  status: ReservationStatus
  price_snapshot: string
  created_by_staff_id: number | null
  cancelled_at: string | null
  cancellation_reason: string | null
  created_at: string
  updated_at: string
}

// ---- Guests (GuestResource, staff directory) ----------------------
export interface Guest {
  id: number
  name: string | null
  email: string | null
  phone: string
  phone_verified_at: string | null
  profile_completed_at: string | null
  profile_complete: boolean
  /** Present only on the staff directory listing (GET /guests, GET /guests/{id}). */
  reservations_count?: number
  created_at: string
  updated_at: string
}

// ---- Extend Stay --------------------------------------------------
export interface ReservationExtension {
  id: number
  reservation_id: number
  previous_check_out: string
  new_check_out: string
  nights_added: number
  unit_price: string
  amount: string
  currency: string | null
  folio_posted: boolean
  created_at: string
}

export interface ExtendReservationResult {
  reservation: Reservation
  extension: ReservationExtension
  folio: { totals: { charges_total: string, payments_total: string, outstanding_total: string } }
}

// ---- Staff users ------------------------------------------------
export interface StaffUser {
  id: number
  name: string
  email: string
  is_active: boolean
  role?: Role
  hotels?: Hotel[]
  created_at: string
  updated_at: string
}

// ---- Payment (PaymentResource / folio.payment_summary) ---------
export type PaymentStatus =
  | 'not_started'
  | 'hold_requested'
  | 'hold_active'
  | 'hold_failed'
  | 'capture_requested'
  | 'captured'
  | 'capture_failed'
  | 'final_settlement_requested'
  | 'settled'
  | 'settlement_failed'
  | 'cancelled'
  | 'expired'
  | 'refund_requested'
  | 'refunded'
  | 'refund_failed'

export interface Payment {
  id: number
  reservation_id: number
  hotel_id: number
  status: PaymentStatus
  amount: string
  currency: string
  hold_expires_at: string | null
  created_at: string
  updated_at: string
}

// ---- Folio (FolioResource) ------------------------------------
export type FolioChargeStatus = 'posted' | 'cancelled'
export type FolioChargeSource = 'service_order' | 'accommodation'

export interface FolioCharge {
  id: number
  reservation_id: number
  hotel_id: number
  source_type: FolioChargeSource | string
  source_id: number | null
  description: string
  quantity: number
  unit_amount: string
  total_amount: string
  currency: string
  status: FolioChargeStatus
  charged_at: string | null
  cancelled_at: string | null
  created_by_user_id: number | null
  created_at: string
  updated_at: string
}

export interface Folio {
  reservation: { id: number, hotel_id: number, guest_id: number | null, status: ReservationStatus }
  currency: string
  charges: FolioCharge[]
  totals: {
    charges_total: string
    payments_total: string
    outstanding_total: string
  }
  payment_summary: null | {
    status: PaymentStatus
    amount: string
    currency: string
    is_captured: boolean
  }
}

// ---- Stay services -------------------------------------------
export interface ServiceCategory {
  id: number
  hotel_id: number
  name: string
  description: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface HotelService {
  id: number
  hotel_id: number
  service_category_id: number | null
  name: string
  description: string | null
  price: string
  currency: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export type ServiceOrderStatus = 'requested' | 'confirmed' | 'fulfilled' | 'cancelled'

export interface ServiceOrder {
  id: number
  reservation_id: number
  hotel_id: number
  service_id: number
  quantity: number
  unit_price_snapshot: string
  currency_snapshot: string
  total_amount: string
  status: ServiceOrderStatus
  notes: string | null
  requested_by_user_id: number | null
  requested_at: string | null
  confirmed_at: string | null
  fulfilled_at: string | null
  cancelled_at: string | null
  cancellation_reason: string | null
  created_at: string
  updated_at: string
}

// ---- Identity verification (IdentityVerificationResource) ----
export type IdentityVerificationStatus =
  | 'not_started'
  | 'document_uploaded'
  | 'selfie_captured'
  | 'matching_in_progress'
  | 'auto_approved'
  | 'pending_manual_review'
  | 'staff_approved'
  | 'staff_rejected'
  | 'retry_allowed'

export interface IdentityVerification {
  reservation_id: number
  hotel_id: number
  guest_id: number | null
  status: IdentityVerificationStatus
  provider: string | null
  attempts: number
  latest_outcome: string | null
  latest_score: number | null
  decided_at: string | null
  created_at: string
  updated_at: string
  latest_decision?: {
    type: string
    result: string
    band: string | null
    reason: string | null
    decided_by_user_id: number | null
    decided_at: string
  }
}

// ---- Digital access (AccessGrantResource) --------------------
export type AccessGrantStatus =
  | 'not_issued'
  | 'issue_requested'
  | 'active'
  | 'failed'
  | 'revoke_requested'
  | 'revoked'
  | 'expired'

export interface AccessGrant {
  reservation_id: number
  hotel_id: number
  guest_id: number | null
  status: AccessGrantStatus
  access_mode: 'pin_code' | 'smart_lock' | string | null
  provider: string | null
  issued_at: string | null
  activated_at: string | null
  expires_at: string | null
  revoked_at: string | null
  revocation_reason: string | null
  failure_reason: string | null
  created_at: string
  updated_at: string
  credential?: string
}

// ---- Checkout / invoice (CheckoutResource / InvoiceResource) -
export type CheckoutStatus =
  | 'in_progress'
  | 'awaiting_settlement'
  | 'settlement_failed'
  | 'completed'

export interface CheckoutResult {
  reservation: { id: number, hotel_id: number, status: ReservationStatus }
  checkout: { status: CheckoutStatus, started_at: string | null, completed_at: string | null }
  totals: { charges_total: string, payments_total: string, outstanding_total: string }
  currency: string
  payment: null | { status: PaymentStatus, amount: string, currency: string }
  invoice: null | { id: number, invoice_number: string, status: string, issued_at: string | null }
}

// ---- Settlement (SettlementResource) — one row of the staff settlements
// ledger. A "settlement" is a Checkout record; the domain has no separate
// Settlement entity. Distinct from CheckoutResult, which wraps the fuller
// checkout+payment+invoice outcome returned by the perform/read-one action.
export interface Settlement {
  id: number
  reservation_id: number
  hotel_id: number
  status: CheckoutStatus
  charges_total: string
  payments_total: string
  outstanding_total: string
  currency: string | null
  started_at: string | null
  completed_at: string | null
}

export type InvoiceStatus = 'draft' | 'issued'

export interface InvoiceItem {
  id: number
  source_type: string
  source_id: number | null
  description: string
  quantity: number
  unit_amount: string
  total_amount: string
}

export interface Invoice {
  id: number
  reservation_id: number
  hotel_id: number
  invoice_number: string
  status: InvoiceStatus
  currency: string
  subtotal: string
  payments_total: string
  outstanding_total: string
  issued_at: string | null
  items?: InvoiceItem[]
  created_at: string
  updated_at: string
}

// ---- Loyalty (LoyaltyAccountResource / LoyaltyTransactionResource / LoyaltyRuleResource) -
export interface LoyaltyAccount {
  id: number
  guest_id: number
  points_balance: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export type LoyaltyTransactionType = 'earn' | 'redeem' | string

export interface LoyaltyTransaction {
  id: number
  type: LoyaltyTransactionType
  points: number
  source_type: string | null
  source_id: number | null
  description: string | null
  metadata: Record<string, unknown> | null
  created_by_user_id: number | null
  created_at: string
}

export interface LoyaltyRule {
  id: number
  hotel_group_id: number
  is_active: boolean
  earn_points_per_currency: string | null
  redeem_currency_per_point: string | null
  eligible_source_types: string[]
  created_at: string
  updated_at: string
}

// ---- Reviews (ReviewResource, staff listing + moderation) -----
export type ReviewStatus = 'pending' | 'published' | 'rejected'

export interface Review {
  id: number
  reservation_id: number
  rating: number
  text: string | null
  status: ReviewStatus
  created_at: string
  hotel_id?: number
  guest_id?: number | null
  moderated_at?: string | null
}

// ---- Problem reports (guest-submitted in-stay issues, ProblemReportResource) ----
export type ProblemReportCategory =
  | 'ac_heating'
  | 'plumbing_water'
  | 'electricity_lighting'
  | 'room_cleanliness'
  | 'internet_wifi'
  | 'noise_disturbance'

export type ProblemReportUrgency = 'normal' | 'important' | 'urgent'
export type ProblemReportStatus = 'open' | 'in_progress' | 'resolved'

export interface ProblemReport {
  id: number
  reservation_id: number
  guest_id: number
  hotel_id: number
  category: ProblemReportCategory
  urgency: ProblemReportUrgency
  notes: string | null
  status: ProblemReportStatus
  resolved_by_user_id: number | null
  resolved_at: string | null
  created_at: string
  updated_at: string
}

// ---- Notifications (NotificationResource) --------------------
export type NotificationChannel = 'in_app' | 'email' | 'sms'
export type NotificationDeliveryStatus = 'pending' | 'sending' | 'sent' | 'failed'

export interface AppNotification {
  id: number
  reservation_id: number
  hotel_id: number
  type: string
  channel: NotificationChannel
  status: NotificationDeliveryStatus
  locale: string
  subject: string
  body: string
  context: Record<string, unknown> | null
  is_read: boolean
  read_at: string | null
  sent_at: string | null
  failed_at: string | null
  created_at: string
}

// ---- Reports (ReportService — aggregates, not persisted resources) ---
export interface ReportRange { from: string, to: string }

export interface OccupancyHotelRow {
  hotel_id: number
  hotel_name: string
  rooms: number
  nights: number
  capacity_room_nights: number
  booked_room_nights: number
  occupancy_rate: number
}

export interface OccupancyReport {
  range: ReportRange
  hotels: OccupancyHotelRow[]
  totals: {
    rooms: number
    capacity_room_nights: number
    booked_room_nights: number
    occupancy_rate: number
  }
}

export interface RevenueEntry { currency: string, amount: string }

export interface RevenueHotelRow {
  hotel_id: number
  hotel_name: string
  revenue: RevenueEntry[]
}

export interface RevenueReport {
  range: ReportRange
  hotels: RevenueHotelRow[]
  totals: RevenueEntry[]
}

export interface HotelComparisonRow {
  hotel_id: number
  hotel_name: string
  occupancy_rate: number
  booked_room_nights: number
  revenue: RevenueEntry[]
}

export interface HotelComparisonReport {
  range: ReportRange
  hotels: HotelComparisonRow[]
}

export interface StatusCountRow {
  hotel_id: number
  hotel_name: string
  by_status: Record<string, number>
  total: number
}

export interface ReservationsReport {
  range: ReportRange
  hotels: StatusCountRow[]
  totals: Record<string, number>
}

export interface PaymentsReport {
  range: ReportRange
  hotels: StatusCountRow[]
  totals: Record<string, number>
}

export interface ServicesHotelRow {
  hotel_id: number
  hotel_name: string
  by_status: Record<string, number>
  total: number
  revenue: RevenueEntry[]
}

export interface ServicesReport {
  range: ReportRange
  hotels: ServicesHotelRow[]
  totals: { by_status: Record<string, number>, revenue: RevenueEntry[] }
}

export interface LoyaltyHotelRow {
  hotel_id: number
  hotel_name: string
  points_earned: number
  points_redeemed: number
  net: number
}

export interface LoyaltyReport {
  range: ReportRange
  hotels: LoyaltyHotelRow[]
  totals: { points_earned: number, points_redeemed: number, net: number }
}

export interface ReviewsHotelRow {
  hotel_id: number
  hotel_name: string
  by_status: Record<string, number>
  total: number
  average_rating: number | null
}

export interface ReviewsReport {
  range: ReportRange
  hotels: ReviewsHotelRow[]
  totals: { by_status: Record<string, number>, average_rating: number | null, count: number }
}

// ---- Audit log (AuditLogResource) -----------------------------------
export interface AuditLogEntry {
  id: number
  actor_id: number | null
  actor?: { id: number, name: string, email: string } | null
  action: string
  auditable_type: string | null
  auditable_id: number | null
  hotel_id: number | null
  before: Record<string, unknown> | null
  after: Record<string, unknown> | null
  ip_address: string | null
  created_at: string
}
