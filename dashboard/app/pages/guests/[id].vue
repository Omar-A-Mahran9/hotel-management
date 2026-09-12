<script setup lang="ts">
import { guestsService, loyaltyService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { LoyaltyTransaction, Reservation } from '~/types/api'
import { RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'
import { date, money } from '~/utils/format'

definePageMeta({ permission: 'guests.view' })

const { t } = useI18n()
const { can } = useCan()
const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const id = Number(route.params.id)
const canViewLoyalty = can('loyalty.view')

const guest = useResource(() => guestsService.get(id))

const loyaltyAccount = useResource(
  () => loyaltyService.forGuest(id),
  { immediate: canViewLoyalty },
)
const loyaltyTransactions = useResource(
  () => loyaltyService.transactionsForGuest(id),
  { immediate: canViewLoyalty },
)

const loyaltyColumns: Column[] = [
  { key: 'created_at', label: t('loyaltyPage.when') },
  { key: 'type', label: t('loyaltyPage.type') },
  { key: 'points', label: t('loyaltyPage.points'), align: 'end' },
  { key: 'description', label: t('loyaltyPage.description') },
]

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

        <DataCard v-if="canViewLoyalty" :title="t('nav.loyalty')">
          <LoadingState v-if="loyaltyAccount.pending.value" :rows="1" />
          <ErrorState
            v-else-if="loyaltyAccount.error.value"
            :error="loyaltyAccount.error.value"
            @retry="loyaltyAccount.reload"
          />
          <template v-else-if="loyaltyAccount.data.value">
            <div class="flex items-center gap-3 border-b border-border px-4 py-4 sm:px-5">
              <div class="flex size-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <KtIcon name="medal-star" class="size-5" />
              </div>
              <div>
                <div class="text-2sm text-muted-foreground">
                  {{ t('loyaltyPage.balance') }}
                </div>
                <div class="text-lg font-semibold text-foreground">
                  {{ t('loyaltyPage.pointsValue', { count: loyaltyAccount.data.value.points_balance }) }}
                </div>
              </div>
            </div>

            <DataTable
              :columns="loyaltyColumns"
              :rows="loyaltyTransactions.data.value ?? []"
              :loading="loyaltyTransactions.pending.value"
              :error="loyaltyTransactions.error.value"
              :empty-title="t('loyaltyPage.empty')"
              @retry="loyaltyTransactions.reload"
            >
              <template #cell-created_at="{ row }">
                {{ dateTime((row as LoyaltyTransaction).created_at) }}
              </template>
              <template #cell-type="{ row }">
                <StatusBadge
                  :label="t(`loyaltyPage.type${(row as LoyaltyTransaction).type === 'earn' ? 'Earn' : 'Redeem'}`)"
                  :tone="(row as LoyaltyTransaction).type === 'earn' ? 'success' : 'warning'"
                />
              </template>
              <template #cell-points="{ row }">
                <span
                  class="font-medium"
                  :class="(row as LoyaltyTransaction).type === 'earn' ? 'text-success' : 'text-warning'"
                >
                  {{ (row as LoyaltyTransaction).type === 'earn' ? '+' : '-' }}{{ (row as LoyaltyTransaction).points }}
                </span>
              </template>
              <template #cell-description="{ row }">
                {{ (row as LoyaltyTransaction).description || t('common.notAvailable') }}
              </template>
            </DataTable>
          </template>
        </DataCard>
      </div>
    </template>
  </div>
</template>
