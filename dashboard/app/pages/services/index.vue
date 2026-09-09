<script setup lang="ts">
import { serviceCategoriesService, servicesService } from '~/services'
import type { HotelService, ServiceCategory } from '~/types/api'
import { money } from '~/utils/format'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'services.view' })

const { t } = useI18n()
const { can } = useCan()
const app = useAppStore()
const hotelCtx = useHotelContextStore()
const route = useRoute()
const canManage = can('services.manage')

onMounted(() => {
  const q = Number(route.query.hotel)
  if (Number.isFinite(q) && q > 0) hotelCtx.setScope(q)
})

const hotelId = computed(() => hotelCtx.currentHotelId)

const categories = useResource(async () => {
  if (hotelId.value == null) return []
  return serviceCategoriesService.list(hotelId.value)
}, { immediate: false })

const services = useResource(async () => {
  if (hotelId.value == null) return []
  return servicesService.list(hotelId.value)
}, { immediate: false })

watch(hotelId, () => {
  if (hotelId.value != null) {
    categories.reload()
    services.reload()
  }
}, { immediate: true })

type CatalogueTab = 'services' | 'categories'
const tab = ref<CatalogueTab>('services')
const tabs = computed<Array<{ key: CatalogueTab, label: string, count: number | null }>>(() => [
  { key: 'services', label: t('services.services'), count: services.data.value?.length ?? null },
  { key: 'categories', label: t('services.categories'), count: categories.data.value?.length ?? null },
])

const categoryName = (id: number | null) =>
  id == null ? t('services.uncategorised') : (categories.data.value ?? []).find(c => c.id === id)?.name ?? `#${id}`

// --- category form -------------------------------------------------------
const catOpen = ref(false)
const catEditing = ref<ServiceCategory | null>(null)
const catForm = reactive({ name: '', description: '' })
const catErrors = ref<Record<string, string[]>>({})
const catSaving = ref(false)

function openCat(c?: ServiceCategory) {
  catEditing.value = c ?? null
  Object.assign(catForm, { name: c?.name ?? '', description: c?.description ?? '' })
  catErrors.value = {}
  catOpen.value = true
}
async function submitCat() {
  if (catSaving.value || hotelId.value == null) return
  catSaving.value = true
  catErrors.value = {}
  const body = { name: catForm.name, description: catForm.description || null }
  try {
    if (catEditing.value) await serviceCategoriesService.update(hotelId.value, catEditing.value.id, body)
    else await serviceCategoriesService.create(hotelId.value, body)
    app.pushToast('success', t('services.created'))
    catOpen.value = false
    categories.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) catErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    catSaving.value = false
  }
}

// --- service form -------------------------------------------------------
const svcOpen = ref(false)
const svcEditing = ref<HotelService | null>(null)
const svcForm = reactive({ name: '', description: '', price: '', currency: '', service_category_id: null as number | null })
const svcErrors = ref<Record<string, string[]>>({})
const svcSaving = ref(false)

function openSvc(s?: HotelService) {
  svcEditing.value = s ?? null
  Object.assign(svcForm, {
    name: s?.name ?? '',
    description: s?.description ?? '',
    price: s?.price ?? '',
    currency: s?.currency ?? '',
    service_category_id: s?.service_category_id ?? null,
  })
  svcErrors.value = {}
  svcOpen.value = true
}
async function submitSvc() {
  if (svcSaving.value || hotelId.value == null) return
  svcSaving.value = true
  svcErrors.value = {}
  const body: Record<string, unknown> = {
    name: svcForm.name,
    description: svcForm.description || null,
    price: svcForm.price,
    service_category_id: svcForm.service_category_id,
  }
  if (svcForm.currency) body.currency = svcForm.currency.toUpperCase()
  try {
    if (svcEditing.value) await servicesService.update(hotelId.value, svcEditing.value.id, body)
    else await servicesService.create(hotelId.value, body)
    app.pushToast('success', t('services.created'))
    svcOpen.value = false
    services.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) svcErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    svcSaving.value = false
  }
}

const toggling = ref<string | null>(null)
async function toggleSvc(s: HotelService) {
  if (toggling.value) return
  toggling.value = `s${s.id}`
  try {
    if (s.is_active) await servicesService.deactivate(hotelId.value!, s.id)
    else await servicesService.activate(hotelId.value!, s.id)
    services.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    toggling.value = null
  }
}
async function toggleCat(c: ServiceCategory) {
  if (toggling.value) return
  toggling.value = `c${c.id}`
  try {
    if (c.is_active) await serviceCategoriesService.deactivate(hotelId.value!, c.id)
    else await serviceCategoriesService.activate(hotelId.value!, c.id)
    categories.reload()
  } catch (e) {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    toggling.value = null
  }
}
</script>

