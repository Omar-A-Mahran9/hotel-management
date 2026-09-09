<script setup lang="ts">
// Renders its slot only when the user holds the required permission(s).
// UI convenience only — never the security boundary.
const props = withDefaults(
  defineProps<{
    permission: string | string[]
    mode?: 'any' | 'all'
  }>(),
  { mode: 'any' },
)

const { canAny, canAll } = useCan()

const allowed = computed(() => {
  const list = Array.isArray(props.permission) ? props.permission : [props.permission]
  return props.mode === 'all' ? canAll(...list) : canAny(...list)
})
</script>

<template>
  <slot v-if="allowed" />
  <slot v-else name="fallback" />
</template>
