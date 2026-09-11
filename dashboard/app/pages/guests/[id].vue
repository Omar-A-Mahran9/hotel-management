<script setup lang="ts">
import { guestsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Reservation } from '~/types/api'
import { RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'
import { date, money } from '~/utils/format'

definePageMeta({ permission: 'guests.view' })

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const id = Number(route.params.id)

const guest = useResource(() => guestsService.get(id))

const page = ref(1)
const reservations = useResource(() => guestsService.reservations(id, page.value))

function changePage(n: number) {
  page.value = n
  reservations.reload()
}

const hotelName = (hotelId: number) =>
  auth.assignedHotels.find(h => h.id === hotelId)?.name ?? `#${hotelId}`

const facts = computed(() => {
  const g = guest.data.value
  if (!g) return []
  return [
    { label: t('guestsPage.email'), value: g.email || t('common.notAvailable') },
    { label: t('guestsPage.phone'), value: g.phone },
    { label: t('guestsPage.phoneVerified'), value: g.phone_verified_at ? t('common.yes') : t('common.no') },
    { label: t('guestsPage.profileComplete'), value: g.profile_complete ? t('common.yes') : t('common.no') },
    { label: t('guestsPage.created'), value: date(g.created_at) },
  ]
})

const columns: Column[] = [
  { key: 'id', label: t('reservations.id') },
  { key: 'hotel_id', label: t('reservations.hotel') },
  { key: 'check_in', label: t('reservations.checkIn'), nowrap: true },
  { key: 'check_out', label: t('reservations.checkOut'), nowrap: true },
  { key: 'price_snapshot', label: t('reservations.price'), align: 'end' },
  { key: 'status', label: t('reservations.status') },
]
</script>

<template>
  <div>
    <LoadingState v-if="guest.pending.value" :rows="3" />
    <ErrorState v-else-if="guest.error.value" :error="guest.error.value" @retry="guest.reload" />
    <template v-else-if="guest.data.value">
      <PageHeader
        :title="guest.data.value.name || t('guestsPage.unnamed')"
        :subtitle="t('guestsPage.profile')"
      >
        <template #actions>
          <NuxtLink to="/guests" class="btn btn-secondary">
            <KtIcon name="left" /> {{ t('common.back') }}
          </NuxtLink>
        </template>
      </PageHeader>

      <div class="grid gap-6">
        <DataCard :title="t('guestsPage.contact')">
          <FactGrid :facts="facts" />
        </DataCard>

        <DataCard :title="t('guestsPage.history')">
          <DataTable
            :columns="columns"
            :rows="reservations.data.value?.data ?? []"
            :loading="reservations.pending.value"
            :error="reservations.error.value"
            :meta="reservations.data.value?.meta ?? null"
            :empty-title="t('guestsPage.noReservations')"
            clickable-rows
            @retry="reservations.reload"
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
        </DataCard>
      </div>
    </template>
  </div>
</template>
