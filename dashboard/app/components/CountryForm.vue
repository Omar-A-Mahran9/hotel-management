<script setup lang="ts">
import type { Country } from '~/types/api'
import { countriesService } from '~/services'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ country?: Country | null }>()
const emit = defineEmits<{ saved: [country: Country] }>()

const { t } = useI18n()
const app = useAppStore()
const router = useRouter()

const isEdit = computed(() => !!props.country)

interface FormState {
  name_en: string
  name_ar: string
  code: string
  is_active: boolean
}

function snapshot(c?: Country | null): FormState {
  return {
    name_en: c?.name_en ?? '',
    name_ar: c?.name_ar ?? '',
    code: c?.code ?? '',
    is_active: c?.is_active ?? true,
  }
}

const form = reactive<FormState>(snapshot(props.country))
let initial = JSON.stringify(form)

watch(
  () => props.country,
  (c) => {
    if (c) {
      Object.assign(form, snapshot(c))
      initial = JSON.stringify(form)
    }
  },
)

const dirty = computed(
  () => JSON.stringify(form) !== initial,
)

const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})

async function save() {
  if (saving.value) return

  saving.value = true
  fieldErrors.value = {}

  try {
    let country: Country

    if (props.country) {
      // is_active is toggled via its own action, not the update payload.
      country = await countriesService.update(
        props.country.id,
        {
          name_en: form.name_en,
          name_ar: form.name_ar,
          code: form.code,
        },
      )

      if (
        form.is_active !==
        props.country.is_active
      ) {
        country = form.is_active
          ? await countriesService.activate(
              props.country.id,
            )
          : await countriesService.deactivate(
              props.country.id,
            )
      }
    } else {
      country = await countriesService.create({
        name_en: form.name_en,
        name_ar: form.name_ar,
        code: form.code,
        is_active: form.is_active,
      })
    }

    initial = JSON.stringify(form)

    app.pushToast(
      'success',
      isEdit.value
        ? t('countries.updated')
        : t('countries.created'),
    )

    emit('saved', country)
  } catch (e) {
    if (
      e instanceof ApiError &&
      e.kind === 'validation' &&
      e.errors
    ) {
      fieldErrors.value = e.errors

      app.pushToast(
        'error',
        t('errors.validationTitle'),
      )
    } else {
      app.pushToast(
        'error',
        e instanceof ApiError
          ? e.message
          : t('errors.genericBody'),
      )
    }
  } finally {
    saving.value = false
  }
}

function cancel() {
  router.push('/countries')
}

onBeforeRouteLeave(() => {
  if (
    dirty.value &&
    !saving.value
  ) {
    return window.confirm(
      t('common.unsavedLeave'),
    )
  }
})
</script>

<template>
  <form
    class="space-y-6"
    novalidate
    @submit.prevent="save"
  >
    <!-- Country Names -->

    <div class="grid gap-5 sm:grid-cols-2">
      <FormField
        for-id="c-name-en"
        :label="t('countries.nameEn')"
        :error="fieldErrors.name_en"
        required
      >
        <input
          id="c-name-en"
          v-model="form.name_en"
          class="input"
          autocomplete="off"
          required
        >
      </FormField>

      <FormField
        for-id="c-name-ar"
        :label="t('countries.nameAr')"
        :error="fieldErrors.name_ar"
        required
      >
        <input
          id="c-name-ar"
          v-model="form.name_ar"
          class="input"
          dir="rtl"
          autocomplete="off"
          required
        >
      </FormField>
    </div>

    <!-- Country Code -->

    <FormField
      for-id="c-code"
      :label="t('countries.code')"
      :error="fieldErrors.code"
      :hint="t('countries.codeHint')"
      required
    >
      <input
        id="c-code"
        v-model="form.code"
        class="input uppercase"
        autocomplete="off"
        maxlength="8"
        required
      >
    </FormField>

    <!-- Active -->

    <div
      class="flex items-center justify-between gap-4 rounded-xl border border-border px-4 py-4"
    >
      <div class="min-w-0">
        <div class="text-sm font-medium text-foreground">
          {{ t('common.active') }}
        </div>

        <p class="mt-1 text-xs text-muted-foreground">
          {{ t('countries.activeHint') }}
        </p>
      </div>

      <button
        type="button"
        role="switch"
        :aria-checked="form.is_active"
        :disabled="saving"
        class="relative inline-flex h-6 w-11 shrink-0 rounded-full border-2 border-transparent transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
        :class="
          form.is_active
            ? 'bg-primary'
            : 'bg-muted'
        "
        @click="form.is_active = !form.is_active"
      >
        <span class="sr-only">
          {{ t('common.active') }}
        </span>

        <span
          class="pointer-events-none block size-5 rounded-full bg-white shadow-sm transition-transform duration-200"
          :class="
            form.is_active
              ? 'translate-x-5 rtl:-translate-x-5'
              : 'translate-x-0'
          "
        />
      </button>
    </div>

    <!-- Actions -->

    <div
      class="flex items-center justify-end gap-2 border-t border-border pt-5"
    >
      <span
        v-if="dirty"
        class="me-auto text-2xs text-muted-foreground"
      >
        {{ t('common.unsavedChanges') }}
      </span>

      <button
        type="button"
        class="btn btn-secondary"
        :disabled="saving"
        @click="cancel"
      >
        {{ t('common.cancel') }}
      </button>

      <button
        type="submit"
        class="btn btn-primary min-w-28"
        :disabled="saving"
      >
        <KtIcon
          v-if="saving"
          name="loading"
          class="animate-spin"
        />

        {{
          saving
            ? t('common.saving')
            : isEdit
              ? t('common.save')
              : t('countries.createAction')
        }}
      </button>
    </div>
  </form>
</template>
