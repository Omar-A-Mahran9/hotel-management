<script setup lang="ts">
const open = defineModel<boolean>('open', { required: true })
const props = withDefaults(
  defineProps<{
    title: string
    message: string
    confirmLabel?: string
    tone?: 'primary' | 'destructive'
    busy?: boolean
  }>(),
  { tone: 'primary' },
)
const emit = defineEmits<{ confirm: [] }>()
const { t } = useI18n()
</script>

<template>
  <AppModal v-model:open="open" :title="props.title">
    <p class="text-sm text-muted-foreground">
      {{ props.message }}
    </p>
    <template #footer>
      <button type="button" class="btn btn-secondary" :disabled="props.busy" @click="open = false">
        {{ t('common.cancel') }}
      </button>
      <button
        type="button"
        class="btn"
        :class="props.tone === 'destructive' ? 'btn-destructive' : 'btn-primary'"
        :disabled="props.busy"
        @click="emit('confirm')"
      >
        {{ props.confirmLabel || t('common.confirm') }}
      </button>
    </template>
  </AppModal>
</template>
