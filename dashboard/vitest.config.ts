import { defineConfig } from 'vitest/config'

const app = new URL('./app/', import.meta.url).pathname.replace(/\/$/, '')

// Unit tests only — pure logic (stores, composables, guards, API error
// mapping). No Nuxt runtime is booted; `~` / `@` resolve to `app/`.
export default defineConfig({
  test: {
    globals: true,
    environment: 'happy-dom',
    include: ['tests/**/*.{test,spec}.ts'],
  },
  resolve: {
    alias: {
      '~': app,
      '@': app,
    },
  },
})
