<script setup lang="ts">
import { facilitiesService } from '~/services'

definePageMeta({ permission: 'facilities.manage' })

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const id = Number(route.params.id)

const facility = useResource(() => facilitiesService.get(id))

const title = computed(() => {
  const f = facility.data.value
  if (!f) return t('facilities.editTitle')
  const name = (locale.value === 'ar' ? f.name_i18n.ar : f.name_i18n.en) || f.key
  return t('facilities.editTitleNamed', { name })
})

function onSaved() {
  router.push('/facilities')
}
</script>

<template>
  <div>
    <PageHeader :title="title">
      <template #actions>
        <NuxtLink to="/facilities" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <LoadingState v-if="facility.pending.value" :rows="5" />
    <ErrorState v-else-if="facility.error.value" :error="facility.error.value" @retry="facility.reload" />
    <div v-else-if="facility.data.value" class="card max-w-2xl p-4 sm:p-6">
      <FacilityForm :facility="facility.data.value" @saved="onSaved" />
    </div>
  </div>
</template>
