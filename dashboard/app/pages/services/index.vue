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

  if (Number.isFinite(q) && q > 0) {
    hotelCtx.setScope(q)
  }
})

const hotelId = computed(() => hotelCtx.currentHotelId)

/* -------------------------------------------------------------------------- */
/* Data                                                                       */
/* -------------------------------------------------------------------------- */

const categories = useResource(
  async () => {
    if (hotelId.value == null) return []

    return serviceCategoriesService.list(hotelId.value)
  },
  { immediate: false },
)

const services = useResource(
  async () => {
    if (hotelId.value == null) return []

    return servicesService.list(hotelId.value)
  },
  { immediate: false },
)

watch(
  hotelId,
  () => {
    if (hotelId.value != null) {
      categories.reload()
      services.reload()
    }
  },
  { immediate: true },
)

/* -------------------------------------------------------------------------- */
/* Tabs                                                                        */
/* -------------------------------------------------------------------------- */

type CatalogueTab = 'services' | 'categories'

const tab = ref<CatalogueTab>('services')

const tabs = computed(() => [
  {
    key: 'services' as CatalogueTab,
    label: t('services.services'),
    count: services.data.value?.length ?? null,
  },
  {
    key: 'categories' as CatalogueTab,
    label: t('services.categories'),
    count: categories.data.value?.length ?? null,
  },
])

/* -------------------------------------------------------------------------- */
/* Search                                                                      */
/* -------------------------------------------------------------------------- */

const serviceSearch = ref('')
const categorySearch = ref('')

const filteredServices = computed(() => {
  const items = services.data.value ?? []
  const query = serviceSearch.value.trim().toLowerCase()

  if (!query) return items

  return items.filter((service) => {
    const name = service.name?.toLowerCase() ?? ''
    const description = service.description?.toLowerCase() ?? ''
    const category = categoryName(service.service_category_id).toLowerCase()

    return (
      name.includes(query) ||
      description.includes(query) ||
      category.includes(query)
    )
  })
})

const filteredCategories = computed(() => {
  const items = categories.data.value ?? []
  const query = categorySearch.value.trim().toLowerCase()

  if (!query) return items

  return items.filter((category) => {
    const name = category.name?.toLowerCase() ?? ''
    const description = category.description?.toLowerCase() ?? ''

    return (
      name.includes(query) ||
      description.includes(query)
    )
  })
})

/* -------------------------------------------------------------------------- */
/* Helpers                                                                     */
/* -------------------------------------------------------------------------- */

const categoryName = (id: number | null) =>
  id == null
    ? t('services.uncategorised')
    : (
        categories.data.value ?? []
      ).find((category) => category.id === id)?.name ?? `#${id}`

const activeServices = computed(
  () => (services.data.value ?? []).filter(service => service.is_active).length,
)

const inactiveServices = computed(
  () => (services.data.value ?? []).filter(service => !service.is_active).length,
)

const activeCategories = computed(
  () => (categories.data.value ?? []).filter(category => category.is_active).length,
)

const inactiveCategories = computed(
  () => (categories.data.value ?? []).filter(category => !category.is_active).length,
)

/* -------------------------------------------------------------------------- */
/* Category form                                                               */
/* -------------------------------------------------------------------------- */

const catOpen = ref(false)
const catEditing = ref<ServiceCategory | null>(null)

const catForm = reactive({
  name: '',
  description: '',
})

const catErrors = ref<Record<string, string[]>>({})
const catSaving = ref(false)

function openCat(category?: ServiceCategory) {
  catEditing.value = category ?? null

  Object.assign(catForm, {
    name: category?.name ?? '',
    description: category?.description ?? '',
  })

  catErrors.value = {}
  catOpen.value = true
}

