<script setup lang="ts">
const route = useRoute()
const { t, te } = useI18n()

// Derive crumbs from the path. Known first-segment keys map to nav labels;
// deeper segments render as-is (ids) — good enough for the current surfaces.
const crumbs = computed(() => {
  const parts = route.path.split('/').filter(Boolean)
  const acc: { label: string, to: string }[] = []
  let path = ''
  for (const part of parts) {
    path += `/${part}`
    const key = `nav.${part}`
    acc.push({ label: te(key) ? t(key) : decodeURIComponent(part), to: path })
  }
  return acc
})
</script>

<template>
  <nav v-if="crumbs.length" class="flex items-center gap-1.5 text-2sm text-muted-foreground">
    <NuxtLink to="/" class="hover:text-foreground">
      {{ t('nav.overview') }}
    </NuxtLink>
    <template v-for="(c, i) in crumbs" :key="c.to">
      <KtIcon name="right" class="text-2xs" />
      <NuxtLink
        :to="c.to"
        class="hover:text-foreground"
        :class="{ 'font-medium text-foreground': i === crumbs.length - 1 }"
      >
        {{ c.label }}
      </NuxtLink>
    </template>
  </nav>
</template>
