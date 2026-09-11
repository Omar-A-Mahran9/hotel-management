<script setup lang="ts">
import type { Facility } from '~/types/api'

definePageMeta({ permission: 'facilities.manage' })

const { t } = useI18n()
const router = useRouter()

function onSaved(_facility: Facility) {
  router.push('/facilities')
}
</script>

<template>
  <div>
    <PageHeader :title="t('facilities.new')" :subtitle="t('facilities.newDesc')">
      <template #actions>
        <NuxtLink to="/facilities" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <div class="card max-w-2xl p-4 sm:p-6">
      <FacilityForm @saved="onSaved" />
    </div>
  </div>
</template>
