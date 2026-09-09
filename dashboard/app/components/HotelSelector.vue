<script setup lang="ts">
import { ALL_HOTELS } from '~/stores/hotelContext'

const hotelCtx = useHotelContextStore()
const { t } = useI18n()

const label = computed(() => {
  if (hotelCtx.currentScope == null) return t('hotelSelector.selectHotel')
  if (hotelCtx.isAllHotels) return t('hotelSelector.allHotels')
  return hotelCtx.currentHotel?.name ?? t('hotelSelector.selectHotel')
})
</script>

<template>
  <AppDropdown v-if="hotelCtx.availableHotels.length > 0 || hotelCtx.canSelectAllHotels" align="start" width="16rem">
    <template #trigger>
      <button type="button" class="btn btn-secondary max-w-[14rem]">
        <KtIcon name="office-bag" />
        <span class="truncate">{{ label }}</span>
        <KtIcon name="down" class="text-2xs" />
      </button>
    </template>

    <button
      v-if="hotelCtx.canSelectAllHotels"
      type="button"
      class="flex w-full items-center gap-2 rounded-md px-2.5 py-2 text-start text-sm hover:bg-secondary"
      :class="{ 'text-primary font-semibold': hotelCtx.isAllHotels }"
      @click="hotelCtx.setScope(ALL_HOTELS)"
    >
      <KtIcon name="element-11" />
      {{ t('hotelSelector.allHotels') }}
    </button>
    <div v-if="hotelCtx.canSelectAllHotels" class="my-1 h-px bg-border" />
    <button
      v-for="hotel in hotelCtx.availableHotels"
      :key="hotel.id"
      type="button"
      class="flex w-full items-center gap-2 rounded-md px-2.5 py-2 text-start text-sm hover:bg-secondary"
      :class="{ 'text-primary font-semibold': hotelCtx.currentHotelId === hotel.id }"
      @click="hotelCtx.setScope(hotel.id)"
    >
      <KtIcon name="geolocation" />
      <span class="truncate">{{ hotel.name }}</span>
    </button>
  </AppDropdown>
</template>
