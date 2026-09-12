<script setup lang="ts">
import { facilitiesService, roomTypeMediaService, roomTypesService } from "~/services";
import type { Column } from "~/components/DataTable.vue";
import type { Facility, RoomType } from "~/types/api";
import { ApiError } from "~/utils/apiError";

definePageMeta({ permission: "inventory.view" });

const { t, locale } = useI18n();
const { can } = useCan();
const app = useAppStore();
const hotelCtx = useHotelContextStore();
const route = useRoute();

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

const list = useResource(
  async () => {
    if (hotelId.value == null) return [];

    return roomTypesService.list(hotelId.value);
  },
  { immediate: false },
);

watch(
  hotelId,
  () => {
    if (hotelId.value != null) {
      list.reload();
    }
  },
  { immediate: true },
);

// ---------------------------------------------------------------------
// Facilities
// ---------------------------------------------------------------------

const facilitiesList = useResource(() => facilitiesService.pickerOptions());

const pickerFacilities = computed<Facility[]>(() => {
  return facilitiesList.data.value ?? [];
});

const facilityName = (f: Facility) => {
  return (locale.value === "ar" ? f.name_i18n.ar : f.name_i18n.en) || f.key;
};

function toggleFacility(key: string) {
  const index = form.amenities.indexOf(key);

  if (index === -1) {
    form.amenities.push(key);
  } else {
    form.amenities.splice(index, 1);
  }
}

// ---------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------

const search = ref("");

const rows = computed<RoomType[]>(() => {
  const all = list.data.value ?? [];
  const q = search.value.trim().toLowerCase();

  return q ? all.filter((rt) => rt.name.toLowerCase().includes(q)) : all;
});

const hasFilters = computed(() => {
  return search.value.trim() !== "";
});

function clearFilters() {
  search.value = "";
}

// ---------------------------------------------------------------------
// Table
// ---------------------------------------------------------------------

