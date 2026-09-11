<script setup lang="ts">
import { citiesService, countriesService } from "~/services";
import type { Column } from "~/components/DataTable.vue";
import type { City } from "~/types/api";
import { ApiError } from "~/utils/apiError";

definePageMeta({ permission: ["locations.view", "locations.manage"] });

const { t, locale } = useI18n();
const { can } = useCan();
const app = useAppStore();

const canManage = can("locations.manage");

const page = ref(1);
const search = ref("");
const status = ref<"all" | "active" | "inactive">("all");
const countryId = ref<number | null>(null);

function paramsFor() {
  return {
    page: page.value,
    search: search.value.trim() || undefined,
    country_id: countryId.value ?? undefined,
    is_active:
      status.value === "all" ? undefined : status.value === "active" ? 1 : 0,
  };
}

const list = useResource(() => citiesService.list(paramsFor()));

const fetchCountries = ({ search: s }: { search?: string }) =>
  countriesService.options(s);

let debounce: ReturnType<typeof setTimeout> | null = null;

watch(search, () => {
  if (debounce) clearTimeout(debounce);

  debounce = setTimeout(() => {
    page.value = 1;
    list.reload();
  }, 300);
});

watch([status, countryId], () => {
  page.value = 1;
  list.reload();
});

const filtersActive = computed(
  () =>
    search.value.trim() !== "" ||
    status.value !== "all" ||
    countryId.value !== null,
);

function clearFilters() {
  search.value = "";
  status.value = "all";
  countryId.value = null;
  page.value = 1;
}

function changePage(n: number) {
  page.value = n;
  list.reload();
}

const cityName = (c: City) => (locale.value === "ar" ? c.name_ar : c.name_en);

const countryName = (c: City) =>
  c.country
    ? locale.value === "ar"
      ? c.country.name_ar
      : c.country.name_en
    : `#${c.country_id}`;

const columns = computed<Column[]>(() => [
  {
    key: "name",
    label: t("cities.nameEn"),
  },
  {
    key: "name_ar",
    label: t("cities.nameAr"),
  },
  {
    key: "country",
    label: t("cities.country"),
  },
  {
    key: "is_active",
    label: t("cities.status"),
  },
  ...(canManage
    ? [
        {
          key: "actions",
          label: t("common.actions"),
          align: "end" as const,
        },
      ]
    : []),
]);

// ---------------------------------------------------------------------
// Activate / Deactivate
// ---------------------------------------------------------------------

const toggling = ref<number | null>(null);

async function toggleActive(c: City) {
  if (toggling.value !== null) return;

  toggling.value = c.id;

  try {
    if (c.is_active) {
      await citiesService.deactivate(c.id);
    } else {
      await citiesService.activate(c.id);
    }

    app.pushToast(
      "success",
      c.is_active ? t("cities.deactivated") : t("cities.activated"),
    );

    list.reload();
  } catch (e) {
    app.pushToast(
      "error",
      e instanceof ApiError ? e.message : t("errors.genericBody"),
    );
  } finally {
    toggling.value = null;
  }
}

// ---------------------------------------------------------------------
// Delete
// ---------------------------------------------------------------------

const deleting = ref<City | null>(null);
const removing = ref(false);

async function confirmDelete() {
  if (!deleting.value || removing.value) return;

  removing.value = true;

  try {
    await citiesService.remove(deleting.value.id);

    app.pushToast("success", t("cities.deleted"));

    deleting.value = null;
    list.reload();
  } catch (e) {
    app.pushToast(
      "error",
      e instanceof ApiError ? e.message : t("errors.genericBody"),
    );
  } finally {
    removing.value = false;
  }
}
</script>

