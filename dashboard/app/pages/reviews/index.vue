<script setup lang="ts">
definePageMeta({ permission: 'hotels.view' })
const { t } = useI18n()
</script>

<template>
  <GapListPage
    :title="t('nav.reviews')"
    :subtitle="t('reviewsPage.subtitle')"
    :columns="[t('reviewsPage.guest'), t('reviewsPage.reservation'), t('reviewsPage.rating'), t('reviewsPage.text'), t('reviewsPage.moderation'), t('reviewsPage.created')]"
    :body="t('gap.reviewsBody')"
    :endpoints="['GET /api/v1/hotels/{hotel}/reviews', 'PATCH /api/v1/reviews/{id}/moderate']"
  />
</template>
