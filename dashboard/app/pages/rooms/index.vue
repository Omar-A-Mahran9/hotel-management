<script setup lang="ts">
import { roomsService, roomTypesService } from "~/services";
import type { Column } from "~/components/DataTable.vue";
import type { Room, RoomStatus } from "~/types/api";
import { ROOM_STATUS_TONE } from "~/utils/reservationStateMachine";
import { ApiError } from "~/utils/apiError";

definePageMeta({ permission: "inventory.view" });

const { t } = useI18n();
const { can } = useCan();
const app = useAppStore();
const hotelCtx = useHotelContextStore();
const route = useRoute();
const router = useRouter();

const canManage = can("inventory.manage");

onMounted(() => {
  const q = Number(route.query.hotel);

  if (Number.isFinite(q) && q > 0) {
    hotelCtx.setScope(q);
  }
});

const hotelId = computed(() => hotelCtx.currentHotelId);

// ---------------------------------------------------------------------
// Room Types
// ---------------------------------------------------------------------

const typeFilter = ref<number | null>(null);

const types = useResource(
  async () => {
    if (hotelId.value == null) return [];

    return roomTypesService.list(hotelId.value);
  },
  { immediate: false },
);

const fetchRoomTypes = () => {
  if (hotelId.value == null) {
    return Promise.resolve([]);
  }

  return roomTypesService.list(hotelId.value);
};

const typeName = (id: number) =>
  (types.data.value ?? []).find((rt) => rt.id === id)?.name ?? `#${id}`;

// ---------------------------------------------------------------------
// Rooms
// ---------------------------------------------------------------------

const list = useResource(
  async () => {
    if (hotelId.value == null) return [];

    return roomsService.list(hotelId.value, typeFilter.value ?? undefined);
  },
  { immediate: false },
);

watch(
  hotelId,
  () => {
    typeFilter.value = null;

    if (hotelId.value != null) {
      types.reload();
      list.reload();
    }
  },
  { immediate: true },
);

watch(typeFilter, () => {
  if (hotelId.value != null) {
    list.reload();
  }
});

// ---------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------

const search = ref("");

const rows = computed<Room[]>(() => {
  const all = list.data.value ?? [];
  const q = search.value.trim().toLowerCase();

  if (!q) {
    return all;
  }

  return all.filter((room) => room.room_number.toLowerCase().includes(q));
});

// ---------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------

const filtersActive = computed(
  () => search.value.trim() !== "" || typeFilter.value !== null,
);

function clearFilters() {
  search.value = "";
  typeFilter.value = null;
}

// ---------------------------------------------------------------------
// Table
// ---------------------------------------------------------------------

