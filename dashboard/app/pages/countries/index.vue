<script setup lang="ts">
import { countriesService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Country } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: ['locations.view', 'locations.manage'] })

const { t, locale } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canManage = can('locations.manage')

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

const list = useResource(() => countriesService.list(params()))

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

const name = (c: Country) => (locale.value === 'ar' ? c.name_ar : c.name_en)

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('countries.title') },
  { key: 'code', label: t('countries.code'), nowrap: true },
  { key: 'cities', label: t('countries.cities'), align: 'end' },
  { key: 'is_active', label: t('countries.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

// --- toggle active / delete -------------------------------------------
const toggling = ref<number | null>(null)
async function toggleActive(c: Country) {
  if (toggling.value) return
  toggling.value = c.id
  try {
    if (c.is_active) await countriesService.deactivate(c.id)
    else await countriesService.activate(c.id)
    app.pushToast('success', c.is_active ? t('countries.deactivated') : t('countries.activated'))
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    toggling.value = null
  }
}

const deleting = ref<Country | null>(null)
const removing = ref(false)
async function confirmDelete() {
  if (!deleting.value || removing.value) return
  removing.value = true
  try {
    await countriesService.remove(deleting.value.id)
    app.pushToast('success', t('countries.deleted'))
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
    <PageHeader :title="t('countries.title')" :subtitle="t('countries.subtitle')">
      <template v-if="canManage" #actions>
        <NuxtLink to="/countries/new" class="btn btn-primary">
          <KtIcon name="plus" /> {{ t('countries.new') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <FilterBar :active="filtersActive" @clear="clearFilters">
      <div class="w-full max-w-xs">
        <SearchField v-model="search" :placeholder="t('countries.searchPlaceholder')" />
      </div>
      <FormField :label="t('countries.filterStatus')">
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
      :empty-title="t('locations.noCountries')"
      @retry="list.reload"
      @page="changePage"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-foreground">{{ name(row as Country) }}</span>
      </template>
      <template #cell-code="{ row }">
        <span class="font-mono text-2xs">{{ (row as Country).code }}</span>
      </template>
      <template #cell-cities="{ row }">
        {{ (row as Country).cities_count ?? t('common.notAvailable') }}
      </template>
      <template #cell-is_active="{ row }">
        <StatusBadge
          :label="(row as Country).is_active ? t('common.active') : t('common.inactive')"
          :tone="(row as Country).is_active ? 'success' : 'neutral'"
        />
      </template>
      <template #cell-actions="{ row }">
        <div class="flex items-center justify-end gap-1">
          <NuxtLink :to="`/countries/${(row as Country).id}/edit`" class="btn btn-ghost px-2 py-1 text-2sm">
            <KtIcon name="pencil" /> {{ t('common.edit') }}
          </NuxtLink>
          <button
            type="button"
            class="btn btn-ghost px-2 py-1 text-2sm"
            :disabled="toggling === (row as Country).id"
            @click="toggleActive(row as Country)"
          >
            {{ (row as Country).is_active ? t('common.deactivate') : t('common.activate') }}
          </button>
          <button type="button" class="btn btn-ghost px-2 py-1 text-2sm text-destructive" @click="deleting = row as Country">
            {{ t('common.delete') }}
          </button>
        </div>
      </template>
    </DataTable>

    <ConfirmDialog
      :open="deleting !== null"
      :title="t('common.delete')"
      :message="deleting ? t('countries.deleteConfirm', { name: name(deleting) }) : ''"
      tone="destructive"
      :busy="removing"
      @update:open="v => !v && (deleting = null)"
      @confirm="confirmDelete"
    />
  </div>
</template>
