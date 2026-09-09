<script setup lang="ts">
import { ApiError } from '~/utils/apiError'

definePageMeta({ layout: 'auth' })

const { t } = useI18n()
const auth = useAuthStore()
const route = useRoute()
const router = useRouter()

const email = ref('')
const password = ref('')
const submitting = ref(false)
const formError = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})

async function submit() {
  if (submitting.value) return
  submitting.value = true
  formError.value = null
  fieldErrors.value = {}
  try {
    // Guest accounts hold no staff permissions — the backend rejects them
    // and the resulting permission-less session simply shows nothing.
    await auth.login(email.value, password.value)
    useHotelContextStore().init()
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/'
    await router.push(redirect)
  } catch (e) {
    if (e instanceof ApiError) {
      if (e.kind === 'validation' && e.errors) {
        fieldErrors.value = e.errors
      } else if (e.status === 403) {
        formError.value = t('auth.inactive')
      } else if (e.status === 401) {
        formError.value = t('auth.invalid')
      } else {
        formError.value = e.message
      }
    } else {
      formError.value = t('errors.genericBody')
    }
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div>
    <h1 class="text-xl font-semibold text-foreground">
      {{ t('auth.loginTitle') }}
    </h1>
    <p class="mt-1 text-sm text-muted-foreground">
      {{ t('auth.loginSubtitle') }}
    </p>

    <form class="mt-8 space-y-4" novalidate @submit.prevent="submit">
      <div
        v-if="formError"
        class="flex items-start gap-2 rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-2sm text-destructive"
      >
        <KtIcon name="information-4" class="mt-0.5" />
        <span>{{ formError }}</span>
      </div>

      <FormField for-id="email" :label="t('auth.email')" :error="fieldErrors.email" required>
        <input
          id="email"
          v-model="email"
          type="email"
          autocomplete="username"
          class="input"
          required
        >
      </FormField>

      <FormField for-id="password" :label="t('auth.password')" :error="fieldErrors.password" required>
        <input
          id="password"
          v-model="password"
          type="password"
          autocomplete="current-password"
          class="input"
          required
        >
      </FormField>

      <button type="submit" class="btn btn-primary w-full" :disabled="submitting">
        <KtIcon v-if="submitting" name="loading" />
        {{ submitting ? t('auth.signingIn') : t('auth.signIn') }}
      </button>
    </form>
  </div>
</template>
