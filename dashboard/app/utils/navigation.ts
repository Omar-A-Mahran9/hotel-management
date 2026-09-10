import type { NavItem, NavSection } from '~/config/navigation'
import { hasAny } from '~/utils/permissions'

export interface NavContext {
  permissions: readonly string[]
  hasHotels: boolean
}

// Pure navigation filter (unit-testable). An item is shown when the user
// holds its permission and, for hotel-scoped items, has at least one hotel.
// `backendGap` no longer hides an item — it only decorates it (lock marker)
// and its page renders an honest unavailable state.
export function filterNavigation(sections: NavSection[], ctx: NavContext): NavSection[] {
  return sections
    .map(section => ({
      ...section,
      items: section.items
        .filter(item => isItemVisible(item, ctx))
        .map(item => item.children
          ? { ...item, children: item.children.filter(child => isItemVisible(child, ctx)) }
          : item),
    }))
    .filter(section => section.items.length > 0)
}

export function isItemVisible(item: NavItem, ctx: NavContext): boolean {
  // A sub-group is visible when at least one of its children is.
  if (item.children && item.children.length > 0) {
    return item.children.some(child => isItemVisible(child, ctx))
  }
  if (item.permission) {
    const list = Array.isArray(item.permission) ? item.permission : [item.permission]
    if (!hasAny(ctx.permissions, list)) return false
  }
  if (item.scope === 'hotel' && !ctx.hasHotels) return false
  return true
}

// Items whose backing endpoint is a documented gap AND that the user could
// otherwise see — used only for docs / the completeness report.
export function gapItemsFor(sections: NavSection[], permissions: readonly string[]): NavItem[] {
  return sections
    .flatMap(s => s.items)
    .filter((item) => {
      if (!item.backendGap) return false
      if (!item.permission) return true
      const list = Array.isArray(item.permission) ? item.permission : [item.permission]
      return hasAny(permissions, list)
    })
}
