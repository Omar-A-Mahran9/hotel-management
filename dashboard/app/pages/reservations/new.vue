<script setup lang="ts">
import { guestsService, reservationsService, roomTypesService } from '~/services'
import type { Guest, Reservation, RoomType } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'reservations.manage' })

const { t } = useI18n()
const app = useAppStore()
const auth = useAuthStore()

// ── Step 1 — Guest: search existing or register a walk-in ──────────────
const guestMode = ref<'search' | 'create'>('search')
const guestSearch = ref('')
const selectedGuest = ref<Guest | null>(null)

const guestResults = useResource<{ data: Guest[] } | null>(async () => {
  const q = guestSearch.value.trim()
  if (!q) return null
  return guestsService.list({ search: q, per_page: 8 })
}, { immediate: false })

let guestDebounce: ReturnType<typeof setTimeout> | null = null
watch(guestSearch, () => {
  if (guestDebounce) clearTimeout(guestDebounce)
  guestDebounce = setTimeout(() => guestResults.reload(), 300)
})

function selectGuest(guest: Guest) {
  selectedGuest.value = guest
}

function changeGuest() {
  selectedGuest.value = null
  guestSearch.value = ''
}

const newGuestForm = reactive({ name: '', phone: '', email: '' })
const registeringGuest = ref(false)
const guestFieldErrors = ref<Record<string, string[]>>({})

async function registerGuest() {
  if (registeringGuest.value) return
  registeringGuest.value = true
  guestFieldErrors.value = {}
  try {
    const guest = await guestsService.create({
      name: newGuestForm.name.trim() || undefined,
      phone: newGuestForm.phone.trim(),
      email: newGuestForm.email.trim() || undefined,
    })
    selectedGuest.value = guest
    app.pushToast('success', t('reservations.guestRegistered'))
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation') {
      guestFieldErrors.value = e.errors ?? {}
    } else {
      app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
    }
  } finally {
    registeringGuest.value = false
  }
}

// ── Step 2 — Hotel, room type, dates ────────────────────────────────────
const hotelId = ref<number | ''>('')
const roomTypeId = ref<number | ''>('')
const dates = ref({ from: '', to: '' })

const roomTypesList = useResource<RoomType[]>(async () => {
  if (!hotelId.value) return []
  return roomTypesService.list(Number(hotelId.value))
}, { immediate: false })

watch(hotelId, () => {
  roomTypeId.value = ''
  roomTypesList.reload()
})

const activeRoomTypes = computed(() => (roomTypesList.data.value ?? []).filter(rt => rt.is_active))
const selectedRoomType = computed(() => activeRoomTypes.value.find(rt => rt.id === roomTypeId.value) ?? null)

const nights = computed(() => {
  if (!dates.value.from || !dates.value.to) return 0
  const diff = Math.round((new Date(dates.value.to).getTime() - new Date(dates.value.from).getTime()) / 86_400_000)
  return diff > 0 ? diff : 0
})

// Display only — the server independently computes and owns the
// authoritative price_snapshot from room_types.base_price; this is never
// sent with the create request.
const estimatedPrice = computed(() => {
  if (!selectedRoomType.value || nights.value <= 0) return null
  const total = Number(selectedRoomType.value.base_price) * nights.value
  return Number.isFinite(total) ? total.toFixed(2) : null
})

const step2Valid = computed(() => !!hotelId.value && !!roomTypeId.value && nights.value > 0)

// ── Step 3 — Create ──────────────────────────────────────────────────────
const creating = ref(false)
const createError = ref<string | null>(null)
const created = ref<Reservation | null>(null)

async function submit() {
  if (!selectedGuest.value || !step2Valid.value || creating.value) return
  creating.value = true
  createError.value = null
  try {
    created.value = await reservationsService.create({
      room_type_id: Number(roomTypeId.value),
      guest_id: selectedGuest.value.id,
      check_in: dates.value.from,
      check_out: dates.value.to,
    })
    app.pushToast('success', t('reservations.created'))
  } catch (e) {
    createError.value = e instanceof ApiError ? e.message : t('errors.genericBody')
  } finally {
    creating.value = false
  }
}

function startOver() {
  created.value = null
  createError.value = null
  selectedGuest.value = null
  guestSearch.value = ''
  hotelId.value = ''
  roomTypeId.value = ''
  dates.value = { from: '', to: '' }
  Object.assign(newGuestForm, { name: '', phone: '', email: '' })
}
</script>

