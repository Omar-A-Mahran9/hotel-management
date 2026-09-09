<script setup lang="ts">
import { identityVerificationService } from '~/services'
import { dateTime } from '~/utils/format'
import { canReviewIdentity, IDENTITY_STATUS_TONE } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number }>()
const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canReview = can('identity-verification.review')
const session = useResource(() => identityVerificationService.status(props.reservationId))

const open = ref(false)
const decision = ref<'approve' | 'reject'>('approve')
const reason = ref('')
const saving = ref(false)

const showReview = computed(() =>
  canReview && session.data.value != null && canReviewIdentity(session.data.value.status),
)

async function submit() {
  if (saving.value) return
  saving.value = true
  try {
    session.data.value = await identityVerificationService.review(
      props.reservationId,
      decision.value,
      reason.value || undefined,
    )
    app.pushToast('success', t('workspace.reviewDone'))
    open.value = false
    reason.value = ''
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}

const facts = computed(() => {
  const s = session.data.value
  if (!s) return []
  return [
    { label: t('workspace.attempts'), value: s.attempts },
    { label: t('workspace.latestOutcome'), value: s.latest_outcome ?? '—' },
    { label: t('workspace.latestScore'), value: s.latest_score ?? '—' },
    { label: t('workspace.decidedAt'), value: dateTime(s.decided_at) },
  ]
})
</script>

<template>
  <WorkspacePanelShell
    :title="t('workspace.identity')"
    :pending="session.pending.value"
    :error="session.error.value"
    @retry="session.reload"
  >
    <template v-if="showReview" #actions>
      <button type="button" class="btn btn-primary px-2.5 py-1 text-2sm" @click="open = true">
        {{ t('workspace.reviewTitle') }}
      </button>
    </template>

    <div v-if="session.data.value" class="space-y-3">
      <StatusBadge
        :label="t(`status.${session.data.value.status}`)"
        :tone="IDENTITY_STATUS_TONE[session.data.value.status]"
      />
      <FactGrid :facts="facts" />
      <div
        v-if="session.data.value.latest_decision"
        class="rounded-lg border border-border bg-secondary/40 p-3 text-2sm"
      >
        <div class="font-medium">
          {{ session.data.value.latest_decision.result }}
          <span v-if="session.data.value.latest_decision.band" class="text-muted-foreground">
            · {{ session.data.value.latest_decision.band }}
          </span>
        </div>
        <p v-if="session.data.value.latest_decision.reason" class="mt-0.5 text-muted-foreground">
          {{ session.data.value.latest_decision.reason }}
        </p>
        <p class="mt-0.5 text-2xs text-muted-foreground">
          {{ dateTime(session.data.value.latest_decision.decided_at) }}
        </p>
      </div>
      <p v-if="canReview && !showReview" class="text-2xs text-muted-foreground">
        {{ t('workspace.reviewOnlyPending') }}
      </p>
    </div>

    <AppModal v-model:open="open" :title="t('workspace.reviewTitle')">
      <form class="space-y-3" novalidate @submit.prevent="submit">
        <FormField :label="t('reservations.status')">
          <select v-model="decision" class="input">
            <option value="approve">
              {{ t('workspace.reviewApprove') }}
            </option>
            <option value="reject">
              {{ t('workspace.reviewReject') }}
            </option>
          </select>
        </FormField>
        <FormField :label="`${t('workspace.reviewReason')} (${t('common.optional')})`">
          <textarea v-model="reason" rows="2" class="input" maxlength="500" />
        </FormField>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="open = false">
          {{ t('common.cancel') }}
        </button>
        <button
          type="button"
          class="btn"
          :class="decision === 'reject' ? 'btn-destructive' : 'btn-primary'"
          :disabled="saving"
          @click="submit"
        >
          {{ saving ? t('common.saving') : t('common.confirm') }}
        </button>
      </template>
    </AppModal>
  </WorkspacePanelShell>
</template>
