// Runs once on client boot, before route middleware: restore the token from
// its cookie, resolve the current user, then seed hotel context + UI prefs.
// Awaited so `auth.ready` is guaranteed true by the time the first route
// guard runs.
export default defineNuxtPlugin(async () => {
  const auth = useAuthStore()
  const app = useAppStore()

  app.initPreferences()
  auth.hydrateToken()

  if (auth.token) {
    await auth.fetchMe()
  } else {
    auth.ready = true
  }

  if (auth.isAuthenticated) {
    useHotelContextStore().init()
  }
})
