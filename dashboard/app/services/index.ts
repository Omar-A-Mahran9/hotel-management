// Typed wrappers over the real Laravel /api/v1 endpoints (see
// md/dashboard-foundation-audit.md §4 and backend routes/api.php). Only
// endpoints that ACTUALLY exist are wrapped here. Missing capabilities are
// tracked in md/dashboard-master.md §"Backend API gaps" — they are never
// faked, and the navigation hides them.
import type {
  AccessGrant,
  AppNotification,
  AuditLogEntry,
  CheckoutResult,
  CheckoutStatus,
  City,
  Country,
  ExtendReservationResult,
  Facility,
  Folio,
  Guest,
  Hotel,
  HotelGroup,
  HotelMedia,
  HotelComparisonReport,
  HotelService,
  IdentityVerification,
  Invoice,
  InvoiceStatus,
  LoyaltyAccount,
  LoyaltyReport,
  LoyaltyRule,
  LoyaltyTransaction,
  OccupancyReport,
  Payment,
  PaymentsReport,
  PaymentStatus,
  Permission,
  Reservation,
  ReservationsReport,
  ReservationStatus,
  RevenueReport,
  Review,
  ReviewsReport,
  ReviewStatus,
  Role,
  RoleWriteBody,
  Room,
  RoomStatus,
  RoomType,
  ServiceCategory,
  ServicesReport,
  ServiceOrder,
  ServiceOrderStatus,
  Settlement,
  StaffUser,
} from '~/types/api'

const api = () => useApi()

// ---- Hotel groups ------------------------------------------------------
export const hotelGroupsService = {
  list: () => api()<HotelGroup[]>('/hotel-groups'),
  get: (id: number) => api()<HotelGroup>(`/hotel-groups/${id}`),
  update: (id: number, body: Partial<Pick<HotelGroup, 'name' | 'slug' | 'is_active'>>) =>
    api()<HotelGroup>(`/hotel-groups/${id}`, { method: 'PUT', body }),
  // Group loyalty economics — Group Owner only (loyalty.rules.manage).
  loyaltyRule: (id: number) => api()<LoyaltyRule>(`/hotel-groups/${id}/loyalty-rule`),
  updateLoyaltyRule: (
    id: number,
    body: {
      is_active?: boolean
      earn_points_per_currency?: string | null
      redeem_currency_per_point?: string | null
    },
  ) => api()<LoyaltyRule>(`/hotel-groups/${id}/loyalty-rule`, { method: 'PATCH', body }),
}

// ---- Hotels ----------------------------------------------------------
// GET /hotels returns the caller's accessible hotels, paginated (per_page
// fixed to 15 server-side; ?page works). `search` / `is_active` / `sort`
// are real server-side filters (IndexHotelRequest) layered on top of the
// caller's server-resolved hotel scope.
export interface HotelListParams {
  page?: number
  per_page?: number
  search?: string
  is_active?: boolean | 0 | 1
  sort?: 'name' | '-name' | 'created_at' | '-created_at'
  [key: string]: unknown
}

export const hotelsService = {
  list: (params: HotelListParams = {}) =>
    api().withMeta<Hotel[]>('/hotels', { query: cleanQuery(params) }),
  get: (id: number) => api()<Hotel>(`/hotels/${id}`),
  create: (body: Record<string, unknown>) => api()<Hotel>('/hotels', { method: 'POST', body }),
  update: (id: number, body: Record<string, unknown>) =>
    api()<Hotel>(`/hotels/${id}`, { method: 'PUT', body }),
}

// ---- Hotel media (logo / cover / gallery, hotel-scoped) --------------
// Real Laravel endpoints (POST/DELETE/PATCH /hotels/{id}/media...). Upload
// is multipart — ofetch sets the boundary from the FormData automatically.
export const hotelMediaService = {
  upload: (hotelId: number, collection: HotelMedia['collection'], file: File) => {
    const body = new FormData()
    body.append('collection', collection)
    body.append('image', file)
    return api()<HotelMedia>(`/hotels/${hotelId}/media`, { method: 'POST', body })
  },
  remove: (hotelId: number, mediaId: number) =>
    api()<null>(`/hotels/${hotelId}/media/${mediaId}`, { method: 'DELETE' }),
  reorderGallery: (hotelId: number, ids: number[]) =>
    api()<HotelMedia[]>(`/hotels/${hotelId}/media/reorder`, { method: 'PATCH', body: { ids } }),
}

