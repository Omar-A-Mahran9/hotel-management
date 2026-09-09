<script setup lang="ts">
import { hotelGroupsService, hotelsService } from '~/services'
import type { Hotel } from '~/types/api'

definePageMeta({ permission: 'hotels.manage' })

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const id = Number(route.params.id)

const hotel = useResource(() => hotelsService.get(id))
const groups = useResource(() => hotelGroupsService.list())

function onSaved(saved: Hotel) {
  router.push(`/hotels/${saved.id}`)
}
</script>

<template>
  <div>
    <PageHeader
      :title="hotel.data.value ? t('hotels.editTitleNamed', { name: hotel.data.value.name }) : t('hotels.editTitle')"
      :subtitle="t('hotels.editDesc')"
    >
      <template #actions>
        <NuxtLink :to="`/hotels/${id}`" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <LoadingState v-if="hotel.pending.value" :rows="6" />
    <ErrorState v-else-if="hotel.error.value" :error="hotel.error.value" @retry="hotel.reload" />
    <div v-else-if="hotel.data.value" class="card px-4 sm:px-6">
      <HotelForm
        :hotel="hotel.data.value"
        :groups="groups.data.value ?? []"
        :groups-pending="groups.pending.value"
        @saved="onSaved"
      />
    </div>
  </div>
</template>
