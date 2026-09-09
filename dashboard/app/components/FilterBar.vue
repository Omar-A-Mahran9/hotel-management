<script setup lang="ts">
// A consistent row for list-page filters. Slot in FormField / SearchField
// controls; the "Clear" button shows when `active` and emits `clear`.
defineProps<{ active?: boolean }>()
const emit = defineEmits<{ clear: [] }>()
const { t } = useI18n()
</script>

<template>
  <div class="mb-4 flex flex-wrap items-end gap-3">
    <slot />
    <button
      v-if="active"
      type="button"
      class="btn btn-ghost px-2.5 py-2 text-2sm text-muted-foreground"
      @click="emit('clear')"
    >
      <KtIcon name="cross-circle" /> {{ t('common.clear') }}
    </button>
  </div>
</template>