async function submitCat() {
  if (catSaving.value || hotelId.value == null) return

  catSaving.value = true
  catErrors.value = {}

  const body = {
    name: catForm.name,
    description: catForm.description || null,
  }

  try {
    if (catEditing.value) {
      await serviceCategoriesService.update(
        hotelId.value,
        catEditing.value.id,
        body,
      )

      app.pushToast('success', t('services.updated'))
    } else {
      await serviceCategoriesService.create(
        hotelId.value,
        body,
      )

      app.pushToast('success', t('services.created'))
    }

    catOpen.value = false
    await categories.reload()
  } catch (e) {
    if (
      e instanceof ApiError &&
      e.kind === 'validation' &&
      e.errors
    ) {
      catErrors.value = e.errors
    } else {
      app.pushToast(
        'error',
        e instanceof ApiError
          ? e.message
          : t('errors.genericBody'),
      )
    }
  } finally {
    catSaving.value = false
  }
}

/* -------------------------------------------------------------------------- */
/* Service form                                                                */
/* -------------------------------------------------------------------------- */

const svcOpen = ref(false)
const svcEditing = ref<HotelService | null>(null)

const svcForm = reactive({
  name: '',
  description: '',
  price: '',
  currency: '',
  service_category_id: null as number | null,
})

const svcErrors = ref<Record<string, string[]>>({})
const svcSaving = ref(false)

