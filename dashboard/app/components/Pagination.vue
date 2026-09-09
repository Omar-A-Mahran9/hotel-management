<script setup lang="ts">
import type { ApiMeta } from '~/types/api'

const props = defineProps<{ meta: ApiMeta | null }>()
const emit = defineEmits<{ page: [n: number] }>()
const { t } = useI18n()

const current = computed(() => props.meta?.current_page ?? 1)
const last = computed(() => props.meta?.last_page ?? 1)
const total = computed(() => props.meta?.total ?? 0)
const from = computed(() => props.meta?.from ?? 0)
const to = computed(() => props.meta?.to ?? 0)

function go(n: number) {
  if (n >= 1 && n <= last.value && n !== current.value) emit('page', n)
}
</script>

<template>
  <div class="flex flex-col items-center justify-between gap-3 text-sm text-muted-foreground sm:flex-row">
    <span>{{ t('common.showing', { from, to, total }) }}</span>
    <div class="flex items-center gap-1">
      <button
        type="button"
        class="btn btn-ghost px-2 py-1"
        :disabled="current <= 1"
        @click="go(current - 1)"
      >
        <KtIcon name="left" />
      </button>
      <span class="px-2">{{ t('common.page') }} {{ current }} {{ t('common.of') }} {{ last }}</span>
      <button
        type="button"
        class="btn btn-ghost px-2 py-1"
        :disabled="current >= last"
        @click="go(current + 1)"
      >
        <KtIcon name="right" />
      </button>
    </div>
  </div>
</template>
