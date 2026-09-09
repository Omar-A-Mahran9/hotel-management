<script setup lang="ts">
definePageMeta({ permission: 'loyalty.view' })
const { t } = useI18n()
</script>

<template>
  <GapListPage
    :title="t('nav.loyalty')"
    :subtitle="t('loyaltyPage.subtitle')"
    :columns="[t('loyaltyPage.guest'), t('loyaltyPage.balance'), t('loyaltyPage.lastActivity'), t('common.actions')]"
    :body="t('gap.loyaltyBody')"
    :endpoints="['GET /api/v1/guests/{id}/loyalty', 'GET /api/v1/guests/{id}/loyalty/transactions']"
    :note="t('loyaltyPage.workspaceNote')"
    alternative-to="/hotel-group"
    :alternative-label="t('hotelGroup.loyaltyRule')"
  />
</template>
