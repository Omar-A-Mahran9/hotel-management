<script setup lang="ts">
definePageMeta({ permission: 'payments.manage' })
const { t } = useI18n()
</script>

<template>
  <GapListPage
    :title="t('nav.payments')"
    :subtitle="t('paymentsPage.subtitle')"
    :columns="[t('paymentsPage.reservation'), t('paymentsPage.amount'), t('paymentsPage.currency'), t('paymentsPage.paymentStatus'), t('paymentsPage.provider'), t('paymentsPage.reference'), t('paymentsPage.created')]"
    :body="t('gap.paymentsBody')"
    :endpoints="['GET /api/v1/hotels/{hotel}/payments', 'GET /api/v1/payments?status=&hotel_id=&from=&to=']"
    alternative-to="/reservations"
    :alternative-label="t('nav.reservations')"
  />
</template>