<template>
  <div class="space-y-5">
    <PageHeader :title="t('reservations.new')" :subtitle="t('reservations.newSubtitle')">
      <template #actions>
        <NuxtLink to="/reservations" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <!-- Result -->
    <DataCard v-if="created" :title="t('reservations.createdTitle')">
      <div class="flex flex-col items-start gap-4 p-5">
        <div class="flex items-center gap-3">
          <div class="flex size-11 items-center justify-center rounded-xl bg-success/10 text-success">
            <KtIcon name="check-circle" class="size-5" />
          </div>
          <div>
            <div class="font-semibold text-foreground">
              {{ t('reservations.detailTitle', { id: created.id }) }}
            </div>
            <div class="text-2sm text-muted-foreground">
              {{ t('status.'+created.status) }} · {{ money(created.price_snapshot) }}
            </div>
          </div>
        </div>
        <div class="flex gap-2">
          <NuxtLink :to="`/reservations/${created.id}`" class="btn btn-primary">
            {{ t('reservations.viewReservation') }}
          </NuxtLink>
          <button type="button" class="btn btn-secondary" @click="startOver">
            {{ t('reservations.createAnother') }}
          </button>
        </div>
      </div>
    </DataCard>

    <template v-else>
      <!-- Step 1: Guest -->
      <DataCard :title="t('reservations.step1Guest')">
        <div v-if="selectedGuest" class="flex items-center justify-between gap-3 p-5">
          <div class="flex items-center gap-3">
            <div class="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <KtIcon name="user" />
            </div>
            <div>
              <div class="font-medium text-foreground">
                {{ selectedGuest.name || t('guestsPage.unnamed') }}
              </div>
              <div class="text-2sm text-muted-foreground">
                {{ selectedGuest.phone }}<span v-if="selectedGuest.email"> · {{ selectedGuest.email }}</span>
              </div>
            </div>
          </div>
          <button type="button" class="btn btn-secondary" @click="changeGuest">
            {{ t('common.change') }}
          </button>
        </div>

        <div v-else class="p-5">
          <AppTabs
            v-model="guestMode"
            class="mb-4"
            :tabs="[
              { key: 'search', label: t('reservations.searchGuest') },
              { key: 'create', label: t('reservations.registerGuest') },
            ]"
          />

          <div v-if="guestMode === 'search'" class="space-y-3">
            <SearchField v-model="guestSearch" :placeholder="t('guestsPage.searchPlaceholder')" />

            <div v-if="guestSearch.trim()" class="divide-y divide-border rounded-lg border border-border">
              <LoadingState v-if="guestResults.pending.value" :rows="2" />
              <ErrorState v-else-if="guestResults.error.value" :error="guestResults.error.value" @retry="guestResults.reload" />
              <EmptyState v-else-if="!guestResults.data.value?.data.length" :title="t('guestsPage.empty')" />
              <button
                v-for="g in guestResults.data.value?.data ?? []"
                :key="g.id"
                type="button"
                class="flex w-full items-center justify-between gap-3 p-3 text-start transition-colors hover:bg-secondary/60"
                @click="selectGuest(g)"
              >
                <div>
                  <div class="font-medium text-foreground">
                    {{ g.name || t('guestsPage.unnamed') }}
                  </div>
                  <div class="text-2sm text-muted-foreground">
                    {{ g.phone }}<span v-if="g.email"> · {{ g.email }}</span>
                  </div>
                </div>
                <KtIcon name="right" class="text-muted-foreground" />
              </button>
            </div>
          </div>

          <form v-else class="grid gap-4 sm:grid-cols-2" @submit.prevent="registerGuest">
            <FormField :label="t('guestsPage.name')" class="sm:col-span-2">
              <input v-model="newGuestForm.name" class="input">
            </FormField>
            <FormField :label="t('guestsPage.phone')" required :error="guestFieldErrors.phone?.[0] ?? null">
              <input v-model="newGuestForm.phone" class="input" placeholder="+15551234567">
            </FormField>
            <FormField :label="t('guestsPage.email')" :error="guestFieldErrors.email?.[0] ?? null">
              <input v-model="newGuestForm.email" type="email" class="input">
            </FormField>
            <div class="sm:col-span-2">
              <button type="submit" class="btn btn-primary" :disabled="!newGuestForm.phone.trim() || registeringGuest">
                {{ registeringGuest ? t('common.saving') : t('reservations.registerAndContinue') }}
              </button>
            </div>
          </form>
        </div>
      </DataCard>

      <!-- Step 2: Hotel / room type / dates -->
      <DataCard :title="t('reservations.step2Stay')" :class="{ 'opacity-50 pointer-events-none': !selectedGuest }">
        <div class="grid gap-4 p-5 sm:grid-cols-2">
          <FormField :label="t('reservations.hotel')">
            <select v-model="hotelId" class="input">
              <option value="">
                {{ t('hotelSelector.selectHotel') }}
              </option>
              <option v-for="h in auth.assignedHotels" :key="h.id" :value="h.id">
                {{ h.name }}
              </option>
            </select>
          </FormField>

          <FormField :label="t('reservations.roomType')">
            <select v-model="roomTypeId" class="input" :disabled="!hotelId">
              <option value="">
                {{ t('common.select') }}
              </option>
              <option v-for="rt in activeRoomTypes" :key="rt.id" :value="rt.id">
                {{ rt.name }} — {{ money(rt.base_price) }}
              </option>
            </select>
            <p v-if="hotelId && !roomTypesList.pending.value && activeRoomTypes.length === 0" class="mt-1 text-2xs text-muted-foreground">
              {{ t('reservations.noRoomTypes') }}
            </p>
          </FormField>

          <div class="sm:col-span-2">
            <DateRangeField v-model="dates" :label="t('reservations.stayDates')" />
          </div>

          <div v-if="selectedRoomType && nights > 0" class="sm:col-span-2">
            <InfoNote>
              {{ t('reservations.estimatedPriceNote', { nights, price: money(estimatedPrice, undefined) }) }}
            </InfoNote>
          </div>
        </div>
      </DataCard>

      <!-- Step 3: Review + submit -->
      <DataCard v-if="selectedGuest && step2Valid" :title="t('reservations.step3Review')">
        <div class="space-y-4 p-5">
          <FactGrid
            :facts="[
              { label: t('reservations.guest'), value: selectedGuest.name || selectedGuest.phone },
              { label: t('reservations.hotel'), value: auth.assignedHotels.find(h => h.id === hotelId)?.name ?? '' },
              { label: t('reservations.roomType'), value: selectedRoomType?.name ?? '' },
              { label: t('reservations.checkIn'), value: dates.from },
              { label: t('reservations.checkOut'), value: dates.to },
            ]"
          />

          <p v-if="createError" class="text-2sm font-medium text-destructive">
            {{ createError }}
          </p>

          <button type="button" class="btn btn-primary" :disabled="creating" @click="submit">
            {{ creating ? t('common.saving') : t('reservations.createSubmit') }}
          </button>
        </div>
      </DataCard>
    </template>
  </div>
</template>
