<script setup lang="ts">
import { hotelGroupsService, hotelsService } from '~/services'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'hotels.view' })

const { t } = useI18n()
const route = useRoute()
const { can } = useCan()
const app = useAppStore()
const id = Number(route.params.id)
const canManage = can('hotels.manage')

const hotel = useResource(() => hotelsService.get(id))

const group = useResource(async () => {
  const h = hotel.data.value
  if (!h || !can('hotel-groups.manage')) return null
  return hotelGroupsService.get(h.hotel_group_id)
}, { immediate: false })

watch(() => hotel.data.value, (h) => {
  if (h && can('hotel-groups.manage')) group.reload()
})

const facts = computed(() => {
  const h = hotel.data.value
  if (!h) return []
  return [
    { label: t('hotels.city'), value: h.city || t('common.notAvailable') },
    { label: t('hotels.country'), value: h.country || t('common.notAvailable') },
    { label: t('hotels.timezone'), value: h.timezone || t('common.notAvailable') },
    { label: t('hotels.slug'), value: h.slug },
  ]
})

// --- edit ---------------------------------------------------------------
const open = ref(false)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})
const form = reactive({ name: '', slug: '', city: '', country: '', timezone: '', is_active: true })

function openEdit() {
  const h = hotel.data.value
  if (!h) return
  Object.assign(form, {
    name: h.name, slug: h.slug, city: h.city ?? '', country: h.country ?? '',
    timezone: h.timezone ?? '', is_active: h.is_active,
  })
  fieldErrors.value = {}
  open.value = true
}

async function submit() {
  if (saving.value) return
  saving.value = true
  fieldErrors.value = {}
  try {
    hotel.data.value = await hotelsService.update(id, {
      name: form.name,
      slug: form.slug,
      city: form.city || null,
      country: form.country || null,
      timezone: form.timezone || undefined,
      is_active: form.is_active,
    })
    app.pushToast('success', t('hotels.updated'))
    open.value = false
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div>
    <LoadingState v-if="hotel.pending.value" :rows="4" />
    <ErrorState v-else-if="hotel.error.value" :error="hotel.error.value" @retry="hotel.reload" />
    <template v-else-if="hotel.data.value">
      <PageHeader :title="hotel.data.value.name">
        <template #meta>
          <div class="mt-2 flex items-center gap-2">
            <StatusBadge
              :label="hotel.data.value.is_active ? t('common.active') : t('common.inactive')"
              :tone="hotel.data.value.is_active ? 'success' : 'neutral'"
            />
            <span v-if="group.data.value" class="text-2sm text-muted-foreground">
              {{ t('hotels.group') }}: {{ group.data.value.name }}
            </span>
          </div>
        </template>
        <template #actions>
          <button v-if="canManage" type="button" class="btn btn-secondary" @click="openEdit">
            <KtIcon name="pencil" /> {{ t('common.edit') }}
          </button>
          <NuxtLink to="/hotels" class="btn btn-secondary">
            <KtIcon name="left" /> {{ t('common.back') }}
          </NuxtLink>
        </template>
      </PageHeader>

      <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div v-for="f in facts" :key="f.label" class="card p-4">
          <div class="text-2xs font-semibold uppercase tracking-wide text-muted-foreground">
            {{ f.label }}
          </div>
          <div class="mt-1 text-sm font-medium text-foreground">
            {{ f.value }}
          </div>
        </div>
      </div>

      <div class="mt-6 flex flex-wrap gap-3">
        <PermissionGate permission="inventory.view">
          <NuxtLink :to="`/room-types?hotel=${hotel.data.value.id}`" class="btn btn-secondary">
            <KtIcon name="cube-2" /> {{ t('nav.roomTypes') }}
          </NuxtLink>
          <NuxtLink :to="`/rooms?hotel=${hotel.data.value.id}`" class="btn btn-secondary">
            <KtIcon name="home-2" /> {{ t('nav.rooms') }}
          </NuxtLink>
        </PermissionGate>
        <PermissionGate permission="services.view">
          <NuxtLink :to="`/services?hotel=${hotel.data.value.id}`" class="btn btn-secondary">
            <KtIcon name="parcel" /> {{ t('nav.services') }}
          </NuxtLink>
        </PermissionGate>
      </div>

      <AppModal v-model:open="open" :title="t('hotels.editTitle')">
        <form class="space-y-3" novalidate @submit.prevent="submit">
          <FormField :label="t('hotels.name')" :error="fieldErrors.name" required>
            <input v-model="form.name" class="input" required>
          </FormField>
          <FormField :label="t('hotels.slug')" :error="fieldErrors.slug" required>
            <input v-model="form.slug" class="input" required>
          </FormField>
          <div class="grid gap-3 sm:grid-cols-2">
            <FormField :label="t('hotels.city')" :error="fieldErrors.city">
              <input v-model="form.city" class="input">
            </FormField>
            <FormField :label="t('hotels.country')" :error="fieldErrors.country">
              <input v-model="form.country" class="input">
            </FormField>
          </div>
          <FormField :label="t('hotels.timezone')" :error="fieldErrors.timezone">
            <input v-model="form.timezone" class="input">
          </FormField>
          <label class="flex items-center gap-2 text-2sm">
            <input v-model="form.is_active" type="checkbox"> {{ t('common.active') }}
          </label>
          <p class="text-2xs text-muted-foreground">
            {{ t('hotels.activeHint') }}
          </p>
        </form>
        <template #footer>
          <button type="button" class="btn btn-secondary" :disabled="saving" @click="open = false">
            {{ t('common.cancel') }}
          </button>
          <button type="button" class="btn btn-primary" :disabled="saving" @click="submit">
            {{ saving ? t('common.saving') : t('common.save') }}
          </button>
        </template>
      </AppModal>
    </template>
  </div>
</template>
