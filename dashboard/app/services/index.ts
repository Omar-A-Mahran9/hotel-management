// Typed wrappers over the real Laravel /api/v1 endpoints (see
// md/dashboard-foundation-audit.md §4 and backend routes/api.php). Only
// endpoints that ACTUALLY exist are wrapped here. Missing capabilities are
// tracked in md/dashboard-master.md §"Backend API gaps" — they are never
// faked, and the navigation hides them.
import type {
  AccessGrant,
  AppNotification,
  CheckoutResult,
  City,
  Country,
  Facility,
  Folio,
  Hotel,
  HotelGroup,
  HotelMedia,
  HotelService,
  IdentityVerification,
  Invoice,
  LoyaltyAccount,
  LoyaltyRule,
  LoyaltyTransaction,
  Payment,
  Permission,
  Reservation,
  ReservationStatus,
  Role,
  RoleWriteBody,
  Room,
  RoomStatus,
  RoomType,
  ServiceCategory,
  ServiceOrder,
  ServiceOrderStatus,
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
}

// ---- Reservation workspace: payment ------------------------------
export const paymentsService = {
  // The only payment write surface exposed to staff — places a deposit hold.
  hold: (reservationId: number, amount: string, currency?: string) =>
    api()<Payment>(`/reservations/${reservationId}/payment/hold`, {
      method: 'POST',
      body: currency ? { amount, currency } : { amount },
    }),
}

// ---- Reservation workspace: folio -------------------------------
export const folioService = {
  get: (reservationId: number) => api()<Folio>(`/reservations/${reservationId}/folio`),
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
