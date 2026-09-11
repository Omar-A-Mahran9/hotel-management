<script setup lang="ts">
import { facilitiesService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Facility } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: ['facilities.view', 'facilities.manage'] })

const { t, locale } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canManage = can('facilities.manage')

const page = ref(1)
const search = ref('')
const status = ref<'all' | 'active' | 'inactive'>('all')

function params() {
  return {
    page: page.value,
    search: search.value.trim() || undefined,
    is_active: status.value === 'all' ? undefined : (status.value === 'active' ? 1 : 0) as 0 | 1,
  }
}

const list = useResource(() => facilitiesService.list(params()))

let debounce: ReturnType<typeof setTimeout> | null = null
watch(search, () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(() => {
    page.value = 1
    list.reload()
  }, 300)
})
watch(status, () => {
  page.value = 1
  list.reload()
})

const filtersActive = computed(() => search.value.trim() !== '' || status.value !== 'all')
function clearFilters() {
  search.value = ''
  status.value = 'all'
}

function changePage(n: number) {
  page.value = n
  list.reload()
}

const name = (f: Facility) => (locale.value === 'ar' ? f.name_i18n.ar : f.name_i18n.en) || f.key

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('facilities.title') },
  { key: 'key', label: t('facilities.key'), nowrap: true },
  { key: 'hotels', label: t('facilities.hotelsCount'), align: 'end' },
  { key: 'is_active', label: t('facilities.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

// --- toggle active / delete -------------------------------------------
const toggling = ref<number | null>(null)
async function toggleActive(f: Facility) {
  if (toggling.value) return
  toggling.value = f.id
  try {
    if (f.is_active) await facilitiesService.deactivate(f.id)
    else await facilitiesService.activate(f.id)
    app.pushToast('success', f.is_active ? t('facilities.deactivated') : t('facilities.activated'))
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    toggling.value = null
  }
}

const deleting = ref<Facility | null>(null)
const removing = ref(false)
async function confirmDelete() {
  if (!deleting.value || removing.value) return
  removing.value = true
  try {
    await facilitiesService.remove(deleting.value.id)
    app.pushToast('success', t('facilities.deleted'))
    deleting.value = null
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    removing.value = false
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('facilities.title')" :subtitle="t('facilities.subtitle')">
      <template v-if="canManage" #actions>
        <NuxtLink to="/facilities/new" class="btn btn-primary">
          <KtIcon name="plus" /> {{ t('facilities.new') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <FilterBar :active="filtersActive" @clear="clearFilters">
      <div class="w-full max-w-xs">
        <SearchField v-model="search" :placeholder="t('facilities.searchPlaceholder')" />
      </div>
      <FormField :label="t('facilities.filterStatus')">
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
    </FilterBar>

    <DataTable
      :columns="columns"
      :rows="list.data.value?.data ?? []"
      :loading="list.pending.value"
      :error="list.error.value"
      :meta="list.data.value?.meta ?? null"
      :empty-title="t('facilities.empty')"
      @retry="list.reload"
      @page="changePage"
    >
      <template #cell-name="{ row }">
        <div class="flex items-center gap-2">
          <KtIcon v-if="(row as Facility).icon" :name="(row as Facility).icon!" class="text-muted-foreground" />
          <span class="font-medium text-foreground">{{ name(row as Facility) }}</span>
        </div>
      </template>
      <template #cell-key="{ row }">
        <span class="font-mono text-2xs">{{ (row as Facility).key }}</span>
      </template>
      <template #cell-hotels="{ row }">
        {{ (row as Facility).hotels_count ?? t('common.notAvailable') }}
      </template>
      <template #cell-is_active="{ row }">
        <StatusBadge
          :label="(row as Facility).is_active ? t('common.active') : t('common.inactive')"
          :tone="(row as Facility).is_active ? 'success' : 'neutral'"
        />
      </template>
      <template #cell-actions="{ row }">
        <div class="flex items-center justify-end gap-1">
          <NuxtLink :to="`/facilities/${(row as Facility).id}/edit`" class="btn btn-ghost px-2 py-1 text-2sm">
            <KtIcon name="pencil" /> {{ t('common.edit') }}
          </NuxtLink>
          <button
            type="button"
            class="btn btn-ghost px-2 py-1 text-2sm"
            :disabled="toggling === (row as Facility).id"
            @click="toggleActive(row as Facility)"
          >
            {{ (row as Facility).is_active ? t('common.deactivate') : t('common.activate') }}
          </button>
          <button type="button" class="btn btn-ghost px-2 py-1 text-2sm text-destructive" @click="deleting = row as Facility">
            {{ t('common.delete') }}
          </button>
        </div>
      </template>
    </DataTable>

    <ConfirmDialog
      :open="deleting !== null"
      :title="t('common.delete')"
      :message="deleting ? t('facilities.deleteConfirm', { name: name(deleting) }) : ''"
      tone="destructive"
      :busy="removing"
      @update:open="v => !v && (deleting = null)"
      @confirm="confirmDelete"
    />
  </div>
</template>
