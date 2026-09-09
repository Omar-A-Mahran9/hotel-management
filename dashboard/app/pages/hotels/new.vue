<script setup lang="ts">
import { hotelGroupsService } from '~/services'
import type { Hotel } from '~/types/api'

definePageMeta({ permission: 'hotels.manage' })

const { t } = useI18n()
const router = useRouter()

const groups = useResource(() => hotelGroupsService.list())

function onSaved(hotel: Hotel) {
  router.push(`/hotels/${hotel.id}`)
}
</script>

<template>
  <div>
    <PageHeader :title="t('hotels.new')" :subtitle="t('hotels.newDesc')">
      <template #actions>
        <NuxtLink to="/hotels" class="btn btn-secondary">
          <KtIcon name="left" /> {{ t('common.back') }}
        </NuxtLink>
      </template>
    </PageHeader>

    <div class="card px-4 sm:px-6">
      <ErrorState v-if="groups.error.value" :error="groups.error.value" @retry="groups.reload" />
      <HotelForm
        v-else
        :groups="groups.data.value ?? []"
        :groups-pending="groups.pending.value"
        @saved="onSaved"
      />
    </div>
  </div>
</template>
