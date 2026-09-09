import { describe, expect, it } from 'vitest'
import { hasAll, hasAny, hasPermission } from '~/utils/permissions'

const PERMS = ['reservations.view', 'inventory.view', 'check-in.perform']

describe('permission predicates', () => {
  it('hasPermission is an exact slug match', () => {
    expect(hasPermission(PERMS, 'reservations.view')).toBe(true)
    expect(hasPermission(PERMS, 'reservations.manage')).toBe(false)
  })

  it('hasAny is true when at least one slug is held', () => {
    expect(hasAny(PERMS, ['reservations.manage', 'inventory.view'])).toBe(true)
    expect(hasAny(PERMS, ['users.view', 'roles.view'])).toBe(false)
  })

  it('hasAll requires every slug', () => {
    expect(hasAll(PERMS, ['reservations.view', 'inventory.view'])).toBe(true)
    expect(hasAll(PERMS, ['reservations.view', 'reservations.manage'])).toBe(false)
  })
})
