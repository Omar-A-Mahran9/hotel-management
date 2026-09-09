<script setup lang="ts">
import { reservationsService, roomsService, roomTypesService } from '~/services'
import type { ReservationStatus } from '~/types/api'
import { allowedTransitions, RESERVATION_STATUS_TONE } from '~/utils/reservationStateMachine'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'reservations.view' })

const { t } = useI18n()
const route = useRoute()
const app = useAppStore()
const { can } = useCan()
const id = Number(route.params.id)

const reservation = useResource(() => reservationsService.get(id))

// Enrich with the real hotel-scoped resources where we have an id. Guests
// have no endpoint (audit §29 #4) — shown as a documented gap.
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

const facts = computed(() => {
  const r = reservation.data.value
  if (!r) return []
  return [
    { label: t('reservations.hotel'), value: hotelCtxName(r.hotel_id) },
    { label: t('reservations.roomType'), value: related.data.value?.roomType?.name ?? `#${r.room_type_id}` },
    { label: t('reservations.room'), value: related.data.value?.room?.room_number ?? (r.room_id ? `#${r.room_id}` : t('reservations.unassigned')) },
    { label: t('reservations.checkIn'), value: r.check_in },
    { label: t('reservations.checkOut'), value: r.check_out },
    { label: t('reservations.price'), value: r.price_snapshot },
  ]
})

function hotelCtxName(hotelId: number) {
  return useAuthStore().assignedHotels.find(h => h.id === hotelId)?.name ?? `#${hotelId}`
}

// --- transition ----------------------------------------------------------
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
    const msg = e instanceof ApiError ? e.message : t('errors.genericBody')
    app.pushToast('error', msg)
    confirmTarget.value = null
  } finally {
    transitioning.value = false
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
        <div class="lg:col-span-2 space-y-6">
          <DataCard :title="t('reservations.detailTitle', { id: reservation.data.value.id })">
            <dl class="grid gap-4 sm:grid-cols-2">
              <div v-for="f in facts" :key="f.label">
                <dt class="text-2xs font-semibold uppercase tracking-wide text-muted-foreground">
                  {{ f.label }}
                </dt>
                <dd class="mt-0.5 text-sm font-medium text-foreground">
                  {{ f.value }}
                </dd>
              </div>
            </dl>
          </DataCard>

          <InfoNote tone="warning" :title="t('nav.guests')">
            {{ t('reservations.guestGap') }}
          </InfoNote>
        </div>

        <div>
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
          </DataCard>
        </div>
      </div>

      <ConfirmDialog
        :open="confirmTarget !== null"
        :title="t('reservations.advanceTo', { status: confirmTarget ? t(`status.${confirmTarget}`) : '' })"
        :message="t('reservations.advanceTo', { status: confirmTarget ? t(`status.${confirmTarget}`) : '' }) + '?'"
        :tone="confirmTarget === 'cancelled' ? 'destructive' : 'primary'"
        :busy="transitioning"
        @update:open="v => !v && (confirmTarget = null)"
        @confirm="doTransition"
      />
    </template>
  </div>
</template>
