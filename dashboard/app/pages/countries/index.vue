<script setup lang="ts">
import { countriesService } from '~/services'
import type { Column } from '~/components/DataTable.vue'
import type { Country } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: ['locations.view', 'locations.manage'] })

const { t, locale } = useI18n()
const { can } = useCan()
const app = useAppStore()

const canManage = can('locations.manage')

const page = ref(1)
const search = ref('')
const status = ref<'all' | 'active' | 'inactive'>('all')

function params() {
  return {
    page: page.value,
    search: search.value.trim() || undefined,
    is_active:
      status.value === 'all'
        ? undefined
        : status.value === 'active'
          ? 1
          : 0,
  }
}

const list = useResource(() => countriesService.list(params()))

let debounce: ReturnType<typeof setTimeout> | null = null

watch(search, () => {
  if (debounce) clearTimeout(debounce)

  debounce = setTimeout(() => {
    page.value = 1
    list.reload()
  }, 300)
})

watch(status, () => {
  page.value = 1
  list.reload()
})

const filtersActive = computed(
  () =>
    search.value.trim() !== '' ||
    status.value !== 'all',
)

function clearFilters() {
  search.value = ''
  status.value = 'all'
  page.value = 1
}

function changePage(n: number) {
  page.value = n
  list.reload()
}

const name = (c: Country) =>
  locale.value === 'ar'
    ? c.name_ar
    : c.name_en

const columns = computed<Column[]>(() => [
  {
    key: 'name',
    label: t('countries.title'),
  },
  {
    key: 'code',
    label: t('countries.code'),
    nowrap: true,
  },
  {
    key: 'cities',
    label: t('countries.cities'),
    align: 'end',
  },
  {
    key: 'is_active',
    label: t('countries.status'),
  },
  ...(canManage
    ? [
        {
          key: 'actions',
          label: t('common.actions'),
          align: 'end' as const,
        },
      ]
    : []),
])

// ---------------------------------------------------------------------
// Activate / Deactivate
// ---------------------------------------------------------------------

const toggling = ref<number | null>(null)

