<script setup lang="ts">
import type { Hotel, HotelGroup } from '~/types/api'
import { hotelsService } from '~/services'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{
  hotel?: Hotel | null
  groups: HotelGroup[]
  groupsPending?: boolean
}>()
const emit = defineEmits<{ saved: [hotel: Hotel] }>()

const { t } = useI18n()
const app = useAppStore()
const router = useRouter()

const isEdit = computed(() => !!props.hotel)

interface FormState {
  hotel_group_id: number | null
  name: string
  slug: string
  country: string
  city: string
  timezone: string
  is_active: boolean
}

function snapshot(h?: Hotel | null): FormState {
  return {
    hotel_group_id: h?.hotel_group_id ?? props.groups[0]?.id ?? null,
    name: h?.name ?? '',
    slug: h?.slug ?? '',
    country: h?.country ?? '',
    city: h?.city ?? '',
    timezone: h?.timezone ?? 'UTC',
    is_active: h?.is_active ?? true,
  }
}

const form = reactive<FormState>(snapshot(props.hotel))
let initial = JSON.stringify(form)

// The edit page resolves the hotel async — seed the form from it exactly
// once it arrives, without clobbering anything the user has already typed.
watch(() => props.hotel, (h) => {
  if (h) {
    Object.assign(form, snapshot(h))
    initial = JSON.stringify(form)
  }
})

// Pre-select the first group once the list resolves, if nothing is chosen.
watch(() => props.groups, (groups) => {
  if (form.hotel_group_id == null && groups[0]) {
    form.hotel_group_id = groups[0].id
    if (!props.hotel) initial = JSON.stringify(form)
  }
}, { immediate: true })

const dirty = computed(() => JSON.stringify(form) !== initial)

const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})

// Suggest a slug from the name while creating — until the user edits the
// slug field themselves, after which it is left alone.
const slugTouched = ref(isEdit.value)
function slugify(s: string) {
  return s.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 60)
}
watch(() => form.name, (name) => {
  if (!slugTouched.value) form.slug = slugify(name)
})

async function save() {
  if (saving.value || form.hotel_group_id == null) return
  saving.value = true
  fieldErrors.value = {}
  const body = {
    hotel_group_id: form.hotel_group_id,
    name: form.name,
    slug: form.slug,
    country: form.country || null,
    city: form.city || null,
    timezone: form.timezone || undefined,
    is_active: form.is_active,
  }
  try {
    const hotel = props.hotel
      ? await hotelsService.update(props.hotel.id, body)
      : await hotelsService.create(body)
    initial = JSON.stringify(form) // clear dirty so the leave guard doesn't fire
    app.pushToast('success', isEdit.value ? t('hotels.updated') : t('hotels.created'))
    emit('saved', hotel)
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) {
      fieldErrors.value = e.errors
      app.pushToast('error', t('errors.validationTitle'))
    } else {
      app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
    }
  } finally {
    saving.value = false
  }
}

function cancel() {
  if (props.hotel) router.push(`/hotels/${props.hotel.id}`)
  else router.push('/hotels')
}

// --- unsaved-changes protection ---------------------------------------
function beforeUnload(e: BeforeUnloadEvent) {
  if (dirty.value && !saving.value) {
    e.preventDefault()
    e.returnValue = ''
  }
}
onMounted(() => window.addEventListener('beforeunload', beforeUnload))
onBeforeUnmount(() => window.removeEventListener('beforeunload', beforeUnload))

onBeforeRouteLeave(() => {
  if (dirty.value && !saving.value) {
    return window.confirm(t('common.unsavedLeave'))
  }
})
</script>

