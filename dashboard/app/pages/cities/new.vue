<script setup lang="ts">
definePageMeta({ permission: 'locations.manage' })

const { t } = useI18n()
const router = useRouter()

function onSaved() {
  router.push('/cities')
}
</script>

<template>
  <div>
    <PageHeader :title="t('cities.new')" :subtitle="t('cities.newDesc')">
      <template #actions>
        <NuxtLink to="/cities" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <div class="card max-w-2xl p-4 sm:p-6">
      <CityForm @saved="onSaved" />
    </div>
  </div>
</template>
