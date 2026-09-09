<script setup lang="ts">
import { checkoutService } from '~/services'
import { dateTime, money } from '~/utils/format'
import { INVOICE_STATUS_TONE } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number }>()
const { t } = useI18n()

const invoice = useResource(() => checkoutService.invoice(props.reservationId))

// A missing invoice is a plain 404 — show a friendly "not issued yet" rather
// than an error state.
const notIssued = computed(() =>
  invoice.error.value instanceof ApiError && invoice.error.value.kind === 'not_found',
)

function print() {
  window.print()
}
</script>

<template>
  <WorkspacePanelShell
    :title="t('workspace.invoice')"
    :pending="invoice.pending.value"
    :error="notIssued ? null : invoice.error.value"
    :is-empty="notIssued"
    :empty-body="t('workspace.noInvoiceYet')"
    @retry="invoice.reload"
  >
    <template v-if="invoice.data.value" #actions>
      <button type="button" class="btn btn-ghost px-2 py-1 text-2sm print:hidden" @click="print">
        <KtIcon name="printer" /> {{ t('workspace.print') }}
      </button>
    </template>

    <div v-if="invoice.data.value" class="space-y-4">
      <div class="flex flex-wrap items-center justify-between gap-2">
        <div>
          <div class="text-lg font-bold">
            {{ invoice.data.value.invoice_number }}
          </div>
          <div class="text-2xs text-muted-foreground">
            {{ t('workspace.issuedAtInvoice') }}: {{ dateTime(invoice.data.value.issued_at) }}
          </div>
        </div>
        <StatusBadge
          :label="t(`status.${invoice.data.value.status}`)"
          :tone="INVOICE_STATUS_TONE[invoice.data.value.status] ?? 'neutral'"
        />
      </div>

      <div class="overflow-x-auto">
        <table class="table-base">
          <thead>
            <tr>
              <th>{{ t('workspace.description') }}</th>
              <th class="text-end">
                {{ t('workspace.qty') }}
              </th>
              <th class="text-end">
                {{ t('workspace.unit') }}
              </th>
              <th class="text-end">
                {{ t('workspace.total') }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in invoice.data.value.items ?? []" :key="item.id">
              <td>{{ item.description }}</td>
              <td class="text-end">
                {{ item.quantity }}
              </td>
              <td class="text-end">
                {{ money(item.unit_amount, invoice.data.value.currency) }}
              </td>
              <td class="text-end font-medium">
                {{ money(item.total_amount, invoice.data.value.currency) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <dl class="ms-auto max-w-xs space-y-1 text-sm">
        <div class="flex justify-between">
          <dt class="text-muted-foreground">
            {{ t('workspace.subtotal') }}
          </dt>
          <dd>{{ money(invoice.data.value.subtotal, invoice.data.value.currency) }}</dd>
        </div>
        <div class="flex justify-between">
          <dt class="text-muted-foreground">
            {{ t('workspace.paymentsTotal') }}
          </dt>
          <dd>{{ money(invoice.data.value.payments_total, invoice.data.value.currency) }}</dd>
        </div>
        <div class="flex justify-between border-t border-border pt-1 font-semibold">
          <dt>{{ t('workspace.outstanding') }}</dt>
          <dd>{{ money(invoice.data.value.outstanding_total, invoice.data.value.currency) }}</dd>
        </div>
      </dl>
    </div>
  </WorkspacePanelShell>
</template>
