<script setup lang="ts">
import { notificationsService } from '~/services'
import { dateTime } from '~/utils/format'
import { NOTIFICATION_STATUS_TONE } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number }>()
const { t } = useI18n()
const app = useAppStore()

const feed = useResource(() => notificationsService.list(props.reservationId))
const busy = ref(false)

async function markRead(id: number) {
  try {
    await notificationsService.markRead(props.reservationId, id)
    feed.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  }
}

async function markAll() {
  if (busy.value) return
  busy.value = true
  try {
    await notificationsService.markAllRead(props.reservationId)
    app.pushToast('success', t('workspace.allRead'))
    feed.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <WorkspacePanelShell
    :title="t('workspace.notifications')"
    :pending="feed.pending.value"
    :error="feed.error.value"
    :is-empty="(feed.data.value?.length ?? 0) === 0"
    @retry="feed.reload"
  >
    <template #actions>
      <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" :disabled="busy" @click="markAll">
        {{ t('workspace.markAllRead') }}
      </button>
    </template>

    <ul class="divide-y divide-border">
      <li v-for="n in feed.data.value ?? []" :key="n.id" class="flex items-start gap-3 py-3">
        <span
          class="mt-1.5 size-2 shrink-0 rounded-full"
          :class="n.is_read ? 'bg-border' : 'bg-primary'"
        />
        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-2">
            <span class="text-2sm font-medium text-foreground">{{ n.subject }}</span>
            <StatusBadge :label="n.channel" tone="neutral" />
            <StatusBadge :label="t(`status.${n.status}`)" :tone="NOTIFICATION_STATUS_TONE[n.status]" />
          </div>
          <p class="mt-0.5 text-2sm text-muted-foreground">
            {{ n.body }}
          </p>
          <p class="mt-0.5 text-2xs text-muted-foreground">
            {{ dateTime(n.created_at) }}
          </p>
        </div>
        <button
          v-if="!n.is_read"
          type="button"
          class="btn btn-ghost px-2 py-0.5 text-2xs"
          @click="markRead(n.id)"
        >
          {{ t('workspace.markRead') }}
        </button>
      </li>
    </ul>

    <p class="mt-2 text-2xs text-muted-foreground">
      {{ t('workspace.notificationsNote') }}
    </p>
  </WorkspacePanelShell>
</template>
