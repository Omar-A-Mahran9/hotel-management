import { defineStore } from 'pinia'
import type { AuthUser, LoginResponse } from '~/types/api'

interface AuthState {
  user: AuthUser | null
  token: string | null
  ready: boolean // true once an initial /auth/me resolution has been attempted
}

// Session state. The bearer token is the only sensitive value held; it lives
// in a cookie (readable by this SPA, sent as an Authorization header — never
// in a URL) and in memory. Role/permission/hotel values from the backend are
// cached for UI decisions only; the backend re-authorises every request.
export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    token: null,
    ready: false,
  }),

  getters: {
    isAuthenticated: (s): boolean => !!s.token && !!s.user,
    permissions: (s): string[] => s.user?.role?.permissions?.map(p => p.slug) ?? [],
    roleSlug: (s): string | null => s.user?.role?.slug ?? null,
    isGroupOwner: (s): boolean => s.user?.role?.slug === 'group_owner',
    assignedHotels: s => s.user?.hotels ?? [],
  },

  actions: {
    hydrateToken() {
      const cookie = useCookie<string | null>('hm_token', {
        sameSite: 'lax',
        secure: !import.meta.dev,
        maxAge: 60 * 60 * 24 * 14,
      })
      this.token = cookie.value ?? null
    },

    persistToken(token: string | null) {
      const cookie = useCookie<string | null>('hm_token', {
        sameSite: 'lax',
        secure: !import.meta.dev,
        maxAge: 60 * 60 * 24 * 14,
      })
      cookie.value = token
      this.token = token
    },

    async login(email: string, password: string) {
      const { $api } = useNuxtApp()
      const data = await $api<LoginResponse>('/auth/login', {
        method: 'POST',
        body: { email, password },
        // login must not carry a stale Authorization header
        skipAuth: true,
      })
      this.persistToken(data.token)
      this.user = data.user
      this.ready = true
      return data.user
    },

    async fetchMe() {
      const { $api } = useNuxtApp()
      if (!this.token) {
        this.ready = true
        return null
      }
      try {
        this.user = await $api<AuthUser>('/auth/me')
      } catch {
        // token invalid/expired — clear locally
        this.clearSession()
      } finally {
        this.ready = true
      }
      return this.user
    },

    async logout() {
      const { $api } = useNuxtApp()
      if (this.token) {
        try {
          await $api('/auth/logout', { method: 'POST' })
        } catch {
          // even if the call fails, drop the local session
        }
      }
      this.clearSession()
    },

    clearSession() {
      this.persistToken(null)
      this.user = null
      useHotelContextStore().reset()
    },
  },
})
