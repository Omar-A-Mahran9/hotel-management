<script setup lang="ts">
import { hotelsService, rbacService, usersService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { StaffUser } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'users.view' })

const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()
const canManage = can('users.manage')

const page = ref(1)
const list = useResource(() => usersService.list(page.value))
const roles = useResource(() => rbacService.roles(), { immediate: canManage })
const hotels = useResource(() => hotelsService.list(1), { immediate: canManage })

const search = ref('')
const rows = computed<StaffUser[]>(() => {
  const all = list.data.value?.data ?? []
  const q = search.value.trim().toLowerCase()
  return q ? all.filter(u => [u.name, u.email].some(v => v.toLowerCase().includes(q))) : all
})

const columns = computed<Column[]>(() => [
  { key: 'name', label: t('users.name') },
  { key: 'email', label: t('users.email') },
  { key: 'role', label: t('users.role') },
  { key: 'hotels', label: t('users.hotels') },
  { key: 'is_active', label: t('users.status') },
  ...(canManage ? [{ key: 'actions', label: t('common.actions'), align: 'end' as const }] : []),
])

function changePage(n: number) {
  page.value = n
  list.reload()
}

// --- form --------------------------------------------------------------
const open = ref(false)
const editing = ref<StaffUser | null>(null)
const saving = ref(false)
const fieldErrors = ref<Record<string, string[]>>({})
const form = reactive({
  name: '',
  email: '',
  password: '',
  role_id: null as number | null,
  is_active: true,
  hotel_ids: [] as number[],
})

function openCreate() {
  editing.value = null
  Object.assign(form, { name: '', email: '', password: '', role_id: roles.data.value?.[0]?.id ?? null, is_active: true, hotel_ids: [] })
  fieldErrors.value = {}
  open.value = true
}
function openEdit(u: StaffUser) {
  editing.value = u
  Object.assign(form, {
    name: u.name,
    email: u.email,
    password: '',
    role_id: u.role?.id ?? null,
    is_active: u.is_active,
    hotel_ids: (u.hotels ?? []).map(h => h.id),
  })
  fieldErrors.value = {}
  open.value = true
}

async function submit() {
  if (saving.value || form.role_id == null) return
  saving.value = true
  fieldErrors.value = {}
  const body: Record<string, unknown> = {
    name: form.name,
    email: form.email,
    role_id: form.role_id,
    is_active: form.is_active,
    hotel_ids: form.hotel_ids,
  }
  if (form.password) body.password = form.password
  try {
    if (editing.value) {
      await usersService.update(editing.value.id, body)
      app.pushToast('success', t('users.updated'))
    } else {
      await usersService.create({ ...body, password: form.password })
      app.pushToast('success', t('users.created'))
    }
    open.value = false
    list.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) fieldErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    saving.value = false
  }
}

// --- delete -----------------------------------------------------------
const deleting = ref<StaffUser | null>(null)
const removing = ref(false)
async function confirmDelete() {
  if (!deleting.value || removing.value) return
  removing.value = true
  try {
    await usersService.remove(deleting.value.id)
    app.pushToast('success', t('users.deleted'))
    deleting.value = null
    list.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    removing.value = false
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('users.title')" :subtitle="t('users.subtitle')">
      <template v-if="canManage" #actions>
        <button type="button" class="btn btn-primary" @click="openCreate">
          <KtIcon name="plus" /> {{ t('users.new') }}
        </button>
      </template>
    </PageHeader>

    <div class="mb-3 max-w-xs">
      <SearchField v-model="search" :hint="t('common.clientFilterNote')" />
    </div>

    <DataTable
      :columns="columns"
      :rows="rows"
      :loading="list.pending.value"
      :error="list.error.value"
      :meta="list.data.value?.meta ?? null"
      @retry="list.reload"
      @page="changePage"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-foreground">{{ (row as StaffUser).name }}</span>
      </template>
      <template #cell-role="{ row }">
        {{ (row as StaffUser).role?.name ?? t('common.notAvailable') }}
      </template>
      <template #cell-hotels="{ row }">
        <span v-if="(row as StaffUser).role?.slug === 'group_owner'" class="text-muted-foreground">
          {{ t('hotelSelector.allHotels') }}
        </span>
        <span v-else>
          {{ (row as StaffUser).hotels?.map(h => h.name).join(', ') || t('common.none') }}
        </span>
      </template>
      <template #cell-is_active="{ row }">
        <StatusBadge
          :label="(row as StaffUser).is_active ? t('common.active') : t('common.inactive')"
          :tone="(row as StaffUser).is_active ? 'success' : 'neutral'"
        />
      </template>
      <template #cell-actions="{ row }">
        <div class="flex items-center justify-end gap-1">
          <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" @click="openEdit(row as StaffUser)">
            {{ t('common.edit') }}
          </button>
          <button type="button" class="btn btn-ghost px-2 py-1 text-2sm text-destructive" @click="deleting = row as StaffUser">
            {{ t('common.delete') }}
          </button>
        </div>
      </template>
    </DataTable>

    <AppModal v-model:open="open" :title="editing ? t('users.editTitle') : t('users.new')">
      <form class="space-y-3" novalidate @submit.prevent="submit">
        <FormField :label="t('users.name')" :error="fieldErrors.name" required>
          <input v-model="form.name" class="input" required>
        </FormField>
        <FormField :label="t('users.email')" :error="fieldErrors.email" required>
          <input v-model="form.email" type="email" class="input" required>
        </FormField>
        <FormField
          :label="t('users.password')"
          :error="fieldErrors.password"
          :hint="editing ? t('users.passwordEditHint') : undefined"
          :required="!editing"
        >
          <input v-model="form.password" type="password" autocomplete="new-password" class="input" :required="!editing">
        </FormField>
        <FormField :label="t('users.role')" :error="fieldErrors.role_id" required>
          <select v-model.number="form.role_id" class="input" required>
            <option v-for="r in roles.data.value ?? []" :key="r.id" :value="r.id">
              {{ r.name }}
            </option>
          </select>
        </FormField>
        <FormField :label="t('users.hotels')" :error="fieldErrors.hotel_ids" :hint="t('users.hotelsHint')">
          <div class="max-h-40 space-y-1 overflow-y-auto rounded-md border border-input p-2">
            <label v-for="h in hotels.data.value?.data ?? []" :key="h.id" class="flex items-center gap-2 text-2sm">
              <input v-model="form.hotel_ids" type="checkbox" :value="h.id"> {{ h.name }}
            </label>
          </div>
        </FormField>
        <label class="flex items-center gap-2 text-2sm">
          <input v-model="form.is_active" type="checkbox"> {{ t('common.active') }}
        </label>
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
      :message="deleting ? t('users.deleteConfirm', { name: deleting.name }) : ''"
      tone="destructive"
      :busy="removing"
      @update:open="v => !v && (deleting = null)"
      @confirm="confirmDelete"
    />
  </div>
</template>
