<script setup lang="ts">
const app = useAppStore()
const { t } = useI18n()
</script>

<template>
  <header
    class="fixed top-0 end-0 start-0 z-30 flex h-[var(--header-height)] items-center gap-2 border-b border-border bg-card/95 px-4 backdrop-blur transition-[inset-inline-start] lg:start-[var(--sidebar-width)] lg:px-6"
  >
    <button
      type="button"
      class="btn btn-ghost px-2 py-1.5 lg:hidden"
      :aria-label="t('nav.menu')"
      @click="app.toggleSidebarMobile()"
    >
      <KtIcon name="burger-menu-2" />
    </button>
    <button
      type="button"
      class="btn btn-ghost hidden px-2 py-1.5 lg:inline-flex"
      :aria-label="app.sidebarCollapsed ? t('nav.expand') : t('nav.collapse')"
      @click="app.toggleSidebarCollapsed()"
    >
      <KtIcon name="burger-menu-2" />
    </button>

    <div class="hidden min-w-0 md:block">
      <AppBreadcrumbs />
    </div>

    <div class="ms-auto flex items-center gap-1.5 sm:gap-2">
      <HotelSelector />
      <LanguageSelector />
      <ThemeToggle />
      <div class="mx-1 hidden h-6 w-px bg-border sm:block" />
      <UserMenu />
    </div>
  </header>
</template>
