<script setup lang="ts">
const { visibleSections } = useNavigation()
const { t } = useI18n()
const app = useAppStore()
const route = useRoute()

function isActive(to: string) {
  return to === '/' ? route.path === '/' : route.path === to || route.path.startsWith(`${to}/`)
}

// Icon-only mode: desktop, sidebar collapsed, and not currently open as the
// mobile drawer (the drawer always shows full labels in its 270px width).
const iconMode = computed(() => app.sidebarCollapsed && !app.sidebarOpenMobile)

function sectionCollapsed(key: string) {
  return !iconMode.value && app.collapsedNavSections.includes(key)
}

// Off-canvas transform for the mobile drawer — scoped below `lg` so it never
// competes with `lg:translate-x-0` on desktop.
const drawerClass = computed(() =>
  app.sidebarOpenMobile
    ? 'translate-x-0'
    : 'max-lg:ltr:-translate-x-full max-lg:rtl:translate-x-full',
)
</script>

<template>
  <aside
    class="fixed inset-y-0 start-0 z-40 flex w-[var(--sidebar-width)] flex-col border-e border-border bg-card transition-[transform,width] lg:translate-x-0"
    :class="drawerClass"
  >
    <div
      class="flex h-[var(--header-height)] items-center border-b border-border"
      :class="iconMode ? 'justify-center px-2' : 'px-4'"
    >
      <NuxtLink to="/" class="min-w-0" :aria-label="t('app.name')">
        <AppLogo :compact="iconMode" />
      </NuxtLink>
    </div>

    <nav class="flex-1 space-y-4 overflow-y-auto overflow-x-hidden px-3 py-4">
      <div v-for="section in visibleSections" :key="section.key">
        <button
          v-if="!iconMode && section.items.length"
          type="button"
          class="flex w-full items-center gap-1 rounded px-2.5 py-1 text-2xs font-semibold uppercase tracking-wider text-muted-foreground hover:text-foreground"
          @click="app.toggleNavSection(section.key)"
        >
          <span>{{ t(section.labelKey) }}</span>
          <KtIcon
            name="down"
            class="ms-auto text-2xs transition-transform"
            :class="{ '-rotate-90 rtl:rotate-90': sectionCollapsed(section.key) }"
          />
        </button>
        <div v-else-if="iconMode" class="mx-auto my-2 h-px w-6 bg-border" />

        <ul v-show="!sectionCollapsed(section.key)" class="mt-1 space-y-0.5">
          <li v-for="item in section.items" :key="item.key">
            <NuxtLink
              :to="item.to"
              class="group flex items-center rounded-md py-2 text-2sm font-medium transition-colors"
              :class="[
                iconMode ? 'justify-center px-0' : 'gap-2.5 px-2.5',
                isActive(item.to) ? 'bg-primary/12 text-primary' : 'text-secondary-foreground hover:bg-secondary',
              ]"
              :title="iconMode ? t(item.labelKey) : undefined"
              @click="app.toggleSidebarMobile(false)"
            >
              <KtIcon :name="item.icon" class="shrink-0" />
              <template v-if="!iconMode">
                <span class="truncate">{{ t(item.labelKey) }}</span>
                <KtIcon
                  v-if="item.backendGap"
                  name="lock-2"
                  class="ms-auto text-2xs text-muted-foreground/70"
                  :title="t('nav.comingSoon')"
                />
                <KtIcon
                  v-else-if="item.scope === 'hotel'"
                  name="geolocation"
                  class="ms-auto text-2xs text-muted-foreground"
                  :title="t('hotelSelector.label')"
                />
              </template>
            </NuxtLink>
          </li>
        </ul>
      </div>
    </nav>

    <div class="hidden border-t border-border p-2 lg:block">
      <button
        type="button"
        class="flex w-full items-center rounded-md py-2 text-2sm font-medium text-muted-foreground hover:bg-secondary hover:text-foreground"
        :class="iconMode ? 'justify-center px-0' : 'gap-2.5 px-2.5'"
        :title="iconMode ? t('nav.expand') : undefined"
        :aria-label="iconMode ? t('nav.expand') : t('nav.collapse')"
        @click="app.toggleSidebarCollapsed()"
      >
        <KtIcon :name="iconMode ? 'double-right' : 'double-left'" class="shrink-0 rtl:rotate-180" />
        <span v-if="!iconMode">{{ t('nav.collapse') }}</span>
      </button>
    </div>
  </aside>
</template>
