<script setup lang="ts">
import { problemReportsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { ProblemReport, ProblemReportCategory, ProblemReportStatus } from '~/types/api'
import { ApiError } from '~/utils/apiError'
import { PROBLEM_STATUS_TONE, PROBLEM_STATUS_TRANSITIONS, PROBLEM_URGENCY_TONE } from '~/utils/statusMeta'

definePageMeta({ permission: 'problems.view' })

const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()
const hotelCtx = useHotelContextStore()
const route = useRoute()
const canManage = can('problems.manage')

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)
const status = ref<'all' | ProblemReportStatus>('all')
const page = ref(1)

const list = useResource(async () => {
  if (hotelId.value == null) return null
  return problemReportsService.list(hotelId.value, {
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

// Decorative icon per category — purely a UI convenience (see rooms/services
// list patterns), not backend data.
const CATEGORY_ICON: Record<ProblemReportCategory, string> = {
  ac_heating: 'thermometer',
  plumbing_water: 'drop',
  electricity_lighting: 'electricity',
  room_cleanliness: 'brush',
  internet_wifi: 'wifi',
  noise_disturbance: 'speaker',
}

const columns = computed<Column[]>(() => [
  { key: 'guest_id', label: t('problemReportsPage.guest') },
  { key: 'reservation_id', label: t('problemReportsPage.reservation') },
  { key: 'category', label: t('problemReportsPage.category') },
  { key: 'urgency', label: t('problemReportsPage.urgency') },
  { key: 'notes', label: t('problemReportsPage.notes') },
  { key: 'status', label: t('problemReportsPage.status') },
  { key: 'created_at', label: t('problemReportsPage.created') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

const transitioning = ref<number | null>(null)
async function transition(report: ProblemReport, target: 'in_progress' | 'resolved') {
  if (transitioning.value) return
  transitioning.value = report.id
  try {
    await problemReportsService.transitionStatus(report.id, target)
    app.pushToast('success', t(target === 'in_progress' ? 'problemReportsPage.movedToInProgress' : 'problemReportsPage.markedResolved'))
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    transitioning.value = null
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('nav.problemReports')" :subtitle="t('problemReportsPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <FilterBar :active="filtersActive" @clear="clearFilters">
        <FormField :label="t('problemReportsPage.status')">
          <select v-model="status" class="input min-w-40">
            <option value="all">
              {{ t('common.all') }}
            </option>
            <option value="open">
              {{ t('status.open') }}
            </option>
            <option value="in_progress">
              {{ t('status.in_progress') }}
            </option>
            <option value="resolved">
              {{ t('status.resolved') }}
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
        :empty-title="t('problemReportsPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-guest_id="{ row }">
          <NuxtLink v-if="(row as ProblemReport).guest_id" :to="`/guests/${(row as ProblemReport).guest_id}`" class="text-primary hover:underline">
            #{{ (row as ProblemReport).guest_id }}
          </NuxtLink>
          <span v-else class="text-muted-foreground">{{ t('common.notAvailable') }}</span>
        </template>
        <template #cell-reservation_id="{ row }">
          <NuxtLink :to="`/reservations/${(row as ProblemReport).reservation_id}`" class="text-primary hover:underline">
            #{{ (row as ProblemReport).reservation_id }}
          </NuxtLink>
        </template>
        <template #cell-category="{ row }">
          <span class="inline-flex items-center gap-1.5">
            <KtIcon :name="CATEGORY_ICON[(row as ProblemReport).category]" class="shrink-0 text-muted-foreground" />
            {{ t(`problemReportsPage.category_${(row as ProblemReport).category}`) }}
          </span>
        </template>
        <template #cell-urgency="{ row }">
          <StatusBadge
            :label="t(`problemReportsPage.urgency_${(row as ProblemReport).urgency}`)"
            :tone="PROBLEM_URGENCY_TONE[(row as ProblemReport).urgency]"
          />
        </template>
        <template #cell-notes="{ row }">
          <p class="line-clamp-2 max-w-sm text-2sm">
            {{ (row as ProblemReport).notes || t('common.notAvailable') }}
          </p>
        </template>
        <template #cell-status="{ row }">
          <StatusBadge
            :label="t(`status.${(row as ProblemReport).status}`)"
            :tone="PROBLEM_STATUS_TONE[(row as ProblemReport).status]"
          />
        </template>
        <template #cell-created_at="{ row }">
          {{ dateTime((row as ProblemReport).created_at) }}
        </template>
        <template #cell-actions="{ row }">
          <div v-if="PROBLEM_STATUS_TRANSITIONS[(row as ProblemReport).status].length" class="flex items-center justify-end gap-1">
            <button
              v-for="target in PROBLEM_STATUS_TRANSITIONS[(row as ProblemReport).status]"
              :key="target"
              type="button"
              class="btn btn-ghost px-2 py-1 text-2sm"
              :disabled="transitioning === (row as ProblemReport).id"
              @click="transition(row as ProblemReport, target)"
            >
              <KtIcon :name="target === 'in_progress' ? 'arrow-right' : 'check-circle'" />
              {{ t(target === 'in_progress' ? 'problemReportsPage.startWork' : 'problemReportsPage.markResolved') }}
            </button>
          </div>
        </template>
      </DataTable>
    </template>
  </div>
</template>
