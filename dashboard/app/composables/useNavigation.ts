import { NAVIGATION } from '~/config/navigation'
import { backendGapItemsFor, filterNavigation } from '~/utils/navigation'

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
  const backendGapItems = computed(() => backendGapItemsFor(NAVIGATION, auth.permissions))

  return { visibleSections, backendGapItems }
}
