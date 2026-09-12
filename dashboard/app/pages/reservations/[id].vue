<script setup lang="ts">
import { reservationsService, roomsService, roomTypesService } from '~/services'
import type { ReservationStatus } from '~/types/api'
import { allowedTransitions, RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'
import { reservationLifecycle } from '~/utils/reservationLifecycle'
import { date, money } from '~/utils/format'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'reservations.view' })

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const app = useAppStore()
const { can } = useCan()
const auth = useAuthStore()
const id = Number(route.params.id)

const reservation = useResource(() => reservationsService.get(id))

// Enrich with the real hotel-scoped resources where we have an id and the
// permission. Guest profile has no endpoint (documented gap).
const related = useResource(async () => {
  const r = reservation.data.value
  if (!r || !can('inventory.view')) return null
  const [roomType, room] = await Promise.all([
    roomTypesService.get(r.hotel_id, r.room_type_id).catch(() => null),
    r.room_id ? roomsService.get(r.hotel_id, r.room_id).catch(() => null) : Promise.resolve(null),
  ])
  return { roomType, room }
}, { immediate: false })

watch(() => reservation.data.value, (r) => {
  if (r && can('inventory.view')) related.reload()
})

const nextStates = computed<ReservationStatus[]>(() =>
  reservation.data.value ? allowedTransitions(reservation.data.value.status) : [],
)

function hotelName(hotelId: number) {
  return auth.assignedHotels.find(h => h.id === hotelId)?.name ?? `#${hotelId}`
}

const facts = computed(() => {
  const r = reservation.data.value
  if (!r) return []
  return [
    { label: t('reservations.hotel'), value: hotelName(r.hotel_id) },
    { label: t('reservations.roomType'), value: related.data.value?.roomType?.name ?? `#${r.room_type_id}` },
    { label: t('reservations.room'), value: related.data.value?.room?.room_number ?? (r.room_id ? `#${r.room_id}` : t('reservations.unassigned')) },
    { label: t('reservations.checkIn'), value: date(r.check_in) },
    { label: t('reservations.checkOut'), value: date(r.check_out) },
    { label: t('reservations.price'), value: money(r.price_snapshot) },
    { label: t('reservations.createdBy'), value: r.created_by_staff_id ? `#${r.created_by_staff_id}` : '—' },
    { label: t('reservations.cancelledAt'), value: r.cancelled_at ?? '—' },
  ]
})

// --- workspace tabs (permission-gated) --------------------------------
type TabKey = 'overview' | 'payment' | 'identity' | 'access' | 'folio' | 'services' | 'checkout' | 'invoice' | 'loyalty' | 'notifications'

const tabs = computed(() => {
  const list: Array<{ key: TabKey, label: string }> = [{ key: 'overview', label: t('reservations.workflow') }]
  if (can('folio.view') || can('payments.manage') || can('payments.view')) list.push({ key: 'payment', label: t('workspace.payment') })
  if (can('identity-verification.view')) list.push({ key: 'identity', label: t('workspace.identity') })
  if (can('digital-access.view')) list.push({ key: 'access', label: t('workspace.access') })
  if (can('folio.view')) list.push({ key: 'folio', label: t('workspace.folio') })
  if (can('service-orders.view')) list.push({ key: 'services', label: t('workspace.services') })
  if (can('checkout.perform')) list.push({ key: 'checkout', label: t('workspace.checkout') })
  if (can('invoice.view')) list.push({ key: 'invoice', label: t('workspace.invoice') })
  if (can('loyalty.view')) list.push({ key: 'loyalty', label: t('workspace.loyalty') })
  if (can('notifications.view')) list.push({ key: 'notifications', label: t('workspace.notifications') })
  return list
})
const TAB_KEYS: TabKey[] = ['overview', 'payment', 'identity', 'access', 'folio', 'services', 'checkout', 'invoice', 'loyalty', 'notifications']
function tabFromQuery(): TabKey {
  const q = route.query.tab
  return typeof q === 'string' && (TAB_KEYS as string[]).includes(q) ? (q as TabKey) : 'overview'
}
const activeTab = ref<TabKey>(tabFromQuery())

