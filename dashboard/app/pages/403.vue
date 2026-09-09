<script setup lang="ts">
const { t } = useI18n()
</script>

<template>
  <div class="flex min-h-[60vh] flex-col items-center justify-center gap-3 text-center">
    <div class="flex size-14 items-center justify-center rounded-full bg-destructive/10 text-destructive">
      <KtIcon name="lock-2" class="text-2xl" />
    </div>
    <h1 class="text-lg font-semibold text-foreground">
      {{ t('errors.forbiddenTitle') }}
    </h1>
    <p class="max-w-md text-sm text-muted-foreground">
      {{ t('errors.forbiddenBody') }}
    </p>
    <NuxtLink to="/" class="btn btn-secondary mt-2">
      {{ t('common.back') }}
    </NuxtLink>
  </div>
</template>
