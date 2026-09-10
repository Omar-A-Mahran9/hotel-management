<script setup lang="ts">
import type { City } from '~/types/api'
import { citiesService, countriesService } from '~/services'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ city?: City | null }>()
const emit = defineEmits<{ saved: [city: City] }>()

const { t, locale } = useI18n()
const app = useAppStore()
const router = useRouter()

const isEdit = computed(() => !!props.city)

interface FormState {
  country_id: number | null
  name_en: string
  name_ar: string
  is_active: boolean
}

function snapshot(c?: City | null): FormState {
  return {
    country_id: c?.country_id ?? null,
    name_en: c?.name_en ?? '',
    name_ar: c?.name_ar ?? '',
    is_active: c?.is_active ?? true,
  }
}

const form = reactive<FormState>(snapshot(props.city))
let initial = JSON.stringify(form)

const localized = (s?: { name_en: string, name_ar: string } | null) =>
  s ? (locale.value === 'ar' ? s.name_ar : s.name_en) : null
const countryLabel = ref<string | null>(localized(props.city?.country))

watch(() => props.city, (c) => {
  if (c) {
    Object.assign(form, snapshot(c))
    countryLabel.value = localized(c.country)
    initial = JSON.stringify(form)
  }
})

const dirty = computed(() => JSON.stringify(form) !== initial)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})

const fetchCountries = ({ search }: { search?: string }) => countriesService.options(search)

async function save() {
  if (saving.value || form.country_id == null) return
  saving.value = true
  fieldErrors.value = {}
  try {
    let city: City
    if (props.city) {
      city = await citiesService.update(props.city.id, {
        country_id: form.country_id,
        name_en: form.name_en,
        name_ar: form.name_ar,
      })
      if (form.is_active !== props.city.is_active) {
        city = form.is_active
          ? await citiesService.activate(props.city.id)
          : await citiesService.deactivate(props.city.id)
      }
    } else {
      city = await citiesService.create({
        country_id: form.country_id,
        name_en: form.name_en,
        name_ar: form.name_ar,
        is_active: form.is_active,
      })
    }
    initial = JSON.stringify(form)
    app.pushToast('success', isEdit.value ? t('cities.updated') : t('cities.created'))
    emit('saved', city)
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
  router.push('/cities')
}

onBeforeRouteLeave(() => {
  if (dirty.value && !saving.value) return window.confirm(t('common.unsavedLeave'))
})
</script>

<template>
  <form class="space-y-5" novalidate @submit.prevent="save">
    <FormField for-id="city-country" :label="t('cities.country')" :error="fieldErrors.country_id" required>
      <EntitySelect
        id="city-country"
        v-model="form.country_id"
        :fetcher="fetchCountries"
        :label-fn="(c) => locale === 'ar' ? c.name_ar : c.name_en"
        :placeholder="t('locations.selectCountry')"
        :selected-label="countryLabel"
        :invalid="!!fieldErrors.country_id"
        required
      >
        <template #empty>
          {{ t('locations.noCountries') }}
        </template>
      </EntitySelect>
    </FormField>

    <div class="grid gap-4 sm:grid-cols-2">
      <FormField for-id="city-name-en" :label="t('cities.nameEn')" :error="fieldErrors.name_en" required>
        <input id="city-name-en" v-model="form.name_en" class="input" autocomplete="off" required>
      </FormField>
      <FormField for-id="city-name-ar" :label="t('cities.nameAr')" :error="fieldErrors.name_ar" required>
        <input id="city-name-ar" v-model="form.name_ar" class="input" dir="rtl" autocomplete="off" required>
      </FormField>
    </div>

    <label class="flex items-start gap-3">
      <input v-model="form.is_active" type="checkbox" class="mt-0.5">
      <span class="text-2sm font-medium text-foreground">{{ t('common.active') }}</span>
    </label>

    <div class="flex items-center justify-end gap-2 border-t border-border pt-4">
      <span v-if="dirty" class="me-auto text-2xs text-muted-foreground">{{ t('common.unsavedChanges') }}</span>
      <button type="button" class="btn btn-secondary" :disabled="saving" @click="cancel">
        {{ t('common.cancel') }}
      </button>
      <button type="submit" class="btn btn-primary min-w-28" :disabled="saving || form.country_id == null">
        <KtIcon v-if="saving" name="loading" class="animate-spin" />
        {{ saving ? t('common.saving') : (isEdit ? t('common.save') : t('cities.createAction')) }}
      </button>
    </div>
  </form>
</template>
