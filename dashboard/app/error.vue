<script setup lang="ts">
import type { NuxtError } from '#app'

defineProps<{ error: NuxtError }>()
const { t } = useI18n()

function goHome() {
  clearError({ redirect: '/' })
}
</script>

<template>
  <div class="flex min-h-screen flex-col items-center justify-center gap-3 bg-background p-6 text-center">
    <div class="flex size-14 items-center justify-center rounded-full bg-destructive/10 text-destructive">
      <KtIcon name="information-4" class="text-2xl" />
    </div>
    <h1 class="text-lg font-semibold text-foreground">
      {{ error.statusCode === 404 ? t('errors.notFoundTitle') : t('errors.genericTitle') }}
    </h1>
    <p class="max-w-md text-sm text-muted-foreground">
      {{ error.statusCode === 404 ? t('errors.notFoundBody') : (error.message || t('errors.genericBody')) }}
    </p>
    <button type="button" class="btn btn-primary mt-2" @click="goHome">
      {{ t('common.back') }}
    </button>
  </div>
</template>
