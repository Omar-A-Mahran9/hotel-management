<script setup lang="ts">
import type { Country } from '~/types/api'

definePageMeta({ permission: 'locations.manage' })

const { t } = useI18n()
const router = useRouter()

function onSaved(_country: Country) {
  router.push('/countries')
}

function goBack() {
  router.push('/countries')
}
</script>

<template>
  <div class="space-y-5">
    <!-- Header -->

    <PageHeader
      :title="t('countries.new')"
      :subtitle="t('countries.newDesc')"
    >
      <template #actions>
        <NuxtLink
          to="/countries"
          class="btn btn-secondary"
        >
          <KtIcon name="left" />
          <span>{{ t('common.back') }}</span>
        </NuxtLink>
      </template>
    </PageHeader>

    <!-- Content -->

    <div class="grid gap-5 lg:grid-cols-[minmax(0,1fr)_280px]">
      <!-- Form -->

      <div class="card overflow-hidden">
        <div class="p-4 sm:p-6">
          <CountryForm @saved="onSaved" />
        </div>
      </div>

      <!-- Side Information -->

      <div class="space-y-5">
        <div class="card p-4 sm:p-5">
          <div class="flex items-start gap-3">
            <div
              class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
            >
              <KtIcon name="globe" />
            </div>

            <div class="min-w-0">
              <h3 class="text-sm font-semibold text-foreground">
                {{ t('countries.new') }}
              </h3>

              <p class="mt-1 text-xs leading-5 text-muted-foreground">
                {{ t('countries.newDesc') }}
              </p>
            </div>
          </div>
        </div>

        <div class="card p-4 sm:p-5">
          <div class="flex items-start gap-3">
            <div
              class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground"
            >
              <KtIcon name="info" />
            </div>

            <div>
              <h3 class="text-sm font-semibold text-foreground">
                {{ t('countries.title') }}
              </h3>

              <p class="mt-1 text-xs åleading-5 text-muted-foreground">
                {{ t('countries.subtitle') }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
