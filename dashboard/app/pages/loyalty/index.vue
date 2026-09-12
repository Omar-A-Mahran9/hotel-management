<script setup lang="ts">
import { guestsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Guest } from '~/types/api'

definePageMeta({ permission: 'loyalty.view' })

const { t } = useI18n()
const router = useRouter()

const page = ref(1)
const search = ref('')

function params() {
  return { page: page.value, search: search.value.trim() || undefined }
}

// Guest identity search reuses the guest directory — the loyalty account
// itself is guest-scoped (GET /guests/{guest}/loyalty), there is no bulk
// "every guest's balance" ledger endpoint to list here directly.
const list = useResource(async () => {
  if (!search.value.trim()) return null
  return guestsService.list(params())
}, { immediate: false })

let debounce: ReturnType<typeof setTimeout> | null = null
watch(search, () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(() => {
    page.value = 1
    list.reload()
  }, 300)
})

function changePage(n: number) {
  page.value = n
  list.reload()
}

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('loyaltyPage.guest') },
  { key: 'email', label: t('guestsPage.email') },
  { key: 'phone', label: t('guestsPage.phone') },
  { key: 'actions', label: t('common.actions'), align: 'end' },
])
</script>

<template>
  <div>
    <PageHeader :title="t('nav.loyalty')" :subtitle="t('loyaltyPage.subtitle')" />

    <div class="mb-3 max-w-xs">
      <SearchField v-model="search" :placeholder="t('guestsPage.searchPlaceholder')" />
    </div>

    <div v-if="!search.trim()" class="card">
      <EmptyState :title="t('loyaltyPage.searchPrompt')" icon="magnifier" />
    </div>

    <DataTable
      v-else
      :columns="columns"
      :rows="list.data.value?.data ?? []"
      :loading="list.pending.value"
      :error="list.error.value"
      :meta="list.data.value?.meta ?? null"
      :empty-title="t('guestsPage.empty')"
      clickable-rows
      @retry="list.reload"
      @page="changePage"
      @row-click="(row: Guest) => router.push(`/guests/${row.id}`)"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-foreground">{{ (row as Guest).name || t('guestsPage.unnamed') }}</span>
      </template>
      <template #cell-email="{ row }">
        {{ (row as Guest).email || t('common.notAvailable') }}
      </template>
      <template #cell-actions="{ row }">
        <NuxtLink :to="`/guests/${(row as Guest).id}`" class="btn btn-ghost px-2 py-1 text-2sm">
          {{ t('loyaltyPage.viewAccount') }}
        </NuxtLink>
      </template>
    </DataTable>
  </div>
</template>
