<script setup lang="ts">
// A panel that slides in from the inline-end edge (RTL-aware). Same role as
// AppModal but better for filters and side detail. Closes on Esc / backdrop.
const open = defineModel<boolean>('open', { required: true })
withDefaults(defineProps<{ title?: string, width?: string }>(), { width: '26rem' })
const { t } = useI18n()

function close() {
  open.value = false
}
function onKey(e: KeyboardEvent) {
  if (e.key === 'Escape') close()
}
watch(open, (v) => {
  if (!import.meta.client) return
  document.body.style.overflow = v ? 'hidden' : ''
  if (v) window.addEventListener('keydown', onKey)
  else window.removeEventListener('keydown', onKey)
})
onBeforeUnmount(() => {
  if (!import.meta.client) return
  document.body.style.overflow = ''
  window.removeEventListener('keydown', onKey)
})
</script>

<template>
  <Teleport to="body">
    <Transition name="drawer">
      <div v-if="open" class="fixed inset-0 z-50" role="dialog" aria-modal="true">
        <div class="absolute inset-0 bg-mono/40 backdrop-blur-[2px]" @click="close" />
        <div
          class="absolute inset-y-0 end-0 flex w-full max-w-[92vw] flex-col border-s border-border bg-card shadow-xl"
          :style="{ width }"
        >
          <header class="flex items-center justify-between border-b border-border px-4 py-3">
            <h2 class="text-sm font-semibold text-foreground">
              {{ title }}
            </h2>
            <button type="button" class="btn btn-ghost px-2 py-1" :aria-label="t('common.close')" @click="close">
              <KtIcon name="cross" />
            </button>
          </header>
          <div class="flex-1 overflow-y-auto p-4">
            <slot />
          </div>
          <footer v-if="$slots.footer" class="flex justify-end gap-2 border-t border-border px-4 py-3">
            <slot name="footer" />
          </footer>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.drawer-enter-active,
.drawer-leave-active {
  transition: opacity 0.18s ease;
}
.drawer-enter-active > div:last-child,
.drawer-leave-active > div:last-child {
  transition: transform 0.22s ease;
}
.drawer-enter-from,
.drawer-leave-to {
  opacity: 0;
}
.drawer-enter-from > div:last-child,
.drawer-leave-to > div:last-child {
  transform: translateX(100%);
}
:global([dir='rtl']) .drawer-enter-from > div:last-child,
:global([dir='rtl']) .drawer-leave-to > div:last-child {
  transform: translateX(-100%);
}
</style>
