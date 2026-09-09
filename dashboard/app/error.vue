<script setup lang="ts">
import type { NuxtError } from '#app'

const props = defineProps<{ error: NuxtError }>()
const { t } = useI18n()

const isNotFound = computed(() => props.error?.statusCode === 404)
const isForbidden = computed(() => props.error?.statusCode === 403)

function goHome() {
  clearError({ redirect: '/' })
}
</script>

<template>
  <div class="flex min-h-screen items-center justify-center bg-background p-6">
    <NotFoundState v-if="isNotFound" />
    <ForbiddenState v-else-if="isForbidden" />
    <div v-else class="flex flex-col items-center gap-3 text-center">
      <div class="flex size-14 items-center justify-center rounded-full bg-destructive/10 text-destructive">
        <KtIcon name="information-4" class="text-2xl" />
      </div>
      <h1 class="text-lg font-semibold text-foreground">
        {{ t('errors.genericTitle') }}
      </h1>
      <p class="max-w-md text-sm text-muted-foreground">
        {{ error.message || t('errors.genericBody') }}
      </p>
      <button type="button" class="btn btn-primary mt-2" @click="goHome">
        {{ t('common.back') }}
      </button>
    </div>
  </div>
</template>
