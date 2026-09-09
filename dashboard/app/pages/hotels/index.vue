<script setup lang="ts">
import { hotelGroupsService, hotelsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Hotel } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'hotels.view' })

const { t } = useI18n()
const router = useRouter()
const { can } = useCan()
const app = useAppStore()

const canManage = can('hotels.manage')

const page = ref(1)
const list = useResource(() => hotelsService.list(page.value))

// Hotel groups are needed for the create form's group picker. Only a Group
// Owner (who also holds hotels.manage) can list them.
const groups = useResource(() => hotelGroupsService.list(), { immediate: canManage })

const search = ref('')
const rows = computed<Hotel[]>(() => {
  const all = list.data.value?.data ?? []
  const q = search.value.trim().toLowerCase()
  if (!q) return all
  return all.filter(h =>
    [h.name, h.city, h.country].filter(Boolean).some(v => v!.toLowerCase().includes(q)),
  )
})

const columns: Column[] = [
  { key: 'name', label: t('hotels.name') },
  { key: 'city', label: t('hotels.city') },
  { key: 'country', label: t('hotels.country') },
  { key: 'timezone', label: t('hotels.timezone'), nowrap: true },
  { key: 'is_active', label: t('hotels.status') },
]

function changePage(n: number) {
  page.value = n
  list.reload()
}

// --- create --------------------------------------------------------------
const open = ref(false)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})
const form = reactive({
  hotel_group_id: null as number | null,
  name: '',
  slug: '',
  city: '',
  country: '',
  timezone: 'UTC',
  is_active: true,
})

function openCreate() {
  Object.assign(form, { hotel_group_id: groups.data.value?.[0]?.id ?? null, name: '', slug: '', city: '', country: '', timezone: 'UTC', is_active: true })
  fieldErrors.value = {}
  open.value = true
}

async function submit() {
  if (saving.value || form.hotel_group_id == null) return
  saving.value = true
  fieldErrors.value = {}
  try {
    await hotelsService.create({
      hotel_group_id: form.hotel_group_id,
      name: form.name,
      slug: form.slug,
      country: form.country || null,
      city: form.city || null,
      timezone: form.timezone,
      is_active: form.is_active,
    })
    app.pushToast('success', t('hotels.created'))
    open.value = false
    list.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('hotels.title')" :subtitle="t('hotels.subtitle')">
      <template v-if="canManage" #actions>
        <button type="button" class="btn btn-primary" @click="openCreate">
          <KtIcon name="plus" /> {{ t('hotels.new') }}
        </button>
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
        <span class="font-medium text-foreground">{{ (row as Hotel).name }}</span>
      </template>
      <template #cell-city="{ row }">
        {{ (row as Hotel).city || t('common.notAvailable') }}
      </template>
      <template #cell-country="{ row }">
        {{ (row as Hotel).country || t('common.notAvailable') }}
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
    </DataTable>

    <AppModal v-model:open="open" :title="t('hotels.new')">
      <form class="space-y-3" novalidate @submit.prevent="submit">
        <FormField :label="t('hotels.group')" :error="fieldErrors.hotel_group_id" required>
          <select v-model.number="form.hotel_group_id" class="input" required>
            <option v-for="g in groups.data.value ?? []" :key="g.id" :value="g.id">
              {{ g.name }}
            </option>
          </select>
        </FormField>
        <FormField :label="t('hotels.name')" :error="fieldErrors.name" required>
          <input v-model="form.name" class="input" required>
        </FormField>
        <FormField :label="t('hotels.slug')" :error="fieldErrors.slug" hint="a-z, 0-9, - and _" required>
          <input v-model="form.slug" class="input" required>
        </FormField>
        <div class="grid gap-3 sm:grid-cols-2">
          <FormField :label="t('hotels.city')" :error="fieldErrors.city">
            <input v-model="form.city" class="input">
          </FormField>
          <FormField :label="t('hotels.country')" :error="fieldErrors.country">
            <input v-model="form.country" class="input">
          </FormField>
        </div>
        <FormField :label="t('hotels.timezone')" :error="fieldErrors.timezone">
          <input v-model="form.timezone" class="input">
        </FormField>
        <label class="flex items-center gap-2 text-2sm">
          <input v-model="form.is_active" type="checkbox"> {{ t('common.active') }}
        </label>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="open = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submit">
          {{ saving ? t('common.saving') : t('common.create') }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
