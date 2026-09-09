<script setup lang="ts">
withDefaults(defineProps<{ rows?: number, label?: string }>(), { rows: 5 })
const { t } = useI18n()
</script>

<template>
  <div class="p-6" role="status" :aria-label="label || t('common.loading')">
    <div class="animate-pulse space-y-3">
      <div v-for="i in rows" :key="i" class="h-10 rounded-md bg-secondary" />
    </div>
  </div>
</template>