function openSvc(service?: HotelService) {
  svcEditing.value = service ?? null

  Object.assign(svcForm, {
    name: service?.name ?? '',
    description: service?.description ?? '',
    price: service?.price ?? '',
    currency: service?.currency ?? '',
    service_category_id: service?.service_category_id ?? null,
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

  if (svcForm.currency) {
    body.currency = svcForm.currency.toUpperCase()
  }

  try {
    if (svcEditing.value) {
      await servicesService.update(
        hotelId.value,
        svcEditing.value.id,
        body,
      )

      app.pushToast('success', t('services.updated'))
    } else {
      await servicesService.create(
        hotelId.value,
        body,
      )

      app.pushToast('success', t('services.created'))
    }

    svcOpen.value = false
    await services.reload()
  } catch (e) {
    if (
      e instanceof ApiError &&
      e.kind === 'validation' &&
      e.errors
    ) {
      svcErrors.value = e.errors
    } else {
      app.pushToast(
        'error',
        e instanceof ApiError
          ? e.message
          : t('errors.genericBody'),
      )
    }
  } finally {
    svcSaving.value = false
  }
}

/* -------------------------------------------------------------------------- */
/* Status                                                                      */
/* -------------------------------------------------------------------------- */

const toggling = ref<string | null>(null)

async function toggleSvc(service: HotelService) {
  if (toggling.value || hotelId.value == null) return

  toggling.value = `s${service.id}`

  try {
    if (service.is_active) {
      await servicesService.deactivate(
        hotelId.value,
        service.id,
      )

      app.pushToast('success', t('services.deactivated'))
    } else {
      await servicesService.activate(
        hotelId.value,
        service.id,
      )

      app.pushToast('success', t('services.activated'))
    }

    await services.reload()
  } catch (e) {
    app.pushToast(
      'error',
      e instanceof ApiError
        ? e.message
        : t('errors.genericBody'),
    )
  } finally {
    toggling.value = null
  }
}

async function toggleCat(category: ServiceCategory) {
  if (toggling.value || hotelId.value == null) return

  toggling.value = `c${category.id}`

  try {
    if (category.is_active) {
      await serviceCategoriesService.deactivate(
        hotelId.value,
        category.id,
      )

      app.pushToast('success', t('services.deactivated'))
    } else {
      await serviceCategoriesService.activate(
        hotelId.value,
        category.id,
      )

      app.pushToast('success', t('services.activated'))
    }

    await categories.reload()
  } catch (e) {
    app.pushToast(
      'error',
      e instanceof ApiError
        ? e.message
        : t('errors.genericBody'),
    )
  } finally {
    toggling.value = null
  }
}

/* -------------------------------------------------------------------------- */
/* UI helpers                                                                  */
/* -------------------------------------------------------------------------- */

function clearSearch() {
  serviceSearch.value = ''
  categorySearch.value = ''
}

const currentSearch = computed(() =>
  tab.value === 'services'
    ? serviceSearch.value
    : categorySearch.value,
)
</script>

<template>
  <div class="space-y-5">
    <!-- Header -->
    <PageHeader
      :title="t('services.title')"
      :subtitle="
        hotelCtx.currentHotel
          ? t('services.subtitle', {
              hotel: hotelCtx.currentHotel.name,
            })
          : ''
      "
    />

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <!-- Tabs + Primary action -->
      <div class="card overflow-hidden">
        <div
          class="flex flex-col gap-4 border-b border-border px-4 py-4 sm:px-5 lg:flex-row lg:items-center lg:justify-between"
        >
          <AppTabs
            v-model="tab"
            :tabs="tabs"
            class="min-w-0 flex-1"
          />

          <button
            v-if="canManage"
            type="button"
            class="btn btn-primary shrink-0"
            @click="
              tab === 'services'
                ? openSvc()
                : openCat()
            "
          >
            <KtIcon name="plus" />

            <span>
              {{
                tab === 'services'
                  ? t('services.newService')
                  : t('services.newCategory')
              }}
            </span>
          </button>
        </div>

        <!-- Filters -->
        <div class="bg-secondary/20 px-4 py-4 sm:px-5">
          <div
            class="flex flex-col gap-3 sm:flex-row sm:items-center"
          >
            <SearchField
              v-if="tab === 'services'"
              v-model="serviceSearch"
              :placeholder="t('services.searchPlaceholder')"
              class="w-full sm:max-w-md sm:flex-1"
            />

            <SearchField
              v-else
              v-model="categorySearch"
              :placeholder="t('services.searchPlaceholder')"
              class="w-full sm:max-w-md sm:flex-1"
            />

            <button
              v-if="currentSearch"
              type="button"
              class="btn btn-secondary shrink-0"
              @click="clearSearch"
            >
              <KtIcon name="close" />
              <span>{{ t('common.clear') }}</span>
            </button>
          </div>

          <div
            v-if="currentSearch"
            class="mt-3 text-2xs text-muted-foreground"
          >
            {{ t('common.filtersApplied') }}
          </div>
        </div>
      </div>

      <!-- Stats -->
      <div
        class="grid gap-3 sm:grid-cols-2 lg:grid-cols-4"
      >
        <div class="card p-4">
          <div class="flex items-center gap-3">
            <div
              class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
            >
              <KtIcon name="service" />
            </div>

            <div class="min-w-0">
              <p class="text-2sm text-muted-foreground">
                {{ t('services.services') }}
              </p>

              <p class="mt-0.5 text-xl font-semibold text-foreground">
                {{ services.data.value?.length ?? 0 }}
              </p>
            </div>
          </div>
        </div>

        <div class="card p-4">
          <div class="flex items-center gap-3">
            <div
              class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-success/10 text-success"
            >
              <KtIcon name="check" />
            </div>

            <div class="min-w-0">
              <p class="text-2sm text-muted-foreground">
                {{ t('common.active') }}
              </p>

              <p class="mt-0.5 text-xl font-semibold text-foreground">
                {{
                  tab === 'services'
                    ? activeServices
                    : activeCategories
                }}
              </p>
            </div>
          </div>
        </div>

        <div class="card p-4">
          <div class="flex items-center gap-3">
            <div
              class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-muted text-muted-foreground"
            >
              <KtIcon name="close" />
            </div>

            <div class="min-w-0">
              <p class="text-2sm text-muted-foreground">
                {{ t('common.inactive') }}
              </p>

              <p class="mt-0.5 text-xl font-semibold text-foreground">
                {{
                  tab === 'services'
                    ? inactiveServices
                    : inactiveCategories
                }}
              </p>
            </div>
          </div>
        </div>

        <div class="card p-4">
          <div class="flex items-center gap-3">
            <div
              class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-secondary text-muted-foreground"
            >
              <KtIcon name="category" />
            </div>

            <div class="min-w-0">
              <p class="text-2sm text-muted-foreground">
                {{ t('services.categories') }}
              </p>

              <p class="mt-0.5 text-xl font-semibold text-foreground">
                {{ categories.data.value?.length ?? 0 }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Services -->
      <template v-if="tab === 'services'">
        <LoadingState
          v-if="services.pending.value"
          :rows="5"
        />

        <ErrorState
          v-else-if="services.error.value"
          :error="services.error.value"
          @retry="services.reload"
        />

        <div
          v-else-if="filteredServices.length === 0"
          class="card"
        >
          <div class="flex flex-col items-center justify-center px-6 py-14 text-center">
            <div
              class="mb-4 flex size-12 items-center justify-center rounded-full bg-secondary text-muted-foreground"
            >
              <KtIcon name="service" />
            </div>

            <h3 class="text-sm font-semibold text-foreground">
              {{ t('services.empty') }}
            </h3>

            <p class="mt-1 max-w-md text-2sm text-muted-foreground">
              {{ t('services.manageNote') }}
            </p>

            <button
              v-if="canManage"
              type="button"
              class="btn btn-primary mt-5"
              @click="openSvc()"
            >
              <KtIcon name="plus" />
              {{ t('services.newService') }}
            </button>
          </div>
        </div>

        <div
          v-else
          class="card overflow-hidden"
        >
          <div
            class="border-b border-border px-4 py-4 sm:px-5"
          >
            <div class="flex items-center justify-between gap-3">
              <div>
                <h2 class="text-sm font-semibold text-foreground">
                  {{ t('services.services') }}
                </h2>

                <p class="mt-0.5 text-2xs text-muted-foreground">
                  {{ filteredServices.length }}
                  {{ t('services.services') }}
                </p>
              </div>
            </div>
          </div>

          <div class="overflow-x-auto">
            <table class="table-base">
              <thead>
                <tr>
                  <th>
                    {{ t('services.name') }}
                  </th>

                  <th>
                    {{ t('services.category') }}
                  </th>

                  <th class="text-end">
                    {{ t('services.price') }}
                  </th>

                  <th>
                    {{ t('services.status') }}
                  </th>

                  <th
                    v-if="canManage"
                    class="w-32 text-end"
                  >
                    {{ t('common.actions') }}
                  </th>
                </tr>
              </thead>

              <tbody>
                <tr
                  v-for="service in filteredServices"
                  :key="service.id"
                >
                  <!-- Name -->
                  <td>
                    <div class="flex min-w-0 items-center gap-3">
                      <div
                        class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
                      >
                        <KtIcon name="service" />
                      </div>

                      <div class="min-w-0">
                        <div class="truncate font-medium text-foreground">
                          {{ service.name }}
                        </div>

                        <p
                          v-if="service.description"
                          class="mt-0.5 max-w-md truncate text-2xs text-muted-foreground"
                        >
                          {{ service.description }}
                        </p>
                      </div>
                    </div>
                  </td>

                  <!-- Category -->
                  <td>
                    <span
                      class="inline-flex items-center rounded-full border border-border bg-secondary/50 px-2.5 py-1 text-2xs font-medium text-muted-foreground"
                    >
                      {{ categoryName(service.service_category_id) }}
                    </span>
                  </td>

                  <!-- Price -->
                  <td class="text-end">
                    <div class="font-semibold text-foreground">
                      {{ money(service.price, service.currency) }}
                    </div>
                  </td>

                  <!-- Status -->
                  <td>
                    <StatusBadge
                      :label="
                        service.is_active
                          ? t('common.active')
                          : t('common.inactive')
                      "
                      :tone="
                        service.is_active
                          ? 'success'
                          : 'neutral'
                      "
                    />
                  </td>

                  <!-- Actions -->
                  <td v-if="canManage">
                    <div class="flex items-center justify-end gap-1">
                      <button
                        type="button"
                        class="btn btn-ghost px-2.5 py-2"
                        :title="t('common.edit')"
                        @click="openSvc(service)"
                      >
                        <KtIcon name="pencil" />

                        <span class="sr-only">
                          {{ t('common.edit') }}
                        </span>
                      </button>

                      <button
                        type="button"
                        class="btn btn-ghost px-2.5 py-2"
                        :disabled="
                          toggling === `s${service.id}`
                        "
                        :title="
                          service.is_active
                            ? t('common.deactivate')
                            : t('common.activate')
                        "
                        @click="toggleSvc(service)"
                      >
                        <KtIcon
                          :name="
                            service.is_active
                              ? 'eye-slash'
                              : 'eye'
                          "
                        />

                        <span class="sr-only">
                          {{
                            service.is_active
                              ? t('common.deactivate')
                              : t('common.activate')
                          }}
                        </span>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>

      <!-- Categories -->
      <template v-else>
        <LoadingState
          v-if="categories.pending.value"
          :rows="5"
        />

        <ErrorState
          v-else-if="categories.error.value"
          :error="categories.error.value"
          @retry="categories.reload"
        />

        <div
          v-else-if="filteredCategories.length === 0"
          class="card"
        >
          <div class="flex flex-col items-center justify-center px-6 py-14 text-center">
            <div
              class="mb-4 flex size-12 items-center justify-center rounded-full bg-secondary text-muted-foreground"
            >
              <KtIcon name="category" />
            </div>

            <h3 class="text-sm font-semibold text-foreground">
              {{ t('services.categories') }}
            </h3>

            <p class="mt-1 max-w-md text-2sm text-muted-foreground">
              {{ t('services.manageNote') }}
            </p>

            <button
              v-if="canManage"
              type="button"
              class="btn btn-primary mt-5"
              @click="openCat()"
            >
              <KtIcon name="plus" />
              {{ t('services.newCategory') }}
            </button>
          </div>
        </div>

        <div
          v-else
          class="card overflow-hidden"
        >
          <div
            class="border-b border-border px-4 py-4 sm:px-5"
          >
            <div class="flex items-center justify-between gap-3">
              <div>
                <h2 class="text-sm font-semibold text-foreground">
                  {{ t('services.categories') }}
                </h2>

                <p class="mt-0.5 text-2xs text-muted-foreground">
                  {{ filteredCategories.length }}
                  {{ t('services.categories') }}
                </p>
              </div>
            </div>
          </div>

          <div class="overflow-x-auto">
            <table class="table-base">
              <thead>
                <tr>
                  <th>
                    {{ t('services.name') }}
                  </th>

                  <th>
                    {{ t('services.description') }}
                  </th>

                  <th>
                    {{ t('services.status') }}
                  </th>

                  <th
                    v-if="canManage"
                    class="w-32 text-end"
                  >
                    {{ t('common.actions') }}
                  </th>
                </tr>
              </thead>

              <tbody>
                <tr
                  v-for="category in filteredCategories"
                  :key="category.id"
                >
                  <!-- Name -->
                  <td>
                    <div class="flex items-center gap-3">
                      <div
                        class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground"
                      >
                        <KtIcon name="category" />
                      </div>

                      <span class="font-medium text-foreground">
                        {{ category.name }}
                      </span>
                    </div>
                  </td>

                  <!-- Description -->
                  <td class="max-w-xl">
                    <span
                      class="line-clamp-2 text-2sm text-muted-foreground"
                    >
                      {{ category.description || '—' }}
                    </span>
                  </td>

                  <!-- Status -->
                  <td>
                    <StatusBadge
                      :label="
                        category.is_active
                          ? t('common.active')
                          : t('common.inactive')
                      "
                      :tone="
                        category.is_active
                          ? 'success'
                          : 'neutral'
                      "
                    />
                  </td>

                  <!-- Actions -->
                  <td v-if="canManage">
                    <div class="flex items-center justify-end gap-1">
                      <button
                        type="button"
                        class="btn btn-ghost px-2.5 py-2"
                        :title="t('common.edit')"
                        @click="openCat(category)"
                      >
                        <KtIcon name="pencil" />

                        <span class="sr-only">
                          {{ t('common.edit') }}
                        </span>
                      </button>

                      <button
                        type="button"
                        class="btn btn-ghost px-2.5 py-2"
                        :disabled="
                          toggling === `c${category.id}`
                        "
                        :title="
                          category.is_active
                            ? t('common.deactivate')
                            : t('common.activate')
                        "
                        @click="toggleCat(category)"
                      >
                        <KtIcon
                          :name="
                            category.is_active
                              ? 'eye-slash'
                              : 'eye'
                          "
                        />

                        <span class="sr-only">
                          {{
                            category.is_active
                              ? t('common.deactivate')
                              : t('common.activate')
                          }}
                        </span>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
    </template>

    <!-- Category Modal -->
    <AppModal
      v-model:open="catOpen"
      :title="
        catEditing
          ? t('services.editCategory')
          : t('services.newCategory')
      "
    >
      <form
        class="space-y-5"
        novalidate
        @submit.prevent="submitCat"
      >
        <FormField
          :label="t('services.name')"
          :error="catErrors.name"
          required
        >
          <input
            v-model="catForm.name"
            class="input"
            required
            autocomplete="off"
          >
        </FormField>

        <FormField
          :label="t('services.description')"
          :error="catErrors.description"
        >
          <textarea
            v-model="catForm.description"
            rows="4"
            class="input resize-none"
            maxlength="500"
          />
        </FormField>
      </form>

      <template #footer>
        <button
          type="button"
          class="btn btn-secondary"
          :disabled="catSaving"
          @click="catOpen = false"
        >
          {{ t('common.cancel') }}
        </button>

        <button
          type="button"
          class="btn btn-primary"
          :disabled="catSaving"
          @click="submitCat"
        >
          <KtIcon
            v-if="!catSaving"
            name="check"
          />

          {{ catSaving ? t('common.saving') : t('common.save') }}
        </button>
      </template>
    </AppModal>

    <!-- Service Modal -->
    <AppModal
      v-model:open="svcOpen"
      :title="
        svcEditing
          ? t('services.editService')
          : t('services.newService')
      "
    >
      <form
        class="space-y-5"
        novalidate
        @submit.prevent="submitSvc"
      >
        <FormField
          :label="t('services.name')"
          :error="svcErrors.name"
          required
        >
          <input
            v-model="svcForm.name"
            class="input"
            required
            autocomplete="off"
          >
        </FormField>

        <FormField
          :label="t('services.description')"
          :error="svcErrors.description"
        >
          <textarea
            v-model="svcForm.description"
            rows="4"
            class="input resize-none"
            maxlength="1000"
          />
        </FormField>

        <div class="grid gap-4 sm:grid-cols-2">
          <FormField
            :label="t('services.price')"
            :error="svcErrors.price"
            required
          >
            <div class="relative">
              <input
                v-model="svcForm.price"
                type="text"
                inputmode="decimal"
                class="input"
                required
              >
            </div>
          </FormField>

          <FormField
            :label="`${t('services.currency')} (${t('common.optional')})`"
            :error="svcErrors.currency"
          >
            <input
              v-model="svcForm.currency"
              class="input uppercase"
              maxlength="3"
              placeholder="EGP"
              autocomplete="off"
            >
          </FormField>
        </div>

        <FormField
          :label="t('services.category')"
          :error="svcErrors.service_category_id"
        >
          <select
            v-model.number="svcForm.service_category_id"
            class="input"
          >
            <option :value="null">
              {{ t('services.uncategorised') }}
            </option>

            <option
              v-for="category in categories.data.value ?? []"
              :key="category.id"
              :value="category.id"
            >
              {{ category.name }}
            </option>
          </select>
        </FormField>
      </form>

      <template #footer>
        <button
          type="button"
          class="btn btn-secondary"
          :disabled="svcSaving"
          @click="svcOpen = false"
        >
          {{ t('common.cancel') }}
        </button>

        <button
          type="button"
          class="btn btn-primary"
          :disabled="svcSaving"
          @click="submitSvc"
        >
          <KtIcon
            v-if="!svcSaving"
            name="check"
          />

          {{ svcSaving ? t('common.saving') : t('common.save') }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
