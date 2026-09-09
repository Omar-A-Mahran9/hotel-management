<script setup lang="ts">
import { checkoutService } from '~/services'
import type { CheckoutResult } from '~/types/api'
import { dateTime, money } from '~/utils/format'
import { CHECKOUT_STATUS_TONE, PAYMENT_STATUS_TONE } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number }>()
const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canPerform = can('checkout.perform')

const result = ref<CheckoutResult | null>(null)
const busy = ref(false)
const problem = ref<string | null>(null)
const confirmOpen = ref(false)

async function perform() {
  if (busy.value) return
  busy.value = true
  problem.value = null
  try {
    result.value = await checkoutService.perform(props.reservationId)
    app.pushToast('success', t('workspace.checkoutDone'))
    confirmOpen.value = false
  } catch (e) {
    // 422 covers settlement pending / failed — both safe to retry.
    problem.value = e instanceof ApiError ? e.message : t('errors.genericBody')
  } finally {
    busy.value = false
  }
}

const totals = computed(() => result.value?.totals)
</script>

<template>
  <WorkspacePanelShell :title="t('workspace.checkout')">
    <template v-if="canPerform" #actions>
      <button type="button" class="btn btn-primary px-2.5 py-1 text-2sm" :disabled="busy" @click="confirmOpen = true">
        <KtIcon name="exit-right" /> {{ t('workspace.performCheckout') }}
      </button>
    </template>

    <div class="space-y-3">
      <p class="text-2sm text-muted-foreground">
        {{ t('workspace.checkoutBody') }}
      </p>

      <div
        v-if="problem"
        class="flex items-start gap-2 rounded-lg border border-warning/40 bg-warning/10 p-3 text-2sm"
      >
        <KtIcon name="information-4" class="mt-0.5 text-warning" />
        <span>{{ problem }}</span>
      </div>

      <div v-if="result" class="space-y-3">
        <div class="flex flex-wrap items-center gap-3">
          <StatusBadge
            :label="t(`status.${result.checkout.status}`)"
            :tone="CHECKOUT_STATUS_TONE[result.checkout.status]"
          />
          <StatusBadge
            :label="t(`status.${result.reservation.status}`)"
            tone="neutral"
          />
        </div>
        <div v-if="totals" class="grid gap-3 sm:grid-cols-3">
          <div class="rounded-lg border border-border p-3">
            <div class="text-2xs uppercase tracking-wide text-muted-foreground">
              {{ t('workspace.chargesTotal') }}
            </div>
            <div class="mt-0.5 font-semibold">
              {{ money(totals.charges_total, result.currency) }}
            </div>
          </div>
          <div class="rounded-lg border border-border p-3">
            <div class="text-2xs uppercase tracking-wide text-muted-foreground">
              {{ t('workspace.paymentsTotal') }}
            </div>
            <div class="mt-0.5 font-semibold text-success">
              {{ money(totals.payments_total, result.currency) }}
            </div>
          </div>
          <div class="rounded-lg border border-border p-3">
            <div class="text-2xs uppercase tracking-wide text-muted-foreground">
              {{ t('workspace.outstanding') }}
            </div>
            <div class="mt-0.5 font-semibold text-warning">
              {{ money(totals.outstanding_total, result.currency) }}
            </div>
          </div>
        </div>
        <div v-if="result.payment" class="flex items-center gap-2 text-2sm">
          <span class="text-muted-foreground">{{ t('workspace.settlementStatus') }}:</span>
          <StatusBadge :label="t(`status.${result.payment.status}`)" :tone="PAYMENT_STATUS_TONE[result.payment.status]" />
        </div>
        <div v-if="result.invoice" class="text-2sm">
          <span class="text-muted-foreground">{{ t('workspace.invoiceNumber') }}:</span>
          <span class="ms-1 font-medium">{{ result.invoice.invoice_number }}</span>
          <span class="ms-2 text-muted-foreground">{{ dateTime(result.invoice.issued_at) }}</span>
        </div>
      </div>
    </div>

    <ConfirmDialog
      v-model:open="confirmOpen"
      :title="t('workspace.checkoutTitle')"
      :message="t('workspace.checkoutBody')"
      :busy="busy"
      @confirm="perform"
    />
  </WorkspacePanelShell>
</template>