// ---- Locations: countries + cities (global reference data) ----------
// Real, paginated Laravel endpoints. `search` / `is_active` / `country_id`
// are server-side filters. The bare `options*` helpers pull a large page
// for API-backed selects.
export interface LocationListParams {
  page?: number
  per_page?: number
  search?: string
  is_active?: boolean | 0 | 1
  country_id?: number
  [key: string]: unknown
}

export const countriesService = {
  list: (params: LocationListParams = {}) =>
    api().withMeta<Country[]>('/countries', { query: cleanQuery(params) }),
  get: (id: number) => api()<Country>(`/countries/${id}`),
  create: (body: Record<string, unknown>) => api()<Country>('/countries', { method: 'POST', body }),
  update: (id: number, body: Record<string, unknown>) =>
    api()<Country>(`/countries/${id}`, { method: 'PATCH', body }),
  activate: (id: number) => api()<Country>(`/countries/${id}/activate`, { method: 'PATCH' }),
  deactivate: (id: number) => api()<Country>(`/countries/${id}/deactivate`, { method: 'PATCH' }),
  remove: (id: number) => api()<null>(`/countries/${id}`, { method: 'DELETE' }),
  // For EntitySelect — active countries only, large page, optional search.
  options: (search?: string) =>
    api()<Country[]>('/countries', { query: cleanQuery({ search, is_active: 1, per_page: 100 }) }),
}

export const citiesService = {
  list: (params: LocationListParams = {}) =>
    api().withMeta<City[]>('/cities', { query: cleanQuery(params) }),
  get: (id: number) => api()<City>(`/cities/${id}`),
  create: (body: Record<string, unknown>) => api()<City>('/cities', { method: 'POST', body }),
  update: (id: number, body: Record<string, unknown>) =>
    api()<City>(`/cities/${id}`, { method: 'PATCH', body }),
  activate: (id: number) => api()<City>(`/cities/${id}/activate`, { method: 'PATCH' }),
  deactivate: (id: number) => api()<City>(`/cities/${id}/deactivate`, { method: 'PATCH' }),
  remove: (id: number) => api()<null>(`/cities/${id}`, { method: 'DELETE' }),
  // Dependent select: cities of ONE country (server-scoped, never leaks others).
  forCountry: (countryId: number, search?: string) =>
    api()<City[]>(`/countries/${countryId}/cities`, {
      query: cleanQuery({ search, is_active: 1, per_page: 100 }),
    }),
}

// ---- Facility catalog (global reference data) -------------------------
// Real, paginated Laravel endpoints, same shape as countries/cities.
// `all: 1` returns every active facility unpaginated (the Hotel create/edit
// picker) — see `pickerOptions()`.
export interface FacilityListParams {
  page?: number
  per_page?: number
  search?: string
  is_active?: boolean | 0 | 1
  [key: string]: unknown
}

export const facilitiesService = {
  list: (params: FacilityListParams = {}) =>
    api().withMeta<Facility[]>('/facilities', { query: cleanQuery(params) }),
  get: (id: number) => api()<Facility>(`/facilities/${id}`),
  create: (body: Record<string, unknown>) => api()<Facility>('/facilities', { method: 'POST', body }),
  update: (id: number, body: Record<string, unknown>) =>
    api()<Facility>(`/facilities/${id}`, { method: 'PUT', body }),
  activate: (id: number) => api()<Facility>(`/facilities/${id}/activate`, { method: 'PATCH' }),
  deactivate: (id: number) => api()<Facility>(`/facilities/${id}/deactivate`, { method: 'PATCH' }),
  remove: (id: number) => api()<null>(`/facilities/${id}`, { method: 'DELETE' }),
  // For the Hotel create/edit facility picker — active only, unpaginated.
  pickerOptions: () => api()<Facility[]>('/facilities', { query: { all: 1 } }),
}

function cleanQuery(params: Record<string, unknown>): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(params).filter(([, v]) => v !== undefined && v !== null && v !== ''),
  )
}

