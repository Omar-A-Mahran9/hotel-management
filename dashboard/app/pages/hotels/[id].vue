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
  ]
})

const locationLine = computed(() => {
  const h = hotel.data.value
  if (!h) return ''
  return [localized(h.city_summary) || h.city, localized(h.country_summary) || h.country]
    .filter(Boolean).join(', ')
})
</script>

<template>
  <div>
    <LoadingState v-if="hotel.pending.value" :rows="4" />
    <ErrorState v-else-if="hotel.error.value" :error="hotel.error.value" @retry="hotel.reload" />
    <template v-else-if="hotel.data.value">
      <div class="mb-5 flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
        <div class="flex items-start gap-4">
          <AppImage :alt="hotel.data.value.name" :name="hotel.data.value.name" size="3.5rem" />
          <div>
            <h1 class="text-xl font-semibold text-foreground">
              {{ hotel.data.value.name }}
            </h1>
            <div class="mt-1 flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
              <StatusBadge
                :label="hotel.data.value.is_active ? t('common.active') : t('common.inactive')"
                :tone="hotel.data.value.is_active ? 'success' : 'neutral'"
              />
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
        <DataCard :title="t('hotels.information')" class="lg:col-span-2">
          <FactGrid :facts="facts" />
        </DataCard>

        <DataCard :title="t('hotels.sectionBranding')">
          <div class="flex items-start gap-3">
            <AppImage :alt="hotel.data.value.name" :name="hotel.data.value.name" size="3rem" />
            <p class="text-2sm text-muted-foreground">
              {{ t('hotels.imagesGapBody') }}
            </p>
          </div>
        </DataCard>
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
