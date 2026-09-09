<script setup lang="ts">
const model = defineModel<string>({ default: '' })
withDefaults(defineProps<{ placeholder?: string, hint?: string }>(), {})
const { t } = useI18n()
</script>

<template>
  <div class="flex flex-col gap-1">
    <div class="relative">
      <span class="pointer-events-none absolute inset-y-0 start-0 flex items-center ps-3 text-muted-foreground">
        <KtIcon name="magnifier" />
      </span>
      <input
        v-model="model"
        type="search"
        class="input ps-9"
        :placeholder="placeholder || t('common.search')"
      >
    </div>
    <p v-if="hint" class="text-2xs text-muted-foreground">
      {{ hint }}
    </p>
  </div>
</template>