// ---- Room types (hotel-scoped) -------------------------------------
export const roomTypesService = {
  list: (hotelId: number) => api()<RoomType[]>(`/hotels/${hotelId}/room-types`),
  get: (hotelId: number, id: number) => api()<RoomType>(`/hotels/${hotelId}/room-types/${id}`),
  create: (hotelId: number, body: Record<string, unknown>) =>
    api()<RoomType>(`/hotels/${hotelId}/room-types`, { method: 'POST', body }),
  update: (hotelId: number, id: number, body: Record<string, unknown>) =>
    api()<RoomType>(`/hotels/${hotelId}/room-types/${id}`, { method: 'PATCH', body }),
  activate: (hotelId: number, id: number) =>
    api()<RoomType>(`/hotels/${hotelId}/room-types/${id}/activate`, { method: 'PATCH' }),
  deactivate: (hotelId: number, id: number) =>
    api()<RoomType>(`/hotels/${hotelId}/room-types/${id}/deactivate`, { method: 'PATCH' }),
}

// ---- Rooms (hotel-scoped) ----------------------------------------------
export const roomsService = {
  list: (hotelId: number, roomTypeId?: number) =>
    api()<Room[]>(`/hotels/${hotelId}/rooms`, {
      query: roomTypeId ? { room_type_id: roomTypeId } : undefined,
    }),
  get: (hotelId: number, id: number) => api()<Room>(`/hotels/${hotelId}/rooms/${id}`),
  create: (hotelId: number, body: Record<string, unknown>) =>
    api()<Room>(`/hotels/${hotelId}/rooms`, { method: 'POST', body }),
  update: (hotelId: number, id: number, body: Record<string, unknown>) =>
    api()<Room>(`/hotels/${hotelId}/rooms/${id}`, { method: 'PATCH', body }),
  // Status transitions go through the backend room state machine. `booked`
  // is never a valid target here.
  setStatus: (hotelId: number, id: number, status: Extract<RoomStatus, 'available' | 'under_maintenance'>) =>
    api()<Room>(`/hotels/${hotelId}/rooms/${id}/status`, { method: 'PATCH', body: { status } }),
}

// ---- Service catalog (hotel-scoped) ----------------------------------
export const serviceCategoriesService = {
  list: (hotelId: number) => api()<ServiceCategory[]>(`/hotels/${hotelId}/service-categories`),
  create: (hotelId: number, body: Record<string, unknown>) =>
    api()<ServiceCategory>(`/hotels/${hotelId}/service-categories`, { method: 'POST', body }),
  update: (hotelId: number, id: number, body: Record<string, unknown>) =>
    api()<ServiceCategory>(`/hotels/${hotelId}/service-categories/${id}`, { method: 'PATCH', body }),
  activate: (hotelId: number, id: number) =>
    api()<ServiceCategory>(`/hotels/${hotelId}/service-categories/${id}/activate`, { method: 'PATCH' }),
  deactivate: (hotelId: number, id: number) =>
    api()<ServiceCategory>(`/hotels/${hotelId}/service-categories/${id}/deactivate`, { method: 'PATCH' }),
}

export const servicesService = {
  list: (hotelId: number) => api()<HotelService[]>(`/hotels/${hotelId}/services`),
  get: (hotelId: number, id: number) => api()<HotelService>(`/hotels/${hotelId}/services/${id}`),
  create: (hotelId: number, body: Record<string, unknown>) =>
    api()<HotelService>(`/hotels/${hotelId}/services`, { method: 'POST', body }),
  update: (hotelId: number, id: number, body: Record<string, unknown>) =>
    api()<HotelService>(`/hotels/${hotelId}/services/${id}`, { method: 'PATCH', body }),
  activate: (hotelId: number, id: number) =>
    api()<HotelService>(`/hotels/${hotelId}/services/${id}/activate`, { method: 'PATCH' }),
  deactivate: (hotelId: number, id: number) =>
    api()<HotelService>(`/hotels/${hotelId}/services/${id}/deactivate`, { method: 'PATCH' }),
}

