<script setup lang="ts">
import { countriesService } from "~/services";

definePageMeta({ permission: "locations.manage" });

const { t, locale } = useI18n();
const route = useRoute();
const router = useRouter();

const id = Number(route.params.id);

const country = useResource(() => countriesService.get(id));

const title = computed(() => {
  const c = country.data.value;

  if (!c) {
    return t("countries.editTitle");
  }

  const name = (locale.value === "ar" ? c.name_ar : c.name_en) || c.code;

  return t("countries.editTitleNamed", { name });
});

function onSaved() {
  router.push("/countries");
}

function goBack() {
  router.push("/countries");
}
</script>

<template>
  <div class="space-y-5">
    <!-- ============================================================= -->
    <!-- Header -->
    <!-- ============================================================= -->

    <PageHeader :title="title">
      <template #actions>
        <button type="button" class="btn btn-secondary" @click="goBack">
          <KtIcon name="left" />
          <span>{{ t("common.back") }}</span>
        </button>
      </template>
    </PageHeader>

    <!-- ============================================================= -->
    <!-- Loading -->
    <!-- ============================================================= -->

    <LoadingState v-if="country.pending.value" :rows="5" />

    <!-- ============================================================= -->
    <!-- Error -->
    <!-- ============================================================= -->

    <ErrorState
      v-else-if="country.error.value"
      :error="country.error.value"
      @retry="country.reload"
    />

    <!-- ============================================================= -->
    <!-- Form -->
    <!-- ============================================================= -->

    <div v-else-if="country.data.value" class="card overflow-hidden">
      <div class="border-b border-border px-4 py-4 sm:px-5">
        <div class="flex items-center gap-3">
          <div
            class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
          >
            <KtIcon name="globe" />
          </div>

          <div class="min-w-0">
            <h2 class="font-semibold text-foreground">
              {{ title }}
            </h2>

            <p class="mt-0.5 text-2sm text-muted-foreground">
              {{ t("countries.subtitle") }}
            </p>
          </div>
        </div>
      </div>

      <div class="p-4 sm:p-6">
        <CountryForm :country="country.data.value" @saved="onSaved" />
      </div>
    </div>
  </div>
</template>
