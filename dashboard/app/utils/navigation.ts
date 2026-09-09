import type { NavItem, NavSection } from '~/config/navigation'
import { hasAny } from '~/utils/permissions'

export interface NavContext {
  permissions: readonly string[]
  hasHotels: boolean
}

// Pure navigation filter (unit-testable). Mirrors the rules in
// useNavigation(): permission held, endpoint exists (no backendGap),
// hotel-scoped items need at least one selectable hotel.
export function filterNavigation(sections: NavSection[], ctx: NavContext): NavSection[] {
  return sections
    .map(section => ({
      ...section,
      items: section.items.filter(item => isItemVisible(item, ctx)),
    }))
    .filter(section => section.items.length > 0)
}

export function isItemVisible(item: NavItem, ctx: NavContext): boolean {
  if (item.backendGap) return false
  if (item.permission) {
    const list = Array.isArray(item.permission) ? item.permission : [item.permission]
    if (!hasAny(ctx.permissions, list)) return false
  }
  if (item.scope === 'hotel' && !ctx.hasHotels) return false
  return true
}

export function backendGapItemsFor(sections: NavSection[], permissions: readonly string[]): NavItem[] {
  return sections
    .flatMap(s => s.items)
    .filter((item) => {
      if (!item.backendGap) return false
      if (!item.permission) return true
      const list = Array.isArray(item.permission) ? item.permission : [item.permission]
      return hasAny(permissions, list)
    })
}