<template>
  <div class="space-y-5">
    <!-- ============================================================= -->
    <!-- Header -->
    <!-- ============================================================= -->

    <PageHeader :title="t('cities.title')" :subtitle="t('cities.subtitle')">
      <template v-if="canManage" #actions>
        <NuxtLink to="/cities/new" class="btn btn-primary">
          <KtIcon name="plus" />
          <span>{{ t("cities.new") }}</span>
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
            :placeholder="t('cities.searchPlaceholder')"
          />
        </div>

        <!-- Country -->

        <FormField :label="t('cities.filterCountry')" class="w-full sm:w-auto">
          <div class="w-full sm:min-w-52">
            <EntitySelect
              v-model="countryId"
              :fetcher="fetchCountries"
              :label-fn="(c) => (locale === 'ar' ? c.name_ar : c.name_en)"
              :placeholder="t('cities.allCountries')"
              clearable
            >
              <template #empty>
                {{ t("locations.noCountries") }}
              </template>
            </EntitySelect>
          </div>
        </FormField>

        <!-- Status -->

        <FormField :label="t('cities.filterStatus')" class="w-full sm:w-auto">
          <select v-model="status" class="input w-full min-w-40 sm:w-auto">
            <option value="all">
              {{ t("common.all") }}
            </option>

            <option value="active">
              {{ t("common.active") }}
            </option>

            <option value="inactive">
              {{ t("common.inactive") }}
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
          {{ t("common.clear") }}
        </button>
      </div>

      <!-- Filter summary -->

      <div
        v-if="filtersActive"
        class="flex items-center justify-between gap-3 bg-secondary/40 px-4 py-2.5 text-xs text-muted-foreground sm:px-5"
      >
        <span>
          {{ t("common.filtersApplied") }}
        </span>

        <button
          type="button"
          class="font-medium text-primary hover:underline"
          @click="clearFilters"
        >
          {{ t("common.clear") }}
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
        :empty-title="t('locations.noCities')"
        @retry="list.reload"
        @page="changePage"
      >
        <!-- ========================================================= -->
        <!-- City -->
        <!-- ========================================================= -->

        <template #cell-name="{ row }">
          <div class="flex min-w-0 items-center gap-3.5">
            <div
              class="flex size-11 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
            >
              <KtIcon name="map-pin" />
            </div>

            <div class="min-w-0">
              <div class="truncate text-sm font-semibold text-foreground">
                {{ (row as City).name_en }}
              </div>

              <div
                class="mt-0.5 truncate text-xs text-muted-foreground"
                dir="rtl"
              >
                {{ (row as City).name_ar }}
              </div>
            </div>
          </div>
        </template>

        <!-- ========================================================= -->
        <!-- Arabic Name -->
        <!-- ========================================================= -->

        <template #cell-name_ar="{ row }">
          <span class="text-sm text-foreground" dir="rtl">
            {{ (row as City).name_ar }}
          </span>
        </template>

        <!-- ========================================================= -->
        <!-- Country -->
        <!-- ========================================================= -->

        <template #cell-country="{ row }">
          <div class="flex items-center gap-2 text-sm">
            <KtIcon name="globe" class="shrink-0 text-muted-foreground" />

            <span class="truncate">
              {{ countryName(row as City) }}
            </span>
          </div>
        </template>

        <!-- ========================================================= -->
        <!-- Status -->
        <!-- ========================================================= -->

        <template #cell-is_active="{ row }">
          <StatusBadge
            :label="
              (row as City).is_active
                ? t('common.active')
                : t('common.inactive')
            "
            :tone="(row as City).is_active ? 'success' : 'neutral'"
          />
        </template>

        <!-- ========================================================= -->
        <!-- Actions -->
        <!-- ========================================================= -->

        <template #cell-actions="{ row }">
          <div class="flex items-center justify-end gap-1" @click.stop>
            <!-- Edit -->

            <NuxtLink
              :to="`/cities/${(row as City).id}/edit`"
              class="btn btn-ghost px-2.5 py-2"
              :title="t('common.edit')"
              @click.stop
            >
              <KtIcon name="pencil" />

              <span class="sr-only">
                {{ t("common.edit") }}
              </span>
            </NuxtLink>

            <!-- Activate / Deactivate -->

            <button
              type="button"
              class="btn btn-ghost px-2.5 py-2"
              :disabled="toggling === (row as City).id"
              :title="
                (row as City).is_active
                  ? t('common.deactivate')
                  : t('common.activate')
              "
              @click.stop="toggleActive(row as City)"
            >
              <KtIcon :name="(row as City).is_active ? 'eye-slash' : 'eye'" />

              <span class="sr-only">
                {{
                  (row as City).is_active
                    ? t("common.deactivate")
                    : t("common.activate")
                }}
              </span>
            </button>

            <!-- Delete -->

            <button
              type="button"
              class="btn btn-ghost px-2.5 py-2 text-destructive hover:text-destructive"
              :disabled="removing"
              :title="t('common.delete')"
              @click.stop="deleting = row as City"
            >
              <KtIcon name="trash" />

              <span class="sr-only">
                {{ t("common.delete") }}
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
          ? t('cities.deleteConfirm', {
              name: cityName(deleting),
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