// ---- Reviews (hotel-scoped, every moderation state) ------------------
export const reviewsService = {
  list: (hotelId: number, params: { status?: ReviewStatus, page?: number, per_page?: number } = {}) =>
    api().withMeta<Review[]>(`/hotels/${hotelId}/reviews`, { query: cleanQuery(params) }),
  // decision is 'published' or 'rejected' — no other state is accepted.
  moderate: (reviewId: number, decision: Extract<ReviewStatus, 'published' | 'rejected'>) =>
    api()<Review>(`/reviews/${reviewId}/moderate`, { method: 'POST', body: { decision } }),
}

// ---- Reservations ---------------------------------------------------
// GET /reservations is scoped to the caller's hotels, paginated (per_page 15
// fixed; ?page works). There is NO status / hotel / date filter server-side
// (audit §6 gap #1) — any filtering here is client-side over the loaded page
// and is labelled as such in the UI.
export const reservationsService = {
  list: (page = 1) => api().withMeta<Reservation[]>('/reservations', { query: { page } }),
  get: (id: number) => api()<Reservation>(`/reservations/${id}`),
  create: (body: {
    room_type_id: number
    room_id?: number | null
    guest_id: number
    check_in: string
    check_out: string
  }) => api()<Reservation>('/reservations', { method: 'POST', body }),
  transition: (id: number, targetStatus: ReservationStatus) =>
    api()<Reservation>(`/reservations/${id}/transition`, {
      method: 'POST',
      body: { target_status: targetStatus },
    }),
  // Extend Stay — only while checked_in/in_stay. The backend re-checks
  // availability and prices the addition from room_types.base_price; the
  // amount accrues to the folio, settled at checkout like a service order.
  extend: (id: number, newCheckOut: string) =>
    api()<ExtendReservationResult>(`/reservations/${id}/extend`, {
      method: 'POST',
      body: { new_check_out: newCheckOut },
    }),
}

// ---- Front desk (hotel-scoped): arrivals / departures / in-house ------
export const frontDeskService = {
  arrivals: (hotelId: number, params: { date?: string, page?: number, per_page?: number } = {}) =>
    api().withMeta<Reservation[]>(`/hotels/${hotelId}/arrivals`, { query: cleanQuery(params) }),
  departures: (hotelId: number, params: { date?: string, page?: number, per_page?: number } = {}) =>
    api().withMeta<Reservation[]>(`/hotels/${hotelId}/departures`, { query: cleanQuery(params) }),
  inHouse: (hotelId: number, params: { page?: number, per_page?: number } = {}) =>
    api().withMeta<Reservation[]>(`/hotels/${hotelId}/in-house`, { query: cleanQuery(params) }),
}

// ---- Guests (staff directory, not hotel-scoped) -----------------------
export const guestsService = {
  list: (params: { search?: string, page?: number, per_page?: number } = {}) =>
    api().withMeta<Guest[]>('/guests', { query: cleanQuery(params) }),
  get: (id: number) => api()<Guest>(`/guests/${id}`),
  reservations: (id: number, page = 1) =>
    api().withMeta<Reservation[]>(`/guests/${id}/reservations`, { query: { page } }),
  // Register a walk-in guest — front desk, no OTP (guests.manage).
  create: (body: { name?: string, phone: string, email?: string }) =>
    api()<Guest>('/guests', { method: 'POST', body }),
}

// ---- Reservation workspace: payment ------------------------------
export const paymentsService = {
  // The only payment write surface exposed to staff — places a deposit hold.
  hold: (reservationId: number, amount: string, currency?: string) =>
    api()<Payment>(`/reservations/${reservationId}/payment/hold`, {
      method: 'POST',
      body: currency ? { amount, currency } : { amount },
    }),
  // The staff payments ledger for a hotel — read-only, `payments.view`.
  list: (hotelId: number, params: { status?: PaymentStatus, page?: number, per_page?: number } = {}) =>
    api().withMeta<Payment[]>(`/hotels/${hotelId}/payments`, { query: cleanQuery(params) }),
}

// ---- Invoices ledger (hotel-scoped) -----------------------------
export const invoicesService = {
  list: (hotelId: number, params: { status?: InvoiceStatus, page?: number, per_page?: number } = {}) =>
    api().withMeta<Invoice[]>(`/hotels/${hotelId}/invoices`, { query: cleanQuery(params) }),
}

// ---- Settlements ledger (hotel-scoped) --------------------------
export const settlementsService = {
  list: (hotelId: number, params: { status?: CheckoutStatus, page?: number, per_page?: number } = {}) =>
    api().withMeta<Settlement[]>(`/hotels/${hotelId}/settlements`, { query: cleanQuery(params) }),
}

