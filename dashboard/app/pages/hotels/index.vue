<script setup lang="ts">
import { hotelsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Hotel } from '~/types/api'

definePageMeta({ permission: 'hotels.view' })

const { t } = useI18n()
const router = useRouter()
const { can } = useCan()

const canManage = can('hotels.manage')

const page = ref(1)
const list = useResource(() => hotelsService.list(page.value))

const search = ref('')
const rows = computed<Hotel[]>(() => {
  const all = list.data.value?.data ?? []
  const q = search.value.trim().toLowerCase()
  if (!q) return all
  return all.filter(h =>
    [h.name, h.city, h.country].filter(Boolean).some(v => v!.toLowerCase().includes(q)),
  )
})

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('hotels.name') },
  { key: 'location', label: t('hotels.location') },
  { key: 'timezone', label: t('hotels.timezone'), nowrap: true },
  { key: 'is_active', label: t('hotels.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

function changePage(n: number) {
  page.value = n
  list.reload()
}

function locationOf(h: Hotel) {
  return [h.city, h.country].filter(Boolean).join(', ') || t('common.notAvailable')
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

    <div class="mb-3 max-w-xs">
      <SearchField v-model="search" :hint="t('common.clientFilterNote')" />
    </div>

    <DataTable
      :columns="columns"
      :rows="rows"
      :loading="list.pending.value"
      :error="list.error.value"
      :meta="list.data.value?.meta ?? null"
      clickable-rows
      @retry="list.reload"
      @page="changePage"
      @row-click="(row: Hotel) => router.push(`/hotels/${row.id}`)"
    >
      <template #cell-name="{ row }">
        <div class="flex items-center gap-3">
          <AppImage :alt="(row as Hotel).name" :name="(row as Hotel).name" size="2.25rem" />
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
      <template #cell-timezone="{ row }">
        {{ (row as Hotel).timezone || t('common.notAvailable') }}
      </template>
      <template #cell-is_active="{ row }">
        <StatusBadge
          :label="(row as Hotel).is_active ? t('common.active') : t('common.inactive')"
          :tone="(row as Hotel).is_active ? 'success' : 'neutral'"
        />
      </template>
      <template #cell-actions="{ row }">
        <NuxtLink
          :to="`/hotels/${(row as Hotel).id}/edit`"
          class="btn btn-ghost px-2 py-1 text-2sm"
          @click.stop
        >
          <KtIcon name="pencil" /> {{ t('common.edit') }}
        </NuxtLink>
      </template>
    </DataTable>
  </div>
</template>
