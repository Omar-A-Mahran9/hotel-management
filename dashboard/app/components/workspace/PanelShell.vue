<script setup lang="ts">
// Consistent frame for every reservation-workspace panel: title, optional
// header actions, and the loading / error / empty lifecycle.
defineProps<{
  title: string
  pending?: boolean
  error?: unknown
  isEmpty?: boolean
  emptyBody?: string
}>()
const emit = defineEmits<{ retry: [] }>()
</script>

<template>
  <DataCard :title="title">
    <template v-if="$slots.actions" #headerActions>
      <slot name="actions" />
    </template>
    <LoadingState v-if="pending" :rows="3" />
    <ErrorState v-else-if="error" :error="error" @retry="emit('retry')" />
    <EmptyState v-else-if="isEmpty" :body="emptyBody" />
    <slot v-else />
  </DataCard>
</template>
