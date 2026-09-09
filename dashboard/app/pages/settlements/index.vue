<script setup lang="ts">
definePageMeta({ permission: 'checkout.perform' })
const { t } = useI18n()
</script>

<template>
  <GapListPage
    :title="t('nav.settlements')"
    :subtitle="t('settlementsPage.subtitle')"
    :columns="[t('settlementsPage.date'), t('settlementsPage.reservation'), t('settlementsPage.amount'), t('settlementsPage.settlementStatus'), t('settlementsPage.reference')]"
    :body="t('gap.settlementsBody')"
    :endpoints="['GET /api/v1/hotels/{hotel}/settlements', 'GET /api/v1/settlements?from=&to=']"
  />
</template>