const columns = computed<Column[]>(() => [
  {
    key: "name",
    label: t("roomTypes.name"),
  },
  {
    key: "base_price",
    label: t("roomTypes.basePrice"),
    align: "end",
  },
  {
    key: "capacity",
    label: t("roomTypes.capacity"),
    align: "end",
  },
  {
    key: "rooms_count",
    label: t("roomTypes.rooms"),
    align: "end",
  },
  {
    key: "available_rooms_count",
    label: t("roomTypes.available"),
    align: "end",
  },
  {
    key: "is_active",
    label: t("roomTypes.status"),
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
// Form
// ---------------------------------------------------------------------

const open = ref(false);
const editing = ref<RoomType | null>(null);
const saving = ref(false);

const fieldErrors = ref<Record<string, string[]>>({});

const form = reactive({
  name: "",
  base_price: "",
  capacity: 1,
  amenities: [] as string[],
  description: "",
  is_active: true,
});

// Photos: create-flow stages files locally until the room type has an id
// (see RoomMediaUploader); edit-flow uploads immediately. `formInstanceKey`
// forces a fresh uploader instance per modal open, so staged files never
// leak between a cancelled create and the next one.
interface MediaUploaderHandle {
  commitStaged: (ownerId: number) => Promise<boolean>;
  hasStaged: boolean;
}
const mediaUploaderRef = ref<MediaUploaderHandle | null>(null);
const formInstanceKey = ref(0);

async function reloadEditingPhotos() {
  if (!editing.value || hotelId.value == null) return;

  try {
    const fresh = await roomTypesService.get(hotelId.value, editing.value.id);
    editing.value = fresh;
    list.reload();
  } catch {
    // Best effort — the media itself already changed on the server.
  }
}

function resetForm() {
  Object.assign(form, {
    name: "",
    base_price: "",
    capacity: 1,
    amenities: [],
    description: "",
    is_active: true,
  });

  fieldErrors.value = {};
}

function openCreate() {
  editing.value = null;

  resetForm();

  formInstanceKey.value++;
  open.value = true;
}

function openEdit(rt: RoomType) {
  editing.value = rt;

  Object.assign(form, {
    name: rt.name,
    base_price: rt.base_price,
    capacity: rt.capacity,
    amenities: [...(rt.amenities ?? [])],
    description: rt.description ?? "",
    is_active: rt.is_active,
  });

  fieldErrors.value = {};

  formInstanceKey.value++;
  open.value = true;
}

// ---------------------------------------------------------------------
// Save
// ---------------------------------------------------------------------

async function submit() {
  if (saving.value || hotelId.value == null) {
    return;
  }

  saving.value = true;
  fieldErrors.value = {};

  const body: Record<string, unknown> = {
    name: form.name,
    base_price: form.base_price,
    capacity: form.capacity,
    amenities: form.amenities.length ? form.amenities : null,
    description: form.description || null,
  };

  try {
    if (editing.value) {
      await roomTypesService.update(hotelId.value, editing.value.id, body);

      app.pushToast("success", t("roomTypes.updated"));
    } else {
      const created = await roomTypesService.create(hotelId.value, {
        ...body,
        is_active: form.is_active,
      });

      if (mediaUploaderRef.value?.hasStaged) {
        const allOk = await mediaUploaderRef.value.commitStaged(created.id);
        if (!allOk) app.pushToast("error", t("media.someUploadsFailed"));
      }

      app.pushToast("success", t("roomTypes.created"));
    }

    open.value = false;
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

const toggling = ref<number | null>(null);

async function toggleActive(rt: RoomType) {
  if (toggling.value != null || hotelId.value == null) {
    return;
  }

  toggling.value = rt.id;

  try {
    if (rt.is_active) {
      await roomTypesService.deactivate(hotelId.value, rt.id);
    } else {
      await roomTypesService.activate(hotelId.value, rt.id);
    }

    app.pushToast(
      "success",
      rt.is_active ? t("roomTypes.deactivated") : t("roomTypes.activated"),
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
</script>

<template>
  <div class="space-y-5">
    <!-- Header -->
    <PageHeader
      :title="t('roomTypes.title')"
      :subtitle="
        hotelCtx.currentHotel
          ? t('roomTypes.subtitle', {
              hotel: hotelCtx.currentHotel.name,
            })
          : ''
      "
    >
      <template v-if="canManage && hotelId != null" #actions>
        <button type="button" class="btn btn-primary" @click="openCreate">
          <KtIcon name="plus" />
          <span>{{ t("roomTypes.new") }}</span>
        </button>
      </template>
    </PageHeader>

    <!-- Hotel Scope -->
    <NeedHotelNotice v-if="hotelId == null" />

    <template v-else>
      <!-- Filters -->
      <div class="card overflow-hidden">
        <div
          class="flex flex-col gap-4 border-b border-border px-4 py-4 sm:px-5 lg:flex-row lg:items-end"
        >
          <div class="w-full lg:max-w-sm lg:flex-1">
            <SearchField
              v-model="search"
              :hint="t('common.clientFilterNote')"
            />
          </div>

          <button
            v-if="hasFilters"
            type="button"
            class="btn btn-secondary shrink-0"
            @click="clearFilters"
          >
            <KtIcon name="close" />
            <span>{{ t("common.clear") }}</span>
          </button>
        </div>

        <div
          v-if="hasFilters"
          class="flex flex-wrap items-center gap-x-3 gap-y-1 bg-secondary/40 px-4 py-3 text-2sm text-muted-foreground sm:px-5"
        >
          <span class="font-medium text-foreground">
            {{ t("common.filters") }}
          </span>

          <span v-if="search">
            {{ search }}
          </span>
        </div>
      </div>

      <!-- Table -->
      <div class="card overflow-hidden">
        <DataTable
          :columns="columns"
          :rows="rows"
          :loading="list.pending.value"
          :error="list.error.value"
          @retry="list.reload"
        >
          <!-- Room Type -->
          <template #cell-name="{ row }">
            <div class="flex min-w-0 items-center gap-3.5">
              <div
                class="flex size-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
              >
                <KtIcon name="bed" class="size-5" />
              </div>

              <div class="min-w-0">
                <div class="truncate font-medium text-foreground">
                  {{ (row as RoomType).name }}
                </div>
              </div>
            </div>
          </template>

          <!-- Base Price -->
          <template #cell-base_price="{ row }">
            <span class="font-medium text-foreground">
              {{ (row as RoomType).base_price }}
            </span>
          </template>

          <!-- Capacity -->
          <template #cell-capacity="{ row }">
            {{ (row as RoomType).capacity }}
          </template>

          <!-- Rooms -->
          <template #cell-rooms_count="{ row }">
            {{ (row as RoomType).rooms_count ?? t("common.notAvailable") }}
          </template>

          <!-- Available -->
          <template #cell-available_rooms_count="{ row }">
            {{
              (row as RoomType).available_rooms_count ??
              t("common.notAvailable")
            }}
          </template>

          <!-- Status -->
          <template #cell-is_active="{ row }">
            <StatusBadge
              :label="
                (row as RoomType).is_active
                  ? t('common.active')
                  : t('common.inactive')
              "
              :tone="(row as RoomType).is_active ? 'success' : 'neutral'"
            />
          </template>

          <!-- Actions -->
          <template #cell-actions="{ row }">
            <div class="flex items-center justify-end gap-1" @click.stop>
              <button
                type="button"
                class="btn btn-ghost px-2.5 py-2"
                @click="openEdit(row as RoomType)"
              >
                <KtIcon name="pencil" />

                <span class="sr-only">
                  {{ t("common.edit") }}
                </span>
              </button>

              <button
                type="button"
                class="btn btn-ghost px-2.5 py-2"
                :disabled="toggling === (row as RoomType).id"
                @click="toggleActive(row as RoomType)"
              >
                <KtIcon
                  :name="(row as RoomType).is_active ? 'eye-slash' : 'eye'"
                />

                <span class="sr-only">
                  {{
                    (row as RoomType).is_active
                      ? t("common.deactivate")
                      : t("common.activate")
                  }}
                </span>
              </button>
            </div>
          </template>
        </DataTable>
      </div>
    </template>

    <!-- Create / Edit Modal -->
    <AppModal
      v-model:open="open"
      :title="editing ? t('roomTypes.editTitle') : t('roomTypes.new')"
    >
      <form class="space-y-4" novalidate @submit.prevent="submit">
        <!-- Name -->
        <FormField
          :label="t('roomTypes.name')"
          :error="fieldErrors.name"
          required
        >
          <input v-model="form.name" class="input" required />
        </FormField>

        <!-- Price / Capacity -->
        <div class="grid gap-4 sm:grid-cols-2">
          <FormField
            :label="t('roomTypes.basePrice')"
            :error="fieldErrors.base_price"
            required
          >
            <input
              v-model="form.base_price"
              type="text"
              inputmode="decimal"
              class="input"
              required
            />
          </FormField>

          <FormField
            :label="t('roomTypes.capacity')"
            :error="fieldErrors.capacity"
            required
          >
            <input
              v-model.number="form.capacity"
              type="number"
              min="1"
              class="input"
              required
            />
          </FormField>
        </div>

        <!-- Facilities -->
        <FormField
          :label="t('roomTypes.amenities')"
          :hint="t('roomTypes.amenitiesHint')"
          :error="fieldErrors.amenities"
        >
          <p
            v-if="facilitiesList.pending.value"
            class="text-2sm text-muted-foreground"
          >
            {{ t("common.loading") }}
          </p>

          <p
            v-else-if="!pickerFacilities.length"
            class="text-2sm text-muted-foreground"
          >
            {{ t("hotels.facilitiesEmptyOptions") }}
          </p>

          <div v-else class="flex flex-wrap gap-2">
            <button
              v-for="f in pickerFacilities"
              :key="f.id"
              type="button"
              class="rounded-full border px-3 py-1.5 text-2sm transition-colors"
              :class="[
                form.amenities.includes(f.key)
                  ? 'border-primary bg-primary/10 text-primary'
                  : 'border-border text-muted-foreground hover:bg-secondary',
                !f.is_active && 'opacity-60',
              ]"
              :aria-pressed="form.amenities.includes(f.key)"
              :disabled="saving"
              @click="toggleFacility(f.key)"
            >
              <KtIcon v-if="f.icon" :name="f.icon" />

              {{ facilityName(f) }}
            </button>
          </div>
        </FormField>

        <!-- Description -->
        <FormField
          :label="t('roomTypes.description')"
          :error="fieldErrors.description"
        >
          <textarea
            v-model="form.description"
            rows="3"
            class="input resize-y"
          />
        </FormField>

        <!-- Photos -->
        <div class="border-t border-border pt-4">
          <RoomMediaUploader
            :key="formInstanceKey"
            ref="mediaUploaderRef"
            :owner-id="editing?.id ?? null"
            :gallery="editing?.photos"
            :upload="
              (id: number, file: File) =>
                roomTypeMediaService.upload(hotelId!, id, file)
            "
            :remove="
              (id: number, mediaId: number) =>
                roomTypeMediaService.remove(hotelId!, id, mediaId)
            "
            :reorder="
              (id: number, ids: number[]) =>
                roomTypeMediaService.reorderGallery(hotelId!, id, ids)
            "
            @changed="reloadEditingPhotos"
          />
        </div>

        <!-- Active -->
        <div
          v-if="!editing"
          class="flex items-center justify-between gap-4 rounded-xl border border-border px-4 py-4"
        >
          <div class="min-w-0">
            <div class="text-sm font-medium text-foreground">
              {{ t("common.active") }}
            </div>
          </div>

          <button
            type="button"
            role="switch"
            :aria-checked="form.is_active"
            :disabled="saving"
            class="relative inline-flex h-6 w-11 shrink-0 rounded-full border-2 border-transparent transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
            :class="form.is_active ? 'bg-primary' : 'bg-muted'"
            @click="form.is_active = !form.is_active"
          >
            <span class="sr-only">
              {{ t("common.active") }}
            </span>

            <span
              class="pointer-events-none block size-5 rounded-full bg-white shadow-sm transition-transform duration-200"
              :class="
                form.is_active
                  ? 'translate-x-5 rtl:-translate-x-5'
                  : 'translate-x-0'
              "
            />
          </button>
        </div>
      </form>

      <!-- Footer -->
      <template #footer>
        <button
          type="button"
          class="btn btn-secondary"
          :disabled="saving"
          @click="open = false"
        >
          {{ t("common.cancel") }}
        </button>

        <button
          type="button"
          class="btn btn-primary"
          :disabled="saving"
          @click="submit"
        >
          {{ saving ? t("common.saving") : t("common.save") }}
        </button>
      </template>
    </AppModal>
  </div>
</template>
