<script setup lang="ts">
defineProps<{ title?: string, noPad?: boolean }>()
</script>

<template>
  <section class="card overflow-hidden">
    <header
      v-if="title || $slots.header || $slots.headerActions"
      class="flex items-center justify-between gap-3 border-b border-border px-4 py-3"
    >
      <div class="text-sm font-semibold text-foreground">
        <slot name="header">
          {{ title }}
        </slot>
      </div>
      <div v-if="$slots.headerActions" class="flex items-center gap-2">
        <slot name="headerActions" />
      </div>
    </header>
    <div :class="noPad ? '' : 'p-4'">
      <slot />
    </div>
    <footer v-if="$slots.footer" class="border-t border-border px-4 py-3">
      <slot name="footer" />
    </footer>
  </section>
</template>
