<script setup lang="ts" generic="K extends string">
interface Tab {
  key: K
  label: string
  count?: number | null
}
defineProps<{ tabs: Tab[] }>()
const model = defineModel<K>({ required: true })
</script>

<template>
  <div class="flex flex-wrap gap-1 border-b border-border">
    <button
      v-for="tab in tabs"
      :key="tab.key"
      type="button"
      class="-mb-px border-b-2 px-3 py-2 text-2sm font-medium transition-colors"
      :class="model === tab.key
        ? 'border-primary text-primary'
        : 'border-transparent text-muted-foreground hover:text-foreground'"
      @click="model = tab.key"
    >
      {{ tab.label }}
      <span
        v-if="tab.count != null"
        class="ms-1.5 rounded-full bg-secondary px-1.5 text-2xs text-secondary-foreground"
      >{{ tab.count }}</span>
    </button>
  </div>
</template>
