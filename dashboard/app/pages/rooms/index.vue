<script setup lang="ts">
import { roomsService, roomTypesService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Room, RoomStatus } from '~/types/api'
import { ROOM_STATUS_TONE } from '~/utils/reservationStateMachine'
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
const typeFilter = ref<number | null>(null)

const types = useResource(async () => {
  if (hotelId.value == null) return []
  return roomTypesService.list(hotelId.value)
}, { immediate: false })

const list = useResource(async () => {
  if (hotelId.value == null) return []
  return roomsService.list(hotelId.value, typeFilter.value ?? undefined)
}, { immediate: false })

watch(hotelId, () => {
  if (hotelId.value != null) {
    types.reload()
    list.reload()
  }
}, { immediate: true })
watch(typeFilter, () => hotelId.value != null && list.reload())

const typeName = (id: number) =>
  (types.data.value ?? []).find(rt => rt.id === id)?.name ?? `#${id}`

// Room type is a hotel-scoped entity relationship — options come from the
// room-types API for the current hotel; the form submits room_type_id.
const fetchRoomTypes = () =>
  hotelId.value == null ? Promise.resolve([]) : roomTypesService.list(hotelId.value)

const search = ref('')
const rows = computed<Room[]>(() => {
  const all = list.data.value ?? []
  const q = search.value.trim().toLowerCase()
  return q ? all.filter(r => r.room_number.toLowerCase().includes(q)) : all
})

