<script setup lang="ts">
withDefaults(defineProps<{ compact?: boolean, to?: string }>(), { to: '/' })
const { t } = useI18n()
</script>

<template>
  <div
    class="flex flex-col items-center justify-center gap-3 text-center"
    :class="compact ? 'p-8' : 'min-h-[55vh] p-6'"
  >
    <div class="flex size-12 items-center justify-center rounded-full bg-secondary text-muted-foreground">
      <KtIcon name="file-deleted" class="text-xl" />
    </div>
    <h2 class="text-base font-semibold text-foreground">
      {{ t('errors.notFoundTitle') }}
    </h2>
    <p class="max-w-sm text-sm text-muted-foreground">
      {{ t('errors.notFoundBody') }}
    </p>
    <NuxtLink :to="to" class="btn btn-secondary mt-1">
      {{ t('common.back') }}
    </NuxtLink>
  </div>
</template>
