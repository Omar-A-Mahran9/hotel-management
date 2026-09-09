import { describe, expect, it } from 'vitest'
import { NAVIGATION } from '~/config/navigation'
import { filterNavigation, gapItemsFor, isItemVisible } from '~/utils/navigation'

const GROUP_OWNER_PERMS = [
  'hotel-groups.manage', 'hotels.view', 'hotels.manage', 'users.view', 'users.manage',
  'roles.view', 'permissions.view', 'inventory.view', 'inventory.manage',
  'reservations.view', 'reservations.manage', 'payments.manage', 'loyalty.view',
  'services.view', 'services.manage', 'loyalty.rules.manage', 'invoice.view',
  'folio.view', 'checkout.perform', 'notifications.view', 'check-in.perform',
]
const RECEPTION_PERMS = [
  'hotels.view', 'inventory.view', 'reservations.view', 'check-in.perform',
  'digital-access.view', 'folio.view', 'checkout.perform', 'invoice.view', 'loyalty.view',
  'services.view', 'service-orders.view', 'service-orders.manage', 'notifications.view',
]

describe('navigation filter', () => {
  it('hides items whose permission the user lacks', () => {
    const nav = filterNavigation(NAVIGATION, { permissions: RECEPTION_PERMS, hasHotels: true })
    const keys = nav.flatMap(s => s.items.map(i => i.key))
    expect(keys).toContain('reservations')
    expect(keys).toContain('room-types')
    expect(keys).toContain('hotels')
    expect(keys).toContain('services')
    expect(keys).toContain('settings')
    expect(keys).not.toContain('users') // needs users.view
    expect(keys).not.toContain('roles') // needs roles.view
    expect(keys).not.toContain('hotel-group') // needs hotel-groups.manage
    expect(keys).not.toContain('payments') // needs payments.manage
  })

  it('shows every IA section item to a Group Owner', () => {
    const nav = filterNavigation(NAVIGATION, { permissions: GROUP_OWNER_PERMS, hasHotels: true })
    const keys = nav.flatMap(s => s.items.map(i => i.key))
    expect(keys).toEqual(expect.arrayContaining([
      'overview', 'hotels', 'room-types', 'rooms',
      'reservations', 'services', 'guests', 'digital-access',
      'payments', 'folio', 'checkout', 'invoices', 'settlements',
      'loyalty', 'reviews', 'notifications', 'reports',
      'users', 'roles', 'hotel-group', 'audit', 'settings',
    ]))
  })

  it('keeps backend-gap items visible in their own section (they route to an honest page)', () => {
    const nav = filterNavigation(NAVIGATION, { permissions: GROUP_OWNER_PERMS, hasHotels: true })
    const finance = nav.find(s => s.key === 'finance')
    expect(finance?.items.map(i => i.key)).toContain('payments')
    expect(finance?.items.every(i => i.to.startsWith('/'))).toBe(true)
  })

  it('hides hotel-scoped items when the user has no hotels', () => {
    expect(isItemVisible(
      { key: 'rooms', labelKey: '', to: '/rooms', icon: '', permission: 'inventory.view', scope: 'hotel' },
      { permissions: ['inventory.view'], hasHotels: false },
    )).toBe(false)
  })

  it('gapItemsFor lists the documented gaps the user could otherwise see', () => {
    const gaps = gapItemsFor(NAVIGATION, GROUP_OWNER_PERMS).map(i => i.key)
    expect(gaps).toContain('reports')
    expect(gaps).toContain('audit')
    expect(gaps).toContain('guests')
    expect(gaps).not.toContain('hotels') // hotels has a real endpoint
  })
})
