<script setup lang="ts">
const { t, locale, locales, setLocale } = useI18n()
const auth = useAuthStore()
const appStore = useAppStore()
const { can } = useCan()

const localeOptions = computed(() =>
  (locales.value as Array<{ code: string, name: string }>).map(l => ({ code: l.code, name: l.name })),
)

const facts = computed(() => [
  { label: t('settings.name'), value: auth.user?.name },
  { label: t('settings.email'), value: auth.user?.email },
  { label: t('settings.role'), value: auth.user?.role ? (locale.value === 'ar' ? auth.user.role.name_ar : auth.user.role.name_en) : undefined },
  {
    label: t('settings.assignedHotels'),
    value: auth.isGroupOwner
      ? t('hotelSelector.allHotels')
      : (auth.assignedHotels.map(h => h.name).join(', ') || t('common.none')),
  },
])
</script>

<template>
  <div>
    <PageHeader :title="t('settings.title')" :subtitle="t('settings.subtitle')" />

    <div class="grid gap-6 lg:grid-cols-2">
      <DataCard :title="t('settings.profile')">
        <FactGrid :facts="facts" />
        <p class="mt-3 text-2xs text-muted-foreground">
          {{ t('settings.profileReadOnly') }}
        </p>
      </DataCard>

      <DataCard :title="t('settings.appearance')">
        <div class="space-y-4">
          <FormField :label="t('settings.language')">
            <select
              class="input max-w-xs"
              :value="locale"
              @change="(e) => setLocale((e.target as HTMLSelectElement).value as 'en' | 'ar')"
            >
              <option v-for="o in localeOptions" :key="o.code" :value="o.code">
                {{ o.name }}
              </option>
            </select>
          </FormField>
          <FormField :label="t('settings.theme')">
            <select
              class="input max-w-xs"
              :value="appStore.theme"
              @change="(e) => appStore.setTheme((e.target as HTMLSelectElement).value as 'light' | 'dark')"
            >
              <option value="light">
                {{ t('theme.light') }}
              </option>
              <option value="dark">
                {{ t('theme.dark') }}
              </option>
            </select>
          </FormField>
        </div>
      </DataCard>

      <DataCard v-if="can('loyalty.rules.manage')" :title="t('nav.loyalty')">
        <p class="text-sm text-muted-foreground">
          {{ t('settings.loyaltyLink') }}
        </p>
        <NuxtLink to="/hotel-group" class="btn btn-secondary mt-3">
          <KtIcon name="abstract-26" /> {{ t('nav.hotelGroup') }}
        </NuxtLink>
      </DataCard>
    </div>
  </div>
</template>