// Keep the deep-linkable ?tab= in sync, and fall back to Overview if the
// requested tab is not one this user can see.
watch([activeTab, tabs], () => {
  if (!tabs.value.some(x => x.key === activeTab.value)) {
    activeTab.value = 'overview'
    return
  }
  const q = activeTab.value === 'overview' ? undefined : activeTab.value
  if (route.query.tab !== q) router.replace({ query: { ...route.query, tab: q } })
}, { immediate: true })

const lifecycle = computed(() =>
  reservation.data.value
    ? reservationLifecycle(reservation.data.value.status, (k: string) => t(k))
    : [],
)

// --- transition ------------------------------------------------------
const confirmTarget = ref<ReservationStatus | null>(null)
const transitioning = ref(false)

async function doTransition() {
  if (!confirmTarget.value || transitioning.value) return
  transitioning.value = true
  try {
    const updated = await reservationsService.transition(id, confirmTarget.value)
    reservation.data.value = updated
    app.pushToast('success', t('reservations.transitionSuccess', { status: t(`status.${updated.status}`) }))
    confirmTarget.value = null
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
    confirmTarget.value = null
  } finally {
    transitioning.value = false
  }
}

// --- extend stay -------------------------------------------------------
// Only while the guest is actually occupying the room — the backend
// (ReservationExtensionService) enforces this independently; this is just
// the UX gate that decides whether to offer the action at all.
const canExtend = computed(() =>
  reservation.data.value !== null
  && ['checked_in', 'in_stay'].includes(reservation.data.value.status),
)
const newCheckOut = ref('')
const extending = ref(false)

async function doExtend() {
  if (!newCheckOut.value || extending.value) return
  extending.value = true
  try {
    const result = await reservationsService.extend(id, newCheckOut.value)
    reservation.data.value = result.reservation
    app.pushToast('success', t('reservations.extendSuccess', {
      date: date(result.extension.new_check_out),
      amount: money(result.extension.amount),
    }))
    newCheckOut.value = ''
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    extending.value = false
  }
}
</script>

