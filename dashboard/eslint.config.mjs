// @ts-check
import withNuxt from './.nuxt/eslint.config.mjs'

export default withNuxt({
  ignores: ['metronic-v9.4.12/**', 'dist/**', '.output/**', '.nuxt/**'],
  rules: {
    'vue/multi-word-component-names': 'off',
    'vue/no-multiple-template-root': 'off',
    // Optional props declared with `?` are intentionally undefined-by-default.
    'vue/require-default-prop': 'off',
  },
})
