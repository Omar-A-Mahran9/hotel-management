<script setup lang="ts">
import { reportsService } from '~/services'
import type { HotelComparisonReport, LoyaltyReport, OccupancyReport, PaymentsReport, PaymentStatus, ReservationsReport, ReservationStatus, RevenueReport, ReviewsReport, ReviewStatus, ServiceOrderStatus, ServicesReport } from '~/types/api'
import { PAYMENT_STATUS_TONE, REVIEW_STATUS_TONE, SERVICE_ORDER_STATUS_TONE } from '~/utils/statusMeta'
import { RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'

definePageMeta({ permission: 'reports.view' })
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

// A UI convenience default (last 30 days) — never a backend-invented
// business default; the backend requires from/to explicitly.
function defaultRange() {
  const to = new Date()
  const from = new Date()
  from.setDate(from.getDate() - 29)
  const iso = (d: Date) => d.toISOString().slice(0, 10)
  return { from: iso(from), to: iso(to) }
}
const range = ref(defaultRange())
const hotelId = ref<number | ''>('')

const rangeValid = computed(() => !!range.value.from && !!range.value.to && range.value.from <= range.value.to)

const occupancy = useResource<OccupancyReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.occupancy({ from: range.value.from, to: range.value.to, hotel_id: hotelId.value || undefined })
}, { immediate: false })

const revenue = useResource<RevenueReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.revenue({ from: range.value.from, to: range.value.to, hotel_id: hotelId.value || undefined })
}, { immediate: false })

const comparison = useResource<HotelComparisonReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.hotelComparison({ from: range.value.from, to: range.value.to })
}, { immediate: false })

const reservationsReport = useResource<ReservationsReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.reservations({ from: range.value.from, to: range.value.to, hotel_id: hotelId.value || undefined })
}, { immediate: false })

const paymentsReport = useResource<PaymentsReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.payments({ from: range.value.from, to: range.value.to, hotel_id: hotelId.value || undefined })
}, { immediate: false })

const servicesReport = useResource<ServicesReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.services({ from: range.value.from, to: range.value.to, hotel_id: hotelId.value || undefined })
}, { immediate: false })

const loyaltyReport = useResource<LoyaltyReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.loyalty({ from: range.value.from, to: range.value.to, hotel_id: hotelId.value || undefined })
}, { immediate: false })

const reviewsReport = useResource<ReviewsReport | null>(async () => {
  if (!rangeValid.value) return null
  return reportsService.reviews({ from: range.value.from, to: range.value.to, hotel_id: hotelId.value || undefined })
}, { immediate: false })

function reload() {
  if (!rangeValid.value) return
  if (report.value === 'occupancy') occupancy.reload()
  else if (report.value === 'revenue') revenue.reload()
  else if (report.value === 'comparison') comparison.reload()
  else if (report.value === 'reservations') reservationsReport.reload()
  else if (report.value === 'payments') paymentsReport.reload()
  else if (report.value === 'services') servicesReport.reload()
  else if (report.value === 'loyalty') loyaltyReport.reload()
  else if (report.value === 'reviews') reviewsReport.reload()
}

watch([report, range, hotelId], reload, { deep: true, immediate: true })

function statusEntries(byStatus: Record<string, number>): Array<{ status: string, count: number }> {
  return Object.entries(byStatus)
    .map(([status, count]) => ({ status, count }))
    .sort((a, b) => b.count - a.count)
}

function primaryAmount(entries: { currency: string, amount: string }[]): string {
  if (entries.length === 0) return t('common.notAvailable')
  return entries.map(e => money(e.amount, e.currency)).join(', ')
}

// Simple CSS bar width — display only, never used for a decision.
function barWidth(value: number, max: number): string {
  if (max <= 0) return '0%'
  return `${Math.min(100, Math.round((value / max) * 100))}%`
}

