<script setup lang="ts">
const app = useAppStore()
</script>

<template>
  <header
    class="fixed top-0 end-0 start-0 z-30 flex h-[var(--header-height)] items-center gap-3 border-b border-border bg-card/95 px-4 backdrop-blur lg:start-[var(--sidebar-width)] lg:px-6"
  >
    <button
      type="button"
      class="btn btn-ghost px-2 py-1.5 lg:hidden"
      aria-label="Menu"
      @click="app.toggleSidebarMobile()"
    >
      <KtIcon name="burger-menu-2" />
    </button>

    <div class="hidden md:block">
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
