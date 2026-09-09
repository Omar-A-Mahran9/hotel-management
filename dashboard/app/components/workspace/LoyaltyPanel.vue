<script setup lang="ts">
import { loyaltyService } from '~/services'
import { dateTime } from '~/utils/format'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number }>()
const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canManage = can('loyalty.manage')

const account = useResource(() => loyaltyService.account(props.reservationId))
const ledger = useResource(() => loyaltyService.transactions(props.reservationId))

const busy = ref(false)
const redeemOpen = ref(false)
const redeemPoints = ref(1)

async function earn() {
  if (busy.value) return
  busy.value = true
  try {
    await loyaltyService.earn(props.reservationId)
    app.pushToast('success', t('workspace.earnDone'))
    account.reload()
    ledger.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    busy.value = false
  }
}

async function redeem() {
  if (busy.value) return
  busy.value = true
  try {
    await loyaltyService.redeem(props.reservationId, redeemPoints.value)
    app.pushToast('success', t('workspace.redeemDone'))
    redeemOpen.value = false
    account.reload()
    ledger.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <WorkspacePanelShell
    :title="t('workspace.loyalty')"
    :pending="account.pending.value"
    :error="account.error.value"
    @retry="() => { account.reload(); ledger.reload() }"
  >
    <template v-if="canManage" #actions>
      <button type="button" class="btn btn-secondary px-2.5 py-1 text-2sm" :disabled="busy" @click="earn">
        {{ t('workspace.earn') }}
      </button>
      <button type="button" class="btn btn-secondary px-2.5 py-1 text-2sm" :disabled="busy" @click="redeemOpen = true">
        {{ t('workspace.redeem') }}
      </button>
    </template>

    <div v-if="account.data.value" class="space-y-3">
      <div>
        <div class="text-2xs uppercase tracking-wide text-muted-foreground">
          {{ t('workspace.pointsBalance') }}
        </div>
        <div class="text-2xl font-bold text-primary">
          {{ account.data.value.points_balance.toLocaleString() }}
        </div>
      </div>

      <div>
        <div class="mb-1 text-2xs font-semibold uppercase tracking-wide text-muted-foreground">
          {{ t('workspace.ledger') }}
        </div>
        <LoadingState v-if="ledger.pending.value" :rows="2" />
        <table v-else class="table-base">
          <thead>
            <tr>
              <th>{{ t('workspace.type') }}</th>
              <th class="text-end">
                {{ t('workspace.points') }}
              </th>
              <th>{{ t('workspace.description') }}</th>
              <th>{{ t('workspace.when') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="tx in ledger.data.value ?? []" :key="tx.id">
              <td>
                <StatusBadge
                  :label="tx.type"
                  :tone="tx.type === 'earn' ? 'success' : tx.type === 'redeem' ? 'warning' : 'neutral'"
                />
              </td>
              <td class="text-end font-medium" :class="tx.points < 0 ? 'text-warning' : 'text-success'">
                {{ tx.points > 0 ? '+' : '' }}{{ tx.points }}
              </td>
              <td class="text-muted-foreground">
                {{ tx.description ?? '—' }}
              </td>
              <td class="text-muted-foreground">
                {{ dateTime(tx.created_at) }}
              </td>
            </tr>
            <tr v-if="(ledger.data.value?.length ?? 0) === 0">
              <td colspan="4" class="text-center text-muted-foreground">
                {{ t('empty.body') }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <p class="text-2xs text-muted-foreground">
        {{ t('workspace.loyaltyManageNote') }}
      </p>
    </div>

    <AppModal v-model:open="redeemOpen" :title="t('workspace.redeemTitle')">
      <FormField :label="t('workspace.redeemPoints')" required>
        <input v-model.number="redeemPoints" type="number" min="1" class="input" required>
      </FormField>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="busy" @click="redeemOpen = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="busy" @click="redeem">
          {{ t('workspace.redeem') }}
        </button>
      </template>
    </AppModal>
  </WorkspacePanelShell>
</template>
