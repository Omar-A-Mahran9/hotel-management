<script setup lang="ts">
import { facilitiesService } from "~/services";
import type { Facility } from "~/types/api";

definePageMeta({
  permission: "facilities.manage",
});

const { t, locale } = useI18n();
const route = useRoute();
const router = useRouter();

const id = Number(route.params.id);

const facility = useResource(() => facilitiesService.get(id));

const facilityData = computed<Facility | null>(
  () => facility.data.value ?? null,
);

const title = computed(() => {
  const f = facilityData.value;

  if (!f) {
    return t("facilities.editTitle");
  }

  const name =
    (locale.value === "ar" ? f.name_i18n?.ar : f.name_i18n?.en) || f.key;

  return t("facilities.editTitleNamed", { name });
});

const statusLabel = computed(() =>
  facilityData.value?.is_active ? t("common.active") : t("common.inactive"),
);

const statusTone = computed(() =>
  facilityData.value?.is_active ? "success" : "neutral",
);

function onSaved() {
  router.push("/facilities");
}

function goBack() {
  router.push("/facilities");
}
</script>

<template>
  <div class="space-y-5">
    <PageHeader :title="title">
      <template #actions>
        <button type="button" class="btn btn-secondary" @click="goBack">
          <KtIcon name="left" />
          <span>{{ t("common.back") }}</span>
        </button>
      </template>
    </PageHeader>

    <LoadingState v-if="facility.pending.value" :rows="5" />

    <ErrorState
      v-else-if="facility.error.value"
      :error="facility.error.value"
      @retry="facility.reload"
    />

    <template v-else-if="facilityData">
      <div class="grid gap-5 lg:grid-cols-[minmax(0,1fr)_320px]">
        <!-- Main Form -->
        <div class="card overflow-hidden">
          <div class="border-b border-border px-4 py-4 sm:px-5">
            <div class="flex items-center gap-3">
              <div
                class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
              >
                <KtIcon
                  :name="facilityData.icon || 'building'"
                  class="size-5"
                />
              </div>

              <div class="min-w-0">
                <h2 class="font-semibold text-foreground">
                  {{ t("facilities.editTitle") }}
                </h2>

                <p class="mt-0.5 text-2sm text-muted-foreground">
                  {{ t("facilities.subtitle") }}
                </p>
              </div>
            </div>
          </div>

          <div class="p-4 sm:p-6">
            <FacilityForm :facility="facilityData" @saved="onSaved" />
          </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-5">
          <!-- Current Status -->
          <div class="card overflow-hidden">
            <div class="border-b border-border px-4 py-4 sm:px-5">
              <h3 class="font-semibold text-foreground">
                {{ t("facilities.status") }}
              </h3>
            </div>

            <div class="space-y-4 p-4 sm:p-5">
              <div class="flex items-center justify-between gap-3">
                <span class="text-2sm text-muted-foreground">
                  {{ t("facilities.status") }}
                </span>

                <StatusBadge :label="statusLabel" :tone="statusTone" />
              </div>

              <div class="flex items-center justify-between gap-3">
                <span class="text-2sm text-muted-foreground">
                  {{ t("facilities.key") }}
                </span>

                <code
                  class="max-w-[160px] truncate rounded bg-secondary px-2 py-1 font-mono text-xs text-foreground"
                >
                  {{ facilityData.key || "—" }}
                </code>
              </div>

              <div class="flex items-center justify-between gap-3">
                <span class="text-2sm text-muted-foreground">
                  {{ t("facilities.hotelsCount") }}
                </span>

                <span class="font-medium text-foreground">
                  {{ facilityData.hotels_count ?? 0 }}
                </span>
              </div>
            </div>
          </div>

          <!-- Icon Preview -->
          <div class="card overflow-hidden">
            <div class="border-b border-border px-4 py-4 sm:px-5">
              <h3 class="font-semibold text-foreground">
                {{ t("facilities.icon") }}
              </h3>
            </div>

            <div class="flex flex-col items-center justify-center p-6">
              <div
                class="flex size-20 items-center justify-center rounded-2xl bg-primary/10 text-primary"
              >
                <KtIcon
                  :name="facilityData.icon || 'building'"
                  class="size-10"
                />
              </div>

              <p
                v-if="facilityData.icon"
                class="mt-3 font-mono text-xs text-muted-foreground"
              >
                {{ facilityData.icon }}
              </p>

              <p v-else class="mt-3 text-xs text-muted-foreground">—</p>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
