import { describe, expect, it } from 'vitest'
import { NAVIGATION } from '~/config/navigation'
import { backendGapItemsFor, filterNavigation, isItemVisible } from '~/utils/navigation'

const GROUP_OWNER_PERMS = [
  'hotel-groups.manage', 'hotels.view', 'hotels.manage', 'users.view', 'users.manage',
  'roles.view', 'permissions.view', 'inventory.view', 'inventory.manage',
  'reservations.view', 'reservations.manage', 'payments.manage', 'loyalty.view',
]
const RECEPTION_PERMS = [
  'hotels.view', 'inventory.view', 'reservations.view', 'check-in.perform',
  'digital-access.view', 'folio.view', 'checkout.perform', 'invoice.view', 'loyalty.view',
]

describe('navigation filter', () => {
  it('hides items whose permission the user lacks', () => {
    const nav = filterNavigation(NAVIGATION, { permissions: RECEPTION_PERMS, hasHotels: true })
    const keys = nav.flatMap(s => s.items.map(i => i.key))
    expect(keys).toContain('reservations') // reservations.view
    expect(keys).toContain('room-types') // inventory.view
    expect(keys).toContain('hotels') // reception holds hotels.view
    expect(keys).not.toContain('users') // needs users.view
    expect(keys).not.toContain('roles') // needs roles.view
  })

  it('shows admin items to a Group Owner', () => {
    const nav = filterNavigation(NAVIGATION, { permissions: GROUP_OWNER_PERMS, hasHotels: true })
    const keys = nav.flatMap(s => s.items.map(i => i.key))
    expect(keys).toEqual(expect.arrayContaining(['overview', 'reservations', 'hotels', 'room-types', 'rooms', 'users', 'roles']))
  })

  it('never surfaces a backend-gap item as a live link', () => {
    const nav = filterNavigation(NAVIGATION, { permissions: GROUP_OWNER_PERMS, hasHotels: true })
    const keys = nav.flatMap(s => s.items.map(i => i.key))
    for (const gap of ['guests', 'reviews', 'reports', 'audit', 'payments', 'loyalty', 'checkin']) {
      expect(keys).not.toContain(gap)
    }
  })

  it('hides hotel-scoped items when the user has no hotels', () => {
    expect(isItemVisible(
      { key: 'rooms', labelKey: '', to: '/rooms', icon: '', permission: 'inventory.view', scope: 'hotel' },
      { permissions: ['inventory.view'], hasHotels: false },
    )).toBe(false)
  })

  it('lists backend-gap items the user would otherwise be allowed to see', () => {
    const gaps = backendGapItemsFor(NAVIGATION, GROUP_OWNER_PERMS).map(i => i.key)
    expect(gaps).toContain('reports')
    expect(gaps).toContain('audit')
  })
})
