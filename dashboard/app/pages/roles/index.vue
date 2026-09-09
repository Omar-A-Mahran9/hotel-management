<script setup lang="ts">
import { rbacService } from '~/services'
import type { Permission } from '~/types/api'

definePageMeta({ permission: 'roles.view' })

const { t } = useI18n()
const { can } = useCan()

const roles = useResource(() => rbacService.roles())
const permissions = useResource(() => rbacService.permissions(), { immediate: can('permissions.view') })

const tab = ref<'matrix' | 'cards'>('matrix')
const tabs = computed<Array<{ key: 'matrix' | 'cards', label: string }>>(() => [
  { key: 'matrix', label: t('roles.matrix') },
  { key: 'cards', label: t('roles.role') },
])

// All permission slugs — prefer the dedicated endpoint, fall back to the
// union of what the roles carry.
const allPermissions = computed<Permission[]>(() => {
  if (permissions.data.value?.length) return permissions.data.value
  const seen = new Map<string, Permission>()
  for (const r of roles.data.value ?? []) {
    for (const p of r.permissions ?? []) if (!seen.has(p.slug)) seen.set(p.slug, p)
  }
  return [...seen.values()]
})

function roleHas(roleSlug: string, permSlug: string): boolean {
  const role = (roles.data.value ?? []).find(r => r.slug === roleSlug)
  return (role?.permissions ?? []).some(p => p.slug === permSlug)
}
</script>

<template>
  <div>
    <PageHeader :title="t('roles.title')" :subtitle="t('roles.subtitle')" />

    <AppTabs v-model="tab" :tabs="tabs" class="mb-4" />

    <LoadingState v-if="roles.pending.value" :rows="6" />
    <ErrorState v-else-if="roles.error.value" :error="roles.error.value" @retry="roles.reload" />

    <template v-else-if="tab === 'matrix'">
      <div class="card overflow-x-auto">
        <table class="table-base">
          <thead>
            <tr>
              <th>{{ t('roles.permissions') }}</th>
              <th v-for="r in roles.data.value ?? []" :key="r.id" class="text-center">
                {{ r.name }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in allPermissions" :key="p.id ?? p.slug">
              <td>
                <span class="font-medium text-foreground">{{ p.slug }}</span>
                <p v-if="p.description" class="text-2xs text-muted-foreground">
                  {{ p.description }}
                </p>
              </td>
              <td v-for="r in roles.data.value ?? []" :key="r.id" class="text-center">
                <KtIcon
                  v-if="roleHas(r.slug, p.slug)"
                  name="check"
                  class="text-success"
                  :title="t('roles.held')"
                />
                <span v-else class="text-muted-foreground/40" :title="t('roles.notHeld')">–</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>

    <div v-else class="space-y-4">
      <DataCard v-for="role in roles.data.value ?? []" :key="role.id">
        <template #header>
          <div class="flex items-center gap-2">
            <KtIcon name="shield-tick" class="text-primary" />
            <span>{{ role.name }}</span>
            <code class="rounded bg-secondary px-1.5 py-0.5 text-2xs text-muted-foreground">{{ role.slug }}</code>
          </div>
        </template>
        <p v-if="role.description" class="mb-3 text-sm text-muted-foreground">
          {{ role.description }}
        </p>
        <div class="flex flex-wrap gap-1.5">
          <span
            v-for="p in role.permissions ?? []"
            :key="p.id"
            class="rounded-md bg-primary/10 px-2 py-0.5 text-2xs font-medium text-primary"
            :title="p.description ?? ''"
          >
            {{ p.slug }}
          </span>
          <span v-if="(role.permissions?.length ?? 0) === 0" class="text-2xs text-muted-foreground">
            {{ t('common.none') }}
          </span>
        </div>
      </DataCard>
    </div>
  </div>
</template>