const columns = computed<Column[]>(() => [
  {
    key: "room_number",
    label: t("rooms.number"),
  },
  {
    key: "room_type_id",
    label: t("rooms.type"),
  },
  {
    key: "status",
    label: t("rooms.status"),
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
// Create / Edit
// ---------------------------------------------------------------------

const formOpen = ref(false);
const editing = ref<Room | null>(null);
const saving = ref(false);

const fieldErrors = ref<Record<string, string[]>>({});

const form = reactive({
  room_number: "",
  room_type_id: null as number | null,
});

function openCreate() {
  editing.value = null;

  Object.assign(form, {
    room_number: "",
    room_type_id: types.data.value?.[0]?.id ?? null,
  });

  fieldErrors.value = {};
  formOpen.value = true;
}

function openEdit(room: Room) {
  editing.value = room;

  Object.assign(form, {
    room_number: room.room_number,
    room_type_id: room.room_type_id,
  });

  fieldErrors.value = {};
  formOpen.value = true;
}

async function submitForm() {
  if (saving.value || hotelId.value == null || form.room_type_id == null) {
    return;
  }

  saving.value = true;
  fieldErrors.value = {};

  try {
    if (editing.value) {
      await roomsService.update(hotelId.value, editing.value.id, {
        room_number: form.room_number,
        room_type_id: form.room_type_id,
      });

      app.pushToast("success", t("rooms.updated"));
    } else {
      await roomsService.create(hotelId.value, {
        room_number: form.room_number,
        room_type_id: form.room_type_id,
      });

      app.pushToast("success", t("rooms.created"));
    }

    formOpen.value = false;
    list.reload();
  } catch (e) {
    if (e instanceof ApiError && e.kind === "validation" && e.errors) {
      fieldErrors.value = e.errors;
    } else {
      app.pushToast(
        "error",
        e instanceof ApiError ? e.message : t("errors.genericBody"),
      );
    }
  } finally {
    saving.value = false;
  }
}

// ---------------------------------------------------------------------
// Status
// ---------------------------------------------------------------------

const STATUSES: Array<Extract<RoomStatus, "available" | "under_maintenance">> =
  ["available", "under_maintenance"];

const statusEditing = ref<Room | null>(null);

const targetStatus = ref<"available" | "under_maintenance">("available");

const savingStatus = ref(false);
const statusError = ref<string | null>(null);

function openStatus(room: Room) {
  statusEditing.value = room;

  targetStatus.value =
    room.status === "under_maintenance" ? "under_maintenance" : "available";

  statusError.value = null;
}

async function saveStatus() {
  if (!statusEditing.value || savingStatus.value || hotelId.value == null) {
    return;
  }

  savingStatus.value = true;
  statusError.value = null;

  try {
    await roomsService.setStatus(
      hotelId.value,
      statusEditing.value.id,
      targetStatus.value,
    );

    app.pushToast("success", t("rooms.statusChanged"));

    statusEditing.value = null;
    list.reload();
  } catch (e) {
    statusError.value =
      e instanceof ApiError ? e.message : t("errors.genericBody");
  } finally {
    savingStatus.value = false;
  }
}

// Hard delete is intentionally not offered here — the backend exposes no
// DELETE /hotels/{hotel}/rooms/{room} endpoint (rooms move to
// under_maintenance, they are never removed).
</script>

<template>
  <div class="space-y-5">
    <!-- ============================================================= -->
    <!-- Header -->
    <!-- ============================================================= -->

    <PageHeader
      :title="t('rooms.title')"
      :subtitle="
        hotelCtx.currentHotel
          ? t('rooms.subtitle', {
              hotel: hotelCtx.currentHotel.name,
            })
          : ''
      "
    >
      <template v-if="canManage && hotelId != null" #actions>
        <button type="button" class="btn btn-primary" @click="openCreate">
          <KtIcon name="plus" />
          <span>{{ t("rooms.new") }}</span>
        </button>
      </template>
    </PageHeader>

    <!-- ============================================================= -->
    <!-- Hotel Scope -->
    <!-- ============================================================= -->

    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <!-- =========================================================== -->
      <!-- Filters -->
      <!-- =========================================================== -->

      <div class="card overflow-hidden">
        <div
          class="flex flex-col gap-4 border-b border-border px-4 py-4 sm:px-5 lg:flex-row lg:items-end"
        >
          <!-- Search -->

          <div class="w-full lg:max-w-sm lg:flex-1">
            <SearchField
              v-model="search"
              :placeholder="t('rooms.searchPlaceholder')"
            />
          </div>

          <!-- Room Type -->

          <FormField :label="t('rooms.filterByType')" class="w-full sm:w-auto">
            <EntitySelect
              v-model="typeFilter"
              :fetcher="fetchRoomTypes"
              label-key="name"
              :placeholder="t('common.all')"
              :reload-key="hotelId"
              clearable
            />
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

        <!-- Filter Summary -->

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

      <!-- =========================================================== -->
      <!-- Table -->
      <!-- =========================================================== -->

      <div class="card overflow-hidden">
        <DataTable
          :columns="columns"
          :rows="rows"
          :loading="list.pending.value"
          :error="list.error.value"
          :empty-title="t('rooms.empty')"
          clickable-rows
          @retry="list.reload"
          @row-click="(row: Room) => router.push(`/rooms/${row.id}`)"
        >
          <!-- ======================================================= -->
          <!-- Room -->
          <!-- ======================================================= -->

          <template #cell-room_number="{ row }">
            <div class="flex min-w-0 items-center gap-3.5">
              <div class="shrink-0">
                <div
                  class="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary"
                >
                  <KtIcon name="door" class="size-5" />
                </div>
              </div>

              <div class="min-w-0">
                <div class="truncate text-sm font-semibold text-foreground">
                  {{ (row as Room).room_number }}
                </div>
              </div>
            </div>
          </template>

          <!-- ======================================================= -->
          <!-- Room Type -->
          <!-- ======================================================= -->

          <template #cell-room_type_id="{ row }">
            <div class="flex items-center gap-2 text-sm">
              <KtIcon name="bed" class="shrink-0 text-muted-foreground" />

              <span class="truncate">
                {{ typeName((row as Room).room_type_id) }}
              </span>
            </div>
          </template>

          <!-- ======================================================= -->
          <!-- Status -->
          <!-- ======================================================= -->

          <template #cell-status="{ row }">
            <StatusBadge
              :label="t(`status.${(row as Room).status}`)"
              :tone="ROOM_STATUS_TONE[(row as Room).status] ?? 'neutral'"
            />
          </template>

          <!-- ======================================================= -->
          <!-- Actions -->
          <!-- ======================================================= -->

          <template #cell-actions="{ row }">
            <div class="flex items-center justify-end gap-1" @click.stop>
              <!-- Edit -->

              <button
                type="button"
                class="btn btn-ghost px-2.5 py-2"
                :title="t('common.edit')"
                @click.stop="openEdit(row as Room)"
              >
                <KtIcon name="pencil" />

                <span class="sr-only">
                  {{ t("common.edit") }}
                </span>
              </button>

              <button
                type="button"
                class="btn btn-ghost px-2.5 py-2"
                :disabled="(row as Room).status === 'booked'"
                :title="t('rooms.setStatus')"
                @click.stop="openStatus(row as Room)"
              >
                <KtIcon name="check-circle" />

                <span class="sr-only">
                  {{ t("rooms.setStatus") }}
                </span>
              </button>
            </div>
          </template>
        </DataTable>
      </div>
    </template>

    <!-- ============================================================= -->
    <!-- Create / Edit Room -->
    <!-- ============================================================= -->

    <AppModal
      v-model:open="formOpen"
      :title="editing ? t('rooms.editTitle') : t('rooms.new')"
    >
      <form class="space-y-4" novalidate @submit.prevent="submitForm">
        <FormField
          :label="t('rooms.number')"
          :error="fieldErrors.room_number"
          required
        >
          <input v-model="form.room_number" class="input" required />
        </FormField>

        <FormField
          :label="t('rooms.type')"
          :error="fieldErrors.room_type_id"
          required
        >
          <EntitySelect
            v-model="form.room_type_id"
            :fetcher="fetchRoomTypes"
            label-key="name"
            :placeholder="t('rooms.type')"
            :reload-key="hotelId"
            :selected-label="editing ? typeName(editing.room_type_id) : null"
            :invalid="!!fieldErrors.room_type_id"
            required
          />
        </FormField>
      </form>

      <template #footer>
        <button
          type="button"
          class="btn btn-secondary"
          :disabled="saving"
          @click="formOpen = false"
        >
          {{ t("common.cancel") }}
        </button>

        <button
          type="button"
          class="btn btn-primary"
          :disabled="saving"
          @click="submitForm"
        >
          {{ saving ? t("common.saving") : t("common.save") }}
        </button>
      </template>
    </AppModal>

    <!-- ============================================================= -->
    <!-- Change Status -->
    <!-- ============================================================= -->

    <AppModal
      :open="statusEditing !== null"
      :title="t('rooms.setStatus')"
      @update:open="(v) => !v && (statusEditing = null)"
    >
      <div v-if="statusEditing" class="space-y-4">
        <div
          class="flex items-center gap-3 rounded-xl border border-border bg-secondary/40 px-4 py-3"
        >
          <div
            class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
          >
            <KtIcon name="door" />
          </div>

          <div class="min-w-0">
            <div class="text-xs text-muted-foreground">
              {{ t("rooms.number") }}
            </div>

            <div class="truncate font-medium text-foreground">
              {{ statusEditing.room_number }}
            </div>
          </div>
        </div>

        <FormField :label="t('rooms.status')" :error="statusError">
          <select v-model="targetStatus" class="input">
            <option v-for="s in STATUSES" :key="s" :value="s">
              {{ t(`status.${s}`) }}
            </option>
          </select>
        </FormField>

        <p class="text-2xs text-muted-foreground">
          {{ t("rooms.statusMachineNote") }}
        </p>
      </div>

      <template #footer>
        <button
          type="button"
          class="btn btn-secondary"
          :disabled="savingStatus"
          @click="statusEditing = null"
        >
          {{ t("common.cancel") }}
        </button>

        <button
          type="button"
          class="btn btn-primary"
          :disabled="savingStatus"
          @click="saveStatus"
        >
          {{ savingStatus ? t("common.saving") : t("common.save") }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
