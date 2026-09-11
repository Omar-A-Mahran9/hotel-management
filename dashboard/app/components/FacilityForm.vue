<script setup lang="ts">
import type { Facility } from '~/types/api'
import { facilitiesService } from '~/services'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ facility?: Facility | null }>()
const emit = defineEmits<{ saved: [facility: Facility] }>()

const { t } = useI18n()
const app = useAppStore()
const router = useRouter()

const isEdit = computed(() => !!props.facility)

interface FormState {
  key: string
  name_en: string
  name_ar: string
  icon: string
  is_active: boolean
}

function snapshot(f?: Facility | null): FormState {
  return {
    key: f?.key ?? '',
    name_en: f?.name_i18n?.en ?? '',
    name_ar: f?.name_i18n?.ar ?? '',
    icon: f?.icon ?? '',
    is_active: f?.is_active ?? true,
  }
}

const form = reactive<FormState>(snapshot(props.facility))
let initial = JSON.stringify(form)

watch(() => props.facility, (f) => {
  if (f) {
    Object.assign(form, snapshot(f))
    initial = JSON.stringify(form)
  }
})

const dirty = computed(() => JSON.stringify(form) !== initial)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})

async function save() {
  if (saving.value) return
  saving.value = true
  fieldErrors.value = {}
  try {
    const name_i18n: Record<string, string> = {}
    if (form.name_en.trim()) name_i18n.en = form.name_en.trim()
    if (form.name_ar.trim()) name_i18n.ar = form.name_ar.trim()

    let facility: Facility
    if (props.facility) {
      // is_active is toggled via its own action, not the update payload.
      facility = await facilitiesService.update(props.facility.id, {
        key: form.key || undefined,
        name_i18n,
        icon: form.icon || null,
      })
      if (form.is_active !== props.facility.is_active) {
        facility = form.is_active
          ? await facilitiesService.activate(props.facility.id)
          : await facilitiesService.deactivate(props.facility.id)
      }
    } else {
      facility = await facilitiesService.create({
        key: form.key || undefined,
        name_i18n,
        icon: form.icon || null,
        is_active: form.is_active,
      })
    }
    initial = JSON.stringify(form)
    app.pushToast('success', isEdit.value ? t('facilities.updated') : t('facilities.created'))
    emit('saved', facility)
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
  router.push('/facilities')
}

onBeforeRouteLeave(() => {
  if (dirty.value && !saving.value) return window.confirm(t('common.unsavedLeave'))
})
</script>

<template>
  <form class="space-y-5" novalidate @submit.prevent="save">
    <div class="grid gap-4 sm:grid-cols-2">
      <FormField for-id="f-name-en" :label="t('facilities.nameEn')" :error="fieldErrors['name_i18n.en']" required>
        <input id="f-name-en" v-model="form.name_en" class="input" autocomplete="off" required>
      </FormField>
      <FormField for-id="f-name-ar" :label="t('facilities.nameAr')" :error="fieldErrors['name_i18n.ar']" :hint="t('facilities.nameArHint')">
        <input id="f-name-ar" v-model="form.name_ar" class="input" dir="rtl" autocomplete="off">
      </FormField>
    </div>

    <FormField for-id="f-key" :label="t('facilities.key')" :error="fieldErrors.key" :hint="t('facilities.keyHint')">
      <input id="f-key" v-model="form.key" class="input font-mono" autocomplete="off" placeholder="free_wifi">
    </FormField>

    <FormField for-id="f-icon" :label="t('facilities.icon')" :error="fieldErrors.icon" :hint="t('facilities.iconHint')">
      <input id="f-icon" v-model="form.icon" class="input" autocomplete="off" placeholder="wifi">
    </FormField>

    <label class="flex items-start gap-3">
      <input v-model="form.is_active" type="checkbox" class="mt-0.5">
      <span class="text-2sm">
        <span class="font-medium text-foreground">{{ t('common.active') }}</span>
        <span class="mt-0.5 block text-muted-foreground">{{ t('facilities.activeHint') }}</span>
      </span>
    </label>

    <div class="flex items-center justify-end gap-2 border-t border-border pt-4">
      <span v-if="dirty" class="me-auto text-2xs text-muted-foreground">{{ t('common.unsavedChanges') }}</span>
      <button type="button" class="btn btn-secondary" :disabled="saving" @click="cancel">
        {{ t('common.cancel') }}
      </button>
      <button type="submit" class="btn btn-primary min-w-28" :disabled="saving">
        <KtIcon v-if="saving" name="loading" class="animate-spin" />
        {{ saving ? t('common.saving') : (isEdit ? t('common.save') : t('facilities.createAction')) }}
      </button>
    </div>
  </form>
</template>
