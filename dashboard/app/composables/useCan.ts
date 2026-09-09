import { hasAll, hasAny, hasPermission } from '~/utils/permissions'

// Permission helpers. Source of truth = the permission slugs returned by
// GET /auth/me (user.role.permissions[].slug). These decide UI visibility
// ONLY — the backend re-authorises every request and a 403 is final.
//
// Roles are used only for high-level context (e.g. "is this a Group Owner"),
// never as the access check itself.
export function useCan() {
  const auth = useAuthStore()

  return {
    can: (permission: string) => hasPermission(auth.permissions, permission),
    canAny: (...permissions: string[]) => hasAny(auth.permissions, permissions),
    canAll: (...permissions: string[]) => hasAll(auth.permissions, permissions),
    isGroupOwner: computed(() => auth.isGroupOwner),
    roleSlug: computed(() => auth.roleSlug),
  }
}
