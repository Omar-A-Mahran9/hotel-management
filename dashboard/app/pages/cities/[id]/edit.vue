<script setup lang="ts">
import { citiesService } from "~/services";

definePageMeta({ permission: "locations.manage" });

const { t, locale } = useI18n();
const route = useRoute();
const router = useRouter();

const id = Number(route.params.id);

const city = useResource(() => citiesService.get(id));

const title = computed(() => {
  const c = city.data.value;

  if (!c) {
    return t("cities.editTitle");
  }

  const name = (locale.value === "ar" ? c.name_ar : c.name_en) || String(c.id);

  return t("cities.editTitleNamed", { name });
});

function onSaved() {
  router.push("/cities");
}

function goBack() {
  router.push("/cities");
}
</script>

<template>
  <div class="space-y-6">
    <!-- Page Header -->
    <PageHeader :title="title">
      <template #actions>
        <button type="button" class="btn btn-secondary" @click="goBack">
          <KtIcon name="left" />
          <span>{{ t("common.back") }}</span>
        </button>
      </template>
    </PageHeader>

    <!-- Loading -->
    <LoadingState v-if="city.pending.value" :rows="5" />

    <!-- Error -->
    <ErrorState
      v-else-if="city.error.value"
      :error="city.error.value"
      @retry="city.reload"
    />

    <!-- Edit Form -->
    <div v-else-if="city.data.value" class="card overflow-hidden">
      <div class="mx-auto w-full max-w-3xl p-5 sm:p-6 lg:p-8">
        <CityForm :city="city.data.value" @saved="onSaved" />
      </div>
    </div>
  </div>
</template>
