<script setup lang="ts">
import { hotelsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Hotel } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'hotels.view' })

const { t, locale } = useI18n()
const router = useRouter()
const { can } = useCan()
const app = useAppStore()

const localized = (s?: { name_en: string, name_ar: string } | null) =>
  s ? (locale.value === 'ar' ? s.name_ar : s.name_en) : null

const canManage = can('hotels.manage')

const page = ref(1)
const search = ref('')
const status = ref<'all' | 'active' | 'inactive'>('all')
const sort = ref<'name' | '-name' | 'created_at' | '-created_at'>('name')

function params() {
  return {
    page: page.value,
    search: search.value.trim() || undefined,
    is_active: status.value === 'all' ? undefined : (status.value === 'active' ? 1 : 0) as 0 | 1,
    sort: sort.value,
  }
}

// Real server-side search / status filter / sort (IndexHotelRequest),
// always layered on top of the caller's server-resolved hotel scope.
const list = useResource(() => hotelsService.list(params()))

let debounce: ReturnType<typeof setTimeout> | null = null
watch(search, () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(() => {
    page.value = 1
    list.reload()
  }, 300)
})
watch([status, sort], () => {
  page.value = 1
  list.reload()
})

const filtersActive = computed(() => search.value.trim() !== '' || status.value !== 'all' || sort.value !== 'name')
function clearFilters() {
  search.value = ''
  status.value = 'all'
  sort.value = 'name'
}

function changePage(n: number) {
  page.value = n
  list.reload()
}

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('hotels.name') },
  { key: 'location', label: t('hotels.location') },
  { key: 'starRating', label: t('hotels.starRating') },
  { key: 'is_active', label: t('hotels.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

function locationOf(h: Hotel) {
  const city = localized(h.city_summary) || h.city
  const country = localized(h.country_summary) || h.country
  return [city, country].filter(Boolean).join(', ') || t('common.notAvailable')
}

// --- activate / deactivate -----------------------------------------
// Hotels have no delete endpoint (a real, hard-to-reverse decision the
// backend does not support) — activate/deactivate is the only status
// action, via the same PUT /hotels/{id} the edit form uses.
const toggling = ref<number | null>(null)
async function toggleActive(h: Hotel) {
  if (toggling.value) return
  toggling.value = h.id
  try {
    await hotelsService.update(h.id, { is_active: !h.is_active })
    app.pushToast('success', h.is_active ? t('hotels.deactivated') : t('hotels.activated'))
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    toggling.value = null
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('hotels.title')" :subtitle="t('hotels.subtitle')">
      <template v-if="canManage" #actions>
        <NuxtLink to="/hotels/new" class="btn btn-primary">
          <KtIcon name="plus" /> {{ t('hotels.new') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <FilterBar :active="filtersActive" @clear="clearFilters">
      <div class="w-full max-w-xs">
        <SearchField v-model="search" :placeholder="t('hotels.searchPlaceholder')" />
      </div>
      <FormField :label="t('hotels.filterStatus')">
        <select v-model="status" class="input min-w-36">
          <option value="all">
            {{ t('common.all') }}
          </option>
          <option value="active">
            {{ t('common.active') }}
          </option>
          <option value="inactive">
            {{ t('common.inactive') }}
          </option>
        </select>
      </FormField>
      <FormField :label="t('hotels.sortBy')">
        <select v-model="sort" class="input min-w-40">
          <option value="name">
            {{ t('hotels.sortNameAsc') }}
          </option>
          <option value="-name">
            {{ t('hotels.sortNameDesc') }}
          </option>
          <option value="-created_at">
            {{ t('hotels.sortNewest') }}
          </option>
          <option value="created_at">
            {{ t('hotels.sortOldest') }}
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
      :empty-title="t('hotels.empty')"
      clickable-rows
      @retry="list.reload"
      @page="changePage"
      @row-click="(row: Hotel) => router.push(`/hotels/${row.id}`)"
    >
      <template #cell-name="{ row }">
        <div class="flex items-center gap-3">
          <AppImage
            :alt="(row as Hotel).name"
            :name="(row as Hotel).name"
            :src="(row as Hotel).logo?.url"
            size="2.25rem"
          />
          <div class="min-w-0">
            <div class="truncate font-medium text-foreground">
              {{ (row as Hotel).name }}
            </div>
            <div class="truncate text-2xs text-muted-foreground">
              {{ (row as Hotel).slug }}
            </div>
          </div>
        </div>
      </template>
      <template #cell-location="{ row }">
        {{ locationOf(row as Hotel) }}
      </template>
      <template #cell-starRating="{ row }">
        <span v-if="(row as Hotel).star_rating">{{ t('hotels.starRatingValue', { count: (row as Hotel).star_rating }) }}</span>
        <span v-else class="text-muted-foreground">{{ t('hotels.starRatingNone') }}</span>
      </template>
      <template #cell-is_active="{ row }">
        <StatusBadge
          :label="(row as Hotel).is_active ? t('common.active') : t('common.inactive')"
          :tone="(row as Hotel).is_active ? 'success' : 'neutral'"
        />
      </template>
      <template #cell-actions="{ row }">
        <div class="flex items-center justify-end gap-1">
          <NuxtLink
            :to="`/hotels/${(row as Hotel).id}/edit`"
            class="btn btn-ghost px-2 py-1 text-2sm"
            @click.stop
          >
            <KtIcon name="pencil" /> {{ t('common.edit') }}
          </NuxtLink>
          <button
            type="button"
            class="btn btn-ghost px-2 py-1 text-2sm"
            :disabled="toggling === (row as Hotel).id"
            @click.stop="toggleActive(row as Hotel)"
          >
            {{ (row as Hotel).is_active ? t('common.deactivate') : t('common.activate') }}
          </button>
        </div>
      </template>
    </DataTable>
  </div>
</template>