// ---- Reservation workspace: folio -------------------------------
export const folioService = {
  get: (reservationId: number) => api()<Folio>(`/reservations/${reservationId}/folio`),
  // The standalone folio ledger for a hotel — every totals row is computed
  // by the same authoritative FolioService the per-reservation read uses.
  listForHotel: (hotelId: number, params: { search?: string, outstanding?: boolean, page?: number, per_page?: number } = {}) =>
    api().withMeta<Folio[]>(`/hotels/${hotelId}/folios`, {
      query: cleanQuery({ ...params, outstanding: params.outstanding ? 1 : undefined }),
    }),
}

// ---- Reservation workspace: service orders ----------------------
export const serviceOrdersService = {
  list: (reservationId: number) =>
    api()<ServiceOrder[]>(`/reservations/${reservationId}/service-orders`),
  create: (reservationId: number, body: { service_id: number, quantity: number, notes?: string }) =>
    api()<ServiceOrder>(`/reservations/${reservationId}/service-orders`, { method: 'POST', body }),
  transition: (
    reservationId: number,
    orderId: number,
    targetStatus: Extract<ServiceOrderStatus, 'confirmed' | 'fulfilled' | 'cancelled'>,
    reason?: string,
  ) =>
    api()<ServiceOrder>(`/reservations/${reservationId}/service-orders/${orderId}/transition`, {
      method: 'POST',
      body: reason ? { target_status: targetStatus, reason } : { target_status: targetStatus },
    }),
}

// ---- Reservation workspace: identity verification --------------
export const identityVerificationService = {
  status: (reservationId: number) =>
    api()<IdentityVerification>(`/identity-verification/${reservationId}/status`),
  review: (reservationId: number, decision: 'approve' | 'reject', reason?: string) =>
    api()<IdentityVerification>(`/identity-verification/${reservationId}/review`, {
      method: 'POST',
      body: reason ? { decision, reason } : { decision },
    }),
}

// ---- Reservation workspace: digital access / check-in ----------
export const digitalAccessService = {
  get: (reservationId: number) => api()<AccessGrant>(`/access/${reservationId}`),
  revoke: (reservationId: number, reason?: string) =>
    api()<AccessGrant>(`/access/${reservationId}/revoke`, {
      method: 'POST',
      body: reason ? { reason } : {},
    }),
  checkIn: (reservationId: number) =>
    api()<AccessGrant>(`/check-in/${reservationId}`, { method: 'POST', body: {} }),
}

// ---- Reservation workspace: checkout + invoice -----------------
export const checkoutService = {
  perform: (reservationId: number) =>
    api()<CheckoutResult>(`/reservations/${reservationId}/checkout`, { method: 'POST', body: {} }),
  invoice: (reservationId: number) => api()<Invoice>(`/reservations/${reservationId}/invoice`),
}

// ---- Reservation workspace: loyalty ---------------------------
export const loyaltyService = {
  account: (reservationId: number) =>
    api()<LoyaltyAccount>(`/reservations/${reservationId}/loyalty`),
  transactions: (reservationId: number) =>
    api()<LoyaltyTransaction[]>(`/reservations/${reservationId}/loyalty/transactions`),
  earn: (reservationId: number) =>
    api()<LoyaltyTransaction>(`/reservations/${reservationId}/loyalty/earn`, { method: 'POST', body: {} }),
  redeem: (reservationId: number, points: number) =>
    api()<LoyaltyTransaction>(`/reservations/${reservationId}/loyalty/redeem`, {
      method: 'POST',
      body: { points },
    }),
  // Guest-level dashboard — read-only, not hotel-scoped (group-wide, like
  // the guest directory itself). Earn/redeem stay reservation-scoped above.
  forGuest: (guestId: number) => api()<LoyaltyAccount>(`/guests/${guestId}/loyalty`),
  transactionsForGuest: (guestId: number) =>
    api()<LoyaltyTransaction[]>(`/guests/${guestId}/loyalty/transactions`),
}

