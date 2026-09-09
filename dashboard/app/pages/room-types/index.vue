<script setup lang="ts">
import { roomTypesService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { RoomType } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'inventory.view' })

const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()
const hotelCtx = useHotelContextStore()
const route = useRoute()
const canManage = can('inventory.manage')

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)

const list = useResource(async () => {
  if (hotelId.value == null) return []
  return roomTypesService.list(hotelId.value)
}, { immediate: false })

watch(hotelId, () => {
  if (hotelId.value != null) list.reload()
}, { immediate: true })

const search = ref('')
const rows = computed<RoomType[]>(() => {
  const all = list.data.value ?? []
  const q = search.value.trim().toLowerCase()
  return q ? all.filter(rt => rt.name.toLowerCase().includes(q)) : all
})

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('roomTypes.name') },
  { key: 'base_price', label: t('roomTypes.basePrice'), align: 'end' },
  { key: 'capacity', label: t('roomTypes.capacity'), align: 'end' },
  { key: 'rooms_count', label: t('roomTypes.rooms'), align: 'end' },
  { key: 'available_rooms_count', label: t('roomTypes.available'), align: 'end' },
  { key: 'is_active', label: t('roomTypes.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

// --- form --------------------------------------------------------------
const open = ref(false)
const editing = ref<RoomType | null>(null)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})
const form = reactive({ name: '', base_price: '', capacity: 1, amenities: '', description: '', is_active: true })

function openCreate() {
  editing.value = null
  Object.assign(form, { name: '', base_price: '', capacity: 1, amenities: '', description: '', is_active: true })
  fieldErrors.value = {}
  open.value = true
}
function openEdit(rt: RoomType) {
  editing.value = rt
  Object.assign(form, {
    name: rt.name,
    base_price: rt.base_price,
    capacity: rt.capacity,
    amenities: (rt.amenities ?? []).join('\n'),
    description: rt.description ?? '',
    is_active: rt.is_active,
  })
  fieldErrors.value = {}
  open.value = true
}

async function submit() {
  if (saving.value || hotelId.value == null) return
  saving.value = true
  fieldErrors.value = {}
  const amenities = form.amenities.split('\n').map(s => s.trim()).filter(Boolean)
  const body: Record<string, unknown> = {
    name: form.name,
    base_price: form.base_price,
    capacity: form.capacity,
    amenities: amenities.length ? amenities : null,
    description: form.description || null,
  }
  try {
    if (editing.value) {
      await roomTypesService.update(hotelId.value, editing.value.id, body)
      app.pushToast('success', t('roomTypes.updated'))
    } else {
      await roomTypesService.create(hotelId.value, { ...body, is_active: form.is_active })
      app.pushToast('success', t('roomTypes.created'))
    }
    open.value = false
    list.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}

const toggling = ref<number | null>(null)
async function toggleActive(rt: RoomType) {
  if (toggling.value) return
  toggling.value = rt.id
  try {
    if (rt.is_active) await roomTypesService.deactivate(hotelId.value!, rt.id)
    else await roomTypesService.activate(hotelId.value!, rt.id)
    app.pushToast('success', rt.is_active ? t('roomTypes.deactivated') : t('roomTypes.activated'))
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
    <PageHeader
      :title="t('roomTypes.title')"
      :subtitle="hotelCtx.currentHotel ? t('roomTypes.subtitle', { hotel: hotelCtx.currentHotel.name }) : ''"
    >
      <template v-if="canManage && hotelId != null" #actions>
        <button type="button" class="btn btn-primary" @click="openCreate">
          <KtIcon name="plus" /> {{ t('roomTypes.new') }}
        </button>
      </template>
    </PageHeader>

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <div class="mb-3 max-w-xs">
        <SearchField v-model="search" :hint="t('common.clientFilterNote')" />
      </div>

      <DataTable
        :columns="columns"
        :rows="rows"
        :loading="list.pending.value"
        :error="list.error.value"
        @retry="list.reload"
      >
        <template #cell-name="{ row }">
          <span class="font-medium text-foreground">{{ (row as RoomType).name }}</span>
        </template>
        <template #cell-base_price="{ row }">
          {{ (row as RoomType).base_price }}
        </template>
        <template #cell-rooms_count="{ row }">
          {{ (row as RoomType).rooms_count ?? t('common.notAvailable') }}
        </template>
        <template #cell-available_rooms_count="{ row }">
          {{ (row as RoomType).available_rooms_count ?? t('common.notAvailable') }}
        </template>
        <template #cell-is_active="{ row }">
          <StatusBadge
            :label="(row as RoomType).is_active ? t('common.active') : t('common.inactive')"
            :tone="(row as RoomType).is_active ? 'success' : 'neutral'"
          />
        </template>
        <template #cell-actions="{ row }">
          <div class="flex items-center justify-end gap-1">
            <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" @click="openEdit(row as RoomType)">
              <KtIcon name="pencil" /> {{ t('common.edit') }}
            </button>
            <button
              type="button"
              class="btn btn-ghost px-2 py-1 text-2sm"
              :disabled="toggling === (row as RoomType).id"
              @click="toggleActive(row as RoomType)"
            >
              {{ (row as RoomType).is_active ? t('common.deactivate') : t('common.activate') }}
            </button>
          </div>
        </template>
      </DataTable>
    </template>

    <AppModal v-model:open="open" :title="editing ? t('roomTypes.editTitle') : t('roomTypes.new')">
      <form class="space-y-3" novalidate @submit.prevent="submit">
        <FormField :label="t('roomTypes.name')" :error="fieldErrors.name" required>
          <input v-model="form.name" class="input" required>
        </FormField>
        <div class="grid gap-3 sm:grid-cols-2">
          <FormField :label="t('roomTypes.basePrice')" :error="fieldErrors.base_price" required>
            <input v-model="form.base_price" type="text" inputmode="decimal" class="input" required>
          </FormField>
          <FormField :label="t('roomTypes.capacity')" :error="fieldErrors.capacity" required>
            <input v-model.number="form.capacity" type="number" min="1" class="input" required>
          </FormField>
        </div>
        <FormField :label="t('roomTypes.amenities')" :error="fieldErrors.amenities" :hint="t('roomTypes.amenitiesHint')">
          <textarea v-model="form.amenities" rows="3" class="input" />
        </FormField>
        <FormField :label="t('roomTypes.description')" :error="fieldErrors.description">
          <textarea v-model="form.description" rows="2" class="input" />
        </FormField>
        <label v-if="!editing" class="flex items-center gap-2 text-2sm">
          <input v-model="form.is_active" type="checkbox"> {{ t('common.active') }}
        </label>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="open = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submit">
          {{ saving ? t('common.saving') : t('common.save') }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
