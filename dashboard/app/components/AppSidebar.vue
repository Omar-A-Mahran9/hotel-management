<script setup lang="ts">
const { visibleSections, backendGapItems } = useNavigation()
const { t } = useI18n()
const app = useAppStore()
const route = useRoute()

function isActive(to: string) {
  return to === '/' ? route.path === '/' : route.path === to || route.path.startsWith(`${to}/`)
}
</script>

<template>
  <aside
    class="fixed inset-y-0 start-0 z-40 flex w-[var(--sidebar-width)] flex-col border-e border-border bg-card transition-transform lg:translate-x-0"
    :class="app.sidebarOpenMobile ? 'translate-x-0' : 'rtl:translate-x-full ltr:-translate-x-full'"
  >
    <div class="flex h-[var(--header-height)] items-center border-b border-border px-4">
      <NuxtLink to="/" class="min-w-0">
        <AppLogo />
      </NuxtLink>
    </div>

    <nav class="flex-1 space-y-5 overflow-y-auto px-3 py-4">
      <div v-for="section in visibleSections" :key="section.key">
        <div class="mb-1.5 px-2.5 text-2xs font-semibold uppercase tracking-wider text-muted-foreground">
          {{ t(section.labelKey) }}
        </div>
        <ul class="space-y-0.5">
          <li v-for="item in section.items" :key="item.key">
            <NuxtLink
              :to="item.to"
              class="flex items-center gap-2.5 rounded-md px-2.5 py-2 text-2sm font-medium transition-colors"
              :class="isActive(item.to)
                ? 'bg-primary/12 text-primary'
                : 'text-secondary-foreground hover:bg-secondary'"
              @click="app.toggleSidebarMobile(false)"
            >
              <KtIcon :name="item.icon" />
              <span class="truncate">{{ t(item.labelKey) }}</span>
              <KtIcon v-if="item.scope === 'hotel'" name="geolocation" class="ms-auto text-2xs text-muted-foreground" />
            </NuxtLink>
          </li>
        </ul>
      </div>

      <div v-if="backendGapItems.length" class="border-t border-border pt-4">
        <div class="mb-1.5 px-2.5 text-2xs font-semibold uppercase tracking-wider text-muted-foreground">
          {{ t('nav.comingSoon') }}
        </div>
        <ul class="space-y-0.5">
          <li v-for="item in backendGapItems" :key="item.key">
            <span
              class="flex cursor-not-allowed items-center gap-2.5 rounded-md px-2.5 py-2 text-2sm font-medium text-muted-foreground/70"
              :title="t('nav.comingSoon')"
            >
              <KtIcon :name="item.icon" />
              <span class="truncate">{{ t(item.labelKey) }}</span>
              <KtIcon name="lock-2" class="ms-auto text-2xs" />
            </span>
          </li>
        </ul>
      </div>
    </nav>
  </aside>
</template>