<template>
  <div>
    <PageHeader
      :title="t('services.title')"
      :subtitle="hotelCtx.currentHotel ? t('services.subtitle', { hotel: hotelCtx.currentHotel.name }) : ''"
    />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <div class="mb-4 flex items-center justify-between gap-3">
        <AppTabs v-model="tab" :tabs="tabs" class="grow" />
        <button
          v-if="canManage"
          type="button"
          class="btn btn-primary shrink-0"
          @click="tab === 'services' ? openSvc() : openCat()"
        >
          <KtIcon name="plus" /> {{ tab === 'services' ? t('services.newService') : t('services.newCategory') }}
        </button>
      </div>

      <p v-if="!canManage" class="mb-3 text-2xs text-muted-foreground">
        {{ t('services.manageNote') }}
      </p>

      <!-- Services -->
      <template v-if="tab === 'services'">
        <LoadingState v-if="services.pending.value" :rows="4" />
        <ErrorState v-else-if="services.error.value" :error="services.error.value" @retry="services.reload" />
        <EmptyState v-else-if="(services.data.value?.length ?? 0) === 0" />
        <div v-else class="card overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('services.name') }}</th>
                <th>{{ t('services.category') }}</th>
                <th class="text-end">
                  {{ t('services.price') }}
                </th>
                <th>{{ t('services.status') }}</th>
                <th v-if="canManage">
                  {{ t('common.actions') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="s in services.data.value ?? []" :key="s.id">
                <td>
                  <span class="font-medium text-foreground">{{ s.name }}</span>
                  <p v-if="s.description" class="text-2xs text-muted-foreground">
                    {{ s.description }}
                  </p>
                </td>
                <td class="text-muted-foreground">
                  {{ categoryName(s.service_category_id) }}
                </td>
                <td class="text-end">
                  {{ money(s.price, s.currency) }}
                </td>
                <td>
                  <StatusBadge
                    :label="s.is_active ? t('common.active') : t('common.inactive')"
                    :tone="s.is_active ? 'success' : 'neutral'"
                  />
                </td>
                <td v-if="canManage">
                  <div class="flex gap-1">
                    <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" @click="openSvc(s)">
                      {{ t('common.edit') }}
                    </button>
                    <button
                      type="button"
                      class="btn btn-ghost px-2 py-1 text-2sm"
                      :disabled="toggling === `s${s.id}`"
                      @click="toggleSvc(s)"
                    >
                      {{ s.is_active ? t('common.deactivate') : t('common.activate') }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <!-- Categories -->
      <template v-else>
        <LoadingState v-if="categories.pending.value" :rows="4" />
        <ErrorState v-else-if="categories.error.value" :error="categories.error.value" @retry="categories.reload" />
        <EmptyState v-else-if="(categories.data.value?.length ?? 0) === 0" />
        <div v-else class="card overflow-x-auto">
          <table class="table-base">
            <thead>
              <tr>
                <th>{{ t('services.name') }}</th>
                <th>{{ t('services.description') }}</th>
                <th>{{ t('services.status') }}</th>
                <th v-if="canManage">
                  {{ t('common.actions') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in categories.data.value ?? []" :key="c.id">
                <td class="font-medium text-foreground">
                  {{ c.name }}
                </td>
                <td class="text-muted-foreground">
                  {{ c.description || '—' }}
                </td>
                <td>
                  <StatusBadge
                    :label="c.is_active ? t('common.active') : t('common.inactive')"
                    :tone="c.is_active ? 'success' : 'neutral'"
                  />
                </td>
                <td v-if="canManage">
                  <div class="flex gap-1">
                    <button type="button" class="btn btn-ghost px-2 py-1 text-2sm" @click="openCat(c)">
                      {{ t('common.edit') }}
                    </button>
                    <button
                      type="button"
                      class="btn btn-ghost px-2 py-1 text-2sm"
                      :disabled="toggling === `c${c.id}`"
                      @click="toggleCat(c)"
                    >
                      {{ c.is_active ? t('common.deactivate') : t('common.activate') }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </template>

    <!-- category modal -->
    <AppModal v-model:open="catOpen" :title="catEditing ? t('services.editCategory') : t('services.newCategory')">
      <form class="space-y-3" novalidate @submit.prevent="submitCat">
        <FormField :label="t('services.name')" :error="catErrors.name" required>
          <input v-model="catForm.name" class="input" required>
        </FormField>
        <FormField :label="t('services.description')" :error="catErrors.description">
          <textarea v-model="catForm.description" rows="2" class="input" maxlength="500" />
        </FormField>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="catSaving" @click="catOpen = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="catSaving" @click="submitCat">
          {{ catSaving ? t('common.saving') : t('common.save') }}
        </button>
      </template>
    </AppModal>

    <!-- service modal -->
    <AppModal v-model:open="svcOpen" :title="svcEditing ? t('services.editService') : t('services.newService')">
      <form class="space-y-3" novalidate @submit.prevent="submitSvc">
        <FormField :label="t('services.name')" :error="svcErrors.name" required>
          <input v-model="svcForm.name" class="input" required>
        </FormField>
        <FormField :label="t('services.description')" :error="svcErrors.description">
          <textarea v-model="svcForm.description" rows="2" class="input" maxlength="1000" />
        </FormField>
        <div class="grid gap-3 sm:grid-cols-2">
          <FormField :label="t('services.price')" :error="svcErrors.price" required>
            <input v-model="svcForm.price" type="text" inputmode="decimal" class="input" required>
          </FormField>
          <FormField :label="`${t('services.currency')} (${t('common.optional')})`" :error="svcErrors.currency">
            <input v-model="svcForm.currency" class="input" maxlength="3" placeholder="EGP">
          </FormField>
        </div>
        <FormField :label="t('services.category')" :error="svcErrors.service_category_id">
          <select v-model.number="svcForm.service_category_id" class="input">
            <option :value="null">
              {{ t('services.uncategorised') }}
            </option>
            <option v-for="c in categories.data.value ?? []" :key="c.id" :value="c.id">
              {{ c.name }}
            </option>
          </select>
        </FormField>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" :disabled="svcSaving" @click="svcOpen = false">
          {{ t('common.cancel') }}
        </button>
        <button type="button" class="btn btn-primary" :disabled="svcSaving" @click="submitSvc">
          {{ svcSaving ? t('common.saving') : t('common.save') }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