async function toggleActive(c: Country) {
  if (toggling.value !== null) return

  toggling.value = c.id

  try {
    if (c.is_active) {
      await countriesService.deactivate(c.id)
    } else {
      await countriesService.activate(c.id)
    }

    app.pushToast(
      'success',
      c.is_active
        ? t('countries.deactivated')
        : t('countries.activated'),
    )

    list.reload()
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

// ---------------------------------------------------------------------
// Delete
// ---------------------------------------------------------------------

const deleting = ref<Country | null>(null)
const removing = ref(false)

async function confirmDelete() {
  if (!deleting.value || removing.value) return

  removing.value = true

  try {
    await countriesService.remove(deleting.value.id)

    app.pushToast(
      'success',
      t('countries.deleted'),
    )

    deleting.value = null
    list.reload()
  } catch (e) {
    app.pushToast(
      'error',
      e instanceof ApiError
        ? e.message
        : t('errors.genericBody'),
    )
  } finally {
    removing.value = false
  }
}
</script>

<template>
  <div class="space-y-5">
    <!-- ============================================================= -->
    <!-- Header -->
    <!-- ============================================================= -->

    <PageHeader
      :title="t('countries.title')"
      :subtitle="t('countries.subtitle')"
    >
      <template v-if="canManage" #actions>
        <NuxtLink
          to="/countries/new"
          class="btn btn-primary"
        >
          <KtIcon name="plus" />
          <span>{{ t('countries.new') }}</span>
        </NuxtLink>
      </template>
    </PageHeader>

    <!-- ============================================================= -->
    <!-- Filters -->
    <!-- ============================================================= -->

    <div class="card overflow-hidden">
      <div
        class="flex flex-col gap-4 border-b border-border px-4 py-4 sm:px-5 lg:flex-row lg:items-end"
      >
        <!-- Search -->

        <div class="w-full lg:max-w-sm lg:flex-1">
          <SearchField
            v-model="search"
            :placeholder="t('countries.searchPlaceholder')"
          />
        </div>

        <!-- Status -->

        <FormField
          :label="t('countries.filterStatus')"
          class="w-full sm:w-auto"
        >
          <select
            v-model="status"
            class="input w-full min-w-40 sm:w-auto"
          >
            <option value="all">
              {{ t('common.all') }}
            </option>

            <option value="active">
              {{ t('common.active') }}
            </option>

            <option value="inactive">
              {{ t('common.inactive') }}
            </option>
          </select>
        </FormField>

        <!-- Clear -->

        <button
          v-if="filtersActive"
          type="button"
          class="btn btn-secondary shrink-0"
          @click="clearFilters"
        >
          <KtIcon name="close" />
          {{ t('common.clear') }}
        </button>
      </div>

      <!-- Filter summary -->

      <div
        v-if="filtersActive"
        class="flex items-center justify-between gap-3 bg-secondary/40 px-4 py-2.5 text-xs text-muted-foreground sm:px-5"
      >
        <span>
          {{ t('common.filtersApplied') }}
        </span>

        <button
          type="button"
          class="font-medium text-primary hover:underline"
          @click="clearFilters"
        >
          {{ t('common.clear') }}
        </button>
      </div>
    </div>

    <!-- ============================================================= -->
    <!-- Table -->
    <!-- ============================================================= -->

    <div class="card overflow-hidden">
      <DataTable
        :columns="columns"
        :rows="list.data.value?.data ?? []"
        :loading="list.pending.value"
        :error="list.error.value"
        :meta="list.data.value?.meta ?? null"
        :empty-title="t('locations.noCountries')"
        @retry="list.reload"
        @page="changePage"
      >
        <!-- ========================================================= -->
        <!-- Country -->
        <!-- ========================================================= -->

        <template #cell-name="{ row }">
          <div class="flex min-w-0 items-center gap-3.5">
            <div
              class="flex size-11 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
            >
              <KtIcon name="globe" />
            </div>

            <div class="min-w-0">
              <div
                class="truncate text-sm font-semibold text-foreground"
              >
                {{ name(row as Country) }}
              </div>

              <div
                class="mt-0.5 truncate text-xs text-muted-foreground"
              >
                {{ (row as Country).code }}
              </div>
            </div>
          </div>
        </template>

        <!-- ========================================================= -->
        <!-- Code -->
        <!-- ========================================================= -->

        <template #cell-code="{ row }">
          <span
            class="rounded bg-secondary px-2 py-1 font-mono text-2xs text-foreground"
          >
            {{ (row as Country).code }}
          </span>
        </template>

        <!-- ========================================================= -->
        <!-- Cities -->
        <!-- ========================================================= -->

        <template #cell-cities="{ row }">
          <span class="text-sm font-medium text-foreground">
            {{
              (row as Country).cities_count ??
              t('common.notAvailable')
            }}
          </span>
        </template>

        <!-- ========================================================= -->
        <!-- Status -->
        <!-- ========================================================= -->

        <template #cell-is_active="{ row }">
          <StatusBadge
            :label="
              (row as Country).is_active
                ? t('common.active')
                : t('common.inactive')
            "
            :tone="
              (row as Country).is_active
                ? 'success'
                : 'neutral'
            "
          />
        </template>

        <!-- ========================================================= -->
        <!-- Actions -->
        <!-- ========================================================= -->

        <template #cell-actions="{ row }">
          <div
            class="flex items-center justify-end gap-1"
            @click.stop
          >
            <!-- Edit -->

            <NuxtLink
              :to="`/countries/${(row as Country).id}/edit`"
              class="btn btn-ghost px-2.5 py-2"
              :title="t('common.edit')"
              @click.stop
            >
              <KtIcon name="pencil" />

              <span class="sr-only">
                {{ t('common.edit') }}
              </span>
            </NuxtLink>

            <!-- Activate / Deactivate -->

            <button
              type="button"
              class="btn btn-ghost px-2.5 py-2"
              :disabled="toggling === (row as Country).id"
              :title="
                (row as Country).is_active
                  ? t('common.deactivate')
                  : t('common.activate')
              "
              @click.stop="toggleActive(row as Country)"
            >
              <KtIcon
                :name="
                  (row as Country).is_active
                    ? 'eye-slash'
                    : 'eye'
                "
              />

              <span class="sr-only">
                {{
                  (row as Country).is_active
                    ? t('common.deactivate')
                    : t('common.activate')
                }}
              </span>
            </button>

            <!-- Delete -->

            <button
              type="button"
              class="btn btn-ghost px-2.5 py-2 text-destructive hover:text-destructive"
              :disabled="removing"
              :title="t('common.delete')"
              @click.stop="deleting = row as Country"
            >
              <KtIcon name="trash" />

              <span class="sr-only">
                {{ t('common.delete') }}
              </span>
            </button>
          </div>
        </template>
      </DataTable>
    </div>

    <!-- ============================================================= -->
    <!-- Delete Confirmation -->
    <!-- ============================================================= -->

    <ConfirmDialog
      :open="deleting !== null"
      :title="t('common.delete')"
      :message="
        deleting
          ? t('countries.deleteConfirm', {
              name: name(deleting),
            })
          : ''
      "
      tone="destructive"
      :busy="removing"
      @update:open="(v) => !v && (deleting = null)"
      @confirm="confirmDelete"
    />
  </div>
</template>