// ---- Reservation workspace: notifications --------------------
export const notificationsService = {
  list: (reservationId: number, unread = false) =>
    api()<AppNotification[]>(`/reservations/${reservationId}/notifications`, {
      query: unread ? { unread: 1 } : undefined,
    }),
  markRead: (reservationId: number, notificationId: number) =>
    api()<AppNotification>(
      `/reservations/${reservationId}/notifications/${notificationId}/read`,
      { method: 'PATCH' },
    ),
  markAllRead: (reservationId: number) =>
    api()<{ marked_read: number }>(`/reservations/${reservationId}/notifications/read-all`, {
      method: 'POST',
      body: {},
    }),
  // The staff-wide in_app feed for a hotel — read-only.
  forHotel: (hotelId: number, params: { unread?: boolean, page?: number, per_page?: number } = {}) =>
    api().withMeta<AppNotification[]>(`/hotels/${hotelId}/notifications`, {
      query: cleanQuery({ ...params, unread: params.unread ? 1 : undefined }),
    }),
}

// ---- Reports (aggregate reads, not hotel-nested) ----------------------
export const reportsService = {
  occupancy: (params: { from: string, to: string, hotel_id?: number }) =>
    api()<OccupancyReport>('/reports/occupancy', { query: cleanQuery(params) }),
  revenue: (params: { from: string, to: string, hotel_id?: number }) =>
    api()<RevenueReport>('/reports/revenue', { query: cleanQuery(params) }),
  hotelComparison: (params: { from: string, to: string }) =>
    api()<HotelComparisonReport>('/reports/hotel-comparison', { query: cleanQuery(params) }),
  reservations: (params: { from: string, to: string, hotel_id?: number }) =>
    api()<ReservationsReport>('/reports/reservations', { query: cleanQuery(params) }),
  payments: (params: { from: string, to: string, hotel_id?: number }) =>
    api()<PaymentsReport>('/reports/payments', { query: cleanQuery(params) }),
  services: (params: { from: string, to: string, hotel_id?: number }) =>
    api()<ServicesReport>('/reports/services', { query: cleanQuery(params) }),
  loyalty: (params: { from: string, to: string, hotel_id?: number }) =>
    api()<LoyaltyReport>('/reports/loyalty', { query: cleanQuery(params) }),
  reviews: (params: { from: string, to: string, hotel_id?: number }) =>
    api()<ReviewsReport>('/reports/reviews', { query: cleanQuery(params) }),
}

// ---- Audit trail (read-only) -------------------------------------
export interface AuditLogParams {
  actor_id?: number
  action?: string
  auditable_type?: string
  from?: string
  to?: string
  page?: number
  per_page?: number
  [key: string]: unknown
}

export const auditService = {
  forHotel: (hotelId: number, params: AuditLogParams = {}) =>
    api().withMeta<AuditLogEntry[]>(`/hotels/${hotelId}/audit-log`, { query: cleanQuery(params) }),
  // Group Owner only — group-wide, `hotel_id` optionally narrows it.
  global: (params: AuditLogParams & { hotel_id?: number } = {}) =>
    api().withMeta<AuditLogEntry[]>('/audit-log', { query: cleanQuery(params) }),
}

// ---- RBAC reference --------------------------------------------------
export const rbacService = {
  roles: () => api()<Role[]>('/roles'),
  role: (id: number) => api()<Role>(`/roles/${id}`),
  createRole: (body: RoleWriteBody) => api()<Role>('/roles', { method: 'POST', body }),
  updateRole: (id: number, body: Partial<RoleWriteBody>) => api()<Role>(`/roles/${id}`, { method: 'PUT', body }),
  deleteRole: (id: number) => api()<null>(`/roles/${id}`, { method: 'DELETE' }),
  permissions: () => api()<Permission[]>('/permissions'),
}

// ---- Staff users ---------------------------------------------------
export const usersService = {
  list: (page = 1) => api().withMeta<StaffUser[]>('/users', { query: { page } }),
  get: (id: number) => api()<StaffUser>(`/users/${id}`),
  create: (body: Record<string, unknown>) => api()<StaffUser>('/users', { method: 'POST', body }),
  update: (id: number, body: Record<string, unknown>) =>
    api()<StaffUser>(`/users/${id}`, { method: 'PUT', body }),
  remove: (id: number) => api()<null>(`/users/${id}`, { method: 'DELETE' }),
}
