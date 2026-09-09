<script setup lang="ts">
withDefaults(defineProps<{ title?: string, body?: string, icon?: string }>(), {
  icon: 'document',
})
const { t } = useI18n()
</script>

<template>
  <div class="flex flex-col items-center justify-center gap-2 p-10 text-center">
    <div class="flex size-11 items-center justify-center rounded-full bg-secondary text-muted-foreground">
      <KtIcon :name="icon" />
    </div>
    <div class="text-sm font-semibold text-foreground">
      {{ title || t('empty.title') }}
    </div>
    <p class="max-w-sm text-sm text-muted-foreground">
      {{ body || t('empty.body') }}
    </p>
    <slot />
  </div>
</template>
