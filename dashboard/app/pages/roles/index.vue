<script setup lang="ts">
import { rbacService } from '~/services'
import type { Permission, Role, RoleWriteBody } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'roles.view' })

const { t, locale } = useI18n()
const { can } = useCan()
const app = useAppStore()
const canManage = can('roles.manage')

const roles = useResource(() => rbacService.roles())
const permissions = useResource(() => rbacService.permissions(), { immediate: can('permissions.view') })

const tab = ref<'matrix' | 'list'>('list')
const tabs = computed<Array<{ key: 'matrix' | 'list', label: string }>>(() => [
  { key: 'list', label: t('roles.list') },
  { key: 'matrix', label: t('roles.matrix') },
])

// Role/permission display strings are backend-authoritative and bilingual
// (name_en/name_ar) — this app never invents a static translation for a
// specific role or permission, it just picks the field for the active
// locale, same pattern as Country/City/Hotel.
const roleName = (r: Role) => (locale.value === 'ar' ? r.name_ar : r.name_en)
const roleDescription = (r: Role) => (locale.value === 'ar' ? r.description_ar : r.description_en)
const permName = (p: Permission) => (locale.value === 'ar' ? p.name_ar : p.name_en)
const permDescription = (p: Permission) => (locale.value === 'ar' ? p.description_ar : p.description_en)
const groupLabel = (p: Permission) => (locale.value === 'ar' ? p.group_label_ar : p.group_label_en)

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

// Grouped for the permission picker in the create/edit form — grouped by
// module (derived server-side from the slug prefix), each group carrying
// its localized label.
const groupedPermissions = computed(() => {
  const groups = new Map<string, { label: string, items: Permission[] }>()
  for (const p of allPermissions.value) {
    if (!groups.has(p.group)) groups.set(p.group, { label: groupLabel(p), items: [] })
    groups.get(p.group)!.items.push(p)
  }
  return [...groups.values()]
})

function roleHas(roleSlug: string, permSlug: string): boolean {
  const role = (roles.data.value ?? []).find(r => r.slug === roleSlug)
  return (role?.permissions ?? []).some(p => p.slug === permSlug)
}

// --- form ----------------------------------------------------------------
const open = ref(false)
const editing = ref<Role | null>(null)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})
const form = reactive({
  name_en: '',
  name_ar: '',
  description_en: '',
  description_ar: '',
  permission_ids: [] as number[],
})

function openCreate() {
  editing.value = null
  Object.assign(form, { name_en: '', name_ar: '', description_en: '', description_ar: '', permission_ids: [] })
  fieldErrors.value = {}
  open.value = true
}

function openEdit(role: Role) {
  editing.value = role
  Object.assign(form, {
    name_en: role.name_en,
    name_ar: role.name_ar,
    description_en: role.description_en ?? '',
    description_ar: role.description_ar ?? '',
    permission_ids: (role.permissions ?? []).map(p => p.id),
  })
  fieldErrors.value = {}
  open.value = true
}

function isGroupFullySelected(items: Permission[]): boolean {
  return items.length > 0 && items.every(p => form.permission_ids.includes(p.id))
}

function toggleGroup(items: Permission[], checked: boolean) {
  const ids = new Set(form.permission_ids)
  for (const p of items) {
    if (checked) ids.add(p.id)
    else ids.delete(p.id)
  }
  form.permission_ids = [...ids]
}

