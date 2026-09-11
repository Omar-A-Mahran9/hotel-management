<script setup lang="ts">
import { hotelGroupsService, hotelsService } from '~/services'

definePageMeta({ permission: 'hotels.view' })

const { t, locale } = useI18n()
const route = useRoute()
const { can } = useCan()
const id = Number(route.params.id)
const canManage = can('hotels.manage')

const localized = (s?: { name_en: string, name_ar: string } | null) =>
  s ? (locale.value === 'ar' ? s.name_ar : s.name_en) : null

const hotel = useResource(() => hotelsService.get(id))

const group = useResource(async () => {
  const h = hotel.data.value
  if (!h || !can('hotel-groups.manage')) return null
  return hotelGroupsService.get(h.hotel_group_id)
}, { immediate: false })

watch(() => hotel.data.value, (h) => {
  if (h && can('hotel-groups.manage')) group.reload()
})

const facts = computed(() => {
  const h = hotel.data.value
  if (!h) return []
  return [
    { label: t('hotels.city'), value: localized(h.city_summary) || h.city || t('common.notAvailable') },
    { label: t('hotels.country'), value: localized(h.country_summary) || h.country || t('common.notAvailable') },
    { label: t('hotels.timezone'), value: h.timezone || t('common.notAvailable') },
    { label: t('hotels.slug'), value: h.slug },
    { label: t('hotels.group'), value: group.data.value?.name ?? `#${h.hotel_group_id}` },
    { label: t('hotels.starRating'), value: h.star_rating ? t('hotels.starRatingValue', { count: h.star_rating }) : t('hotels.starRatingNone') },
  ]
})

const description = computed(() => {
  const h = hotel.data.value
  if (!h) return null
  return locale.value === 'ar' ? (h.description_i18n?.ar ?? null) : (h.description_i18n?.en ?? null)
})

const tagline = computed(() => {
  const h = hotel.data.value
  if (!h) return null
  return locale.value === 'ar' ? (h.tagline_i18n?.ar ?? null) : (h.tagline_i18n?.en ?? null)
})

const locationLine = computed(() => {
  const h = hotel.data.value
  if (!h) return ''
  return [localized(h.city_summary) || h.city, localized(h.country_summary) || h.country]
    .filter(Boolean).join(', ')
})

const facilityName = (f: { name_i18n: { en?: string | null, ar?: string | null }, key: string }) =>
  (locale.value === 'ar' ? f.name_i18n.ar : f.name_i18n.en) || f.key

const metaTitle = computed(() => {
  const h = hotel.data.value
  if (!h) return null
  return locale.value === 'ar' ? (h.meta_title_i18n?.ar ?? null) : (h.meta_title_i18n?.en ?? null)
})
const metaDescription = computed(() => {
  const h = hotel.data.value
  if (!h) return null
  return locale.value === 'ar' ? (h.meta_description_i18n?.ar ?? null) : (h.meta_description_i18n?.en ?? null)
})
</script>

