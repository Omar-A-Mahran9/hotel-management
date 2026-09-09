<script setup lang="ts">
withDefaults(defineProps<{ tone?: 'info' | 'warning', title?: string }>(), { tone: 'info' })
</script>

<template>
  <div
    class="flex gap-2.5 rounded-lg border p-3 text-2sm"
    :class="tone === 'warning'
      ? 'border-warning/40 bg-warning/10 text-[color:color-mix(in_oklab,var(--warning),black_30%)]'
      : 'border-info/30 bg-info/8 text-foreground'"
  >
    <KtIcon name="information-4" class="mt-0.5 shrink-0" :class="tone === 'warning' ? 'text-warning' : 'text-info'" />
    <div>
      <p v-if="title" class="font-semibold">
        {{ title }}
      </p>
      <p class="text-muted-foreground">
        <slot />
      </p>
    </div>
  </div>
</template>
