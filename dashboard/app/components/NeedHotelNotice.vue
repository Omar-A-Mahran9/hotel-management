<script setup lang="ts">
const { t } = useI18n()
</script>

<template>
  <div class="card p-10 text-center">
    <div class="mx-auto flex size-12 items-center justify-center rounded-full bg-primary/12 text-primary">
      <KtIcon name="geolocation" />
    </div>
    <h2 class="mt-3 text-base font-semibold text-foreground">
      {{ t('hotelSelector.needHotel') }}
    </h2>
    <p class="mx-auto mt-1 max-w-sm text-sm text-muted-foreground">
      {{ t('hotelSelector.needHotelBody') }}
    </p>
  </div>
</template>
