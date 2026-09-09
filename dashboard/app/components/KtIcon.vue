<script setup lang="ts">
// Keenicons (vendored from metronic-v9.4.12). `variant` picks the icon family.
withDefaults(defineProps<{ name: string, variant?: 'outline' | 'duotone' }>(), {
  variant: 'outline',
})
</script>

<template>
  <i :class="[`ki-${variant}`, `ki-${name}`, 'ki']" aria-hidden="true" />
</template>
