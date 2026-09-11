<script setup lang="ts">
const app = useAppStore()
</script>

<template>
  <div
    class="app-shell min-h-screen bg-background text-foreground"
    :data-sidebar="app.sidebarCollapsed ? 'collapsed' : 'expanded'"
  >
    <!-- Sidebar -->
    <AppSidebar />

    <!-- Mobile overlay -->
    <Transition
      enter-active-class="transition-opacity duration-200 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-opacity duration-150 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="app.sidebarOpenMobile"
        class="fixed inset-0 z-30 bg-mono/40 backdrop-blur-[1px] lg:hidden"
        aria-hidden="true"
        @click="app.toggleSidebarMobile(false)"
      />
    </Transition>

    <!-- Header -->
    <AppHeader />

    <!-- Main -->
    <main
      class="
        min-h-screen
        pt-[var(--header-height)]
        transition-[padding]
        duration-300
        ease-in-out
        lg:ps-[var(--sidebar-width)]
      "
    >
      <div
        class="
          mx-auto
          w-full
          max-w-[1600px]
          px-4
          py-5
          sm:px-5
          sm:py-6
          lg:px-6
          lg:py-7
          xl:px-8
        "
      >
        <slot />
      </div>
    </main>
  </div>
</template>
