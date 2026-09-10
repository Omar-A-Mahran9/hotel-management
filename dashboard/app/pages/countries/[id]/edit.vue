<script setup lang="ts">
import { countriesService } from '~/services'

definePageMeta({ permission: 'locations.manage' })

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const id = Number(route.params.id)

const country = useResource(() => countriesService.get(id))

const title = computed(() => {
  const c = country.data.value
  if (!c) return t('countries.editTitle')
  return t('countries.editTitleNamed', { name: locale.value === 'ar' ? c.name_ar : c.name_en })
})

function onSaved() {
  router.push('/countries')
}
</script>

<template>
  <div>
    <PageHeader :title="title">
      <template #actions>
        <NuxtLink to="/countries" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <LoadingState v-if="country.pending.value" :rows="5" />
    <ErrorState v-else-if="country.error.value" :error="country.error.value" @retry="country.reload" />
    <div v-else-if="country.data.value" class="card max-w-2xl p-4 sm:p-6">
      <CountryForm :country="country.data.value" @saved="onSaved" />
    </div>
  </div>
</template>
