import { NAVIGATION } from '~/config/navigation'
import { filterNavigation, gapItemsFor } from '~/utils/navigation'

// Resolves NAVIGATION down to what the current user may actually see. All
// rules live in the pure `filterNavigation` helper (unit-tested); this
// composable only supplies the reactive context.
export function useNavigation() {
  const auth = useAuthStore()
  const hotelCtx = useHotelContextStore()

  const ctx = computed(() => ({
    permissions: auth.permissions,
    hasHotels: hotelCtx.availableHotels.length > 0,
  }))

  const visibleSections = computed(() => filterNavigation(NAVIGATION, ctx.value))
  const gapItems = computed(() => gapItemsFor(NAVIGATION, auth.permissions))

  return { visibleSections, gapItems }
}