async function submit() {
  if (saving.value) return
  saving.value = true
  fieldErrors.value = {}
  const body: RoleWriteBody = {
    name_en: form.name_en,
    name_ar: form.name_ar,
    description_en: form.description_en || null,
    description_ar: form.description_ar || null,
    permission_ids: form.permission_ids,
  }
  try {
    if (editing.value) {
      await rbacService.updateRole(editing.value.id, body)
      app.pushToast('success', t('roles.updated'))
    } else {
      await rbacService.createRole(body)
      app.pushToast('success', t('roles.created'))
    }
    open.value = false
    roles.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}

// --- delete ---------------------------------------------------------------
const deleting = ref<Role | null>(null)
const removing = ref(false)
async function confirmDelete() {
  if (!deleting.value || removing.value) return
  removing.value = true
  try {
    await rbacService.deleteRole(deleting.value.id)
    app.pushToast('success', t('roles.deleted'))
    deleting.value = null
    roles.reload()
  } catch (e) {
    // A system role or a role still assigned to users is blocked
    // server-side (422) with an already-localized, specific message —
    // surface it as-is rather than a generic fallback.
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    removing.value = false
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('roles.title')" :subtitle="t('roles.subtitle')">
      <template v-if="canManage" #actions>
        <button type="button" class="btn btn-primary" @click="openCreate">
          <KtIcon name="plus" /> {{ t('roles.create') }}
        </button>
      </template>
    </PageHeader>

    <AppTabs v-model="tab" :tabs="tabs" class="mb-4" />

    <LoadingState v-if="roles.pending.value" :rows="6" />
    <ErrorState v-else-if="roles.error.value" :error="roles.error.value" @retry="roles.reload" />

    <template v-else-if="tab === 'matrix'">
      <p class="mb-2 text-2xs text-muted-foreground">
        {{ t('roles.matrixNote') }}
      </p>
      <div class="card overflow-x-auto">
        <table class="table-base">
          <thead>
            <tr>
              <th>{{ t('roles.permissions') }}</th>
              <th v-for="r in roles.data.value ?? []" :key="r.id" class="text-center">
                {{ roleName(r) }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in allPermissions" :key="p.id ?? p.slug">
              <td>
                <span class="font-medium text-foreground">{{ permName(p) }}</span>
                <p v-if="permDescription(p)" class="text-2xs text-muted-foreground">
                  {{ permDescription(p) }}
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
            <span>{{ roleName(role) }}</span>
            <StatusBadge
              :label="role.is_system ? t('roles.systemBadge') : t('roles.customBadge')"
              :tone="role.is_system ? 'primary' : 'info'"
            />
            <code class="rounded bg-secondary px-1.5 py-0.5 text-2xs text-muted-foreground">{{ role.slug }}</code>
          </div>
        </template>
        <template v-if="canManage" #headerActions>
          <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" @click="openEdit(role)">
            {{ t('common.edit') }}
          </button>
          <button
            v-if="!role.is_system"
            type="button"
            class="btn btn-ghost px-2 py-1 text-2sm text-destructive"
            @click="deleting = role"
          >
            {{ t('common.delete') }}
          </button>
        </template>

        <p v-if="roleDescription(role)" class="mb-2 text-sm text-muted-foreground">
          {{ roleDescription(role) }}
        </p>
        <div class="mb-3 flex flex-wrap items-center gap-3 text-2xs text-muted-foreground">
          <span>{{ t('roles.permissionsCount', { count: role.permissions_count ?? role.permissions?.length ?? 0 }) }}</span>
          <span v-if="role.users_count != null">{{ t('roles.usersCount', { count: role.users_count }) }}</span>
        </div>

        <p v-if="role.slug === 'guest'" class="text-sm text-muted-foreground">
          {{ t('roles.guestExplanation') }}
        </p>
        <div v-else class="flex flex-wrap gap-1.5">
          <span
            v-for="p in role.permissions ?? []"
            :key="p.id"
            class="rounded-md bg-primary/10 px-2 py-0.5 text-2xs font-medium text-primary"
            :title="permDescription(p) ?? ''"
          >
            {{ permName(p) }}
          </span>
          <span v-if="(role.permissions?.length ?? 0) === 0" class="text-2xs text-muted-foreground">
            {{ t('roles.noPermissionsAssigned') }}
          </span>
        </div>
      </DataCard>
    </div>

    <AppModal v-model:open="open" :title="editing ? t('roles.edit') : t('roles.create')">
      <form class="space-y-3" novalidate @submit.prevent="submit">
        <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
          <FormField :label="t('roles.nameEn')" :error="fieldErrors.name_en" required>
            <input v-model="form.name_en" class="input" required>
          </FormField>
          <FormField :label="t('roles.nameAr')" :error="fieldErrors.name_ar" required>
            <input v-model="form.name_ar" class="input" dir="rtl" required>
          </FormField>
          <FormField :label="t('roles.descriptionEn')" :error="fieldErrors.description_en">
            <textarea v-model="form.description_en" class="input" rows="2" />
          </FormField>
          <FormField :label="t('roles.descriptionAr')" :error="fieldErrors.description_ar">
            <textarea v-model="form.description_ar" class="input" rows="2" dir="rtl" />
          </FormField>
        </div>

        <FormField :label="t('roles.permissions')" :error="fieldErrors.permission_ids">
          <div class="max-h-72 space-y-3 overflow-y-auto rounded-md border border-input p-3">
            <div v-for="group in groupedPermissions" :key="group.label">
              <label class="mb-1 flex items-center gap-2 text-2sm font-semibold text-foreground">
                <input
                  type="checkbox"
                  :checked="isGroupFullySelected(group.items)"
                  @change="toggleGroup(group.items, ($event.target as HTMLInputElement).checked)"
                >
                {{ group.label }}
              </label>
              <div class="ms-6 flex flex-wrap gap-x-4 gap-y-1">
                <label v-for="p in group.items" :key="p.id" class="flex items-center gap-1.5 text-2sm">
                  <input v-model="form.permission_ids" type="checkbox" :value="p.id">
                  <span :title="permDescription(p) ?? ''">{{ permName(p) }}</span>
                </label>
              </div>
            </div>
          </div>
        </FormField>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="saving" @click="open = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submit">
          {{ saving ? t('common.saving') : t('common.save') }}
        </button>
      </template>
    </AppModal>

    <ConfirmDialog
      :open="deleting !== null"
      :title="t('common.delete')"
      :message="deleting ? t('roles.deleteConfirm', { name: roleName(deleting) }) : ''"
      tone="destructive"
      :busy="removing"
      @update:open="v => !v && (deleting = null)"
      @confirm="confirmDelete"
    />
  </div>
</template>
