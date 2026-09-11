<script setup lang="ts">
import type { Facility } from "~/types/api";
import { facilitiesService } from "~/services";
import { ApiError } from "~/utils/apiError";

const props = defineProps<{ facility?: Facility | null }>();

const emit = defineEmits<{
  saved: [facility: Facility];
}>();

const { t } = useI18n();
const app = useAppStore();
const router = useRouter();

const isEdit = computed(() => !!props.facility);

interface FormState {
  key: string;
  name_en: string;
  name_ar: string;
  icon: string;
  is_active: boolean;
}

function snapshot(f?: Facility | null): FormState {
  return {
    key: f?.key ?? "",
    name_en: f?.name_i18n?.en ?? "",
    name_ar: f?.name_i18n?.ar ?? "",
    icon: f?.icon ?? "",
    is_active: f?.is_active ?? true,
  };
}

const form = reactive<FormState>(snapshot(props.facility));

let initial = JSON.stringify(form);

watch(
  () => props.facility,
  (f) => {
    Object.assign(form, snapshot(f));
    initial = JSON.stringify(form);
  },
);

const dirty = computed(() => JSON.stringify(form) !== initial);

const saving = ref(false);

const fieldErrors = ref<Record<string, string[]>>({});

/**
 * Available facility icons.
 *
 * Make sure these names exist in your KtIcon registry.
 */
const facilityIcons = [
  "wifi",
  "pool",
  "restaurant",
  "coffee",
  "parking",
  "gym",
  "spa",
  "bed",
  "air-conditioning",
  "tv",
  "washing-machine",
  "elevator",
  "security",
  "bell",
  "office-bag",
  "building",
];

function selectIcon(icon: string) {
  form.icon = icon;
}

function clearIcon() {
  form.icon = "";
}

