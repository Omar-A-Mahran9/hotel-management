<script setup lang="ts">
import { folioService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Folio } from '~/types/api'

definePageMeta({ permission: 'folio.view' })

const { t } = useI18n()
const hotelCtx = useHotelContextStore()
const route = useRoute()

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)
const search = ref('')
const outstandingOnly = ref(false)
const page = ref(1)

const list = useResource(async () => {
  if (hotelId.value == null) return null
  return folioService.listForHotel(hotelId.value, {
    search: search.value.trim() || undefined,
    outstanding: outstandingOnly.value,
    page: page.value,
  })
}, { immediate: false })

watch(hotelId, () => {
  if (hotelId.value != null) { page.value = 1; list.reload() }
}, { immediate: true })

watch(outstandingOnly, () => {
  page.value = 1
  list.reload()
})

let debounce: ReturnType<typeof setTimeout> | null = null
watch(search, () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(() => {
    page.value = 1
    list.reload()
  }, 300)
})

function changePage(n: number) {
  page.value = n
  list.reload()
}

const columns = computed<Column[]>(() => [
  { key: 'reservation', label: t('folioPage.reservation') },
  { key: 'guest', label: t('folioPage.guest') },
  { key: 'charges', label: t('folioPage.charges'), align: 'end' },
  { key: 'payments', label: t('folioPage.payments'), align: 'end' },
  { key: 'outstanding', label: t('folioPage.outstanding'), align: 'end' },
  { key: 'actions', label: t('common.actions'), align: 'end' },
])
</script>

<template>
  <div>
    <PageHeader :title="t('nav.folio')" :subtitle="t('folioPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <FilterBar :active="outstandingOnly || !!search.trim()" @clear="() => { outstandingOnly = false; search = '' }">
        <div class="w-full max-w-xs">
          <SearchField v-model="search" :placeholder="t('folioPage.searchPlaceholder')" />
        </div>
        <label class="flex items-center gap-2 text-2sm text-foreground">
          <input v-model="outstandingOnly" type="checkbox">
          {{ t('folioPage.outstandingOnly') }}
        </label>
      </FilterBar>

      <DataTable
        :columns="columns"
        :rows="list.data.value?.data ?? []"
        :loading="list.pending.value"
        :error="list.error.value"
        :meta="list.data.value?.meta ?? null"
        :empty-title="t('folioPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-reservation="{ row }">
          <NuxtLink :to="`/reservations/${(row as Folio).reservation.id}`" class="font-medium text-primary hover:underline">
            #{{ (row as Folio).reservation.id }}
          </NuxtLink>
        </template>
        <template #cell-guest="{ row }">
          <NuxtLink v-if="(row as Folio).reservation.guest_id" :to="`/guests/${(row as Folio).reservation.guest_id}`" class="text-primary hover:underline">
            #{{ (row as Folio).reservation.guest_id }}
          </NuxtLink>
          <span v-else class="text-muted-foreground">{{ t('common.notAvailable') }}</span>
        </template>
        <template #cell-charges="{ row }">
          {{ money((row as Folio).totals.charges_total, (row as Folio).currency) }}
        </template>
        <template #cell-payments="{ row }">
          {{ money((row as Folio).totals.payments_total, (row as Folio).currency) }}
        </template>
        <template #cell-outstanding="{ row }">
          <span
            class="font-medium"
            :class="Number((row as Folio).totals.outstanding_total) > 0 ? 'text-warning' : 'text-foreground'"
          >
            {{ money((row as Folio).totals.outstanding_total, (row as Folio).currency) }}
          </span>
        </template>
        <template #cell-actions="{ row }">
          <NuxtLink :to="`/reservations/${(row as Folio).reservation.id}?tab=folio`" class="btn btn-ghost px-2 py-1 text-2sm">
            {{ t('folioPage.openWorkspace') }}
          </NuxtLink>
        </template>
      </DataTable>
    </template>
  </div>
</template>