const columns = computed<Column[]>(() => [
  { key: 'room_number', label: t('rooms.number') },
  { key: 'room_type_id', label: t('rooms.type') },
  { key: 'status', label: t('rooms.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

// --- create / edit ------------------------------------------------------
const formOpen = ref(false)
const editing = ref<Room | null>(null)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})
const form = reactive({ room_number: '', room_type_id: null as number | null })

function openCreate() {
  editing.value = null
  Object.assign(form, { room_number: '', room_type_id: types.data.value?.[0]?.id ?? null })
  fieldErrors.value = {}
  formOpen.value = true
}
function openEdit(room: Room) {
  editing.value = room
  Object.assign(form, { room_number: room.room_number, room_type_id: room.room_type_id })
  fieldErrors.value = {}
  formOpen.value = true
}

async function submitForm() {
  if (saving.value || hotelId.value == null || form.room_type_id == null) return
  saving.value = true
  fieldErrors.value = {}
  try {
    if (editing.value) {
      await roomsService.update(hotelId.value, editing.value.id, {
        room_number: form.room_number,
        room_type_id: form.room_type_id,
      })
      app.pushToast('success', t('rooms.updated'))
    } else {
      await roomsService.create(hotelId.value, {
        room_number: form.room_number,
        room_type_id: form.room_type_id,
      })
      app.pushToast('success', t('rooms.created'))
    }
    formOpen.value = false
    list.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}

// --- status change ----------------------------------------------------
const STATUSES: Array<Extract<RoomStatus, 'available' | 'under_maintenance'>> = ['available', 'under_maintenance']
const statusEditing = ref<Room | null>(null)
const targetStatus = ref<'available' | 'under_maintenance'>('available')
const savingStatus = ref(false)
const statusError = ref<string | null>(null)

function openStatus(room: Room) {
  statusEditing.value = room
  targetStatus.value = room.status === 'under_maintenance' ? 'under_maintenance' : 'available'
  statusError.value = null
}

async function saveStatus() {
  if (!statusEditing.value || savingStatus.value) return
  savingStatus.value = true
  statusError.value = null
  try {
    await roomsService.setStatus(hotelId.value!, statusEditing.value.id, targetStatus.value)
    app.pushToast('success', t('rooms.statusChanged'))
    statusEditing.value = null
    list.reload()
  } catch (e) {
    statusError.value = e instanceof ApiError ? e.message : t('errors.genericBody')
  } finally {
    savingStatus.value = false
  }
}
</script>

<template>
  <div>
    <PageHeader
      :title="t('rooms.title')"
      :subtitle="hotelCtx.currentHotel ? t('rooms.subtitle', { hotel: hotelCtx.currentHotel.name }) : ''"
    >
      <template v-if="canManage && hotelId != null" #actions>
        <button type="button" class="btn btn-primary" @click="openCreate">
          <KtIcon name="plus" /> {{ t('rooms.new') }}
        </button>
      </template>
    </PageHeader>

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <div class="mb-3 flex flex-wrap items-end gap-3">
        <div class="max-w-xs grow">
          <SearchField v-model="search" :hint="t('common.clientFilterNote')" />
        </div>
        <FormField :label="t('rooms.filterByType')">
          <div class="min-w-44">
            <EntitySelect
              v-model="typeFilter"
              :fetcher="fetchRoomTypes"
              label-key="name"
              :placeholder="t('common.all')"
              :reload-key="hotelId"
              clearable
            />
          </div>
        </FormField>
      </div>

      <DataTable
        :columns="columns"
        :rows="rows"
        :loading="list.pending.value"
        :error="list.error.value"
        @retry="list.reload"
      >
        <template #cell-room_number="{ row }">
          <span class="font-medium text-foreground">{{ (row as Room).room_number }}</span>
        </template>
        <template #cell-room_type_id="{ row }">
          {{ typeName((row as Room).room_type_id) }}
        </template>
        <template #cell-status="{ row }">
          <StatusBadge
            :label="t(`status.${(row as Room).status}`)"
            :tone="ROOM_STATUS_TONE[(row as Room).status] ?? 'neutral'"
          />
        </template>
        <template #cell-actions="{ row }">
          <div class="flex items-center justify-end gap-1">
            <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" @click="openEdit(row as Room)">
              <KtIcon name="pencil" /> {{ t('common.edit') }}
            </button>
            <button
              type="button"
              class="btn btn-ghost px-2 py-1 text-2sm"
              :disabled="(row as Room).status === 'booked'"
              @click="openStatus(row as Room)"
            >
              {{ t('rooms.setStatus') }}
            </button>
          </div>
        </template>
      </DataTable>
    </template>

    <AppModal v-model:open="formOpen" :title="editing ? t('rooms.editTitle') : t('rooms.new')">
      <form class="space-y-3" novalidate @submit.prevent="submitForm">
        <FormField :label="t('rooms.number')" :error="fieldErrors.room_number" required>
          <input v-model="form.room_number" class="input" required>
        </FormField>
        <FormField :label="t('rooms.type')" :error="fieldErrors.room_type_id" required>
          <EntitySelect
            v-model="form.room_type_id"
            :fetcher="fetchRoomTypes"
            label-key="name"
            :placeholder="t('rooms.type')"
            :reload-key="hotelId"
            :selected-label="editing ? typeName(editing.room_type_id) : null"
            :invalid="!!fieldErrors.room_type_id"
            required
          />
        </FormField>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="formOpen = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submitForm">
          {{ saving ? t('common.saving') : t('common.save') }}
        </button>
      </template>
    </AppModal>

    <AppModal
      :open="statusEditing !== null"
      :title="t('rooms.setStatus')"
      @update:open="v => !v && (statusEditing = null)"
    >
      <div v-if="statusEditing" class="space-y-3">
        <p class="text-sm text-muted-foreground">
          {{ t('rooms.number') }}: <span class="font-medium text-foreground">{{ statusEditing.room_number }}</span>
        </p>
        <FormField :label="t('rooms.status')" :error="statusError">
          <select v-model="targetStatus" class="input">
            <option v-for="s in STATUSES" :key="s" :value="s">
              {{ t(`status.${s}`) }}
            </option>
          </select>
        </FormField>
        <p class="text-2xs text-muted-foreground">
          {{ t('rooms.statusMachineNote') }}
        </p>
      </div>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="savingStatus" @click="statusEditing = null">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="savingStatus" @click="saveStatus">
          {{ t('common.save') }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
