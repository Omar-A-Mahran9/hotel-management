import tailwindcss from '@tailwindcss/vite'

// Unified Hotel Management Dashboard.
// SPA only (ssr: false): the backend uses Sanctum bearer tokens, not SPA
// cookies, and there is no SEO surface — an SSR server holding tokens would
// add risk for zero benefit. The public marketing site is a separate app.
export default defineNuxtConfig({
  compatibilityDate: '2025-01-01',
  future: { compatibilityVersion: 4 },
  ssr: false,

  devtools: { enabled: true },

  modules: ['@pinia/nuxt', '@nuxtjs/i18n', '@nuxt/eslint'],

  css: ['~/assets/css/main.css'],

  vite: {
    plugins: [tailwindcss()],
  },

  app: {
    head: {
      title: 'Hotel Management',
      htmlAttrs: { dir: 'ltr', lang: 'en' },
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      ],
    },
  },

  runtimeConfig: {
    public: {
      // Laravel API base. Override with NUXT_PUBLIC_API_BASE at deploy time.
      apiBase: 'http://localhost:8000/api/v1',
    },
  },

  i18n: {
    strategy: 'no_prefix',
    defaultLocale: 'en',
    locales: [
      { code: 'en', name: 'English', file: 'en.json', dir: 'ltr', language: 'en' },
      { code: 'ar', name: 'العربية', file: 'ar.json', dir: 'rtl', language: 'ar' },
    ],
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'hm_locale',
      redirectOn: 'root',
      alwaysRedirect: false,
    },
  },

  eslint: {
    config: { stylistic: false },
  },

  typescript: {
    strict: true,
  },
})
