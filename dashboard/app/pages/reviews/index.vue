<script setup lang="ts">
import { reviewsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Review, ReviewStatus } from '~/types/api'
import { ApiError } from '~/utils/apiError'
import { REVIEW_STATUS_TONE } from '~/utils/statusMeta'

definePageMeta({ permission: 'reviews.view' })

const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()
const hotelCtx = useHotelContextStore()
const route = useRoute()
const canModerate = can('reviews.moderate')

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)
const status = ref<'all' | ReviewStatus>('all')
const page = ref(1)

const list = useResource(async () => {
  if (hotelId.value == null) return null
  return reviewsService.list(hotelId.value, {
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
  { key: 'guest_id', label: t('reviewsPage.guest') },
  { key: 'reservation_id', label: t('reviewsPage.reservation') },
  { key: 'rating', label: t('reviewsPage.rating') },
  { key: 'text', label: t('reviewsPage.text') },
  { key: 'status', label: t('reviewsPage.moderation') },
  { key: 'created_at', label: t('reviewsPage.created') },
  ...(canModerate ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

const moderating = ref<number | null>(null)
async function moderate(review: Review, decision: 'published' | 'rejected') {
  if (moderating.value) return
  moderating.value = review.id
  try {
    await reviewsService.moderate(review.id, decision)
    app.pushToast('success', t(decision === 'published' ? 'reviewsPage.approved' : 'reviewsPage.rejected'))
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    moderating.value = null
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('nav.reviews')" :subtitle="t('reviewsPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <FilterBar :active="filtersActive" @clear="clearFilters">
        <FormField :label="t('reviewsPage.moderation')">
          <select v-model="status" class="input min-w-40">
            <option value="all">
              {{ t('common.all') }}
            </option>
            <option value="pending">
              {{ t('status.pending') }}
            </option>
            <option value="published">
              {{ t('status.published') }}
            </option>
            <option value="rejected">
              {{ t('status.rejected') }}
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
        :empty-title="t('reviewsPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-guest_id="{ row }">
          <NuxtLink v-if="(row as Review).guest_id" :to="`/guests/${(row as Review).guest_id}`" class="text-primary hover:underline">
            #{{ (row as Review).guest_id }}
          </NuxtLink>
          <span v-else class="text-muted-foreground">{{ t('common.notAvailable') }}</span>
        </template>
        <template #cell-reservation_id="{ row }">
          <NuxtLink :to="`/reservations/${(row as Review).reservation_id}`" class="text-primary hover:underline">
            #{{ (row as Review).reservation_id }}
          </NuxtLink>
        </template>
        <template #cell-rating="{ row }">
          {{ t('reviewsPage.ratingValue', { count: (row as Review).rating }) }}
        </template>
        <template #cell-text="{ row }">
          <p class="line-clamp-2 max-w-sm text-2sm">
            {{ (row as Review).text || t('common.notAvailable') }}
          </p>
        </template>
        <template #cell-status="{ row }">
          <StatusBadge
            :label="t(`status.${(row as Review).status}`)"
            :tone="REVIEW_STATUS_TONE[(row as Review).status]"
          />
        </template>
        <template #cell-created_at="{ row }">
          {{ dateTime((row as Review).created_at) }}
        </template>
        <template #cell-actions="{ row }">
          <div v-if="(row as Review).status === 'pending'" class="flex items-center justify-end gap-1">
            <button
              type="button"
              class="btn btn-ghost px-2 py-1 text-2sm"
              :disabled="moderating === (row as Review).id"
              @click="moderate(row as Review, 'published')"
            >
              <KtIcon name="check" /> {{ t('reviewsPage.approve') }}
            </button>
            <button
              type="button"
              class="btn btn-ghost px-2 py-1 text-2sm text-destructive"
              :disabled="moderating === (row as Review).id"
              @click="moderate(row as Review, 'rejected')"
            >
              <KtIcon name="cross" /> {{ t('reviewsPage.reject') }}
            </button>
          </div>
        </template>
      </DataTable>
    </template>
  </div>
</template>
