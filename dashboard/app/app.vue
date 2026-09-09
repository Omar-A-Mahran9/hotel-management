<script setup lang="ts">
const { locale, locales } = useI18n()

const dir = computed<'rtl' | 'ltr'>(() => {
  const current = (locales.value as Array<{ code: string, dir?: string }>).find(
    l => l.code === locale.value,
  )
  return current?.dir === 'rtl' ? 'rtl' : 'ltr'
})

useHead({
  htmlAttrs: {
    dir,
    lang: locale,
  },
  link: [
    { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
    { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
    {
      rel: 'stylesheet',
      href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Tajawal:wght@400;500;700&display=swap',
    },
  ],
})
</script>

<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
    <AppToaster />
  </div>
</template>
