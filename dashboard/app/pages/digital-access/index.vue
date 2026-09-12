<script setup lang="ts">
import { frontDeskService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Reservation } from '~/types/api'
import { RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'

definePageMeta({ permission: 'reservations.view' })

const { t } = useI18n()
const hotelCtx = useHotelContextStore()
const route = useRoute()

type TabKey = 'arrivals' | 'departures' | 'in-house'

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)

const initialTab = (route.query.tab as string) ?? ''
const tab = ref<TabKey>(
  initialTab === 'departures' || initialTab === 'in-house' ? initialTab : 'arrivals',
)
const page = ref(1)

const tabs = computed(() => [
  { key: 'arrivals' as const, label: t('digitalAccessPage.arrivals') },
  { key: 'departures' as const, label: t('digitalAccessPage.departures') },
  { key: 'in-house' as const, label: t('digitalAccessPage.inHouse') },
])

const list = useResource(async () => {
  if (hotelId.value == null) return null
  if (tab.value === 'arrivals') return frontDeskService.arrivals(hotelId.value, { page: page.value })
  if (tab.value === 'departures') return frontDeskService.departures(hotelId.value, { page: page.value })
  return frontDeskService.inHouse(hotelId.value, { page: page.value })
}, { immediate: false })

watch(hotelId, () => {
  if (hotelId.value != null) { page.value = 1; list.reload() }
}, { immediate: true })

watch(tab, () => {
  page.value = 1
  list.reload()
})

function changePage(n: number) {
  page.value = n
  list.reload()
}

const columns = computed<Column[]>(() => [
  { key: 'id', label: t('digitalAccessPage.reservation') },
  { key: 'guest_id', label: t('digitalAccessPage.guest') },
  { key: 'check_in', label: t('digitalAccessPage.checkIn') },
  { key: 'check_out', label: t('digitalAccessPage.checkOut') },
  { key: 'status', label: t('digitalAccessPage.accessStatus') },
  { key: 'actions', label: t('common.actions'), align: 'end' },
])

const emptyTitle = computed(() => {
  if (tab.value === 'arrivals') return t('digitalAccessPage.emptyArrivals')
  if (tab.value === 'departures') return t('digitalAccessPage.emptyDepartures')
  return t('digitalAccessPage.emptyInHouse')
})
</script>

<template>
  <div>
    <PageHeader :title="t('nav.digitalAccess')" :subtitle="t('digitalAccessPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <AppTabs v-model="tab" :tabs="tabs" class="mb-4" />

      <DataTable
        :columns="columns"
        :rows="list.data.value?.data ?? []"
        :loading="list.pending.value"
        :error="list.error.value"
        :meta="list.data.value?.meta ?? null"
        :empty-title="emptyTitle"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-id="{ row }">
          <NuxtLink :to="`/reservations/${(row as Reservation).id}`" class="text-primary hover:underline">
            #{{ (row as Reservation).id }}
          </NuxtLink>
        </template>
        <template #cell-guest_id="{ row }">
          <NuxtLink v-if="(row as Reservation).guest_id" :to="`/guests/${(row as Reservation).guest_id}`" class="text-primary hover:underline">
            #{{ (row as Reservation).guest_id }}
          </NuxtLink>
          <span v-else class="text-muted-foreground">{{ t('common.notAvailable') }}</span>
        </template>
        <template #cell-check_in="{ row }">
          {{ date((row as Reservation).check_in) }}
        </template>
        <template #cell-check_out="{ row }">
          {{ date((row as Reservation).check_out) }}
        </template>
        <template #cell-status="{ row }">
          <StatusBadge
            :label="t(`status.${(row as Reservation).status}`)"
            :tone="RESERVATION_STATUS_TONE[(row as Reservation).status]"
          />
        </template>
        <template #cell-actions="{ row }">
          <NuxtLink :to="`/reservations/${(row as Reservation).id}?tab=access`" class="btn btn-ghost px-2 py-1 text-2sm">
            {{ t('digitalAccessPage.openWorkspace') }}
          </NuxtLink>
        </template>
      </DataTable>
    </template>
  </div>
</template>
