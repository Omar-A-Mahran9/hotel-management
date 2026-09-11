<script setup lang="ts">
import { hotelGroupsService, hotelsService } from "~/services";

definePageMeta({ permission: "hotels.view" });

const { t, locale } = useI18n();
const route = useRoute();
const { can } = useCan();

const id = Number(route.params.id);

const canManage = can("hotels.manage");
const canManageGroups = can("hotel-groups.manage");

const localized = (
  value?: {
    name_en?: string | null;
    name_ar?: string | null;
  } | null,
) => {
  if (!value) return null;

  return locale.value === "ar"
    ? value.name_ar || value.name_en || null
    : value.name_en || value.name_ar || null;
};

const localizedText = (
  value?: {
    en?: string | null;
    ar?: string | null;
  } | null,
) => {
  if (!value) return null;

  return locale.value === "ar"
    ? value.ar || value.en || null
    : value.en || value.ar || null;
};

/* -------------------------------------------------------------------------- */
/* Hotel                                                                      */
/* -------------------------------------------------------------------------- */

const hotel = useResource(() => hotelsService.get(id));

const hotelData = computed(() => hotel.data.value);

/* -------------------------------------------------------------------------- */
/* Hotel Group                                                                */
/* -------------------------------------------------------------------------- */

const group = useResource(
  async () => {
    const h = hotelData.value;

    if (!h?.hotel_group_id || !canManageGroups) {
      return null;
    }

    return hotelGroupsService.get(h.hotel_group_id);
  },
  {
    immediate: false,
  },
);

watch(
  () => hotelData.value?.hotel_group_id,
  (groupId) => {
    if (groupId && canManageGroups) {
      group.reload();
    }
  },
  {
    immediate: true,
  },
);

/* -------------------------------------------------------------------------- */
/* Localized content                                                          */
/* -------------------------------------------------------------------------- */

const description = computed(() =>
  localizedText(hotelData.value?.description_i18n),
);

const tagline = computed(() => localizedText(hotelData.value?.tagline_i18n));

const metaTitle = computed(() =>
  localizedText(hotelData.value?.meta_title_i18n),
);

const metaDescription = computed(() =>
  localizedText(hotelData.value?.meta_description_i18n),
);

const locationLine = computed(() => {
  const h = hotelData.value;

  if (!h) return "";

  return [
    localized(h.city_summary) || h.city,
    localized(h.country_summary) || h.country,
  ]
    .filter(Boolean)
    .join(", ");
});

const facilityName = (facility: {
  key: string;
  name_i18n?: {
    en?: string | null;
    ar?: string | null;
  };
}) => localizedText(facility.name_i18n) || facility.key;

/* -------------------------------------------------------------------------- */
/* Facts                                                                      */
/* -------------------------------------------------------------------------- */

const facts = computed(() => {
  const h = hotelData.value;

  if (!h) return [];

  return [
    {
      label: t("hotels.city"),
      value: localized(h.city_summary) || h.city || t("common.notAvailable"),
    },
    {
      label: t("hotels.country"),
      value:
        localized(h.country_summary) || h.country || t("common.notAvailable"),
    },
    {
      label: t("hotels.timezone"),
      value: h.timezone || t("common.notAvailable"),
    },
    {
      label: t("hotels.slug"),
      value: h.slug || t("common.notAvailable"),
    },
    {
      label: t("hotels.group"),
      value:
        group.data.value?.name ||
        (h.hotel_group_id ? `#${h.hotel_group_id}` : t("common.notAvailable")),
    },
    {
      label: t("hotels.starRating"),
      value: h.star_rating
        ? t("hotels.starRatingValue", {
            count: h.star_rating,
          })
        : t("hotels.starRatingNone"),
    },
  ];
});

/* -------------------------------------------------------------------------- */
/* Management modules                                                         */
/* -------------------------------------------------------------------------- */

const modules = computed(() => {
  const h = hotelData.value;

  if (!h) return [];

  const items = [];

  if (can("inventory.view")) {
    items.push(
      {
        to: `/room-types?hotel=${h.id}`,
        title: t("nav.roomTypes"),
        description: t("overview.roomTypes"),
        icon: "cube-2",
      },
      {
        to: `/rooms?hotel=${h.id}`,
        title: t("nav.rooms"),
        description: t("overview.rooms"),
        icon: "home-2",
      },
    );
  }

  if (can("reservations.view")) {
    items.push({
      to: `/reservations?hotel=${h.id}`,
      title: t("nav.reservations"),
      description: t("overview.reservationsTotal"),
      icon: "calendar-tick",
    });
  }

  if (can("services.view")) {
    items.push({
      to: `/services?hotel=${h.id}`,
      title: t("nav.services"),
      description: t("overview.services"),
      icon: "parcel",
    });
  }

  return items;
});
</script>

