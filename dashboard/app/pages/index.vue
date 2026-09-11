<script setup lang="ts">
import { hotelsService, reservationsService, roomsService, roomTypesService } from '~/services'
import { RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'
import { date, money } from '~/utils/format'

const { t } = useI18n()
const auth = useAuthStore()
const hotelCtx = useHotelContextStore()
const { can } = useCan()

const scopeLabel = computed(() =>
  hotelCtx.isAllHotels || hotelCtx.currentHotelId == null
    ? t('overview.scopeAll')
    : t('overview.scopeHotel', { hotel: hotelCtx.currentHotel?.name ?? '' }),
)

// --- Recent reservations (real: GET /reservations, first page) -----------
const canSeeReservations = can('reservations.view')
const reservations = useResource(() => reservationsService.list(1), { immediate: canSeeReservations })
const recentRows = computed(() => (reservations.data.value?.data ?? []).slice(0, 8))
const reservationsTotal = computed(() => reservations.data.value?.meta.total ?? null)

// Status breakdown over the loaded page only — labelled as such.
const statusBreakdown = computed(() => {
  const counts: Record<string, number> = {}
  for (const r of reservations.data.value?.data ?? []) counts[r.status] = (counts[r.status] ?? 0) + 1
  return Object.entries(counts).sort((a, b) => b[1] - a[1])
})

// --- Inventory snapshot (real: only when one hotel is in scope) ---------
const canSeeInventory = can('inventory.view')
const inventoryHotelId = computed(() => hotelCtx.currentHotelId)

const inventory = useResource(async () => {
  const id = inventoryHotelId.value
  if (id == null) return null
  const [types, rooms] = await Promise.all([roomTypesService.list(id), roomsService.list(id)])
  return {
    roomTypes: types.length,
    rooms: rooms.length,
    available: rooms.filter(r => r.status === 'available').length,
    maintenance: rooms.filter(r => r.status === 'under_maintenance').length,
  }
}, { immediate: false })

watch(inventoryHotelId, () => {
  if (canSeeInventory && inventoryHotelId.value != null) inventory.reload()
}, { immediate: true })

// --- Hotels count (real: GET /hotels meta.total) ----------------------
const hotels = useResource(() => hotelsService.list({ page: 1 }), { immediate: can('hotels.view') })
const hotelsTotal = computed(() => hotels.data.value?.meta.total ?? hotelCtx.availableHotels.length)

const currentHotelName = computed(() => hotelCtx.currentHotel?.name ?? '')

// Quick actions — permission-gated shortcuts to the most common tasks.
const quickActions = computed(() => {
  const out: Array<{ to: string, label: string, icon: string }> = []
  if (can('hotels.manage')) out.push({ to: '/hotels/new', label: t('hotels.new'), icon: 'plus' })
  if (can('reservations.view')) out.push({ to: '/reservations', label: t('nav.reservations'), icon: 'calendar-tick' })
  if (can('inventory.view')) out.push({ to: '/rooms', label: t('nav.rooms'), icon: 'home-2' })
  if (can('services.view')) out.push({ to: '/services', label: t('nav.services'), icon: 'parcel' })
  if (can('users.manage')) out.push({ to: '/users', label: t('users.new'), icon: 'shield-tick' })
  return out
})
</script>

<template>
  <div>
    <PageHeader :title="t('overview.title')" :subtitle="t('overview.welcome', { name: auth.user?.name ?? '' })">
      <template #meta>
        <p class="mt-1 text-2sm font-medium text-primary">
          {{ scopeLabel }}
        </p>
      </template>
    </PageHeader>

    <div v-if="quickActions.length" class="mb-5 flex flex-wrap gap-2">
      <NuxtLink
        v-for="a in quickActions"
        :key="a.to"
        :to="a.to"
        class="btn btn-secondary"
      >
        <KtIcon :name="a.icon" /> {{ a.label }}
      </NuxtLink>
    </div>

    <InfoNote :title="t('overview.kpiGapTitle')" class="mb-5">
      {{ t('overview.kpiGapBody') }}
    </InfoNote>

    <div class="mb-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard v-if="can('hotels.view')" :label="t('nav.hotels')" :value="hotelsTotal" icon="office-bag" />
      <StatCard
        v-if="canSeeReservations && reservationsTotal != null"
        :label="t('overview.reservationsTotal')"
        :value="reservationsTotal"
        icon="calendar-tick"
      />
      <StatCard
        v-if="canSeeInventory && inventory.data.value"
        :label="t('overview.available')"
        :value="`${inventory.data.value.available} / ${inventory.data.value.rooms}`"
        icon="home-2"
        :hint="currentHotelName"
      />
      <StatCard
        v-if="canSeeInventory && inventory.data.value"
        :label="t('overview.maintenance')"
        :value="inventory.data.value.maintenance"
        icon="wrench"
        :hint="currentHotelName"
      />
    </div>

    <div class="grid gap-6 lg:grid-cols-3">
      <div class="lg:col-span-2">
        <DataCard :title="t('overview.recentReservations')" no-pad>
          <template v-if="canSeeReservations">
            <LoadingState v-if="reservations.pending.value" :rows="5" />
            <ErrorState v-else-if="reservations.error.value" :error="reservations.error.value" @retry="reservations.reload" />
            <EmptyState v-else-if="recentRows.length === 0" />
            <table v-else class="table-base">
              <thead>
                <tr>
                  <th>{{ t('reservations.id') }}</th>
                  <th>{{ t('reservations.checkIn') }}</th>
                  <th>{{ t('reservations.checkOut') }}</th>
                  <th class="text-end">
                    {{ t('reservations.price') }}
                  </th>
                  <th>{{ t('reservations.status') }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in recentRows" :key="r.id">
                  <td>
                    <NuxtLink :to="`/reservations/${r.id}`" class="font-medium text-primary hover:underline">
                      #{{ r.id }}
                    </NuxtLink>
                  </td>
                  <td class="whitespace-nowrap">
                    {{ date(r.check_in) }}
                  </td>
                  <td class="whitespace-nowrap">
                    {{ date(r.check_out) }}
                  </td>
                  <td class="text-end">
                    {{ money(r.price_snapshot) }}
                  </td>
                  <td>
                    <StatusBadge :label="t(`status.${r.status}`)" :tone="RESERVATION_STATUS_TONE[r.status]" />
                  </td>
                </tr>
              </tbody>
            </table>
          </template>
          <EmptyState v-else :title="t('errors.forbiddenTitle')" :body="t('errors.forbiddenBody')" icon="lock-2" />
          <template v-if="canSeeReservations && recentRows.length" #footer>
            <NuxtLink to="/reservations" class="text-2sm font-medium text-primary hover:underline">
              {{ t('common.view') }} · {{ t('nav.reservations') }}
            </NuxtLink>
          </template>
        </DataCard>
      </div>

      <div class="space-y-6">
        <DataCard :title="t('overview.inventorySnapshot')">
          <template v-if="!canSeeInventory">
            <EmptyState :title="t('errors.forbiddenTitle')" :body="t('errors.forbiddenBody')" icon="lock-2" />
          </template>
          <template v-else-if="inventoryHotelId == null">
            <p class="text-sm text-muted-foreground">
              {{ t('overview.noHotelForInventory') }}
            </p>
          </template>
          <template v-else>
            <LoadingState v-if="inventory.pending.value" :rows="3" />
            <ErrorState v-else-if="inventory.error.value" :error="inventory.error.value" @retry="inventory.reload" />
            <ul v-else-if="inventory.data.value" class="space-y-2.5 text-sm">
              <li class="flex items-center justify-between">
                <span class="text-muted-foreground">{{ t('overview.roomTypes') }}</span>
                <span class="font-semibold">{{ inventory.data.value.roomTypes }}</span>
              </li>
              <li class="flex items-center justify-between">
                <span class="text-muted-foreground">{{ t('overview.rooms') }}</span>
                <span class="font-semibold">{{ inventory.data.value.rooms }}</span>
              </li>
              <li class="flex items-center justify-between">
                <span class="text-muted-foreground">{{ t('overview.available') }}</span>
                <span class="font-semibold text-success">{{ inventory.data.value.available }}</span>
              </li>
              <li class="flex items-center justify-between">
                <span class="text-muted-foreground">{{ t('overview.maintenance') }}</span>
                <span class="font-semibold text-warning">{{ inventory.data.value.maintenance }}</span>
              </li>
            </ul>
          </template>
        </DataCard>

        <DataCard v-if="canSeeReservations && statusBreakdown.length" :title="t('overview.statusBreakdown')">
          <ul class="space-y-2 text-sm">
            <li v-for="[st, n] in statusBreakdown" :key="st" class="flex items-center justify-between">
              <StatusBadge :label="t(`status.${st}`)" :tone="RESERVATION_STATUS_TONE[st as keyof typeof RESERVATION_STATUS_TONE]" />
              <span class="font-semibold">{{ n }}</span>
            </li>
          </ul>
        </DataCard>
      </div>
    </div>
  </div>
</template>
