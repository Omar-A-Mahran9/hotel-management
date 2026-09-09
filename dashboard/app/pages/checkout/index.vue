<script setup lang="ts">
definePageMeta({ permission: 'checkout.perform' })
const { t } = useI18n()
const router = useRouter()

const resId = ref('')
function open() {
  const id = Number(resId.value)
  if (Number.isFinite(id) && id > 0) router.push(`/reservations/${id}?tab=checkout`)
}
</script>

<template>
  <div>
    <PageHeader :title="t('nav.checkout')" :subtitle="t('checkoutPage.subtitle')" />

    <div class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('common.lookUp')">
        <form class="space-y-3" @submit.prevent="open">
          <FormField :label="t('checkoutPage.lookupLabel')">
            <input v-model="resId" type="number" min="1" class="input" inputmode="numeric">
          </FormField>
          <button type="submit" class="btn btn-primary" :disabled="!resId">
            <KtIcon name="exit-right-corner" /> {{ t('checkoutPage.open') }}
          </button>
        </form>
      </DataCard>

      <div class="lg:col-span-2">
        <UnavailablePanel
          :body="t('gap.checkoutBody')"
          :endpoints="['GET /api/v1/hotels/{hotel}/departures', 'GET /api/v1/checkouts?status=awaiting_settlement']"
          alternative-to="/reservations"
          :alternative-label="t('nav.reservations')"
        />
      </div>
    </div>
  </div>
</template>
