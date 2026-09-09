<script setup lang="ts">
const { locale, locales, setLocale } = useI18n()

const options = computed(() =>
  (locales.value as Array<{ code: string, name: string }>).map(l => ({ code: l.code, name: l.name })),
)

function pick(code: string) {
  setLocale(code as 'en' | 'ar')
}
</script>

<template>
  <AppDropdown width="10rem">
    <template #trigger>
      <button type="button" class="btn btn-ghost px-2 py-1.5" aria-label="Language">
        <KtIcon name="flag" />
        <span class="text-2sm uppercase">{{ locale }}</span>
      </button>
    </template>
    <button
      v-for="opt in options"
      :key="opt.code"
      type="button"
      class="flex w-full items-center justify-between rounded-md px-2.5 py-2 text-start text-sm hover:bg-secondary"
      :class="{ 'text-primary font-semibold': locale === opt.code }"
      @click="pick(opt.code)"
    >
      {{ opt.name }}
      <KtIcon v-if="locale === opt.code" name="check" />
    </button>
  </AppDropdown>
</template>
