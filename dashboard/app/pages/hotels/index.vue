<script setup lang="ts">
import { hotelsService } from "~/services";
import type { Column } from "~/components/DataTable.vue";
import type { Hotel } from "~/types/api";
import { ApiError } from "~/utils/apiError";

definePageMeta({ permission: "hotels.view" });

const { t, locale } = useI18n();
const router = useRouter();
const { can } = useCan();
const app = useAppStore();

const canManage = can("hotels.manage");

const page = ref(1);
const search = ref("");
const status = ref<"all" | "active" | "inactive">("all");
const sort = ref<"name" | "-name" | "created_at" | "-created_at">("name");

function params() {
  return {
    page: page.value,
    search: search.value.trim() || undefined,
    is_active:
      status.value === "all"
        ? undefined
        : ((status.value === "active" ? 1 : 0) as 0 | 1),
    sort: sort.value,
  };
}

const list = useResource(() => hotelsService.list(params()));

let debounce: ReturnType<typeof setTimeout> | null = null;

watch(search, () => {
  if (debounce) clearTimeout(debounce);

  debounce = setTimeout(() => {
    page.value = 1;
    list.reload();
  }, 300);
});

watch([status, sort], () => {
  page.value = 1;
  list.reload();
});

const filtersActive = computed(
  () =>
    search.value.trim() !== "" ||
    status.value !== "all" ||
    sort.value !== "name",
);

function clearFilters() {
  search.value = "";
  status.value = "all";
  sort.value = "name";
  page.value = 1;
}

function changePage(n: number) {
  page.value = n;
  list.reload();
}

const columns = computed<Column[]>(() => [
  {
    key: "name",
    label: t("hotels.name"),
  },
  {
    key: "location",
    label: t("hotels.location"),
  },
  {
    key: "starRating",
    label: t("hotels.starRating"),
  },
  {
    key: "is_active",
    label: t("hotels.status"),
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

function localized(s?: { name_en: string; name_ar: string } | null) {
  if (!s) return null;

  return locale.value === "ar" ? s.name_ar : s.name_en;
}

function locationOf(h: Hotel) {
  const city = localized(h.city_summary) || h.city;
  const country = localized(h.country_summary) || h.country;

  return [city, country].filter(Boolean).join(", ") || t("common.notAvailable");
}

// ---------------------------------------------------------------------
// Activate / Deactivate
// ---------------------------------------------------------------------

const toggling = ref<number | null>(null);

async function toggleActive(h: Hotel) {
  if (toggling.value !== null) return;

  toggling.value = h.id;

  try {
    await hotelsService.update(h.id, {
      is_active: !h.is_active,
    });

    app.pushToast(
      "success",
      h.is_active ? t("hotels.deactivated") : t("hotels.activated"),
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

// Hard delete is intentionally not offered here — the backend exposes no
// DELETE /hotels/{hotel} endpoint (hotels are deactivated, never removed).
</script>

<template>
  <div class="space-y-5">
    <!-- ============================================================= -->
    <!-- Header -->
    <!-- ============================================================= -->

    <PageHeader :title="t('hotels.title')" :subtitle="t('hotels.subtitle')">
      <template v-if="canManage" #actions>
        <NuxtLink to="/hotels/new" class="btn btn-primary">
          <KtIcon name="plus" />
          <span>{{ t("hotels.new") }}</span>
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
            :placeholder="t('hotels.searchPlaceholder')"
          />
        </div>

        <!-- Status -->

        <FormField :label="t('hotels.filterStatus')" class="w-full sm:w-auto">
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

        <!-- Sort -->

        <FormField :label="t('hotels.sortBy')" class="w-full sm:w-auto">
          <select v-model="sort" class="input w-full min-w-44 sm:w-auto">
            <option value="name">
              {{ t("hotels.sortNameAsc") }}
            </option>

            <option value="-name">
              {{ t("hotels.sortNameDesc") }}
            </option>

            <option value="-created_at">
              {{ t("hotels.sortNewest") }}
            </option>

            <option value="created_at">
              {{ t("hotels.sortOldest") }}
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
        :empty-title="t('hotels.empty')"
        clickable-rows
        @retry="list.reload"
        @page="changePage"
        @row-click="(row: Hotel) => router.push(`/hotels/${row.id}`)"
      >
        <!-- ========================================================= -->
        <!-- Hotel -->
        <!-- ========================================================= -->

        <template #cell-name="{ row }">
          <div class="flex min-w-0 items-center gap-3.5">
            <div class="shrink-0">
              <AppImage
                :alt="(row as Hotel).name"
                :name="(row as Hotel).name"
                :src="(row as Hotel).logo?.url"
                size="2.75rem"
              />
            </div>

            <div class="min-w-0">
              <div class="truncate text-sm font-semibold text-foreground">
                {{ (row as Hotel).name }}
              </div>

              <div class="mt-0.5 truncate text-xs text-muted-foreground">
                /{{ (row as Hotel).slug }}
              </div>
            </div>
          </div>
        </template>

        <!-- ========================================================= -->
        <!-- Location -->
        <!-- ========================================================= -->

        <template #cell-location="{ row }">
          <div class="flex items-center gap-2 text-sm">
            <KtIcon name="map-pin" class="shrink-0 text-muted-foreground" />

            <span class="truncate">
              {{ locationOf(row as Hotel) }}
            </span>
          </div>
        </template>

        <!-- ========================================================= -->
        <!-- Rating -->
        <!-- ========================================================= -->

        <template #cell-starRating="{ row }">
          <div
            v-if="(row as Hotel).star_rating"
            class="inline-flex items-center gap-1.5"
          >
            <span class="text-amber-500" aria-hidden="true"> ★ </span>

            <span class="text-sm font-medium text-foreground">
              {{ (row as Hotel).star_rating }}
            </span>
          </div>

          <span v-else class="text-xs text-muted-foreground">
            {{ t("hotels.starRatingNone") }}
          </span>
        </template>

        <!-- ========================================================= -->
        <!-- Status -->
        <!-- ========================================================= -->

        <template #cell-is_active="{ row }">
          <StatusBadge
            :label="
              (row as Hotel).is_active
                ? t('common.active')
                : t('common.inactive')
            "
            :tone="(row as Hotel).is_active ? 'success' : 'neutral'"
          />
        </template>

        <!-- ========================================================= -->
        <!-- Actions -->
        <!-- ========================================================= -->

        <template #cell-actions="{ row }">
          <div class="flex items-center justify-end gap-1" @click.stop>
            <!-- Edit -->

            <NuxtLink
              :to="`/hotels/${(row as Hotel).id}/edit`"
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
              :disabled="toggling === (row as Hotel).id"
              :title="
                (row as Hotel).is_active
                  ? t('common.deactivate')
                  : t('common.activate')
              "
              @click.stop="toggleActive(row as Hotel)"
            >
              <KtIcon :name="(row as Hotel).is_active ? 'eye-slash' : 'eye'" />

              <span class="sr-only">
                {{
                  (row as Hotel).is_active
                    ? t("common.deactivate")
                    : t("common.activate")
                }}
              </span>
            </button>
          </div>
        </template>
      </DataTable>
    </div>
  </div>
</template>
