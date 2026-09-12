<script setup lang="ts">
import { settlementsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { CheckoutStatus, Settlement } from '~/types/api'
import { CHECKOUT_STATUS_TONE } from '~/utils/statusMeta'

definePageMeta({ permission: 'checkout.perform' })

const { t } = useI18n()
const hotelCtx = useHotelContextStore()
const route = useRoute()

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)
const status = ref<'all' | CheckoutStatus>('all')
const page = ref(1)

const list = useResource(async () => {
  if (hotelId.value == null) return null
  return settlementsService.list(hotelId.value, {
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

const STATUSES: CheckoutStatus[] = ['in_progress', 'awaiting_settlement', 'settlement_failed', 'completed']

const columns = computed<Column[]>(() => [
  { key: 'reservation_id', label: t('settlementsPage.reservation') },
  { key: 'outstanding_total', label: t('settlementsPage.amount'), align: 'end' },
  { key: 'settlementStatus', label: t('settlementsPage.settlementStatus') },
  { key: 'date', label: t('settlementsPage.date') },
])
</script>

<template>
  <div>
    <PageHeader :title="t('nav.settlements')" :subtitle="t('settlementsPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <FilterBar :active="filtersActive" @clear="clearFilters">
        <FormField :label="t('settlementsPage.settlementStatus')">
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
        :empty-title="t('settlementsPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-reservation_id="{ row }">
          <NuxtLink :to="`/reservations/${(row as Settlement).reservation_id}?tab=checkout`" class="text-primary hover:underline">
            #{{ (row as Settlement).reservation_id }}
          </NuxtLink>
        </template>
        <template #cell-outstanding_total="{ row }">
          <span class="font-medium text-foreground">
            {{ money((row as Settlement).outstanding_total, (row as Settlement).currency) }}
          </span>
        </template>
        <template #cell-settlementStatus="{ row }">
          <StatusBadge
            :label="t(`status.${(row as Settlement).status}`)"
            :tone="CHECKOUT_STATUS_TONE[(row as Settlement).status]"
          />
        </template>
        <template #cell-date="{ row }">
          {{ dateTime((row as Settlement).completed_at ?? (row as Settlement).started_at) }}
        </template>
      </DataTable>
    </template>
  </div>
</template>
