<script setup lang="ts">
const app = useAppStore()
const { t } = useI18n()
</script>

<template>
  <button
    type="button"
    class="btn btn-ghost px-2 py-1.5"
    :aria-label="app.theme === 'dark' ? t('theme.switchToLight') : t('theme.switchToDark')"
    @click="app.setTheme(app.theme === 'dark' ? 'light' : 'dark')"
  >
    <KtIcon :name="app.theme === 'dark' ? 'sun' : 'moon'" />
  </button>
</template>
