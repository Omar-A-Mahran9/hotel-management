<script setup lang="ts">
defineProps<{ facts: Array<{ label: string, value: string | number | null | undefined }> }>()
</script>

<template>
  <dl class="grid gap-4 sm:grid-cols-2">
    <div v-for="f in facts" :key="f.label">
      <dt class="text-2xs font-semibold uppercase tracking-wide text-muted-foreground">
        {{ f.label }}
      </dt>
      <dd class="mt-0.5 text-sm font-medium text-foreground">
        {{ f.value ?? '—' }}
      </dd>
    </div>
  </dl>
</template>
