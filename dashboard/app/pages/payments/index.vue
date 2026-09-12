<script setup lang="ts">
import { paymentsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Payment, PaymentStatus } from '~/types/api'
import { PAYMENT_STATUS_TONE } from '~/utils/statusMeta'

definePageMeta({ permission: 'payments.view' })

const { t } = useI18n()
const hotelCtx = useHotelContextStore()
const route = useRoute()

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)
const status = ref<'all' | PaymentStatus>('all')
const page = ref(1)

const list = useResource(async () => {
  if (hotelId.value == null) return null
  return paymentsService.list(hotelId.value, {
    status: status.value === 'all' ? undefined : status.value,
    page: page.value,
  })
}, { immediate: false })

watch(hotelId, () => {
  if (hotelId.value != null) { page.value = 1; list.reload() }
}, { immediate: true })

watch(status, () => {
  page.value = 1
  list.reload()
})

function changePage(n: number) {
  page.value = n
  list.reload()
}

const filtersActive = computed(() => status.value !== 'all')
function clearFilters() {
  status.value = 'all'
}

const STATUSES: PaymentStatus[] = [
  'not_started', 'hold_requested', 'hold_active', 'hold_failed',
  'capture_requested', 'captured', 'capture_failed',
  'final_settlement_requested', 'settled', 'settlement_failed',
  'cancelled', 'expired', 'refund_requested', 'refunded', 'refund_failed',
]

const columns = computed<Column[]>(() => [
  { key: 'reservation_id', label: t('paymentsPage.reservation') },
  { key: 'amount', label: t('paymentsPage.amount'), align: 'end' },
  { key: 'status', label: t('paymentsPage.paymentStatus') },
  { key: 'created_at', label: t('paymentsPage.created') },
])
</script>

<template>
  <div>
    <PageHeader :title="t('nav.payments')" :subtitle="t('paymentsPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <FilterBar :active="filtersActive" @clear="clearFilters">
        <FormField :label="t('paymentsPage.filterStatus')">
          <select v-model="status" class="input min-w-44">
            <option value="all">
              {{ t('common.all') }}
            </option>
            <option v-for="s in STATUSES" :key="s" :value="s">
              {{ t(`status.${s}`) }}
            </option>
          </select>
        </FormField>
      </FilterBar>

      <DataTable
        :columns="columns"
        :rows="list.data.value?.data ?? []"
        :loading="list.pending.value"
        :error="list.error.value"
        :meta="list.data.value?.meta ?? null"
        :empty-title="t('paymentsPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-reservation_id="{ row }">
          <NuxtLink :to="`/reservations/${(row as Payment).reservation_id}?tab=payment`" class="text-primary hover:underline">
            #{{ (row as Payment).reservation_id }}
          </NuxtLink>
        </template>
        <template #cell-amount="{ row }">
          <span class="font-medium text-foreground">
            {{ money((row as Payment).amount, (row as Payment).currency) }}
          </span>
        </template>
        <template #cell-status="{ row }">
          <StatusBadge
            :label="t(`status.${(row as Payment).status}`)"
            :tone="PAYMENT_STATUS_TONE[(row as Payment).status]"
          />
        </template>
        <template #cell-created_at="{ row }">
          {{ dateTime((row as Payment).created_at) }}
        </template>
      </DataTable>
    </template>
  </div>
</template>
