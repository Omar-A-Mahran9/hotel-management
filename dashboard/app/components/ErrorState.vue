<script setup lang="ts">
import { ApiError } from '~/utils/apiError'

const props = defineProps<{ error: unknown }>()
const emit = defineEmits<{ retry: [] }>()
const { t } = useI18n()

const view = computed(() => {
  const e = props.error
  if (e instanceof ApiError) {
    switch (e.kind) {
      case 'network':
        return { icon: 'wifi-square', title: t('errors.networkTitle'), body: t('errors.networkBody'), retry: true }
      case 'forbidden':
        return { icon: 'lock-2', title: t('errors.forbiddenTitle'), body: t('errors.forbiddenBody'), retry: false }
      case 'not_found':
        return { icon: 'file-deleted', title: t('errors.notFoundTitle'), body: t('errors.notFoundBody'), retry: false }
      case 'rate_limited':
        return { icon: 'time', title: t('errors.rateLimitedTitle'), body: t('errors.rateLimitedBody'), retry: true }
      case 'server':
        return { icon: 'information-4', title: t('errors.serverTitle'), body: t('errors.serverBody'), retry: true }
      case 'validation':
        return { icon: 'information-4', title: t('errors.validationTitle'), body: e.message, retry: false }
      default:
        return { icon: 'information-4', title: t('errors.genericTitle'), body: e.message || t('errors.genericBody'), retry: true }
    }
  }
  return { icon: 'information-4', title: t('errors.genericTitle'), body: t('errors.genericBody'), retry: true }
})
</script>

<template>
  <div class="flex flex-col items-center justify-center gap-3 p-10 text-center">
    <div class="flex size-12 items-center justify-center rounded-full bg-destructive/10 text-destructive">
      <KtIcon :name="view.icon" />
    </div>
    <div class="text-base font-semibold text-foreground">
      {{ view.title }}
    </div>
    <p class="max-w-sm text-sm text-muted-foreground">
      {{ view.body }}
    </p>
    <button v-if="view.retry" type="button" class="btn btn-secondary mt-1" @click="emit('retry')">
      <KtIcon name="arrows-circle" />
      {{ t('common.retry') }}
    </button>
  </div>
</template>
