// Pure permission predicates — shared by useCan() and the navigation filter,
// and unit-testable without a Nuxt runtime. `permissions` is the list of
// slugs from GET /auth/me (user.role.permissions[].slug).

export function hasPermission(permissions: readonly string[], slug: string): boolean {
  return permissions.includes(slug)
}

export function hasAny(permissions: readonly string[], required: readonly string[]): boolean {
  return required.some(r => permissions.includes(r))
}

export function hasAll(permissions: readonly string[], required: readonly string[]): boolean {
  return required.every(r => permissions.includes(r))
}
