<script setup lang="ts">
definePageMeta({ permission: 'locations.manage' })

const { t } = useI18n()
const router = useRouter()

function onSaved() {
  router.push('/cities')
}

function goBack() {
  router.push('/cities')
}
</script>

<template>
  <div class="space-y-6">
    <!-- Page Header -->
    <PageHeader
      :title="t('cities.new')"
      :subtitle="t('cities.newDesc')"
    >
      <template #actions>
        <button
          type="button"
          class="btn btn-secondary"
          @click="goBack"
        >
          <KtIcon name="left" />
          <span>{{ t('common.back') }}</span>
        </button>
      </template>
    </PageHeader>

    <!-- Form -->
    <div class="card overflow-hidden">
      <div class="mx-auto w-full max-w-3xl p-5 sm:p-6 lg:p-8">
        <CityForm @saved="onSaved" />
      </div>
    </div>
  </div>
</template>
