<script setup lang="ts">
type Tone = 'neutral' | 'info' | 'primary' | 'success' | 'warning' | 'destructive'

const props = withDefaults(defineProps<{ label: string, tone?: Tone }>(), {
  tone: 'neutral',
})

const toneClass = computed(() => {
  const map: Record<Tone, string> = {
    neutral: 'bg-secondary text-secondary-foreground',
    info: 'bg-info/15 text-info',
    primary: 'bg-primary/12 text-primary',
    success: 'bg-success/15 text-success',
    warning: 'bg-warning/18 text-[color:color-mix(in_oklab,var(--warning),black_25%)]',
    destructive: 'bg-destructive/12 text-destructive',
  }
  return map[props.tone]
})
</script>

<template>
  <span
    class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-2xs font-semibold uppercase tracking-wide"
    :class="toneClass"
  >
    {{ label }}
  </span>
</template>