<template>
  <div>
    <LoadingState v-if="reservation.pending.value" :rows="5" />
    <ErrorState v-else-if="reservation.error.value" :error="reservation.error.value" @retry="reservation.reload" />
    <template v-else-if="reservation.data.value">
      <PageHeader :title="t('reservations.detailTitle', { id: reservation.data.value.id })">
        <template #meta>
          <div class="mt-2">
            <StatusBadge
              :label="t(`status.${reservation.data.value.status}`)"
              :tone="RESERVATION_STATUS_TONE[reservation.data.value.status]"
            />
          </div>
        </template>
        <template #actions>
          <NuxtLink to="/reservations" class="btn btn-secondary">
            <KtIcon name="left" /> {{ t('common.back') }}
          </NuxtLink>
        </template>
      </PageHeader>

      <div class="grid gap-6 lg:grid-cols-3">
        <div class="space-y-6 lg:col-span-2">
          <AppTabs v-model="activeTab" :tabs="tabs" />

          <template v-if="activeTab === 'overview'">
            <DataCard :title="t('reservations.detailTitle', { id: reservation.data.value.id })">
              <FactGrid :facts="facts" />
              <p v-if="reservation.data.value.cancellation_reason" class="mt-3 text-2sm text-muted-foreground">
                {{ t('reservations.cancellationReason') }}: {{ reservation.data.value.cancellation_reason }}
              </p>
            </DataCard>
            <DataCard v-if="reservation.data.value.guest_id" :title="t('reservations.guest')" class="mt-4">
              <NuxtLink
                v-if="can('guests.view')"
                :to="`/guests/${reservation.data.value.guest_id}`"
                class="btn btn-secondary"
              >
                <KtIcon name="user" /> {{ t('reservations.viewGuestProfile', { id: reservation.data.value.guest_id }) }}
              </NuxtLink>
              <p v-else class="text-2sm text-muted-foreground">
                #{{ reservation.data.value.guest_id }}
              </p>
            </DataCard>
          </template>

          <WorkspacePaymentPanel
            v-else-if="activeTab === 'payment'"
            :reservation-id="id"
          />
          <WorkspaceIdentityPanel
            v-else-if="activeTab === 'identity'"
            :reservation-id="id"
          />
          <WorkspaceAccessPanel
            v-else-if="activeTab === 'access'"
            :reservation-id="id"
          />
          <WorkspaceFolioPanel
            v-else-if="activeTab === 'folio'"
            :reservation-id="id"
          />
          <WorkspaceServiceOrdersPanel
            v-else-if="activeTab === 'services'"
            :reservation-id="id"
            :hotel-id="reservation.data.value.hotel_id"
          />
          <WorkspaceCheckoutPanel
            v-else-if="activeTab === 'checkout'"
            :reservation-id="id"
          />
          <WorkspaceInvoicePanel
            v-else-if="activeTab === 'invoice'"
            :reservation-id="id"
          />
          <WorkspaceLoyaltyPanel
            v-else-if="activeTab === 'loyalty'"
            :reservation-id="id"
          />
          <WorkspaceNotificationsPanel
            v-else-if="activeTab === 'notifications'"
            :reservation-id="id"
          />
        </div>

        <div class="space-y-4">
          <DataCard :title="t('lifecycle.title')">
            <AppTimeline :stages="lifecycle" />
          </DataCard>

          <DataCard :title="t('reservations.timeline')">
            <PermissionGate permission="reservations.manage">
              <template #fallback>
                <p class="text-sm text-muted-foreground">
                  {{ t('reservations.noTransitions') }}
                </p>
              </template>
              <div v-if="nextStates.length" class="space-y-2">
                <button
                  v-for="s in nextStates"
                  :key="s"
                  type="button"
                  class="btn w-full"
                  :class="s === 'cancelled' ? 'btn-destructive' : 'btn-primary'"
                  @click="confirmTarget = s"
                >
                  {{ t('reservations.advanceTo', { status: t(`status.${s}`) }) }}
                </button>
              </div>
              <p v-else class="text-sm text-muted-foreground">
                {{ t('reservations.noTransitions') }}
              </p>
            </PermissionGate>
            <p class="mt-3 text-2xs text-muted-foreground">
              {{ t('reservations.manageNote') }}
            </p>
          </DataCard>

          <DataCard v-if="can('reservations.manage') && canExtend" :title="t('reservations.extendStay')">
            <div class="space-y-3">
              <label class="block text-sm">
                <span class="text-muted-foreground">{{ t('reservations.extendNewCheckOut') }}</span>
                <input
                  v-model="newCheckOut"
                  type="date"
                  class="input mt-1 w-full"
                  :min="reservation.data.value.check_out"
                >
              </label>
              <button
                type="button"
                class="btn btn-primary w-full"
                :disabled="!newCheckOut || extending"
                @click="doExtend"
              >
                {{ t('reservations.extendCta') }}
              </button>
              <p class="text-2xs text-muted-foreground">
                {{ t('reservations.extendNote') }}
              </p>
            </div>
          </DataCard>
        </div>
      </div>

      <ConfirmDialog
        :open="confirmTarget !== null"
        :title="t('reservations.advanceTo', { status: confirmTarget ? t(`status.${confirmTarget}`) : '' })"
        :message="t('reservations.advanceTo', { status: confirmTarget ? t(`status.${confirmTarget}`) : '' }) + ' ?'"
        :tone="confirmTarget === 'cancelled' ? 'destructive' : 'primary'"
        :busy="transitioning"
        @update:open="v => !v && (confirmTarget = null)"
        @confirm="doTransition"
      />
    </template>
  </div>
</template>
