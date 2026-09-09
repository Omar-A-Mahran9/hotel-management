<script setup lang="ts">
definePageMeta({ permission: 'folio.view' })
const { t } = useI18n()
const router = useRouter()

const resId = ref('')
function open() {
  const id = Number(resId.value)
  if (Number.isFinite(id) && id > 0) router.push(`/reservations/${id}?tab=folio`)
}
</script>

<template>
  <div>
    <PageHeader :title="t('nav.folio')" :subtitle="t('folioPage.subtitle')" />

    <div class="grid gap-6 lg:grid-cols-3">
      <DataCard :title="t('common.lookUp')">
        <form class="space-y-3" @submit.prevent="open">
          <FormField :label="t('folioPage.lookupLabel')" :hint="t('folioPage.lookupHint')">
            <input v-model="resId" type="number" min="1" class="input" inputmode="numeric">
          </FormField>
          <button type="submit" class="btn btn-primary" :disabled="!resId">
            <KtIcon name="book-open" /> {{ t('folioPage.open') }}
          </button>
        </form>
      </DataCard>

      <div class="lg:col-span-2">
        <UnavailablePanel
          :body="t('gap.folioBody')"
          :endpoints="['GET /api/v1/hotels/{hotel}/folios', 'GET /api/v1/folios?outstanding=1']"
          alternative-to="/reservations"
          :alternative-label="t('nav.reservations')"
        />
      </div>
    </div>
  </div>
</template>
