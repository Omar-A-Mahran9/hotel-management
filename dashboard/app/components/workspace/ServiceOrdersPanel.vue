<script setup lang="ts">
import { serviceOrdersService, servicesService } from '~/services'
import type { ServiceOrder } from '~/types/api'
import { money } from '~/utils/format'
import { SERVICE_ORDER_STATUS_TONE, SERVICE_ORDER_TRANSITIONS } from '~/utils/statusMeta'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ reservationId: number, hotelId: number }>()
const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canManage = can('service-orders.manage')
const canSeeCatalogue = can('services.view')

const orders = useResource(() => serviceOrdersService.list(props.reservationId))
const catalogue = useResource(
  () => servicesService.list(props.hotelId),
  { immediate: canManage && canSeeCatalogue },
)

const serviceName = (id: number) =>
  (catalogue.data.value ?? []).find(s => s.id === id)?.name ?? `#${id}`
const activeServices = computed(() => (catalogue.data.value ?? []).filter(s => s.is_active))

const open = ref(false)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})
const form = reactive({ service_id: null as number | null, quantity: 1, notes: '' })

function openCreate() {
  Object.assign(form, { service_id: catalogue.data.value?.find(s => s.is_active)?.id ?? null, quantity: 1, notes: '' })
  fieldErrors.value = {}
  open.value = true
}

async function submit() {
  if (saving.value || form.service_id == null) return
  saving.value = true
  fieldErrors.value = {}
  try {
    await serviceOrdersService.create(props.reservationId, {
      service_id: form.service_id,
      quantity: form.quantity,
      notes: form.notes || undefined,
    })
    app.pushToast('success', t('workspace.orderCreated'))
    open.value = false
    orders.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}

const moving = ref<number | null>(null)
async function move(order: ServiceOrder, target: 'confirmed' | 'fulfilled' | 'cancelled') {
  if (moving.value) return
  moving.value = order.id
  try {
    await serviceOrdersService.transition(props.reservationId, order.id, target)
    app.pushToast('success', t('workspace.orderMoved'))
    orders.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    moving.value = null
  }
}

function actionLabel(target: 'confirmed' | 'fulfilled' | 'cancelled'): string {
  return target === 'confirmed'
    ? t('workspace.confirm')
    : target === 'fulfilled'
      ? t('workspace.fulfill')
      : t('workspace.cancelOrder')
}
</script>

<template>
  <WorkspacePanelShell
    :title="t('workspace.services')"
    :pending="orders.pending.value"
    :error="orders.error.value"
    @retry="orders.reload"
  >
    <template v-if="canManage" #actions>
      <button type="button" class="btn btn-primary px-2.5 py-1 text-2sm" @click="openCreate">
        <KtIcon name="plus" /> {{ t('workspace.addServiceOrder') }}
      </button>
    </template>

    <div class="overflow-x-auto">
      <table class="table-base">
        <thead>
          <tr>
            <th>{{ t('workspace.service') }}</th>
            <th class="text-end">
              {{ t('workspace.qty') }}
            </th>
            <th class="text-end">
              {{ t('workspace.total') }}
            </th>
            <th>{{ t('reservations.status') }}</th>
            <th v-if="canManage">
              {{ t('common.actions') }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="o in orders.data.value ?? []" :key="o.id">
            <td>
              <span class="font-medium">{{ canSeeCatalogue ? serviceName(o.service_id) : `#${o.service_id}` }}</span>
              <p v-if="o.notes" class="text-2xs text-muted-foreground">
                {{ o.notes }}
              </p>
            </td>
            <td class="text-end">
              {{ o.quantity }}
            </td>
            <td class="text-end font-medium">
              {{ money(o.total_amount, o.currency_snapshot) }}
            </td>
            <td>
              <StatusBadge :label="t(`status.${o.status}`)" :tone="SERVICE_ORDER_STATUS_TONE[o.status]" />
            </td>
            <td v-if="canManage">
              <div class="flex flex-wrap gap-1">
                <button
                  v-for="target in SERVICE_ORDER_TRANSITIONS[o.status]"
                  :key="target"
                  type="button"
                  class="btn btn-ghost px-2 py-0.5 text-2xs"
                  :disabled="moving === o.id"
                  @click="move(o, target)"
                >
                  {{ actionLabel(target) }}
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="(orders.data.value?.length ?? 0) === 0">
            <td :colspan="canManage ? 5 : 4" class="text-center text-muted-foreground">
              {{ t('empty.body') }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <AppModal v-model:open="open" :title="t('workspace.addServiceOrderTitle')">
      <form class="space-y-3" novalidate @submit.prevent="submit">
        <FormField :label="t('workspace.service')" :error="fieldErrors.service_id" required>
          <select v-model.number="form.service_id" class="input" required>
            <option v-for="s in activeServices" :key="s.id" :value="s.id">
              {{ s.name }} — {{ money(s.price, s.currency) }}
            </option>
          </select>
        </FormField>
        <FormField :label="t('workspace.quantity')" :error="fieldErrors.quantity" required>
          <input v-model.number="form.quantity" type="number" min="1" max="1000" class="input" required>
        </FormField>
        <FormField :label="`${t('workspace.notes')} (${t('common.optional')})`" :error="fieldErrors.notes">
          <textarea v-model="form.notes" rows="2" class="input" maxlength="500" />
        </FormField>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="open = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submit">
          {{ saving ? t('common.saving') : t('common.add') }}
        </button>
      </template>
    </AppModal>
  </WorkspacePanelShell>
</template>
