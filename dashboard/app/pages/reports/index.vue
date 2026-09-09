<script setup lang="ts">
definePageMeta({ permission: 'hotels.view' })
const { t } = useI18n()
const auth = useAuthStore()

type ReportKey = 'occupancy' | 'reservations' | 'revenue' | 'payments' | 'services' | 'loyalty' | 'reviews' | 'comparison'

const report = ref<ReportKey>('occupancy')
const tabs = computed<Array<{ key: ReportKey, label: string }>>(() => ([
  { key: 'occupancy', label: t('reportsPage.occupancy') },
  { key: 'reservations', label: t('reportsPage.reservations') },
  { key: 'revenue', label: t('reportsPage.revenue') },
  { key: 'payments', label: t('reportsPage.payments') },
  { key: 'services', label: t('reportsPage.services') },
  { key: 'loyalty', label: t('reportsPage.loyalty') },
  { key: 'reviews', label: t('reportsPage.reviews') },
  { key: 'comparison', label: t('reportsPage.comparison') },
]))

const range = ref({ from: '', to: '' })
const hotelId = ref<number | ''>('')

const endpoint = computed(() => `GET /api/v1/reports/${report.value}?from=&to=&hotel_id=`)
</script>

<template>
  <div>
    <PageHeader :title="t('nav.reports')" :subtitle="t('reportsPage.subtitle')">
      <template #actions>
        <button type="button" class="btn btn-secondary" disabled :title="t('reportsPage.exportHint')">
          <KtIcon name="exit-down" /> {{ t('common.export') }}
        </button>
      </template>
    </PageHeader>

    <AppTabs v-model="report" :tabs="tabs" class="mb-4" />

    <FilterBar>
      <DateRangeField v-model="range" />
      <FormField v-if="auth.assignedHotels.length > 1 || auth.isGroupOwner" :label="t('auditPage.hotel')">
        <select v-model="hotelId" class="input min-w-44">
          <option value="">
            {{ t('hotelSelector.allHotels') }}
          </option>
          <option v-for="h in auth.assignedHotels" :key="h.id" :value="h.id">
            {{ h.name }}
          </option>
        </select>
      </FormField>
    </FilterBar>

    <div class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <div class="flex h-56 items-center justify-center">
          <UnavailablePanel :body="t('gap.reportsBody')" :endpoints="[endpoint]" />
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div class="flex h-56 items-center justify-center">
          <UnavailablePanel :body="t('gap.reportsBody')" />
        </div>
      </DataCard>
    </div>
  </div>
</template>
