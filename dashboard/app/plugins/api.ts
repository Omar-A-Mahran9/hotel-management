import type { FetchOptions } from 'ofetch'
import type { ApiEnvelope, ApiMeta, ValidationErrors } from '~/types/api'
import { ApiError, kindForStatus } from '~/utils/apiError'

type ApiRequestOptions = FetchOptions & {
  // Skip attaching the bearer token (used by /auth/login).
  skipAuth?: boolean
  // Suppress the automatic redirect-to-login on 401 (used by /auth/me on boot).
  silent401?: boolean
}

export interface ApiClient {
  <T>(url: string, options?: ApiRequestOptions): Promise<T>
  withMeta: <T>(url: string, options?: ApiRequestOptions) => Promise<{ data: T, meta: ApiMeta }>
}

// The single API client for the whole dashboard. Every request goes through
// here: base URL, bearer token, locale header, envelope unwrapping and a
// uniform ApiError. Components/stores must never call $fetch directly.
export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig()

  const raw = $fetch.create({
    baseURL: config.public.apiBase,
    retry: 0,

    onRequest({ options }) {
      const opts = options as ApiRequestOptions
      const headers = new Headers(options.headers)
      headers.set('Accept', 'application/json')

      const i18n = nuxtApp.$i18n as { locale?: { value?: string } } | undefined
      const locale = i18n?.locale?.value
      if (locale) headers.set('X-Locale', locale)

      if (!opts.skipAuth) {
        const token = useAuthStore().token
        if (token) headers.set('Authorization', `Bearer ${token}`)
      }
      options.headers = headers
    },
  })

  function toApiError(err: unknown): ApiError {
    const e = err as {
      response?: { status?: number, headers?: Headers, _data?: unknown }
      status?: number
      message?: string
    }
    const status = e.response?.status ?? e.status ?? 0
    const body = e.response?._data as
      | { message?: string, errors?: ValidationErrors }
      | undefined

    const retryAfterHeader = e.response?.headers?.get?.('Retry-After')
    const retryAfter = retryAfterHeader ? Number(retryAfterHeader) : null

    return new ApiError({
      kind: kindForStatus(status),
      status,
      message: body?.message || e.message || 'Request failed',
      errors: body?.errors ?? null,
      retryAfter: Number.isFinite(retryAfter) ? retryAfter : null,
    })
  }

  async function handle401(silent: boolean) {
    const auth = useAuthStore()
    auth.clearSession()
    if (silent) return
    const route = useRoute()
    if (route.path !== '/login') {
      await navigateTo({ path: '/login', query: { redirect: route.fullPath } })
    }
  }

  const client = (async <T>(url: string, options: ApiRequestOptions = {}): Promise<T> => {
    try {
      const res = await raw<ApiEnvelope<T>>(url, options as Parameters<typeof raw>[1])
      return res.data
    } catch (err) {
      const apiError = toApiError(err)
      if (apiError.kind === 'unauthenticated') {
        await handle401(options.silent401 === true)
      }
      throw apiError
    }
  }) as ApiClient

  client.withMeta = async <T>(url: string, options: ApiRequestOptions = {}) => {
    try {
      const res = await raw<ApiEnvelope<T>>(url, options as Parameters<typeof raw>[1])
      return { data: res.data, meta: res.meta ?? {} }
    } catch (err) {
      const apiError = toApiError(err)
      if (apiError.kind === 'unauthenticated') {
        await handle401(options.silent401 === true)
      }
      throw apiError
    }
  }

  return {
    provide: { api: client },
  }
})
