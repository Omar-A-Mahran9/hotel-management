<script setup lang="ts">
import { citiesService } from '~/services'

definePageMeta({ permission: 'locations.manage' })

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const id = Number(route.params.id)

const city = useResource(() => citiesService.get(id))

const title = computed(() => {
  const c = city.data.value
  if (!c) return t('cities.editTitle')
  return t('cities.editTitleNamed', { name: locale.value === 'ar' ? c.name_ar : c.name_en })
})

function onSaved() {
  router.push('/cities')
}
</script>

<template>
  <div>
    <PageHeader :title="title">
      <template #actions>
        <NuxtLink to="/cities" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <LoadingState v-if="city.pending.value" :rows="5" />
    <ErrorState v-else-if="city.error.value" :error="city.error.value" @retry="city.reload" />
    <div v-else-if="city.data.value" class="card max-w-2xl p-4 sm:p-6">
      <CityForm :city="city.data.value" @saved="onSaved" />
    </div>
  </div>
</template>
