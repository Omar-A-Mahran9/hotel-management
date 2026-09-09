<script setup lang="ts">
const app = useAppStore()

const icon = (kind: string) =>
  kind === 'success' ? 'check-circle' : kind === 'error' ? 'information-4' : 'notification-status'
</script>

<template>
  <Teleport to="body">
    <div class="fixed bottom-4 end-4 z-[60] flex w-[min(92vw,22rem)] flex-col gap-2">
      <TransitionGroup name="toast">
        <div
          v-for="toast in app.toasts"
          :key="toast.id"
          class="card flex items-start gap-2 p-3 text-sm shadow-lg"
          :class="{
            'border-s-4 border-s-success': toast.kind === 'success',
            'border-s-4 border-s-destructive': toast.kind === 'error',
            'border-s-4 border-s-info': toast.kind === 'info',
          }"
          role="status"
        >
          <KtIcon
            :name="icon(toast.kind)"
            class="mt-0.5"
            :class="{
              'text-success': toast.kind === 'success',
              'text-destructive': toast.kind === 'error',
              'text-info': toast.kind === 'info',
            }"
          />
          <span class="flex-1 text-foreground">{{ toast.message }}</span>
          <button type="button" class="text-muted-foreground hover:text-foreground" @click="app.dismissToast(toast.id)">
            <KtIcon name="cross" />
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.2s ease;
}
.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(8px);
}
</style>
