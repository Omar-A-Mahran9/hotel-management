<script setup lang="ts">
definePageMeta({ permission: 'invoice.view' })
const { t } = useI18n()
const router = useRouter()

const resId = ref('')
function open() {
  const id = Number(resId.value)
  if (Number.isFinite(id) && id > 0) router.push(`/reservations/${id}?tab=invoice`)
}
</script>

<template>
  <div>
    <PageHeader :title="t('nav.invoices')" :subtitle="t('invoicesPage.subtitle')">
      <template #actions>
        <form class="flex items-end gap-2" @submit.prevent="open">
          <FormField :label="t('invoicesPage.lookupLabel')">
            <input v-model="resId" type="number" min="1" class="input w-32" inputmode="numeric">
          </FormField>
          <button type="submit" class="btn btn-secondary" :disabled="!resId">
            {{ t('invoicesPage.open') }}
          </button>
        </form>
      </template>
    </PageHeader>

    <div class="card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="table-base">
          <thead>
            <tr>
              <th>{{ t('invoicesPage.number') }}</th>
              <th>{{ t('invoicesPage.reservation') }}</th>
              <th>{{ t('invoicesPage.hotel') }}</th>
              <th>{{ t('invoicesPage.invoiceStatus') }}</th>
              <th class="text-end">
                {{ t('invoicesPage.subtotal') }}
              </th>
              <th class="text-end">
                {{ t('invoicesPage.outstanding') }}
              </th>
              <th>{{ t('invoicesPage.issued') }}</th>
            </tr>
          </thead>
        </table>
      </div>
      <UnavailablePanel
        :body="t('gap.invoicesBody')"
        :endpoints="['GET /api/v1/hotels/{hotel}/invoices', 'GET /api/v1/invoices?status=issued']"
        alternative-to="/reservations"
        :alternative-label="t('nav.reservations')"
      />
    </div>
  </div>
</template>