const occupancyMax = computed(() => Math.max(1, ...(occupancy.data.value?.hotels.map(h => h.occupancy_rate) ?? [1])))
const comparisonMax = computed(() => Math.max(1, ...(comparison.data.value?.hotels.map(h => h.occupancy_rate) ?? [1])))
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
      <FormField v-if="report !== 'comparison' && (auth.assignedHotels.length > 1 || auth.isGroupOwner)" :label="t('auditPage.hotel')">
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

    <!-- Occupancy -->
    <div v-if="report === 'occupancy'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="occupancy.pending.value" :rows="3" />
        <ErrorState v-else-if="occupancy.error.value" :error="occupancy.error.value" @retry="occupancy.reload" />
        <EmptyState v-else-if="!occupancy.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="space-y-3 p-4 sm:p-5">
          <div v-for="h in occupancy.data.value.hotels" :key="h.hotel_id" class="space-y-1">
            <div class="flex items-center justify-between text-2sm">
              <span class="font-medium text-foreground">{{ h.hotel_name }}</span>
              <span class="text-muted-foreground">{{ t('reportsPage.occupancyValue', { rate: h.occupancy_rate }) }}</span>
            </div>
            <div class="h-2 overflow-hidden rounded-full bg-secondary">
              <div class="h-full rounded-full bg-primary" :style="{ width: barWidth(h.occupancy_rate, occupancyMax) }" />
            </div>
          </div>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="occupancy.data.value" class="space-y-3 p-4 text-2sm sm:p-5">
          <div class="flex items-center justify-between">
            <span class="text-muted-foreground">{{ t('reportsPage.totalRooms') }}</span>
            <span class="font-medium text-foreground">{{ occupancy.data.value.totals.rooms }}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-muted-foreground">{{ t('reportsPage.bookedNights') }}</span>
            <span class="font-medium text-foreground">{{ occupancy.data.value.totals.booked_room_nights }}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-muted-foreground">{{ t('reportsPage.capacityNights') }}</span>
            <span class="font-medium text-foreground">{{ occupancy.data.value.totals.capacity_room_nights }}</span>
          </div>
          <div class="flex items-center justify-between border-t border-border pt-3">
            <span class="text-muted-foreground">{{ t('reportsPage.overallRate') }}</span>
            <span class="text-lg font-semibold text-primary">{{ t('reportsPage.occupancyValue', { rate: occupancy.data.value.totals.occupancy_rate }) }}</span>
          </div>
        </div>
      </DataCard>
    </div>

    <!-- Revenue -->
    <div v-else-if="report === 'revenue'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="revenue.pending.value" :rows="3" />
        <ErrorState v-else-if="revenue.error.value" :error="revenue.error.value" @retry="revenue.reload" />
        <EmptyState v-else-if="!revenue.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('reportsPage.hotel') }}</th>
                <th class="text-end">
                  {{ t('reportsPage.revenue') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="h in revenue.data.value.hotels" :key="h.hotel_id">
                <td class="font-medium text-foreground">{{ h.hotel_name }}</td>
                <td class="text-end">{{ primaryAmount(h.revenue) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="revenue.data.value" class="space-y-2 p-4 text-2sm sm:p-5">
          <div v-if="!revenue.data.value.totals.length" class="text-muted-foreground">
            {{ t('common.notAvailable') }}
          </div>
          <div v-for="t2 in revenue.data.value.totals" :key="t2.currency" class="flex items-center justify-between">
            <span class="text-muted-foreground">{{ t2.currency }}</span>
            <span class="text-lg font-semibold text-primary">{{ money(t2.amount, t2.currency) }}</span>
          </div>
        </div>
      </DataCard>
    </div>

    <!-- Hotel comparison -->
    <div v-else-if="report === 'comparison'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="comparison.pending.value" :rows="3" />
        <ErrorState v-else-if="comparison.error.value" :error="comparison.error.value" @retry="comparison.reload" />
        <EmptyState v-else-if="!comparison.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="space-y-3 p-4 sm:p-5">
          <div v-for="h in comparison.data.value.hotels" :key="h.hotel_id" class="space-y-1">
            <div class="flex items-center justify-between text-2sm">
              <span class="font-medium text-foreground">{{ h.hotel_name }}</span>
              <span class="text-muted-foreground">{{ t('reportsPage.occupancyValue', { rate: h.occupancy_rate }) }}</span>
            </div>
            <div class="h-2 overflow-hidden rounded-full bg-secondary">
              <div class="h-full rounded-full bg-primary" :style="{ width: barWidth(h.occupancy_rate, comparisonMax) }" />
            </div>
          </div>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="comparison.data.value" class="overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('reportsPage.hotel') }}</th>
                <th class="text-end">
                  {{ t('reportsPage.revenue') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="h in comparison.data.value.hotels" :key="h.hotel_id">
                <td class="text-2sm font-medium text-foreground">{{ h.hotel_name }}</td>
                <td class="text-end text-2sm">{{ primaryAmount(h.revenue) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </DataCard>
    </div>

    <!-- Reservations -->
    <div v-else-if="report === 'reservations'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="reservationsReport.pending.value" :rows="3" />
        <ErrorState v-else-if="reservationsReport.error.value" :error="reservationsReport.error.value" @retry="reservationsReport.reload" />
        <EmptyState v-else-if="!reservationsReport.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('reportsPage.hotel') }}</th>
                <th class="text-end">
                  {{ t('reportsPage.total') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="h in reservationsReport.data.value.hotels" :key="h.hotel_id">
                <td class="font-medium text-foreground">{{ h.hotel_name }}</td>
                <td class="text-end">{{ h.total }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="reservationsReport.data.value" class="space-y-2 p-4 text-2sm sm:p-5">
          <div v-for="e in statusEntries(reservationsReport.data.value.totals)" :key="e.status" class="flex items-center justify-between">
            <StatusBadge :label="t(`status.${e.status}`)" :tone="RESERVATION_STATUS_TONE[e.status as ReservationStatus] ?? 'neutral'" />
            <span class="font-medium text-foreground">{{ e.count }}</span>
          </div>
        </div>
      </DataCard>
    </div>

    <!-- Payments -->
    <div v-else-if="report === 'payments'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="paymentsReport.pending.value" :rows="3" />
        <ErrorState v-else-if="paymentsReport.error.value" :error="paymentsReport.error.value" @retry="paymentsReport.reload" />
        <EmptyState v-else-if="!paymentsReport.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('reportsPage.hotel') }}</th>
                <th class="text-end">
                  {{ t('reportsPage.total') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="h in paymentsReport.data.value.hotels" :key="h.hotel_id">
                <td class="font-medium text-foreground">{{ h.hotel_name }}</td>
                <td class="text-end">{{ h.total }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="paymentsReport.data.value" class="space-y-2 p-4 text-2sm sm:p-5">
          <div v-for="e in statusEntries(paymentsReport.data.value.totals)" :key="e.status" class="flex items-center justify-between">
            <StatusBadge :label="t(`status.${e.status}`)" :tone="PAYMENT_STATUS_TONE[e.status as PaymentStatus] ?? 'neutral'" />
            <span class="font-medium text-foreground">{{ e.count }}</span>
          </div>
        </div>
      </DataCard>
    </div>

    <!-- Services -->
    <div v-else-if="report === 'services'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="servicesReport.pending.value" :rows="3" />
        <ErrorState v-else-if="servicesReport.error.value" :error="servicesReport.error.value" @retry="servicesReport.reload" />
        <EmptyState v-else-if="!servicesReport.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('reportsPage.hotel') }}</th>
                <th class="text-end">
                  {{ t('reportsPage.total') }}
                </th>
                <th class="text-end">
                  {{ t('reportsPage.revenue') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="h in servicesReport.data.value.hotels" :key="h.hotel_id">
                <td class="font-medium text-foreground">{{ h.hotel_name }}</td>
                <td class="text-end">{{ h.total }}</td>
                <td class="text-end">{{ primaryAmount(h.revenue) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="servicesReport.data.value" class="space-y-2 p-4 text-2sm sm:p-5">
          <div v-for="e in statusEntries(servicesReport.data.value.totals.by_status)" :key="e.status" class="flex items-center justify-between">
            <StatusBadge :label="t(`status.${e.status}`)" :tone="SERVICE_ORDER_STATUS_TONE[e.status as ServiceOrderStatus] ?? 'neutral'" />
            <span class="font-medium text-foreground">{{ e.count }}</span>
          </div>
          <div class="flex items-center justify-between border-t border-border pt-3">
            <span class="text-muted-foreground">{{ t('reportsPage.revenue') }}</span>
            <span class="text-lg font-semibold text-primary">{{ primaryAmount(servicesReport.data.value.totals.revenue) }}</span>
          </div>
        </div>
      </DataCard>
    </div>

    <!-- Loyalty -->
    <div v-else-if="report === 'loyalty'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="loyaltyReport.pending.value" :rows="3" />
        <ErrorState v-else-if="loyaltyReport.error.value" :error="loyaltyReport.error.value" @retry="loyaltyReport.reload" />
        <EmptyState v-else-if="!loyaltyReport.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('reportsPage.hotel') }}</th>
                <th class="text-end">
                  {{ t('reportsPage.pointsEarned') }}
                </th>
                <th class="text-end">
                  {{ t('reportsPage.pointsRedeemed') }}
                </th>
                <th class="text-end">
                  {{ t('reportsPage.net') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="h in loyaltyReport.data.value.hotels" :key="h.hotel_id">
                <td class="font-medium text-foreground">{{ h.hotel_name }}</td>
                <td class="text-end">{{ h.points_earned }}</td>
                <td class="text-end">{{ h.points_redeemed }}</td>
                <td class="text-end">{{ h.net }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="loyaltyReport.data.value" class="space-y-3 p-4 text-2sm sm:p-5">
          <div class="flex items-center justify-between">
            <span class="text-muted-foreground">{{ t('reportsPage.pointsEarned') }}</span>
            <span class="font-medium text-foreground">{{ loyaltyReport.data.value.totals.points_earned }}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-muted-foreground">{{ t('reportsPage.pointsRedeemed') }}</span>
            <span class="font-medium text-foreground">{{ loyaltyReport.data.value.totals.points_redeemed }}</span>
          </div>
          <div class="flex items-center justify-between border-t border-border pt-3">
            <span class="text-muted-foreground">{{ t('reportsPage.net') }}</span>
            <span class="text-lg font-semibold text-primary">{{ loyaltyReport.data.value.totals.net }}</span>
          </div>
        </div>
      </DataCard>
    </div>

    <!-- Reviews -->
    <div v-else-if="report === 'reviews'" class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('reportsPage.chartArea')" class="lg:col-span-2">
        <LoadingState v-if="reviewsReport.pending.value" :rows="3" />
        <ErrorState v-else-if="reviewsReport.error.value" :error="reviewsReport.error.value" @retry="reviewsReport.reload" />
        <EmptyState v-else-if="!reviewsReport.data.value?.hotels.length" :title="t('reportsPage.empty')" />
        <div v-else class="overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('reportsPage.hotel') }}</th>
                <th class="text-end">
                  {{ t('reportsPage.total') }}
                </th>
                <th class="text-end">
                  {{ t('reportsPage.averageRating') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="h in reviewsReport.data.value.hotels" :key="h.hotel_id">
                <td class="font-medium text-foreground">{{ h.hotel_name }}</td>
                <td class="text-end">{{ h.total }}</td>
                <td class="text-end">{{ h.average_rating ?? t('common.notAvailable') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </DataCard>
      <DataCard :title="t('reportsPage.tableArea')">
        <div v-if="reviewsReport.data.value" class="space-y-2 p-4 text-2sm sm:p-5">
          <div v-for="e in statusEntries(reviewsReport.data.value.totals.by_status)" :key="e.status" class="flex items-center justify-between">
            <StatusBadge :label="t(`status.${e.status}`)" :tone="REVIEW_STATUS_TONE[e.status as ReviewStatus] ?? 'neutral'" />
            <span class="font-medium text-foreground">{{ e.count }}</span>
          </div>
          <div class="flex items-center justify-between border-t border-border pt-3">
            <span class="text-muted-foreground">{{ t('reportsPage.averageRating') }}</span>
            <span class="text-lg font-semibold text-primary">{{ reviewsReport.data.value.totals.average_rating ?? t('common.notAvailable') }}</span>
          </div>
        </div>
      </DataCard>
    </div>
  </div>
</template>
