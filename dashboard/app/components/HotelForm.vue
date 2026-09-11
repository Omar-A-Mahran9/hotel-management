<script setup lang="ts">
import type { Hotel, HotelGroup } from '~/types/api'
import { citiesService, countriesService, hotelsService } from '~/services'
import { ApiError } from '~/utils/apiError'
import { amenityLabelKey, HOTEL_AMENITIES } from '~/utils/hotelAmenities'

const STAR_RATINGS = [1, 2, 3, 4, 5] as const

const props = defineProps<{
  hotel?: Hotel | null
  groups: HotelGroup[]
  groupsPending?: boolean
}>()
const emit = defineEmits<{ saved: [hotel: Hotel] }>()

const { t, locale } = useI18n()
const app = useAppStore()
const router = useRouter()

const isEdit = computed(() => !!props.hotel)

interface FormState {
  hotel_group_id: number | null
  name: string
  name_ar: string
  tagline_en: string
  tagline_ar: string
  description_en: string
  description_ar: string
  star_rating: number | null
  amenities: string[]
  slug: string
  country_id: number | null
  city_id: number | null
  timezone: string
  is_active: boolean
}

function snapshot(h?: Hotel | null): FormState {
  return {
    hotel_group_id: h?.hotel_group_id ?? props.groups[0]?.id ?? null,
    // `name` is the English display name (feeds the slug); the backend keeps
    // the legacy `name` column in sync from name_i18n.en.
    name: h?.name_i18n?.en ?? h?.name ?? '',
    name_ar: h?.name_i18n?.ar ?? '',
    tagline_en: h?.tagline_i18n?.en ?? '',
    tagline_ar: h?.tagline_i18n?.ar ?? '',
    description_en: h?.description_i18n?.en ?? '',
    description_ar: h?.description_i18n?.ar ?? '',
    star_rating: h?.star_rating ?? null,
    amenities: [...(h?.amenities ?? [])],
    slug: h?.slug ?? '',
    country_id: h?.country_id ?? null,
    city_id: h?.city_id ?? null,
    timezone: h?.timezone ?? 'UTC',
    is_active: h?.is_active ?? true,
  }
}

function i18nMap(en: string, ar: string): Record<string, string> | undefined {
  const map: Record<string, string> = {}
  if (en.trim()) map.en = en.trim()
  if (ar.trim()) map.ar = ar.trim()
  return Object.keys(map).length ? map : undefined
}

const form = reactive<FormState>(snapshot(props.hotel))
let initial = JSON.stringify(form)

// Human labels for a pre-selected country/city that may not be in the first
// page of options (edit flow) — taken from the hotel's embedded summaries.
const localized = (s?: { name_en: string, name_ar: string } | null) =>
  s ? (locale.value === 'ar' ? s.name_ar : s.name_en) : null
const countryLabel = ref<string | null>(localized(props.hotel?.country_summary))
const cityLabel = ref<string | null>(localized(props.hotel?.city_summary))

// True while we seed the form from an incoming hotel, so the
// country-change watcher below does not wipe the seeded city.
const seeding = ref(false)

watch(() => props.hotel, (h) => {
  if (h) {
    seeding.value = true
    Object.assign(form, snapshot(h))
    countryLabel.value = localized(h.country_summary)
    cityLabel.value = localized(h.city_summary)
    initial = JSON.stringify(form)
    nextTick(() => { seeding.value = false })
  }
})

watch(() => props.groups, (groups) => {
  if (form.hotel_group_id == null && groups[0]) {
    form.hotel_group_id = groups[0].id
    if (!props.hotel) initial = JSON.stringify(form)
  }
}, { immediate: true })

// Country -> City dependency: when the country changes, drop a city that no
// longer belongs to it (the City select reloads via :reload-key).
watch(() => form.country_id, (next, prev) => {
  if (!seeding.value && prev !== undefined && next !== prev) {
    form.city_id = null
    cityLabel.value = null
  }
})

function toggleAmenity(slug: string) {
  const i = form.amenities.indexOf(slug)
  if (i === -1) form.amenities.push(slug)
  else form.amenities.splice(i, 1)
}

const dirty = computed(() => JSON.stringify(form) !== initial)

const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})

const slugTouched = ref(isEdit.value)
function slugify(s: string) {
  return s.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 60)
}
watch(() => form.name, (name) => {
  if (!slugTouched.value) form.slug = slugify(name)
})

// EntitySelect fetchers — thin wrappers over the real Laravel endpoints.
const fetchCountries = ({ search }: { search?: string }) => countriesService.options(search)
const fetchCities = ({ search }: { search?: string }) =>
  form.country_id ? citiesService.forCountry(form.country_id, search) : Promise.resolve([])