<template>
  <div>
    <LoadingState v-if="hotel.pending.value" :rows="4" />
    <ErrorState v-else-if="hotel.error.value" :error="hotel.error.value" @retry="hotel.reload" />
    <template v-else-if="hotel.data.value">
      <div
        v-if="hotel.data.value.cover"
        class="mb-5 h-40 w-full overflow-hidden rounded-xl border border-border sm:h-56"
      >
        <img :src="hotel.data.value.cover.url" alt="" class="h-full w-full object-cover">
      </div>

      <div class="mb-5 flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
        <div class="flex items-start gap-4">
          <AppImage
            :alt="hotel.data.value.name"
            :name="hotel.data.value.name"
            :src="hotel.data.value.logo?.url"
            size="3.5rem"
          />
          <div>
            <h1 class="text-xl font-semibold text-foreground">
              {{ hotel.data.value.name }}
            </h1>
            <p v-if="tagline" class="text-sm text-muted-foreground">
              {{ tagline }}
            </p>
            <div class="mt-1 flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
              <StatusBadge
                :label="hotel.data.value.is_active ? t('common.active') : t('common.inactive')"
                :tone="hotel.data.value.is_active ? 'success' : 'neutral'"
              />
              <span v-if="!hotel.data.value.seo_indexable" class="inline-flex">
                <StatusBadge :label="t('hotels.indexable')" tone="warning" />
              </span>
              <span v-if="locationLine">·</span>
              <span v-if="locationLine">{{ locationLine }}</span>
            </div>
          </div>
        </div>
        <div class="flex shrink-0 items-center gap-2">
          <NuxtLink v-if="canManage" :to="`/hotels/${id}/edit`" class="btn btn-secondary">
            <KtIcon name="pencil" /> {{ t('common.edit') }}
          </NuxtLink>
          <NuxtLink to="/hotels" class="btn btn-secondary">
            <KtIcon name="left" /> {{ t('common.back') }}
          </NuxtLink>
        </div>
      </div>

      <div class="grid gap-6 lg:grid-cols-3">
        <div class="space-y-6 lg:col-span-2">
          <DataCard :title="t('hotels.information')">
            <FactGrid :facts="facts" />
          </DataCard>

          <DataCard v-if="description" :title="t('hotels.sectionContent')">
            <p class="text-sm text-foreground">
              {{ description }}
            </p>
          </DataCard>

          <DataCard :title="t('hotels.facilitiesLabel')">
            <p v-if="!hotel.data.value.facilities?.length" class="text-2sm text-muted-foreground">
              {{ t('hotels.facilitiesNone') }}
            </p>
            <div v-else class="flex flex-wrap gap-2">
              <span
                v-for="f in hotel.data.value.facilities"
                :key="f.id"
                class="inline-flex items-center gap-1.5 rounded-full border border-border px-3 py-1.5 text-2sm text-foreground"
              >
                <KtIcon v-if="f.icon" :name="f.icon" class="text-muted-foreground" />
                {{ facilityName(f) }}
              </span>
            </div>
          </DataCard>

          <DataCard :title="t('hotels.media.gallery')">
            <p v-if="!hotel.data.value.gallery?.length" class="text-2sm text-muted-foreground">
              {{ t('hotels.media.galleryEmpty') }}
            </p>
            <ul v-else class="grid gap-3 sm:grid-cols-3">
              <li v-for="m in hotel.data.value.gallery" :key="m.id" class="overflow-hidden rounded-lg border border-border">
                <img :src="m.url" alt="" class="aspect-video w-full object-cover">
              </li>
            </ul>
          </DataCard>
        </div>

        <div class="space-y-6">
          <DataCard :title="t('hotels.sectionBranding')">
            <div class="grid grid-cols-2 gap-3">
              <div>
                <p class="mb-1 text-2xs font-medium text-muted-foreground">
                  {{ t('hotels.media.logo') }}
                </p>
                <AppImage
                  :alt="hotel.data.value.name"
                  :name="hotel.data.value.name"
                  :src="hotel.data.value.logo?.url"
                  shape="square"
                  size="4rem"
                />
              </div>
              <div>
                <p class="mb-1 text-2xs font-medium text-muted-foreground">
                  {{ t('hotels.media.cover') }}
                </p>
                <div class="flex h-16 items-center justify-center overflow-hidden rounded-lg border border-border bg-secondary">
                  <img v-if="hotel.data.value.cover" :src="hotel.data.value.cover.url" alt="" class="h-full w-full object-cover">
                  <KtIcon v-else name="picture" class="text-muted-foreground" />
                </div>
              </div>
            </div>
          </DataCard>

          <DataCard :title="t('hotels.sectionSeo')">
            <p class="truncate text-2sm font-medium text-primary">
              {{ metaTitle || hotel.data.value.name }}
            </p>
            <p class="truncate text-2xs text-muted-foreground">
              /hotels/{{ hotel.data.value.slug }}
            </p>
            <p class="mt-1 line-clamp-2 text-2xs text-muted-foreground">
              {{ metaDescription || description || t('hotels.seoPreviewFallbackDescription') }}
            </p>
            <div class="mt-3">
              <StatusBadge
                :label="hotel.data.value.seo_indexable ? t('hotels.indexable') : t('common.inactive')"
                :tone="hotel.data.value.seo_indexable ? 'success' : 'warning'"
              />
            </div>
          </DataCard>
        </div>
      </div>

      <div class="mt-6 flex flex-wrap gap-3">
        <PermissionGate permission="inventory.view">
          <NuxtLink :to="`/room-types?hotel=${hotel.data.value.id}`" class="btn btn-secondary">
            <KtIcon name="cube-2" /> {{ t('nav.roomTypes') }}
          </NuxtLink>
          <NuxtLink :to="`/rooms?hotel=${hotel.data.value.id}`" class="btn btn-secondary">
            <KtIcon name="home-2" /> {{ t('nav.rooms') }}
          </NuxtLink>
        </PermissionGate>
        <PermissionGate permission="services.view">
          <NuxtLink :to="`/services?hotel=${hotel.data.value.id}`" class="btn btn-secondary">
            <KtIcon name="parcel" /> {{ t('nav.services') }}
          </NuxtLink>
        </PermissionGate>
      </div>
    </template>
  </div>
</template>
