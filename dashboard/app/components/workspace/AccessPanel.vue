<script setup lang="ts">
import { digitalAccessService } from '~/services'
import { dateTime } from '~/utils/format'
import { ACCESS_STATUS_TONE } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number }>()
const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canCheckIn = can('check-in.perform')
const canRevoke = can('digital-access.revoke')

const grant = useResource(() => digitalAccessService.get(props.reservationId))

const busy = ref(false)
const revokeOpen = ref(false)
const revokeReason = ref('')

async function checkIn() {
  if (busy.value) return
  busy.value = true
  try {
    grant.data.value = await digitalAccessService.checkIn(props.reservationId)
    app.pushToast('success', t('workspace.checkInDone'))
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    busy.value = false
  }
}

async function revoke() {
  if (busy.value) return
  busy.value = true
  try {
    grant.data.value = await digitalAccessService.revoke(props.reservationId, revokeReason.value || undefined)
    app.pushToast('success', t('workspace.revokeDone'))
    revokeOpen.value = false
    revokeReason.value = ''
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    busy.value = false
  }
}

const facts = computed(() => {
  const g = grant.data.value
  if (!g) return []
  return [
    { label: t('workspace.accessMode'), value: g.access_mode ?? '—' },
    { label: t('workspace.issuedAt'), value: dateTime(g.issued_at) },
    { label: t('workspace.activatedAt'), value: dateTime(g.activated_at) },
    { label: t('workspace.expiresAt'), value: dateTime(g.expires_at) },
    { label: t('workspace.revokedAt'), value: dateTime(g.revoked_at) },
    { label: t('workspace.revocationReason'), value: g.revocation_reason ?? '—' },
    { label: t('workspace.failureReason'), value: g.failure_reason ?? '—' },
  ]
})

const canDoCheckIn = computed(() =>
  canCheckIn && ['not_issued', 'failed', 'issue_requested'].includes(grant.data.value?.status ?? ''),
)
const canDoRevoke = computed(() =>
  canRevoke && ['active', 'issue_requested'].includes(grant.data.value?.status ?? ''),
)
</script>

<template>
  <WorkspacePanelShell
    :title="t('workspace.access')"
    :pending="grant.pending.value"
    :error="grant.error.value"
    @retry="grant.reload"
  >
    <template #actions>
      <button
        v-if="canDoCheckIn"
        type="button"
        class="btn btn-primary px-2.5 py-1 text-2sm"
        :disabled="busy"
        @click="checkIn"
      >
        <KtIcon name="entrance-left" /> {{ t('workspace.checkIn') }}
      </button>
      <button
        v-if="canDoRevoke"
        type="button"
        class="btn btn-secondary px-2.5 py-1 text-2sm"
        :disabled="busy"
        @click="revokeOpen = true"
      >
        {{ t('workspace.revoke') }}
      </button>
    </template>

    <div v-if="grant.data.value" class="space-y-3">
      <StatusBadge
        :label="t(`status.${grant.data.value.status}`)"
        :tone="ACCESS_STATUS_TONE[grant.data.value.status]"
      />
      <div
        v-if="grant.data.value.credential"
        class="rounded-lg border border-success/40 bg-success/10 p-3"
      >
        <div class="text-2xs font-semibold uppercase tracking-wide text-success">
          {{ t('workspace.credential') }}
        </div>
        <div class="mt-0.5 font-mono text-lg font-bold tracking-widest text-foreground">
          {{ grant.data.value.credential }}
        </div>
        <p class="mt-0.5 text-2xs text-muted-foreground">
          {{ t('workspace.credentialNote') }}
        </p>
      </div>
      <FactGrid :facts="facts" />
    </div>

    <AppModal v-model:open="revokeOpen" :title="t('workspace.revokeTitle')">
      <FormField :label="`${t('workspace.revokeReason')} (${t('common.optional')})`">
        <textarea v-model="revokeReason" rows="2" class="input" maxlength="500" />
      </FormField>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="busy" @click="revokeOpen = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-destructive" :disabled="busy" @click="revoke">
          {{ t('workspace.revoke') }}
        </button>
      </template>
    </AppModal>
  </WorkspacePanelShell>
</template>
