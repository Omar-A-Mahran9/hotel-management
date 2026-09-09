import type { ApiClient } from '~/plugins/api'

// Thin accessor for the API client provided by plugins/api.ts.
export function useApi(): ApiClient {
  return useNuxtApp().$api as ApiClient
}
