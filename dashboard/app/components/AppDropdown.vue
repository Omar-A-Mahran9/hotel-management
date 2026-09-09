<script setup lang="ts">
withDefaults(defineProps<{ align?: 'start' | 'end', width?: string }>(), {
  align: 'end',
  width: '14rem',
})
const open = ref(false)
const root = ref<HTMLElement | null>(null)

function onDocClick(e: MouseEvent) {
  if (root.value && !root.value.contains(e.target as Node)) open.value = false
}
onMounted(() => document.addEventListener('click', onDocClick))
onBeforeUnmount(() => document.removeEventListener('click', onDocClick))

defineExpose({ close: () => (open.value = false) })
</script>

<template>
  <div ref="root" class="relative">
    <div @click="open = !open">
      <slot name="trigger" :open="open" />
    </div>
    <Transition name="dd">
      <div
        v-if="open"
        class="card absolute z-40 mt-1 overflow-hidden p-1 shadow-lg"
        :class="align === 'end' ? 'end-0' : 'start-0'"
        :style="{ width }"
        @click="open = false"
      >
        <slot />
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.dd-enter-active,
.dd-leave-active {
  transition: opacity 0.12s ease, transform 0.12s ease;
}
.dd-enter-from,
.dd-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}
</style>
