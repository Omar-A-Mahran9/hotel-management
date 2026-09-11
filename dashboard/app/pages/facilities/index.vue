<script setup lang="ts">
import { facilitiesService } from "~/services";
import type { Column } from "~/components/DataTable.vue";
import type { Facility } from "~/types/api";
import { ApiError } from "~/utils/apiError";

definePageMeta({ permission: ["facilities.view", "facilities.manage"] });

const { t, locale } = useI18n();
const router = useRouter();
const { can } = useCan();
const app = useAppStore();

const canManage = can("facilities.manage");

const page = ref(1);
const search = ref("");
const status = ref<"all" | "active" | "inactive">("all");
const sort = ref<"name" | "-name" | "key" | "-key">("name");

function params() {
  return {
    page: page.value,
    search: search.value.trim() || undefined,
    is_active:
      status.value === "all" ? undefined : status.value === "active" ? 1 : 0,
    sort: sort.value,
  };
}

const list = useResource(() => facilitiesService.list(params()));

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

function name(f: Facility) {
  return (locale.value === "ar" ? f.name_i18n?.ar : f.name_i18n?.en) || f.key;
}

const columns = computed<Column[]>(() => [
  {
    key: "name",
    label: t("facilities.title"),
  },
  {
    key: "key",
    label: t("facilities.key"),
    nowrap: true,
  },
  {
    key: "hotels",
    label: t("facilities.hotelsCount"),
    align: "end",
  },
  {
    key: "is_active",
    label: t("facilities.status"),
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

async function toggleActive(f: Facility) {
  if (toggling.value !== null) return;

  toggling.value = f.id;

  try {
    if (f.is_active) {
      await facilitiesService.deactivate(f.id);
    } else {
      await facilitiesService.activate(f.id);
    }

    app.pushToast(
      "success",
      f.is_active ? t("facilities.deactivated") : t("facilities.activated"),
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

const deleting = ref<Facility | null>(null);
const removing = ref(false);

async function confirmDelete() {
  if (!deleting.value || removing.value) return;

  removing.value = true;

  try {
    await facilitiesService.remove(deleting.value.id);

    app.pushToast("success", t("facilities.deleted"));

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

    <PageHeader
      :title="t('facilities.title')"
      :subtitle="t('facilities.subtitle')"
    >
      <template v-if="canManage" #actions>
        <NuxtLink to="/facilities/new" class="btn btn-primary">
          <KtIcon name="plus" />
          <span>{{ t("facilities.new") }}</span>
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
            :placeholder="t('facilities.searchPlaceholder')"
          />
        </div>

        <!-- Status -->

        <FormField
          :label="t('facilities.filterStatus')"
          class="w-full sm:w-auto"
        >
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

        <FormField :label="t('facilities.sortBy')" class="w-full sm:w-auto">
          <select v-model="sort" class="input w-full min-w-44 sm:w-auto">
            <option value="name">
              {{ t("facilities.sortNameAsc") }}
            </option>

            <option value="-name">
              {{ t("facilities.sortNameDesc") }}
            </option>

            <option value="key">
              {{ t("facilities.sortKeyAsc") }}
            </option>

            <option value="-key">
              {{ t("facilities.sortKeyDesc") }}
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
        :empty-title="t('facilities.empty')"
        clickable-rows
        @retry="list.reload"
        @page="changePage"
        @row-click="(row: Facility) => router.push(`/facilities/${row.id}`)"
      >
        <!-- ========================================================= -->
        <!-- Facility -->
        <!-- ========================================================= -->

        <template #cell-name="{ row }">
          <div class="flex min-w-0 items-center gap-3.5">
            <div class="shrink-0">
              <div
                class="flex h-11 w-11 items-center justify-center rounded-xl bg-primary/10 text-primary"
              >
                <KtIcon
                  v-if="(row as Facility).icon"
                  :name="(row as Facility).icon!"
                  class="h-5 w-5"
                />

                <KtIcon v-else name="office-bag" class="h-5 w-5" />
              </div>
            </div>

            <div class="min-w-0">
              <div class="truncate text-sm font-semibold text-foreground">
                {{ name(row as Facility) }}
              </div>

              <div class="mt-0.5 truncate text-xs text-muted-foreground">
                /{{ (row as Facility).key }}
              </div>
            </div>
          </div>
        </template>

        <!-- ========================================================= -->
        <!-- Key -->
        <!-- ========================================================= -->

        <template #cell-key="{ row }">
          <span class="font-mono text-xs text-muted-foreground">
            {{ (row as Facility).key }}
          </span>
        </template>

        <!-- ========================================================= -->
        <!-- Hotels -->
        <!-- ========================================================= -->

        <template #cell-hotels="{ row }">
          <div class="text-end text-sm">
            <span
              v-if="
                (row as Facility).hotels_count !== null &&
                (row as Facility).hotels_count !== undefined
              "
              class="font-medium text-foreground"
            >
              {{ (row as Facility).hotels_count }}
            </span>

            <span v-else class="text-xs text-muted-foreground">
              {{ t("common.notAvailable") }}
            </span>
          </div>
        </template>

        <!-- ========================================================= -->
        <!-- Status -->
        <!-- ========================================================= -->

        <template #cell-is_active="{ row }">
          <StatusBadge
            :label="
              (row as Facility).is_active
                ? t('common.active')
                : t('common.inactive')
            "
            :tone="(row as Facility).is_active ? 'success' : 'neutral'"
          />
        </template>

        <!-- ========================================================= -->
        <!-- Actions -->
        <!-- ========================================================= -->

        <template #cell-actions="{ row }">
          <div class="flex items-center justify-end gap-1" @click.stop>
            <!-- Edit -->

            <NuxtLink
              :to="`/facilities/${(row as Facility).id}/edit`"
              class="btn btn-ghost px-2.5 py-2"
              :title="t('common.edit')"
              @click.stop
            >
              <KtIcon name="pencil" />

              <span class="sr-only">
                {{ t("common.edit") }}
              </span>
            </NuxtLink>

            <!-- Toggle -->

            <button
              type="button"
              class="btn btn-ghost px-2.5 py-2"
              :disabled="toggling === (row as Facility).id"
              :title="
                (row as Facility).is_active
                  ? t('common.deactivate')
                  : t('common.activate')
              "
              @click.stop="toggleActive(row as Facility)"
            >
              <KtIcon
                v-if="toggling === (row as Facility).id"
                name="loading"
                class="animate-spin"
              />

              <KtIcon
                v-else
                :name="(row as Facility).is_active ? 'eye-slash' : 'eye'"
              />

              <span class="sr-only">
                {{
                  (row as Facility).is_active
                    ? t("common.deactivate")
                    : t("common.activate")
                }}
              </span>
            </button>

            <!-- Delete -->

            <button
              type="button"
              class="btn btn-ghost px-2.5 py-2 text-destructive"
              :title="t('common.delete')"
              @click.stop="deleting = row as Facility"
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
          ? t('facilities.deleteConfirm', {
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