<template>
  <form class="pb-24" novalidate @submit.prevent="save">
    <FormSection :title="t('hotels.sectionBasic')" :description="t('hotels.sectionBasicDesc')">
      <FormField for-id="hotel-name" :label="t('hotels.name')" :error="fieldErrors.name" required>
        <input id="hotel-name" v-model="form.name" class="input" autocomplete="off" required>
      </FormField>
      <FormField
        for-id="hotel-slug"
        :label="t('hotels.slug')"
        :error="fieldErrors.slug"
        :hint="t('hotels.slugHint')"
        required
      >
        <input
          id="hotel-slug"
          v-model="form.slug"
          class="input"
          autocomplete="off"
          required
          @input="slugTouched = true"
        >
      </FormField>
      <FormField for-id="hotel-group" :label="t('hotels.group')" :error="fieldErrors.hotel_group_id" required>
        <select id="hotel-group" v-model.number="form.hotel_group_id" class="input" :disabled="groupsPending" required>
          <option v-if="groupsPending" :value="null">
            {{ t('common.loading') }}
          </option>
          <option v-for="g in groups" :key="g.id" :value="g.id">
            {{ g.name }}
          </option>
        </select>
      </FormField>
    </FormSection>

    <FormSection :title="t('hotels.sectionLocation')" :description="t('hotels.sectionLocationDesc')">
      <div class="grid gap-4 sm:grid-cols-2">
        <FormField for-id="hotel-country" :label="t('hotels.country')" :error="fieldErrors.country">
          <input id="hotel-country" v-model="form.country" class="input" autocomplete="off">
        </FormField>
        <FormField for-id="hotel-city" :label="t('hotels.city')" :error="fieldErrors.city">
          <input id="hotel-city" v-model="form.city" class="input" autocomplete="off">
        </FormField>
      </div>
      <FormField
        for-id="hotel-tz"
        :label="t('hotels.timezone')"
        :error="fieldErrors.timezone"
        :hint="t('hotels.timezoneHint')"
      >
        <input id="hotel-tz" v-model="form.timezone" class="input" autocomplete="off" placeholder="UTC">
      </FormField>
    </FormSection>

    <FormSection :title="t('hotels.sectionBranding')" :description="t('hotels.sectionBrandingDesc')">
      <div class="rounded-lg border border-dashed border-border bg-secondary/40 p-5">
        <div class="flex items-start gap-3">
          <div class="flex size-10 items-center justify-center rounded-lg bg-warning/15 text-warning">
            <KtIcon name="picture" />
          </div>
          <div class="text-2sm">
            <p class="font-semibold text-foreground">
              {{ t('hotels.imagesGapTitle') }}
            </p>
            <p class="mt-0.5 text-muted-foreground">
              {{ t('hotels.imagesGapBody') }}
            </p>
            <ul class="mt-2 space-y-0.5 font-mono text-2xs text-foreground">
              <li>migration: hotels.logo_path, hotels.cover_path (nullable string)</li>
              <li>Store/UpdateHotelRequest: image|mimes:jpg,jpeg,png,webp|max:…</li>
              <li>HotelResource: logo_url, cover_url (Storage::disk('public')-&gt;url)</li>
              <li>route: POST /hotels/{hotel}/media · DELETE /hotels/{hotel}/media/{type}</li>
            </ul>
          </div>
        </div>
      </div>
    </FormSection>

    <FormSection :title="t('hotels.sectionStatus')" :description="t('hotels.sectionStatusDesc')">
      <label class="flex items-start gap-3">
        <input v-model="form.is_active" type="checkbox" class="mt-0.5">
        <span class="text-2sm">
          <span class="font-medium text-foreground">{{ t('common.active') }}</span>
          <span class="mt-0.5 block text-muted-foreground">{{ t('hotels.activeHint') }}</span>
        </span>
      </label>
    </FormSection>

    <!-- sticky action bar -->
    <div
      class="fixed bottom-0 z-20 border-t border-border bg-card/95 px-4 py-3 backdrop-blur end-0 start-0 lg:start-[var(--sidebar-width)] lg:px-6"
    >
      <div class="mx-auto flex max-w-7xl items-center justify-end gap-2">
        <span v-if="dirty" class="me-auto ps-1 text-2xs text-muted-foreground">
          {{ t('common.unsavedChanges') }}
        </span>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="cancel">
          {{ t('common.cancel') }}
        </button>
        <button type="submit" class="btn btn-primary min-w-28" :disabled="saving">
          <KtIcon v-if="saving" name="loading" class="animate-spin" />
          {{ saving ? t('common.saving') : (isEdit ? t('common.save') : t('hotels.createAction')) }}
        </button>
      </div>
    </div>
  </form>
</template>
