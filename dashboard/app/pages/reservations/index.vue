<script setup lang="ts">
import { reservationsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Reservation, ReservationStatus } from '~/types/api'
import { RESERVATION_STATUSES, RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'

definePageMeta({ permission: 'reservations.view' })

const { t } = useI18n()
const router = useRouter()

const page = ref(1)
const list = useResource(() => reservationsService.list(page.value))

// Client-side filters over the loaded page only — the backend list endpoint
// has no status/hotel/date query params yet (audit §6 gap #1).
const statusFilter = ref<ReservationStatus | ''>('')
const search = ref('')

const rows = computed<Reservation[]>(() => {
  let all = list.data.value?.data ?? []
  if (statusFilter.value) all = all.filter(r => r.status === statusFilter.value)
  const q = search.value.trim()
  if (q) all = all.filter(r => String(r.id).includes(q))
  return all
})

const columns: Column[] = [
  { key: 'id', label: t('reservations.id') },
  { key: 'hotel_id', label: t('reservations.hotel'), align: 'end' },
  { key: 'room_type_id', label: t('reservations.roomType'), align: 'end' },
  { key: 'room_id', label: t('reservations.room'), align: 'end' },
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
    <PageHeader :title="t('reservations.title')" :subtitle="t('reservations.subtitle')" />

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
      <template #cell-room_id="{ row }">
        {{ (row as Reservation).room_id ?? t('reservations.unassigned') }}
      </template>
      <template #cell-price_snapshot="{ row }">
        {{ (row as Reservation).price_snapshot }}
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
