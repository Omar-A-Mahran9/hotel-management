<script setup lang="ts">
definePageMeta({ permission: 'notifications.view' })
const { t } = useI18n()
</script>

<template>
  <GapListPage
    :title="t('nav.notifications')"
    :subtitle="t('notificationsPage.subtitle')"
    :columns="[t('notificationsPage.type'), t('notificationsPage.channel'), t('notificationsPage.notificationStatus'), t('notificationsPage.created'), t('notificationsPage.read')]"
    :body="t('gap.notificationsBody')"
    :endpoints="['GET /api/v1/notifications', 'GET /api/v1/hotels/{hotel}/notifications', 'POST /api/v1/notifications/read-all']"
    :note="t('notificationsPage.workspaceNote')"
    alternative-to="/reservations"
    :alternative-label="t('nav.reservations')"
  />
</template>
