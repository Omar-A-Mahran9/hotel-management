// Route protection for the whole dashboard.
//
//  - unauthenticated  -> /login (except public routes)
//  - authenticated on /login -> /
//  - route declares `meta.permission` the user lacks -> /403
//
// UI-side only. The backend authorises every API call independently; this
// guard just avoids showing a shell the user can't use.
const PUBLIC_ROUTES = new Set(['/login'])

export default defineNuxtRouteMiddleware((to) => {
  const auth = useAuthStore()

  // bootstrap.client plugin awaits fetchMe, so `ready` is true here.
  const isPublic = PUBLIC_ROUTES.has(to.path)

  if (!auth.isAuthenticated) {
    if (isPublic) return
    return navigateTo({ path: '/login', query: to.fullPath !== '/' ? { redirect: to.fullPath } : undefined })
  }

  if (isPublic) {
    return navigateTo('/')
  }

  const required = to.meta.permission as string | string[] | undefined
  if (required) {
    const { canAny } = useCan()
    const list = Array.isArray(required) ? required : [required]
    if (!canAny(...list)) {
      return navigateTo('/403')
    }
  }
})
