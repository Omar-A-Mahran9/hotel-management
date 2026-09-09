<script setup lang="ts">
const app = useAppStore()
</script>

<template>
  <div
    class="app-shell min-h-screen bg-background"
    :data-sidebar="app.sidebarCollapsed ? 'collapsed' : 'expanded'"
  >
    <AppSidebar />

    <!-- mobile scrim -->
    <div
      v-if="app.sidebarOpenMobile"
      class="fixed inset-0 z-30 bg-mono/40 lg:hidden"
      @click="app.toggleSidebarMobile(false)"
    />

    <AppHeader />

    <main class="pt-[var(--header-height)] transition-[padding] lg:ps-[var(--sidebar-width)]">
      <div class="mx-auto max-w-7xl p-4 lg:p-6">
        <slot />
      </div>
    </main>
  </div>
</template>