async function save() {
  if (saving.value) return;

  saving.value = true;
  fieldErrors.value = {};

  try {
    const name_i18n: Record<string, string> = {};

    if (form.name_en.trim()) {
      name_i18n.en = form.name_en.trim();
    }

    if (form.name_ar.trim()) {
      name_i18n.ar = form.name_ar.trim();
    }

    let facility: Facility;

    if (props.facility) {
      /*
       * is_active is toggled through its own action,
       * not included in the update payload.
       */
      facility = await facilitiesService.update(props.facility.id, {
        key: form.key || undefined,
        name_i18n,
        icon: form.icon || null,
      });

      if (form.is_active !== props.facility.is_active) {
        facility = form.is_active
          ? await facilitiesService.activate(props.facility.id)
          : await facilitiesService.deactivate(props.facility.id);
      }
    } else {
      facility = await facilitiesService.create({
        key: form.key || undefined,
        name_i18n,
        icon: form.icon || null,
        is_active: form.is_active,
      });
    }

    initial = JSON.stringify(form);

    app.pushToast(
      "success",
      isEdit.value ? t("facilities.updated") : t("facilities.created"),
    );

    emit("saved", facility);
  } catch (e) {
    if (e instanceof ApiError && e.kind === "validation" && e.errors) {
      fieldErrors.value = e.errors;

      app.pushToast("error", t("errors.validationTitle"));
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

function cancel() {
  router.push("/facilities");
}

onBeforeRouteLeave(() => {
  if (dirty.value && !saving.value) {
    return window.confirm(t("common.unsavedLeave"));
  }
});
</script>

<template>
  <form class="space-y-6" novalidate @submit.prevent="save">
    <!-- Names -->
    <div class="grid gap-4 sm:grid-cols-2">
      <FormField
        for-id="f-name-en"
        :label="t('facilities.nameEn')"
        :error="fieldErrors['name_i18n.en']"
        required
      >
        <input
          id="f-name-en"
          v-model="form.name_en"
          class="input"
          autocomplete="off"
          required
        />
      </FormField>

      <FormField
        for-id="f-name-ar"
        :label="t('facilities.nameAr')"
        :error="fieldErrors['name_i18n.ar']"
        :hint="t('facilities.nameArHint')"
      >
        <input
          id="f-name-ar"
          v-model="form.name_ar"
          class="input"
          dir="rtl"
          autocomplete="off"
        />
      </FormField>
    </div>

    <!-- Key -->
    <FormField
      for-id="f-key"
      :label="t('facilities.key')"
      :error="fieldErrors.key"
      :hint="t('facilities.keyHint')"
    >
      <input
        id="f-key"
        v-model="form.key"
        class="input font-mono"
        autocomplete="off"
        placeholder="free_wifi"
      />
    </FormField>

    <!-- Icon -->
    <FormField
      for-id="f-icon"
      :label="t('facilities.icon')"
      :error="fieldErrors.icon"
      :hint="t('facilities.iconHint')"
    >
      <div class="space-y-3">
        <!-- Selected Icon Preview -->
        <div
          class="flex items-center justify-between gap-4 rounded-xl border border-border bg-secondary/20 p-3"
        >
          <div class="flex min-w-0 items-center gap-3">
            <div
              class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border border-border bg-card text-primary"
            >
              <KtIcon :name="form.icon || 'office-bag'" class="h-5 w-5" />
            </div>

            <div class="min-w-0">
              <p class="truncate text-sm font-semibold text-foreground">
                {{ form.icon || t("facilities.icon") }}
              </p>

              <p class="mt-0.5 text-xs text-muted-foreground">
                {{ t("facilities.iconHint") }}
              </p>
            </div>
          </div>

          <!-- Clear -->
          <button
            v-if="form.icon"
            type="button"
            class="btn btn-sm btn-secondary shrink-0"
            :disabled="saving"
            @click="clearIcon"
          >
            <KtIcon name="cross" class="h-4 w-4" />

            <span class="hidden sm:inline">
              {{ t("common.clear") }}
            </span>
          </button>
        </div>

        <!-- Icon Grid -->
        <div class="rounded-xl border border-border bg-card p-3">
          <div class="grid grid-cols-4 gap-2 sm:grid-cols-6 md:grid-cols-8">
            <button
              v-for="icon in facilityIcons"
              :key="icon"
              type="button"
              :title="icon"
              :aria-label="icon"
              :aria-pressed="form.icon === icon"
              :disabled="saving"
              class="group relative flex aspect-square items-center justify-center rounded-xl border transition-all duration-150 focus:outline-none focus:ring-2 focus:ring-primary/30 disabled:cursor-not-allowed disabled:opacity-50"
              :class="
                form.icon === icon
                  ? 'border-primary bg-primary/10 text-primary shadow-sm ring-2 ring-primary/20'
                  : 'border-transparent bg-secondary/40 text-muted-foreground hover:border-border hover:bg-secondary hover:text-foreground'
              "
              @click="selectIcon(icon)"
            >
              <KtIcon
                :name="icon"
                class="h-5 w-5 transition-transform duration-150 group-hover:scale-110"
              />

              <!-- Selected indicator -->
              <span
                v-if="form.icon === icon"
                class="absolute -end-1 -top-1 flex h-4 w-4 items-center justify-center rounded-full bg-primary text-primary-foreground"
              >
                <KtIcon name="check" class="h-2.5 w-2.5" />
              </span>
            </button>
          </div>
        </div>

        <!-- Custom Icon -->
        <details class="group">
          <summary
            class="flex cursor-pointer list-none items-center gap-2 text-xs font-medium text-muted-foreground transition-colors hover:text-foreground"
          >
            <KtIcon name="settings" class="h-3.5 w-3.5" />

            <span>
              {{ t("facilities.iconCustom") }}
            </span>

            <KtIcon
              name="down"
              class="ms-auto h-3.5 w-3.5 transition-transform duration-200 group-open:rotate-180"
            />
          </summary>

          <div class="mt-3">
            <input
              id="f-icon"
              v-model="form.icon"
              class="input font-mono"
              autocomplete="off"
              placeholder="wifi"
              :disabled="saving"
            />
          </div>
        </details>
      </div>
    </FormField>

    <!-- Active -->
    <div
      class="flex items-center justify-between gap-4 rounded-xl border border-border bg-secondary/20 p-4"
    >
      <div class="flex min-w-0 items-center gap-3">
        <div
          class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl transition-colors"
          :class="
            form.is_active
              ? 'bg-success/10 text-success'
              : 'bg-secondary text-muted-foreground'
          "
        >
          <KtIcon :name="form.is_active ? 'check' : 'pause'" class="h-5 w-5" />
        </div>

        <div class="min-w-0">
          <p class="text-sm font-semibold text-foreground">
            {{ t("common.active") }}
          </p>

          <p class="mt-0.5 text-xs leading-5 text-muted-foreground">
            {{ t("facilities.activeHint") }}
          </p>
        </div>
      </div>

      <!-- Switch -->
      <button
        type="button"
        role="switch"
        :aria-checked="form.is_active"
        :disabled="saving"
        class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors focus:outline-none focus:ring-2 focus:ring-primary/30 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
        :class="form.is_active ? 'bg-success' : 'bg-muted-foreground/30'"
        @click="form.is_active = !form.is_active"
      >
        <span
          class="pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow-sm transition-transform duration-200"
          :class="
            form.is_active
              ? 'translate-x-5 rtl:-translate-x-5'
              : 'translate-x-0'
          "
        />
      </button>
    </div>

    <!-- Actions -->
    <div
      class="flex flex-col-reverse gap-3 border-t border-border pt-5 sm:flex-row sm:items-center sm:justify-end"
    >
      <!-- Dirty State -->
      <span
        v-if="dirty"
        class="me-auto flex items-center gap-1.5 text-xs text-muted-foreground"
      >
        <span class="h-1.5 w-1.5 rounded-full bg-warning" />

        {{ t("common.unsavedChanges") }}
      </span>

      <button
        type="button"
        class="btn btn-secondary"
        :disabled="saving"
        @click="cancel"
      >
        {{ t("common.cancel") }}
      </button>

      <button type="submit" class="btn btn-primary min-w-28" :disabled="saving">
        <KtIcon v-if="saving" name="loading" class="h-4 w-4 animate-spin" />

        {{
          saving
            ? t("common.saving")
            : isEdit
              ? t("common.save")
              : t("facilities.createAction")
        }}
      </button>
    </div>
  </form>
</template>
