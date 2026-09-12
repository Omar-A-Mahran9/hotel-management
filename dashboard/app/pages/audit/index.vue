<script setup lang="ts">
import { auditService } from '~/services'
import type { AuditLogParams } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { AuditLogEntry } from '~/types/api'

definePageMeta({ permission: 'audit.view' })

const { t } = useI18n()
const auth = useAuthStore()
const hotelCtx = useHotelContextStore()
const route = useRoute()

const isOwner = computed(() => auth.isGroupOwner)

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const actorId = ref('')
const action = ref('')
const entityType = ref('')
const range = ref({ from: '', to: '' })
const hotelFilter = ref<number | ''>('')
const page = ref(1)

function filters(): AuditLogParams {
  return {
    actor_id: actorId.value.trim() ? Number(actorId.value) : undefined,
    action: action.value.trim() || undefined,
    auditable_type: entityType.value.trim() || undefined,
    from: range.value.from || undefined,
    to: range.value.to || undefined,
    page: page.value,
  }
}

const hotelId = computed(() => hotelCtx.currentHotelId)
const canLoad = computed(() => isOwner.value || hotelId.value != null)

const list = useResource(async () => {
  if (!canLoad.value) return null
  if (isOwner.value) {
    return auditService.global({ ...filters(), hotel_id: hotelFilter.value || undefined })
  }
  return auditService.forHotel(hotelId.value!, filters())
}, { immediate: false })

watch([isOwner, hotelId], () => {
  if (canLoad.value) { page.value = 1; list.reload() }
}, { immediate: true })

let debounce: ReturnType<typeof setTimeout> | null = null
watch([actorId, action, entityType, range, hotelFilter], () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(() => {
    page.value = 1
    list.reload()
  }, 300)
}, { deep: true })

function changePage(n: number) {
  page.value = n
  list.reload()
}

const columns = computed<Column[]>(() => [
  { key: 'created_at', label: t('auditPage.time') },
  { key: 'actor', label: t('auditPage.actor') },
  { key: 'action', label: t('auditPage.action') },
  { key: 'entity', label: t('auditPage.entity') },
  ...(isOwner.value ? [{ key: 'hotel_id', label: t('auditPage.hotel') }] : []),
  { key: 'metadata', label: t('auditPage.metadata'), align: 'end' as const },
])

const detailsEntry = ref<AuditLogEntry | null>(null)
const detailsOpen = computed({
  get: () => detailsEntry.value !== null,
  set: (v: boolean) => { if (!v) detailsEntry.value = null },
})
</script>

<template>
  <div>
    <PageHeader :title="t('nav.audit')" :subtitle="t('auditPage.subtitle')" />

    <NeedHotelNotice v-if="!canLoad" />

    <template v-else>
      <FilterBar>
        <FormField :label="t('auditPage.filterActor')">
          <input v-model="actorId" type="number" min="1" class="input min-w-32" inputmode="numeric">
        </FormField>
        <FormField :label="t('auditPage.filterAction')">
          <input v-model="action" class="input min-w-40" :placeholder="t('auditPage.actionPlaceholder')">
        </FormField>
        <FormField :label="t('auditPage.filterEntity')">
          <input v-model="entityType" class="input min-w-40" :placeholder="t('auditPage.entityPlaceholder')">
        </FormField>
        <DateRangeField v-model="range" />
        <FormField v-if="isOwner" :label="t('auditPage.hotel')">
          <select v-model="hotelFilter" class="input min-w-44">
            <option value="">
              {{ t('hotelSelector.allHotels') }}
            </option>
            <option v-for="h in auth.assignedHotels" :key="h.id" :value="h.id">
              {{ h.name }}
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
        :empty-title="t('auditPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-created_at="{ row }">
          {{ dateTime((row as AuditLogEntry).created_at) }}
        </template>
        <template #cell-actor="{ row }">
          <span v-if="(row as AuditLogEntry).actor" class="font-medium text-foreground">
            {{ (row as AuditLogEntry).actor!.name }}
          </span>
          <span v-else class="text-muted-foreground">{{ t('auditPage.system') }}</span>
        </template>
        <template #cell-action="{ row }">
          <code class="text-2xs">{{ (row as AuditLogEntry).action }}</code>
        </template>
        <template #cell-entity="{ row }">
          <span v-if="(row as AuditLogEntry).auditable_type">
            {{ (row as AuditLogEntry).auditable_type }}
            <span v-if="(row as AuditLogEntry).auditable_id" class="text-muted-foreground">#{{ (row as AuditLogEntry).auditable_id }}</span>
          </span>
          <span v-else class="text-muted-foreground">{{ t('common.notAvailable') }}</span>
        </template>
        <template #cell-hotel_id="{ row }">
          <span v-if="(row as AuditLogEntry).hotel_id">#{{ (row as AuditLogEntry).hotel_id }}</span>
          <span v-else class="text-muted-foreground">{{ t('common.notAvailable') }}</span>
        </template>
        <template #cell-metadata="{ row }">
          <button
            v-if="(row as AuditLogEntry).before || (row as AuditLogEntry).after"
            type="button"
            class="btn btn-ghost px-2 py-1 text-2sm"
            @click="detailsEntry = row as AuditLogEntry"
          >
            {{ t('auditPage.viewDetails') }}
          </button>
          <span v-else class="text-muted-foreground">{{ t('common.notAvailable') }}</span>
        </template>
      </DataTable>
    </template>

    <AppModal v-model:open="detailsOpen" :title="t('auditPage.metadata')">
      <div v-if="detailsEntry" class="space-y-4 text-2sm">
        <div v-if="detailsEntry.before">
          <div class="mb-1 font-medium text-foreground">
            {{ t('auditPage.before') }}
          </div>
          <pre class="overflow-x-auto rounded-lg bg-secondary p-3 text-2xs">{{ JSON.stringify(detailsEntry.before, null, 2) }}</pre>
        </div>
        <div v-if="detailsEntry.after">
          <div class="mb-1 font-medium text-foreground">
            {{ t('auditPage.after') }}
          </div>
          <pre class="overflow-x-auto rounded-lg bg-secondary p-3 text-2xs">{{ JSON.stringify(detailsEntry.after, null, 2) }}</pre>
        </div>
      </div>
      <template #footer>
        <button type="button" class="btn btn-secondary" @click="detailsEntry = null">
          {{ t('common.close') }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
