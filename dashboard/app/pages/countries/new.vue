<script setup lang="ts">
import type { Country } from '~/types/api'

definePageMeta({ permission: 'locations.manage' })

const { t } = useI18n()
const router = useRouter()

function onSaved(_country: Country) {
  router.push('/countries')
}
</script>

<template>
  <div>
    <PageHeader :title="t('countries.new')" :subtitle="t('countries.newDesc')">
      <template #actions>
        <NuxtLink to="/countries" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <div class="card max-w-2xl p-4 sm:p-6">
      <CountryForm @saved="onSaved" />
    </div>
  </div>
</template>
