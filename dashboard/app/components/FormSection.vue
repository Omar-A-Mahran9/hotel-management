<script setup lang="ts">
// A titled section of an enterprise form: a heading + short description on
// one side, the fields on the other (stacked on small screens). Keeps every
// long form on the dashboard visually consistent.
defineProps<{ title: string, description?: string }>()
</script>

<template>
  <section class="grid gap-4 border-b border-border py-6 first:pt-0 last:border-b-0 md:grid-cols-[minmax(0,14rem)_1fr] md:gap-8">
    <div>
      <h2 class="text-sm font-semibold text-foreground">
        {{ title }}
      </h2>
      <p v-if="description" class="mt-1 text-2sm text-muted-foreground">
        {{ description }}
      </p>
    </div>
    <div class="space-y-4">
      <slot />
    </div>
  </section>
</template>