<template>
  <div class="space-y-6">
    <!-- ================================================================== -->
    <!-- Loading                                                             -->
    <!-- ================================================================== -->

    <LoadingState v-if="hotel.pending.value" :rows="7" />

    <ErrorState
      v-else-if="hotel.error.value"
      :error="hotel.error.value"
      @retry="hotel.reload"
    />

    <template v-else-if="hotelData">
      <!-- ================================================================ -->
      <!-- Top navigation                                                    -->
      <!-- ================================================================ -->

      <div class="flex items-center justify-between gap-3">
        <NuxtLink
          to="/hotels"
          class="inline-flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-foreground"
        >
          <KtIcon name="left" />
          {{ t("common.back") }}
        </NuxtLink>

        <NuxtLink
          v-if="canManage"
          :to="`/hotels/${id}/edit`"
          class="btn btn-primary"
        >
          <KtIcon name="pencil" />
          {{ t("common.edit") }}
        </NuxtLink>
      </div>

      <!-- ================================================================ -->
      <!-- Hotel Hero                                                        -->
      <!-- ================================================================ -->

      <section
        class="relative overflow-hidden rounded-2xl border border-border bg-card"
      >
        <!-- Cover -->

        <div class="relative h-52 overflow-hidden bg-secondary sm:h-64 lg:h-80">
          <img
            v-if="hotelData.cover?.url"
            :src="hotelData.cover.url"
            :alt="hotelData.name"
            class="h-full w-full object-cover"
          />

          <div v-else class="flex h-full items-center justify-center">
            <KtIcon name="picture" class="text-4xl text-muted-foreground" />
          </div>

          <!-- Subtle overlay -->

          <div
            class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/10 to-transparent"
          />

          <!-- Status -->

          <div class="absolute start-5 top-5 flex flex-wrap gap-2">
            <StatusBadge
              :label="
                hotelData.is_active ? t('common.active') : t('common.inactive')
              "
              :tone="hotelData.is_active ? 'success' : 'neutral'"
            />

            <StatusBadge
              v-if="hotelData.seo_indexable"
              :label="t('hotels.indexable')"
              tone="success"
            />
          </div>

          <!-- Hotel name on image -->

          <div
            class="absolute inset-x-5 bottom-5 text-white sm:inset-x-6 sm:bottom-6"
          >
            <div class="flex items-end gap-4">
              <div
                class="hidden h-16 w-16 shrink-0 overflow-hidden rounded-xl border border-white/30 bg-white shadow-lg sm:flex sm:items-center sm:justify-center"
              >
                <AppImage
                  :alt="hotelData.name"
                  :name="hotelData.name"
                  :src="hotelData.logo?.url"
                  size="3.75rem"
                />
              </div>

              <div class="min-w-0">
                <div class="flex flex-wrap items-center gap-3">
                  <h1
                    class="truncate text-2xl font-bold tracking-tight sm:text-3xl"
                  >
                    {{ hotelData.name }}
                  </h1>

                  <div
                    v-if="hotelData.star_rating"
                    class="inline-flex items-center gap-1 rounded-full bg-black/30 px-2.5 py-1 text-sm font-semibold backdrop-blur-sm"
                  >
                    <KtIcon name="star" />
                    {{ hotelData.star_rating }}
                  </div>
                </div>

                <p
                  v-if="tagline"
                  class="mt-1 max-w-2xl text-sm text-white/80 sm:text-base"
                >
                  {{ tagline }}
                </p>

                <div
                  v-if="locationLine"
                  class="mt-2 flex items-center gap-1.5 text-sm text-white/75"
                >
                  <KtIcon name="geolocation" />
                  {{ locationLine }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Hotel summary -->

        <div
          class="grid divide-y divide-border sm:grid-cols-3 sm:divide-x sm:divide-y-0"
        >
          <div class="px-5 py-4 sm:px-6">
            <p class="text-xs font-medium text-muted-foreground">
              {{ t("hotels.starRating") }}
            </p>

            <div class="mt-1 flex items-center gap-2">
              <KtIcon name="star" class="text-warning" />

              <span class="text-sm font-semibold">
                {{ hotelData.star_rating || t("hotels.starRatingNone") }}
              </span>
            </div>
          </div>

          <div class="px-5 py-4 sm:px-6">
            <p class="text-xs font-medium text-muted-foreground">
              {{ t("hotels.group") }}
            </p>

            <p class="mt-1 truncate text-sm font-semibold">
              {{
                group.data.value?.name ||
                (hotelData.hotel_group_id
                  ? `#${hotelData.hotel_group_id}`
                  : t("common.notAvailable"))
              }}
            </p>
          </div>

          <div class="px-5 py-4 sm:px-6">
            <p class="text-xs font-medium text-muted-foreground">
              {{ t("hotels.timezone") }}
            </p>

            <p class="mt-1 truncate text-sm font-semibold">
              {{ hotelData.timezone || t("common.notAvailable") }}
            </p>
          </div>
        </div>
      </section>

      <!-- ================================================================ -->
      <!-- Management Modules                                                -->
      <!-- ================================================================ -->

      <section v-if="modules.length">
        <div class="mb-3">
          <h2 class="text-base font-semibold text-foreground">
            {{ t("common.management") }}
          </h2>

          <p class="mt-0.5 text-sm text-muted-foreground">
            {{ t("common.quickActions") }}
          </p>
        </div>

        <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <NuxtLink
            v-for="module in modules"
            :key="module.to"
            :to="module.to"
            class="group relative overflow-hidden rounded-xl border border-border bg-card p-4 transition-all hover:-translate-y-0.5 hover:border-primary/40 hover:shadow-sm"
          >
            <div class="flex items-start justify-between">
              <div
                class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary transition-colors group-hover:bg-primary group-hover:text-primary-foreground"
              >
                <KtIcon :name="module.icon" />
              </div>

              <KtIcon
                name="right"
                class="text-muted-foreground transition-transform group-hover:translate-x-0.5 group-hover:text-primary"
              />
            </div>

            <p class="mt-4 text-sm font-semibold text-foreground">
              {{ module.title }}
            </p>

            <p class="mt-1 text-xs text-muted-foreground">
              {{ module.description }}
            </p>
          </NuxtLink>
        </div>
      </section>

      <!-- ================================================================ -->
      <!-- Main content                                                      -->
      <!-- ================================================================ -->

      <div class="grid gap-6 lg:grid-cols-3">
        <!-- ============================================================ -->
        <!-- Left / Main                                                    -->
        <!-- ============================================================ -->

        <div class="space-y-6 lg:col-span-2">
          <!-- Hotel Information -->

          <DataCard :title="t('hotels.information')">
            <FactGrid :facts="facts" />
          </DataCard>

          <!-- Description -->

          <DataCard v-if="description" :title="t('hotels.sectionContent')">
            <div class="max-w-4xl text-sm leading-7 text-muted-foreground">
              {{ description }}
            </div>
          </DataCard>

          <!-- Facilities -->

          <DataCard :title="t('hotels.facilitiesLabel')">
            <div
              v-if="hotelData.facilities?.length"
              class="grid gap-2 sm:grid-cols-2 lg:grid-cols-3"
            >
              <div
                v-for="facility in hotelData.facilities"
                :key="facility.id"
                class="flex items-center gap-2.5 rounded-lg border border-border bg-secondary/20 px-3 py-2.5"
              >
                <div
                  class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md bg-background text-muted-foreground"
                >
                  <KtIcon v-if="facility.icon" :name="facility.icon" />

                  <KtIcon v-else name="check" />
                </div>

                <span class="text-sm font-medium text-foreground">
                  {{ facilityName(facility) }}
                </span>
              </div>
            </div>

            <div
              v-else
              class="rounded-lg border border-dashed border-border px-4 py-6 text-center"
            >
              <KtIcon
                name="information-2"
                class="text-xl text-muted-foreground"
              />

              <p class="mt-2 text-sm text-muted-foreground">
                {{ t("hotels.facilitiesNone") }}
              </p>
            </div>
          </DataCard>

          <!-- Gallery -->

          <DataCard :title="t('hotels.media.gallery')">
            <div
              v-if="hotelData.gallery?.length"
              class="grid grid-cols-2 gap-3 sm:grid-cols-3"
            >
              <div
                v-for="(media, index) in hotelData.gallery"
                :key="media.id"
                class="group relative overflow-hidden rounded-xl border border-border bg-secondary"
                :class="{
                  'sm:col-span-2 sm:row-span-2': index === 0,
                }"
              >
                <img
                  :src="media.url"
                  :alt="`${hotelData.name} ${index + 1}`"
                  class="h-full min-h-32 w-full object-cover transition-transform duration-300 group-hover:scale-105"
                />

                <div
                  class="pointer-events-none absolute inset-0 bg-gradient-to-t from-black/30 to-transparent opacity-0 transition-opacity group-hover:opacity-100"
                />
              </div>
            </div>

            <div
              v-else
              class="flex min-h-40 items-center justify-center rounded-xl border border-dashed border-border"
            >
              <div class="text-center">
                <KtIcon name="picture" class="text-2xl text-muted-foreground" />

                <p class="mt-2 text-sm text-muted-foreground">
                  {{ t("hotels.media.galleryEmpty") }}
                </p>
              </div>
            </div>
          </DataCard>
        </div>

        <!-- ============================================================ -->
        <!-- Right sidebar                                                  -->
        <!-- ============================================================ -->

        <aside class="space-y-6">
          <!-- Brand -->

          <DataCard :title="t('hotels.sectionBranding')">
            <div class="space-y-4">
              <div>
                <p class="mb-2 text-xs font-medium text-muted-foreground">
                  {{ t("hotels.media.logo") }}
                </p>

                <div
                  class="flex h-28 items-center justify-center rounded-xl border border-border bg-secondary/30"
                >
                  <AppImage
                    :alt="hotelData.name"
                    :name="hotelData.name"
                    :src="hotelData.logo?.url"
                    shape="square"
                    size="5.5rem"
                  />
                </div>
              </div>

              <div>
                <div class="mb-2 flex items-center justify-between">
                  <p class="text-xs font-medium text-muted-foreground">
                    {{ t("hotels.media.cover") }}
                  </p>
                </div>

                <div
                  class="overflow-hidden rounded-xl border border-border bg-secondary"
                >
                  <img
                    v-if="hotelData.cover?.url"
                    :src="hotelData.cover.url"
                    :alt="hotelData.name"
                    class="aspect-video w-full object-cover"
                  />

                  <div
                    v-else
                    class="flex aspect-video items-center justify-center"
                  >
                    <KtIcon
                      name="picture"
                      class="text-2xl text-muted-foreground"
                    />
                  </div>
                </div>
              </div>
            </div>
          </DataCard>

          <!-- SEO -->

          <DataCard :title="t('hotels.sectionSeo')">
            <div class="space-y-4">
              <div>
                <p class="text-xs font-medium text-muted-foreground">
                  {{ t("hotels.metaTitle") }}
                </p>

                <p class="mt-1 text-sm font-medium text-foreground">
                  {{ metaTitle || hotelData.name }}
                </p>
              </div>

              <div>
                <p class="text-xs font-medium text-muted-foreground">URL</p>

                <div class="mt-1 rounded-lg bg-secondary/50 px-3 py-2">
                  <code class="break-all text-xs text-muted-foreground">
                    /hotels/{{ hotelData.slug }}
                  </code>
                </div>
              </div>

              <div>
                <p class="text-xs font-medium text-muted-foreground">
                  {{ t("hotels.metaDescription") }}
                </p>

                <p class="mt-1 text-xs leading-5 text-muted-foreground">
                  {{
                    metaDescription ||
                    description ||
                    t("hotels.seoPreviewFallbackDescription")
                  }}
                </p>
              </div>

              <div class="border-t border-border pt-3">
                <StatusBadge
                  v-if="hotelData.seo_indexable"
                  :label="t('hotels.indexable')"
                  tone="success"
                />

                <StatusBadge
                  v-else
                  :label="t('common.inactive')"
                  tone="warning"
                />
              </div>
            </div>
          </DataCard>

          <!-- Technical -->

          <DataCard :title="t('hotels.information')">
            <div class="space-y-3">
              <div class="flex items-center justify-between gap-4">
                <span class="text-xs text-muted-foreground"> ID </span>

                <span class="text-sm font-medium text-foreground">
                  #{{ hotelData.id }}
                </span>
              </div>

              <div class="flex items-center justify-between gap-4">
                <span class="text-xs text-muted-foreground">
                  {{ t("hotels.slug") }}
                </span>

                <span
                  class="max-w-[60%] truncate text-xs font-medium text-foreground"
                >
                  {{ hotelData.slug }}
                </span>
              </div>

              <div class="flex items-center justify-between gap-4">
                <span class="text-xs text-muted-foreground">
                  {{ t("common.status") }}
                </span>

                <StatusBadge
                  :label="
                    hotelData.is_active
                      ? t('common.active')
                      : t('common.inactive')
                  "
                  :tone="hotelData.is_active ? 'success' : 'neutral'"
                />
              </div>
            </div>
          </DataCard>
        </aside>
      </div>
    </template>
  </div>
</template>
