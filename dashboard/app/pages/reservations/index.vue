<script setup lang="ts">
import { reservationsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Reservation, ReservationStatus } from '~/types/api'
import { RESERVATION_STATUSES, RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'
import { date, money } from '~/utils/format'

definePageMeta({ permission: 'reservations.view' })

const { t } = useI18n()
const router = useRouter()
const auth = useAuthStore()
const { can } = useCan()

const page = ref(1)
const list = useResource(() => reservationsService.list(page.value))

// Client-side filters over the loaded page only — the backend list endpoint
// has no status/hotel/date query params yet (audit §6 gap #1). Labelled.
const statusFilter = ref<ReservationStatus | ''>('')
const hotelFilter = ref<number | ''>('')
const search = ref('')

const hotelName = (hotelId: number) =>
  auth.assignedHotels.find(h => h.id === hotelId)?.name ?? `#${hotelId}`

const rows = computed<Reservation[]>(() => {
  let all = list.data.value?.data ?? []
  if (statusFilter.value) all = all.filter(r => r.status === statusFilter.value)
  if (hotelFilter.value) all = all.filter(r => r.hotel_id === hotelFilter.value)
  const q = search.value.trim()
  if (q) all = all.filter(r => String(r.id).includes(q))
  return all
})

const columns: Column[] = [
  { key: 'id', label: t('reservations.id') },
  { key: 'hotel_id', label: t('reservations.hotel') },
  { key: 'check_in', label: t('reservations.checkIn'), nowrap: true },
  { key: 'check_out', label: t('reservations.checkOut'), nowrap: true },
  { key: 'price_snapshot', label: t('reservations.price'), align: 'end' },
  { key: 'status', label: t('reservations.status') },
]

function changePage(n: number) {
  page.value = n
  list.reload()
}

</script>

<template>
  <div>
    <PageHeader :title="t('reservations.title')" :subtitle="t('reservations.subtitle')">
      <template v-if="can('reservations.manage')" #actions>
        <NuxtLink to="/reservations/new" class="btn btn-primary">
          <KtIcon name="plus" /> {{ t('reservations.new') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <InfoNote class="mb-4">
      {{ t('common.clientFilterNote') }} {{ t('common.perPageNote') }}
    </InfoNote>

    <div class="mb-3 flex flex-wrap items-end gap-3">
      <div class="max-w-xs grow">
        <SearchField v-model="search" placeholder="#ID" />
      </div>
      <FormField :label="t('reservations.filterStatus')">
        <select v-model="statusFilter" class="input min-w-44">
          <option value="">
            {{ t('common.all') }}
          </option>
          <option v-for="s in RESERVATION_STATUSES" :key="s" :value="s">
            {{ t(`status.${s}`) }}
          </option>
        </select>
      </FormField>
      <FormField v-if="auth.assignedHotels.length > 1 || auth.isGroupOwner" :label="t('reservations.filterHotel')">
        <select v-model="hotelFilter" class="input min-w-44">
          <option value="">
            {{ t('common.all') }}
          </option>
          <option v-for="h in auth.assignedHotels" :key="h.id" :value="h.id">
            {{ h.name }}
          </option>
        </select>
      </FormField>
    </div>

    <DataTable
      :columns="columns"
      :rows="rows"
      :loading="list.pending.value"
      :error="list.error.value"
      :meta="list.data.value?.meta ?? null"
      clickable-rows
      @retry="list.reload"
      @page="changePage"
      @row-click="(row: Reservation) => router.push(`/reservations/${row.id}`)"
    >
      <template #cell-id="{ row }">
        <span class="font-medium text-primary">#{{ (row as Reservation).id }}</span>
      </template>
      <template #cell-hotel_id="{ row }">
        {{ hotelName((row as Reservation).hotel_id) }}
      </template>
      <template #cell-check_in="{ row }">
        {{ date((row as Reservation).check_in) }}
      </template>
      <template #cell-check_out="{ row }">
        {{ date((row as Reservation).check_out) }}
      </template>
      <template #cell-price_snapshot="{ row }">
        {{ money((row as Reservation).price_snapshot) }}
      </template>
      <template #cell-status="{ row }">
        <StatusBadge
          :label="t(`status.${(row as Reservation).status}`)"
          :tone="RESERVATION_STATUS_TONE[(row as Reservation).status]"
        />
      </template>
    </DataTable>
  </div>
</template>
