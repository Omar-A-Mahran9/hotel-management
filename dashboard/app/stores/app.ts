import { defineStore } from 'pinia'

export interface Toast {
  id: number
  kind: 'success' | 'error' | 'info'
  message: string
}

interface AppState {
  sidebarOpenMobile: boolean
  sidebarCollapsed: boolean
  collapsedNavSections: string[]
  toasts: Toast[]
  theme: 'light' | 'dark'
}

let toastSeq = 0

// UI-only state: layout chrome, toasts, theme. Nothing here is
// security-relevant.
export const useAppStore = defineStore('app', {
  state: (): AppState => ({
    sidebarOpenMobile: false,
    sidebarCollapsed: false,
    collapsedNavSections: [],
    toasts: [],
    theme: 'light',
  }),

  actions: {
    initPreferences() {
      if (!import.meta.client) return
      try {
        this.sidebarCollapsed = localStorage.getItem('hm_sidebar_collapsed') === '1'
        this.collapsedNavSections = JSON.parse(localStorage.getItem('hm_nav_sections') || '[]')
        const t = localStorage.getItem('hm_theme')
        this.theme = t === 'dark' ? 'dark' : 'light'
      } catch {
        // ignore
      }
      this.applyTheme()
    },

    toggleSidebarMobile(v?: boolean) {
      this.sidebarOpenMobile = v ?? !this.sidebarOpenMobile
    },

    toggleSidebarCollapsed() {
      this.sidebarCollapsed = !this.sidebarCollapsed
      this.persist('hm_sidebar_collapsed', this.sidebarCollapsed ? '1' : '0')
    },

    toggleNavSection(key: string) {
      const i = this.collapsedNavSections.indexOf(key)
      if (i === -1) this.collapsedNavSections.push(key)
      else this.collapsedNavSections.splice(i, 1)
      this.persist('hm_nav_sections', JSON.stringify(this.collapsedNavSections))
    },

    setTheme(theme: 'light' | 'dark') {
      this.theme = theme
      this.persist('hm_theme', theme)
      this.applyTheme()
    },

    applyTheme() {
      if (!import.meta.client) return
      document.documentElement.classList.toggle('dark', this.theme === 'dark')
    },

    pushToast(kind: Toast['kind'], message: string) {
      const id = ++toastSeq
      this.toasts.push({ id, kind, message })
      setTimeout(() => this.dismissToast(id), 5000)
    },

    dismissToast(id: number) {
      this.toasts = this.toasts.filter(t => t.id !== id)
    },

    persist(key: string, value: string) {
      if (!import.meta.client) return
      try {
        localStorage.setItem(key, value)
      } catch {
        // ignore
      }
    },
  },
})
