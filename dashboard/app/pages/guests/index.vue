<script setup lang="ts">
definePageMeta({ permission: 'reservations.view' })
const { t } = useI18n()
</script>

<template>
  <GapListPage
    :title="t('nav.guests')"
    :subtitle="t('guestsPage.contact')"
    :columns="[t('guestsPage.name'), t('guestsPage.email'), t('guestsPage.phone'), t('guestsPage.reservations'), t('guestsPage.lastStay'), t('common.actions')]"
    :body="t('gap.guestsBody')"
    :endpoints="['GET /api/v1/guests', 'GET /api/v1/guests/{id}', 'GET /api/v1/guests/{id}/reservations']"
  />
</template>
