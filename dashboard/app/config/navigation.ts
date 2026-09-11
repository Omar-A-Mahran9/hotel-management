// Single navigation definition for the whole dashboard (the final approved
// information architecture). The sidebar renders every item whose
// `permission` the signed-in user holds. An item whose backing list/detail
// endpoint does not exist yet carries `backendGap: true` — it still appears
// in its proper section with a lock marker and routes to a professionally
// structured page that shows an honest "awaiting backend endpoint" state
// (never fake data). See md/dashboard-master.md §"Backend API gaps".

export interface NavItem {
  key: string
  labelKey: string // i18n key
  to: string
  icon: string // keenicons class suffix (ki-outline ki-<icon>)
  permission?: string | string[] // any-of
  scope?: 'group' | 'hotel' // 'hotel' items need a concrete hotel selected
  backendGap?: boolean
  // A collapsible sub-group (e.g. Administration -> Locations). The parent
  // is shown when at least one child is visible; `to` is the first child's
  // route so the header stays a valid link.
  children?: NavItem[]
}

export interface NavSection {
  key: string
  labelKey: string
  items: NavItem[]
}

export const NAVIGATION: NavSection[] = [
  {
    key: 'main',
    labelKey: 'nav.section.main',
    items: [
      { key: 'overview', labelKey: 'nav.overview', to: '/', icon: 'ki-element-11' },
    ],
  },
  {
    key: 'hotels',
    labelKey: 'nav.section.hotels',
    items: [
      {
        key: 'hotels',
        labelKey: 'nav.hotels',
        to: '/hotels',
        icon: 'ki-office-bag',
        permission: 'hotels.view',
      },
      {
        key: 'facilities',
        labelKey: 'nav.facilities',
        to: '/facilities',
        icon: 'ki-abstract-39',
        permission: ['facilities.view', 'facilities.manage'],
      },
      {
        key: 'room-types',
        labelKey: 'nav.roomTypes',
        to: '/room-types',
        icon: 'ki-cube-2',
        permission: 'inventory.view',
        scope: 'hotel',
      },
      {
        key: 'rooms',
        labelKey: 'nav.rooms',
        to: '/rooms',
        icon: 'ki-home-2',
        permission: 'inventory.view',
        scope: 'hotel',
      },
    ],
  },
  {
    key: 'operations',
    labelKey: 'nav.section.operations',
    items: [
      {
        key: 'reservations',
        labelKey: 'nav.reservations',
        to: '/reservations',
        icon: 'ki-calendar-tick',
        permission: 'reservations.view',
      },
      {
        key: 'services',
        labelKey: 'nav.services',
        to: '/services',
        icon: 'ki-parcel',
        permission: 'services.view',
        scope: 'hotel',
      },
      {
        key: 'guests',
        labelKey: 'nav.guests',
        to: '/guests',
        icon: 'ki-people',
        permission: 'reservations.view',
        backendGap: true, // no GET /guests resource
      },
      {
        key: 'digital-access',
        labelKey: 'nav.digitalAccess',
        to: '/digital-access',
        icon: 'ki-entrance-left',
        permission: 'check-in.perform',
        backendGap: true, // no arrivals/departures/in-house list endpoint
      },
    ],
  },
  {
    key: 'finance',
    labelKey: 'nav.section.finance',
    items: [
      {
        key: 'payments',
        labelKey: 'nav.payments',
        to: '/payments',
        icon: 'ki-dollar',
        permission: 'payments.manage',
        backendGap: true, // only reservation-scoped; no hotel/group ledger
      },
      {
        key: 'folio',
        labelKey: 'nav.folio',
        to: '/folio',
        icon: 'ki-book-open',
        permission: 'folio.view',
        backendGap: true, // reservation-scoped only; lookup routes into the workspace
      },
      {
        key: 'checkout',
        labelKey: 'nav.checkout',
        to: '/checkout',
        icon: 'ki-exit-right-corner',
        permission: 'checkout.perform',
        backendGap: true, // reservation-scoped only; lookup routes into the workspace
      },
      {
        key: 'invoices',
        labelKey: 'nav.invoices',
        to: '/invoices',
        icon: 'ki-document',
        permission: 'invoice.view',
        backendGap: true, // only reservation-scoped; no ledger
      },
      {
        key: 'settlements',
        labelKey: 'nav.settlements',
        to: '/settlements',
        icon: 'ki-bank',
        permission: 'checkout.perform',
        backendGap: true, // no settlement ledger endpoint
      },
    ],
  },
  {
    key: 'customer',
    labelKey: 'nav.section.customer',
    items: [
      {
        key: 'loyalty',
        labelKey: 'nav.loyalty',
        to: '/loyalty',
        icon: 'ki-medal-star',
        permission: 'loyalty.view',
        backendGap: true, // only reservation-scoped; no group loyalty ledger
      },
      {
        key: 'reviews',
        labelKey: 'nav.reviews',
        to: '/reviews',
        icon: 'ki-star',
        permission: 'hotels.view',
        backendGap: true, // no reviews domain on the backend
      },
      {
        key: 'notifications',
        labelKey: 'nav.notifications',
        to: '/notifications',
        icon: 'ki-notification-status',
        permission: 'notifications.view',
        backendGap: true, // reservation-scoped feed only; no staff-wide feed
      },
    ],
  },
  {
    key: 'reports',
    labelKey: 'nav.section.reports',
    items: [
      {
        key: 'reports',
        labelKey: 'nav.reports',
        to: '/reports',
        icon: 'ki-chart-simple',
        permission: 'hotels.view',
        backendGap: true, // no reporting endpoints
      },
    ],
  },
  {
    key: 'administration',
    labelKey: 'nav.section.administration',
    items: [
      {
        key: 'users',
        labelKey: 'nav.users',
        to: '/users',
        icon: 'ki-shield-tick',
        permission: 'users.view',
      },
      {
        key: 'roles',
        labelKey: 'nav.roles',
        to: '/roles',
        icon: 'ki-key',
        permission: 'roles.view',
      },
      {
        key: 'hotel-group',
        labelKey: 'nav.hotelGroup',
        to: '/hotel-group',
        icon: 'ki-abstract-26',
        permission: 'hotel-groups.manage',
      },
      {
        key: 'locations',
        labelKey: 'nav.locations',
        to: '/countries',
        icon: 'ki-geolocation',
        permission: ['locations.view', 'locations.manage'],
        children: [
          {
            key: 'countries',
            labelKey: 'nav.countries',
            to: '/countries',
            icon: 'ki-flag',
            permission: ['locations.view', 'locations.manage'],
          },
          {
            key: 'cities',
            labelKey: 'nav.cities',
            to: '/cities',
            icon: 'ki-geolocation',
            permission: ['locations.view', 'locations.manage'],
          },
        ],
      },
      {
        key: 'audit',
        labelKey: 'nav.audit',
        to: '/audit',
        icon: 'ki-notepad-edit',
        permission: 'users.view',
        backendGap: true, // audit written on every sensitive action, no read endpoint
      },
    ],
  },
  {
    key: 'settings',
    labelKey: 'nav.section.settings',
    items: [
      { key: 'settings', labelKey: 'nav.settings', to: '/settings', icon: 'ki-setting-2' },
    ],
  },
]
