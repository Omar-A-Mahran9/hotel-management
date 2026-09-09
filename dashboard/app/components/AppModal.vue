<script setup lang="ts">
const open = defineModel<boolean>('open', { required: true })
defineProps<{ title?: string }>()
const { t } = useI18n()

function close() {
  open.value = false
}

function onKey(e: KeyboardEvent) {
  if (e.key === 'Escape') close()
}

watch(open, (v) => {
  if (import.meta.client) {
    document.body.style.overflow = v ? 'hidden' : ''
    if (v) window.addEventListener('keydown', onKey)
    else window.removeEventListener('keydown', onKey)
  }
})

onBeforeUnmount(() => {
  if (import.meta.client) {
    document.body.style.overflow = ''
    window.removeEventListener('keydown', onKey)
  }
})
</script>

<template>
  <Teleport to="body">
    <Transition name="fade">
      <div
        v-if="open"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
        role="dialog"
        aria-modal="true"
      >
        <div class="absolute inset-0 bg-mono/40 backdrop-blur-[2px]" @click="close" />
        <div class="card relative z-10 w-full max-w-lg">
          <header class="flex items-center justify-between border-b border-border px-4 py-3">
            <h2 class="text-sm font-semibold">
              {{ title }}
            </h2>
            <button type="button" class="btn btn-ghost px-2 py-1" :aria-label="t('common.close')" @click="close">
              <KtIcon name="cross" />
            </button>
          </header>
          <div class="p-4">
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
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
