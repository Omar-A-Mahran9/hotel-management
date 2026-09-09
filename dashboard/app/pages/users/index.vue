<script setup lang="ts">
import { usersService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { StaffUser } from '~/types/api'

definePageMeta({ permission: 'users.view' })

const { t } = useI18n()

const page = ref(1)
const list = useResource(() => usersService.list(page.value))

const search = ref('')
const rows = computed<StaffUser[]>(() => {
  const all = list.data.value?.data ?? []
  const q = search.value.trim().toLowerCase()
  return q
    ? all.filter(u => [u.name, u.email].some(v => v.toLowerCase().includes(q)))
    : all
})

const columns: Column[] = [
  { key: 'name', label: t('users.name') },
  { key: 'email', label: t('users.email') },
  { key: 'role', label: t('users.role') },
  { key: 'hotels', label: t('users.hotels') },
  { key: 'is_active', label: t('users.status') },
]

function changePage(n: number) {
  page.value = n
  list.reload()
}
</script>

<template>
  <div>
    <PageHeader :title="t('users.title')" :subtitle="t('users.subtitle')" />

    <div class="mb-3 max-w-xs">
      <SearchField v-model="search" :hint="t('common.clientFilterNote')" />
    </div>

    <DataTable
      :columns="columns"
      :rows="rows"
      :loading="list.pending.value"
      :error="list.error.value"
      :meta="list.data.value?.meta ?? null"
      @retry="list.reload"
      @page="changePage"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-foreground">{{ (row as StaffUser).name }}</span>
      </template>
      <template #cell-role="{ row }">
        {{ (row as StaffUser).role?.name ?? t('common.notAvailable') }}
      </template>
      <template #cell-hotels="{ row }">
        <span v-if="(row as StaffUser).role?.slug === 'group_owner'" class="text-muted-foreground">
          {{ t('hotelSelector.allHotels') }}
        </span>
        <span v-else>
          {{ (row as StaffUser).hotels?.map(h => h.name).join(', ') || t('common.none') }}
        </span>
      </template>
      <template #cell-is_active="{ row }">
        <StatusBadge
          :label="(row as StaffUser).is_active ? t('common.active') : t('common.inactive')"
          :tone="(row as StaffUser).is_active ? 'success' : 'neutral'"
        />
      </template>
    </DataTable>
  </div>
</template>
