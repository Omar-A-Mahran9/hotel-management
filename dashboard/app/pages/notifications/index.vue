<script setup lang="ts">
import { notificationsService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { AppNotification } from '~/types/api'
import { NOTIFICATION_STATUS_TONE } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'notifications.view' })

const { t } = useI18n()
const app = useAppStore()
const hotelCtx = useHotelContextStore()
const route = useRoute()

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)
const unreadOnly = ref(false)
const page = ref(1)

const list = useResource(async () => {
  if (hotelId.value == null) return null
  return notificationsService.forHotel(hotelId.value, { unread: unreadOnly.value, page: page.value })
}, { immediate: false })

watch(hotelId, () => {
  if (hotelId.value != null) { page.value = 1; list.reload() }
}, { immediate: true })

watch(unreadOnly, () => {
  page.value = 1
  list.reload()
})

function changePage(n: number) {
  page.value = n
  list.reload()
}

const columns = computed<Column[]>(() => [
  { key: 'subject', label: t('notificationsPage.type') },
  { key: 'notificationStatus', label: t('notificationsPage.notificationStatus') },
  { key: 'created_at', label: t('notificationsPage.created') },
  { key: 'read', label: t('notificationsPage.read') },
  { key: 'actions', label: t('common.actions'), align: 'end' },
])

const marking = ref<number | null>(null)
async function markRead(n: AppNotification) {
  if (marking.value) return
  marking.value = n.id
  try {
    await notificationsService.markRead(n.reservation_id, n.id)
    app.pushToast('success', t('notificationsPage.markRead'))
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    marking.value = null
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('nav.notifications')" :subtitle="t('notificationsPage.subtitle')" />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <FilterBar :active="unreadOnly" @clear="unreadOnly = false">
        <label class="flex items-center gap-2 text-2sm text-foreground">
          <input v-model="unreadOnly" type="checkbox">
          {{ t('notificationsPage.unreadOnly') }}
        </label>
      </FilterBar>

      <DataTable
        :columns="columns"
        :rows="list.data.value?.data ?? []"
        :loading="list.pending.value"
        :error="list.error.value"
        :meta="list.data.value?.meta ?? null"
        :empty-title="t('notificationsPage.empty')"
        @retry="list.reload"
        @page="changePage"
      >
        <template #cell-subject="{ row }">
          <div class="min-w-0">
            <div class="truncate font-medium text-foreground">
              {{ (row as AppNotification).subject }}
            </div>
            <NuxtLink
              :to="`/reservations/${(row as AppNotification).reservation_id}?tab=notifications`"
              class="text-2xs text-primary hover:underline"
            >
              #{{ (row as AppNotification).reservation_id }}
            </NuxtLink>
          </div>
        </template>
        <template #cell-notificationStatus="{ row }">
          <StatusBadge
            :label="t(`status.${(row as AppNotification).status}`)"
            :tone="NOTIFICATION_STATUS_TONE[(row as AppNotification).status]"
          />
        </template>
        <template #cell-created_at="{ row }">
          {{ dateTime((row as AppNotification).created_at) }}
        </template>
        <template #cell-read="{ row }">
          <span v-if="(row as AppNotification).is_read" class="text-2sm text-muted-foreground">
            {{ t('common.yes') }}
          </span>
          <span v-else class="text-2sm font-medium text-primary">
            {{ t('common.no') }}
          </span>
        </template>
        <template #cell-actions="{ row }">
          <button
            v-if="!(row as AppNotification).is_read"
            type="button"
            class="btn btn-ghost px-2 py-1 text-2sm"
            :disabled="marking === (row as AppNotification).id"
            @click="markRead(row as AppNotification)"
          >
            {{ t('notificationsPage.markRead') }}
          </button>
        </template>
      </DataTable>
    </template>
  </div>
</template>
