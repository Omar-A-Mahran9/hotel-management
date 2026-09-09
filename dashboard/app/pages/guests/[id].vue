<script setup lang="ts">
definePageMeta({ permission: 'reservations.view' })
const { t } = useI18n()
const route = useRoute()
</script>

<template>
  <div>
    <PageHeader :title="`${t('guestsPage.name')} #${route.params.id}`" :subtitle="t('guestsPage.profile')">
      <template #actions>
        <NuxtLink to="/guests" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <div class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('guestsPage.contact')" class="lg:col-span-2">
        <UnavailablePanel
          :body="t('gap.guestsBody')"
          :endpoints="['GET /api/v1/guests/{id}']"
        />
      </DataCard>
      <DataCard :title="t('guestsPage.history')">
        <UnavailablePanel
          :body="t('gap.guestsBody')"
          :endpoints="['GET /api/v1/guests/{id}/reservations']"
        />
      </DataCard>
    </div>
  </div>
</template>
