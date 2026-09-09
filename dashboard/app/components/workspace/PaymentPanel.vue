<script setup lang="ts">
import { folioService, paymentsService } from '~/services'
import type { Payment } from '~/types/api'
import { money } from '~/utils/format'
import { PAYMENT_STATUS_TONE } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number }>()
const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canManage = can('payments.manage')

// There is no GET /payment endpoint — the folio's payment_summary is the
// authoritative current view of the reservation's payment.
const folio = useResource(() => folioService.get(props.reservationId))
const lastHold = ref<Payment | null>(null)

const open = ref(false)
const saving = ref(false)
const amount = ref('')
const currency = ref('')
const fieldErrors = ref<Record<string, string[]>>({})

async function placeHold() {
  if (saving.value) return
  saving.value = true
  fieldErrors.value = {}
  try {
    lastHold.value = await paymentsService.hold(props.reservationId, amount.value, currency.value || undefined)
    app.pushToast('success', t('workspace.holdPlaced'))
    open.value = false
    folio.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <WorkspacePanelShell
    :title="t('workspace.payment')"
    :pending="folio.pending.value"
    :error="folio.error.value"
    @retry="folio.reload"
  >
    <template v-if="canManage" #actions>
      <button type="button" class="btn btn-primary px-2.5 py-1 text-2sm" @click="open = true">
        <KtIcon name="dollar" /> {{ t('workspace.placeHold') }}
      </button>
    </template>

    <div v-if="folio.data.value" class="space-y-3">
      <div v-if="folio.data.value.payment_summary" class="flex flex-wrap items-center gap-3">
        <StatusBadge
          :label="t(`status.${folio.data.value.payment_summary.status}`)"
          :tone="PAYMENT_STATUS_TONE[folio.data.value.payment_summary.status]"
        />
        <span class="text-sm font-medium">
          {{ money(folio.data.value.payment_summary.amount, folio.data.value.payment_summary.currency) }}
        </span>
        <span v-if="folio.data.value.payment_summary.is_captured" class="text-2sm text-success">
          {{ t('workspace.captured') }}
        </span>
      </div>
      <p v-else class="text-sm text-muted-foreground">
        {{ t('workspace.notStarted') }}
      </p>

      <div v-if="lastHold" class="rounded-lg border border-border bg-secondary/40 p-3 text-2sm">
        <div class="flex items-center gap-2">
          <StatusBadge :label="t(`status.${lastHold.status}`)" :tone="PAYMENT_STATUS_TONE[lastHold.status]" />
          <span>{{ money(lastHold.amount, lastHold.currency) }}</span>
        </div>
        <div v-if="lastHold.hold_expires_at" class="mt-1 text-muted-foreground">
          {{ t('workspace.holdExpires') }}: {{ lastHold.hold_expires_at }}
        </div>
      </div>

      <p class="text-2xs text-muted-foreground">
        {{ t('payment.abstractedNote') }}
      </p>
    </div>

    <AppModal v-model:open="open" :title="t('workspace.placeHoldTitle')">
      <form class="space-y-3" novalidate @submit.prevent="placeHold">
        <FormField :label="t('workspace.amount')" :error="fieldErrors.amount" required>
          <input v-model="amount" type="text" inputmode="decimal" class="input" placeholder="0.00" required>
        </FormField>
        <FormField :label="`${t('workspace.currency')} (${t('common.optional')})`" :error="fieldErrors.currency">
          <input v-model="currency" class="input" maxlength="3" placeholder="EGP">
        </FormField>
        <p class="text-2xs text-muted-foreground">
          {{ t('workspace.holdAmountHint') }}
        </p>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="open = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="placeHold">
          {{ saving ? t('common.saving') : t('workspace.placeHold') }}
        </button>
      </template>
    </AppModal>
  </WorkspacePanelShell>
</template>
