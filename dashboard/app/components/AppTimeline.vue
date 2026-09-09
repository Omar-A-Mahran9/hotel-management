<script setup lang="ts">
export interface TimelineStage {
  key: string
  label: string
  hint?: string
  state: 'done' | 'current' | 'upcoming' | 'blocked'
}
defineProps<{ stages: TimelineStage[] }>()

const dot: Record<string, string> = {
  done: 'bg-success border-success text-success-foreground',
  current: 'bg-primary border-primary text-primary-foreground',
  upcoming: 'bg-card border-border text-muted-foreground',
  blocked: 'bg-destructive border-destructive text-destructive-foreground',
}
</script>

<template>
  <ol class="relative space-y-4 ps-1">
    <li v-for="(s, i) in stages" :key="s.key" class="relative flex gap-3">
      <div class="flex flex-col items-center">
        <span
          class="z-10 flex size-6 shrink-0 items-center justify-center rounded-full border-2 text-2xs font-bold"
          :class="dot[s.state]"
        >
          <KtIcon v-if="s.state === 'done'" name="check" class="text-2xs" />
          <KtIcon v-else-if="s.state === 'blocked'" name="cross" class="text-2xs" />
          <span v-else>{{ i + 1 }}</span>
        </span>
        <span
          v-if="i < stages.length - 1"
          class="mt-0.5 w-0.5 flex-1"
          :class="s.state === 'done' ? 'bg-success/50' : 'bg-border'"
        />
      </div>
      <div class="pb-1">
        <div
          class="text-2sm font-medium"
          :class="s.state === 'current' ? 'text-primary' : s.state === 'upcoming' ? 'text-muted-foreground' : 'text-foreground'"
        >
          {{ s.label }}
        </div>
        <div v-if="s.hint" class="text-2xs text-muted-foreground">
          {{ s.hint }}
        </div>
      </div>
    </li>
  </ol>
</template>
