<script setup lang="ts">
// From/to date pair. v-model is `{ from: string, to: string }` (ISO date
// strings, '' when empty). Native inputs — keyboard accessible, locale-aware.
const model = defineModel<{ from: string, to: string }>({
  default: () => ({ from: '', to: '' }),
})
defineProps<{ label?: string }>()
const { t } = useI18n()
</script>

<template>
  <FormField :label="label ?? t('common.dateRange')">
    <div class="flex items-center gap-2">
      <input
        :value="model.from"
        type="date"
        class="input"
        :aria-label="t('common.from')"
        @input="model = { ...model, from: ($event.target as HTMLInputElement).value }"
      >
      <span class="text-muted-foreground">–</span>
      <input
        :value="model.to"
        type="date"
        class="input"
        :aria-label="t('common.to')"
        :min="model.from || undefined"
        @input="model = { ...model, to: ($event.target as HTMLInputElement).value }"
      >
    </div>
  </FormField>
</template>
