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

// --- status change --------------------------------------------------------
const STATUSES: RoomStatus[] = ['available', 'booked', 'under_maintenance']
const editing = ref<Room | null>(null)
const targetStatus = ref<RoomStatus>('available')
const saving = ref(false)
const saveError = ref<string | null>(null)

function openStatus(room: Room) {
  editing.value = room
  targetStatus.value = room.status
  saveError.value = null
}

async function saveStatus() {
  if (!editing.value || saving.value) return
  saving.value = true
  saveError.value = null
  try {
    await roomsService.setStatus(hotelId.value!, editing.value.id, targetStatus.value)
    app.pushToast('success', t('rooms.statusChanged'))
    editing.value = null
    list.reload()
  } catch (e) {
    saveError.value = e instanceof ApiError ? e.message : t('errors.genericBody')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div>
    <PageHeader
      :title="t('rooms.title')"
      :subtitle="hotelCtx.currentHotel ? t('rooms.subtitle', { hotel: hotelCtx.currentHotel.name }) : ''"
    />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <div class="mb-3 flex flex-wrap items-end gap-3">
        <div class="max-w-xs grow">
          <SearchField v-model="search" :hint="t('common.clientFilterNote')" />
        </div>
        <FormField :label="t('rooms.filterByType')">
          <select v-model="typeFilter" class="input min-w-40">
            <option :value="null">
              {{ t('common.all') }}
            </option>
            <option v-for="rt in types.data.value ?? []" :key="rt.id" :value="rt.id">
              {{ rt.name }}
            </option>
          </select>
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
          <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" @click="openStatus(row as Room)">
            <KtIcon name="pencil" /> {{ t('rooms.setStatus') }}
          </button>
        </template>
      </DataTable>
    </template>

    <AppModal
      :open="editing !== null"
      :title="t('rooms.setStatus')"
      @update:open="v => !v && (editing = null)"
    >
      <div v-if="editing" class="space-y-3">
        <p class="text-sm text-muted-foreground">
          {{ t('rooms.number') }}: <span class="font-medium text-foreground">{{ editing.room_number }}</span>
        </p>
        <FormField :label="t('rooms.status')" :error="saveError">
          <select v-model="targetStatus" class="input">
            <option v-for="s in STATUSES" :key="s" :value="s">
              {{ t(`status.${s}`) }}
            </option>
          </select>
        </FormField>
        <p class="text-2xs text-muted-foreground">
          The backend validates every status change against its room state machine.
        </p>
      </div>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="editing = null">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="saveStatus">
          {{ t('common.save') }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
