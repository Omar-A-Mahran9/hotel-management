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

      <DataCard :title="t('checkoutPage.shortcuts')" class="lg:col-span-2">
        <div class="flex flex-col gap-3 p-4 sm:p-5">
          <NuxtLink to="/digital-access?tab=departures" class="flex items-center gap-3 rounded-lg border border-border p-3 transition-colors hover:bg-secondary/60">
            <div class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
              <KtIcon name="exit-left" />
            </div>
            <div class="min-w-0">
              <div class="font-medium text-foreground">
                {{ t('nav.digitalAccess') }}
              </div>
              <p class="text-2sm text-muted-foreground">
                {{ t('checkoutPage.departuresHint') }}
              </p>
            </div>
          </NuxtLink>
          <NuxtLink to="/settlements" class="flex items-center gap-3 rounded-lg border border-border p-3 transition-colors hover:bg-secondary/60">
            <div class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
              <KtIcon name="bank" />
            </div>
            <div class="min-w-0">
              <div class="font-medium text-foreground">
                {{ t('nav.settlements') }}
              </div>
              <p class="text-2sm text-muted-foreground">
                {{ t('checkoutPage.settlementsHint') }}
              </p>
            </div>
          </NuxtLink>
        </div>
      </DataCard>
    </div>
  </div>
</template>
