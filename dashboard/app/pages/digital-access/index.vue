<script setup lang="ts">
definePageMeta({ permission: 'check-in.perform' })
const { t } = useI18n()
</script>

<template>
  <GapListPage
    :title="t('nav.digitalAccess')"
    :subtitle="t('digitalAccessPage.subtitle')"
    :columns="[t('digitalAccessPage.reservation'), t('digitalAccessPage.guest'), t('digitalAccessPage.accessStatus'), t('digitalAccessPage.mode'), t('digitalAccessPage.expires'), t('common.actions')]"
    :body="t('gap.digitalAccessBody')"
    :endpoints="['GET /api/v1/hotels/{hotel}/arrivals', 'GET /api/v1/hotels/{hotel}/departures', 'GET /api/v1/hotels/{hotel}/in-house']"
    :note="t('digitalAccessPage.workspaceNote')"
    alternative-to="/reservations"
    :alternative-label="t('nav.reservations')"
  />
</template>