async function save() {
  if (saving.value || form.hotel_group_id == null) return
  saving.value = true
  fieldErrors.value = {}
  const body = {
    hotel_group_id: form.hotel_group_id,
    name: form.name,
    name_i18n: i18nMap(form.name, form.name_ar) ?? { en: form.name },
    tagline_i18n: i18nMap(form.tagline_en, form.tagline_ar) ?? null,
    description_i18n: i18nMap(form.description_en, form.description_ar) ?? null,
    star_rating: form.star_rating,
    amenities: form.amenities,
    slug: form.slug,
    country_id: form.country_id,
    city_id: form.city_id,
    timezone: form.timezone || undefined,
    is_active: form.is_active,
  }
  try {
    const hotel = props.hotel
      ? await hotelsService.update(props.hotel.id, body)
      : await hotelsService.create(body)
    initial = JSON.stringify(form)
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

// A local copy of the hotel used only for the embedded media relations, so
// an upload/delete/reorder refreshes the thumbnails in place. Media is
// persisted server-side by its own endpoint immediately — it is NOT part of
// the form's Save, so this never navigates or touches the dirty state.
const liveHotel = ref<Hotel | null>(props.hotel ?? null)
watch(() => props.hotel, h => (liveHotel.value = h ?? null))

async function reloadMedia() {
  if (!props.hotel) return
  try {
    liveHotel.value = await hotelsService.get(props.hotel.id)
  }
  catch { /* toast already shown by the uploader */ }
}

function cancel() {
  if (props.hotel) router.push(`/hotels/${props.hotel.id}`)
  else router.push('/hotels')
}

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
      <div class="grid gap-4 sm:grid-cols-2">
        <FormField for-id="hotel-name" :label="t('hotels.nameEn')" :error="fieldErrors.name || fieldErrors['name_i18n.en']" required>
          <input id="hotel-name" v-model="form.name" class="input" autocomplete="off" required>
        </FormField>
        <FormField for-id="hotel-name-ar" :label="t('hotels.nameAr')" :error="fieldErrors['name_i18n.ar']" :hint="t('hotels.nameArHint')">
          <input id="hotel-name-ar" v-model="form.name_ar" class="input" dir="rtl" autocomplete="off">
        </FormField>
      </div>
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
        <FormField
          for-id="hotel-country"
          :label="t('locations.country')"
          :error="fieldErrors.country_id"
          required
        >
          <EntitySelect
            id="hotel-country"
            v-model="form.country_id"
            :fetcher="fetchCountries"
            :label-fn="(c) => locale === 'ar' ? c.name_ar : c.name_en"
            :placeholder="t('locations.selectCountry')"
            :selected-label="countryLabel"
            :invalid="!!fieldErrors.country_id"
            clearable
            required
          >
            <template #empty>
              {{ t('locations.noCountries') }}
            </template>
          </EntitySelect>
        </FormField>

        <FormField
          for-id="hotel-city"
          :label="t('locations.city')"
          :error="fieldErrors.city_id"
          required
        >
          <EntitySelect
            id="hotel-city"
            v-model="form.city_id"
            :fetcher="fetchCities"
            :label-fn="(c) => locale === 'ar' ? c.name_ar : c.name_en"
            :placeholder="t('locations.selectCity')"
            :selected-label="cityLabel"
            :reload-key="form.country_id"
            :disabled="form.country_id == null"
            :disabled-hint="t('locations.selectCountryFirst')"
            :invalid="!!fieldErrors.city_id"
            clearable
            required
          >
            <template #empty>
              {{ t('locations.noCities') }}
            </template>
          </EntitySelect>
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

    <FormSection :title="t('hotels.sectionContent')" :description="t('hotels.sectionContentDesc')">
      <div class="grid gap-4 sm:grid-cols-2">
        <FormField for-id="hotel-tagline-en" :label="t('hotels.taglineEn')" :error="fieldErrors['tagline_i18n.en']">
          <input id="hotel-tagline-en" v-model="form.tagline_en" class="input" autocomplete="off">
        </FormField>
        <FormField for-id="hotel-tagline-ar" :label="t('hotels.taglineAr')" :error="fieldErrors['tagline_i18n.ar']">
          <input id="hotel-tagline-ar" v-model="form.tagline_ar" class="input" dir="rtl" autocomplete="off">
        </FormField>
      </div>
      <div class="grid gap-4 sm:grid-cols-2">
        <FormField for-id="hotel-desc-en" :label="t('hotels.descriptionEn')" :error="fieldErrors['description_i18n.en']">
          <textarea id="hotel-desc-en" v-model="form.description_en" class="input min-h-24" rows="3" />
        </FormField>
        <FormField for-id="hotel-desc-ar" :label="t('hotels.descriptionAr')" :error="fieldErrors['description_i18n.ar']">
          <textarea id="hotel-desc-ar" v-model="form.description_ar" class="input min-h-24" rows="3" dir="rtl" />
        </FormField>
      </div>
    </FormSection>

    <FormSection :title="t('hotels.sectionClassification')" :description="t('hotels.sectionClassificationDesc')">
      <FormField for-id="hotel-stars" :label="t('hotels.starRating')" :error="fieldErrors.star_rating">
        <select id="hotel-stars" v-model.number="form.star_rating" class="input max-w-40">
          <option :value="null">
            {{ t('hotels.starRatingNone') }}
          </option>
          <option v-for="s in STAR_RATINGS" :key="s" :value="s">
            {{ t('hotels.starRatingValue', { count: s }) }}
          </option>
        </select>
      </FormField>
      <FormField :label="t('hotels.amenitiesLabel')" :error="fieldErrors.amenities">
        <div class="flex flex-wrap gap-2">
          <button
            v-for="a in HOTEL_AMENITIES"
            :key="a"
            type="button"
            class="rounded-full border px-3 py-1.5 text-2sm transition-colors"
            :class="form.amenities.includes(a)
              ? 'border-primary bg-primary/10 text-primary'
              : 'border-border text-muted-foreground hover:bg-secondary'"
            :aria-pressed="form.amenities.includes(a)"
            @click="toggleAmenity(a)"
          >
            {{ t(amenityLabelKey(a)) }}
          </button>
        </div>
      </FormField>
    </FormSection>

    <FormSection :title="t('hotels.sectionBranding')" :description="t('hotels.sectionBrandingDesc')">
      <HotelMediaUploader
        v-if="isEdit && liveHotel"
        :hotel-id="liveHotel.id"
        :logo="liveHotel.logo"
        :cover="liveHotel.cover"
        :gallery="liveHotel.gallery"
        @changed="reloadMedia"
      />
      <InfoNote v-else>
        {{ t('hotels.mediaAfterCreate') }}
      </InfoNote>
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
