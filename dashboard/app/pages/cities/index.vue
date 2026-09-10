<script setup lang="ts">
import { citiesService, countriesService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { City } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: ['locations.view', 'locations.manage'] })

const { t, locale } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canManage = can('locations.manage')

const page = ref(1)
const search = ref('')
const status = ref<'all' | 'active' | 'inactive'>('all')
const countryId = ref<number | null>(null)

function paramsFor() {
  return {
    page: page.value,
    search: search.value.trim() || undefined,
    country_id: countryId.value ?? undefined,
    is_active: status.value === 'all' ? undefined : (status.value === 'active' ? 1 : 0) as 0 | 1,
  }
}

const list = useResource(() => citiesService.list(paramsFor()))

const fetchCountries = ({ search: s }: { search?: string }) => countriesService.options(s)

let debounce: ReturnType<typeof setTimeout> | null = null
watch(search, () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(() => {
    page.value = 1
    list.reload()
  }, 300)
})
watch([status, countryId], () => {
  page.value = 1
  list.reload()
})

const filtersActive = computed(() => search.value.trim() !== '' || status.value !== 'all' || countryId.value != null)
function clearFilters() {
  search.value = ''
  status.value = 'all'
  countryId.value = null
}

function changePage(n: number) {
  page.value = n
  list.reload()
}

const cityName = (c: City) => (locale.value === 'ar' ? c.name_ar : c.name_en)
const countryName = (c: City) =>
  c.country ? (locale.value === 'ar' ? c.country.name_ar : c.country.name_en) : `#${c.country_id}`

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('cities.nameEn') },
  { key: 'name_ar', label: t('cities.nameAr') },
  { key: 'country', label: t('cities.country') },
  { key: 'is_active', label: t('cities.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

const toggling = ref<number | null>(null)
async function toggleActive(c: City) {
  if (toggling.value) return
  toggling.value = c.id
  try {
    if (c.is_active) await citiesService.deactivate(c.id)
    else await citiesService.activate(c.id)
    app.pushToast('success', c.is_active ? t('cities.deactivated') : t('cities.activated'))
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    toggling.value = null
  }
}

const deleting = ref<City | null>(null)
const removing = ref(false)
async function confirmDelete() {
  if (!deleting.value || removing.value) return
  removing.value = true
  try {
    await citiesService.remove(deleting.value.id)
    app.pushToast('success', t('cities.deleted'))
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
    <PageHeader :title="t('cities.title')" :subtitle="t('cities.subtitle')">
      <template v-if="canManage" #actions>
        <NuxtLink to="/cities/new" class="btn btn-primary">
          <KtIcon name="plus" /> {{ t('cities.new') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <FilterBar :active="filtersActive" @clear="clearFilters">
      <div class="w-full max-w-xs">
        <SearchField v-model="search" :placeholder="t('cities.searchPlaceholder')" />
      </div>
      <FormField :label="t('cities.filterCountry')">
        <div class="min-w-52">
          <EntitySelect
            v-model="countryId"
            :fetcher="fetchCountries"
            :label-fn="(c) => locale === 'ar' ? c.name_ar : c.name_en"
            :placeholder="t('cities.allCountries')"
            clearable
          >
            <template #empty>
              {{ t('locations.noCountries') }}
            </template>
          </EntitySelect>
        </div>
      </FormField>
      <FormField :label="t('cities.filterStatus')">
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
      :empty-title="t('locations.noCities')"
      @retry="list.reload"
      @page="changePage"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-foreground">{{ (row as City).name_en }}</span>
      </template>
      <template #cell-name_ar="{ row }">
        <span dir="rtl">{{ (row as City).name_ar }}</span>
      </template>
      <template #cell-country="{ row }">
        {{ countryName(row as City) }}
      </template>
      <template #cell-is_active="{ row }">
        <StatusBadge
          :label="(row as City).is_active ? t('common.active') : t('common.inactive')"
          :tone="(row as City).is_active ? 'success' : 'neutral'"
        />
      </template>
      <template #cell-actions="{ row }">
        <div class="flex items-center justify-end gap-1">
          <NuxtLink :to="`/cities/${(row as City).id}/edit`" class="btn btn-ghost px-2 py-1 text-2sm">
            <KtIcon name="pencil" /> {{ t('common.edit') }}
          </NuxtLink>
          <button
            type="button"
            class="btn btn-ghost px-2 py-1 text-2sm"
            :disabled="toggling === (row as City).id"
            @click="toggleActive(row as City)"
          >
            {{ (row as City).is_active ? t('common.deactivate') : t('common.activate') }}
          </button>
          <button type="button" class="btn btn-ghost px-2 py-1 text-2sm text-destructive" @click="deleting = row as City">
            {{ t('common.delete') }}
          </button>
        </div>
      </template>
    </DataTable>

    <ConfirmDialog
      :open="deleting !== null"
      :title="t('common.delete')"
      :message="deleting ? t('cities.deleteConfirm', { name: cityName(deleting) }) : ''"
      tone="destructive"
      :busy="removing"
      @update:open="v => !v && (deleting = null)"
      @confirm="confirmDelete"
    />
  </div>
</template>
