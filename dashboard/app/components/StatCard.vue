<script setup lang="ts">
defineProps<{ label: string, value: string | number, icon?: string, hint?: string }>()
</script>

<template>
  <div class="card p-4">
    <div class="flex items-start justify-between">
      <div>
        <div class="text-2xs font-semibold uppercase tracking-wide text-muted-foreground">
          {{ label }}
        </div>
        <div class="mt-1 text-2xl font-bold text-foreground">
          {{ value }}
        </div>
      </div>
      <div v-if="icon" class="flex size-9 items-center justify-center rounded-lg bg-primary/12 text-primary">
        <KtIcon :name="icon" />
      </div>
    </div>
    <div v-if="hint" class="mt-1 text-2xs text-muted-foreground">
      {{ hint }}
    </div>
  </div>
</template>
