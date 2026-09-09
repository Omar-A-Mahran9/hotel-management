<script setup lang="ts">
defineProps<{ title: string, subtitle?: string }>()
</script>

<template>
  <div class="mb-5 flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
    <div>
      <h1 class="text-xl font-semibold text-foreground">
        {{ title }}
      </h1>
      <p v-if="subtitle" class="mt-1 text-sm text-muted-foreground">
        {{ subtitle }}
      </p>
      <slot name="meta" />
    </div>
    <div v-if="$slots.actions" class="flex shrink-0 items-center gap-2">
      <slot name="actions" />
    </div>
  </div>
</template>
