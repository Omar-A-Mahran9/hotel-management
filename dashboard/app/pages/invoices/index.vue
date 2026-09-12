<script setup lang="ts">
import { invoicesService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Invoice, InvoiceStatus } from '~/types/api'
import { INVOICE_STATUS_TONE } from '~/utils/statusMeta'

definePageMeta({ permission: 'invoice.view' })

const { t } = useI18n()
const hotelCtx = useHotelContextStore()
const route = useRoute()

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)
const status = ref<'all' | InvoiceStatus>('all')
const page = ref(1)

const list = useResource(async () => {
  if (hotelId.value == null) return null
  return invoicesService.list(hotelId.value, {
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

const columns = computed<Column[]>(() => [
  { key: 'invoice_number', label: t('invoicesPage.number') },
  { key: 'reservation_id', label: t('invoicesPage.reservation') },
  { key: 'invoiceStatus', label: t('invoicesPage.invoiceStatus') },
  { key: 'subtotal', label: t('invoicesPage.subtotal'), align: 'end' },
  { key: 'outstanding', label: t('invoicesPage.outstanding'), align: 'end' },
  { key: 'issued_at', label: t('invoicesPage.issued') },
])
</script>

<template>
  <div>
    <PageHeader :title="t('nav.invoices')" :subtitle="t('invoicesPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <FilterBar :active="filtersActive" @clear="clearFilters">
        <FormField :label="t('invoicesPage.invoiceStatus')">
          <select v-model="status" class="input min-w-40">
            <option value="all">
              {{ t('common.all') }}
            </option>
            <option value="draft">
              {{ t('status.draft') }}
            </option>
            <option value="issued">
              {{ t('status.issued') }}
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
        :empty-title="t('invoicesPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-invoice_number="{ row }">
          <NuxtLink :to="`/reservations/${(row as Invoice).reservation_id}?tab=invoice`" class="text-primary hover:underline">
            {{ (row as Invoice).invoice_number || `#${(row as Invoice).id}` }}
          </NuxtLink>
        </template>
        <template #cell-reservation_id="{ row }">
          <NuxtLink :to="`/reservations/${(row as Invoice).reservation_id}`" class="text-primary hover:underline">
            #{{ (row as Invoice).reservation_id }}
          </NuxtLink>
        </template>
        <template #cell-invoiceStatus="{ row }">
          <StatusBadge
            :label="t(`status.${(row as Invoice).status}`)"
            :tone="INVOICE_STATUS_TONE[(row as Invoice).status]"
          />
        </template>
        <template #cell-subtotal="{ row }">
          <span class="font-medium text-foreground">
            {{ money((row as Invoice).subtotal, (row as Invoice).currency) }}
          </span>
        </template>
        <template #cell-outstanding="{ row }">
          {{ money((row as Invoice).outstanding_total, (row as Invoice).currency) }}
        </template>
        <template #cell-issued_at="{ row }">
          {{ dateTime((row as Invoice).issued_at) }}
        </template>
      </DataTable>
    </template>
  </div>
</template>
