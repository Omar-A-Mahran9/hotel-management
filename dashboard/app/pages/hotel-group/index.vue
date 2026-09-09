<script setup lang="ts">
import { hotelGroupsService } from '~/services'
import type { HotelGroup, LoyaltyRule } from '~/types/api'
import { ApiError } from '~/utils/apiError'

definePageMeta({ permission: 'hotel-groups.manage' })

const { t } = useI18n()
const app = useAppStore()

const groups = useResource(() => hotelGroupsService.list())
const selectedId = ref<number | null>(null)

watch(() => groups.data.value, (g) => {
  if (g?.length && selectedId.value == null) selectedId.value = g[0]!.id
})

const selected = computed<HotelGroup | null>(() =>
  (groups.data.value ?? []).find(g => g.id === selectedId.value) ?? null,
)

// --- profile ----------------------------------------------------------
const profile = reactive({ name: '', slug: '', is_active: true })
const profileErrors = ref<Record<string, string[]>>({})
const savingProfile = ref(false)

watch(selected, (g) => {
  if (g) Object.assign(profile, { name: g.name, slug: g.slug, is_active: g.is_active })
}, { immediate: true })

async function saveProfile() {
  if (!selected.value || savingProfile.value) return
  savingProfile.value = true
  profileErrors.value = {}
  try {
    await hotelGroupsService.update(selected.value.id, {
      name: profile.name,
      slug: profile.slug,
      is_active: profile.is_active,
    })
    app.pushToast('success', t('hotelGroup.updated'))
    groups.reload()
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) profileErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    savingProfile.value = false
  }
}

// --- loyalty rule ---------------------------------------------------
const rule = ref<LoyaltyRule | null>(null)
const ruleForm = reactive({ is_active: false, earn: '', redeem: '' })
const ruleErrors = ref<Record<string, string[]>>({})
const savingRule = ref(false)
const ruleLoading = ref(false)
const ruleError = ref<unknown>(null)

async function loadRule(id: number) {
  ruleLoading.value = true
  ruleError.value = null
  try {
    rule.value = await hotelGroupsService.loyaltyRule(id)
    ruleForm.is_active = rule.value.is_active
    ruleForm.earn = rule.value.earn_points_per_currency ?? ''
    ruleForm.redeem = rule.value.redeem_currency_per_point ?? ''
  } catch (e) {
    ruleError.value = e
  } finally {
    ruleLoading.value = false
  }
}

watch(selectedId, (id) => {
  if (id != null) loadRule(id)
}, { immediate: true })

async function saveRule() {
  if (selectedId.value == null || savingRule.value) return
  savingRule.value = true
  ruleErrors.value = {}
  try {
    rule.value = await hotelGroupsService.updateLoyaltyRule(selectedId.value, {
      is_active: ruleForm.is_active,
      earn_points_per_currency: ruleForm.earn === '' ? null : ruleForm.earn,
      redeem_currency_per_point: ruleForm.redeem === '' ? null : ruleForm.redeem,
    })
    app.pushToast('success', t('hotelGroup.ruleUpdated'))
  } catch (e) {
    if (e instanceof ApiError && e.kind === 'validation' && e.errors) ruleErrors.value = e.errors
    else app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  } finally {
    savingRule.value = false
  }
}
</script>

<template>
  <div>
    <PageHeader :title="t('hotelGroup.title')" :subtitle="t('hotelGroup.subtitle')" />

    <LoadingState v-if="groups.pending.value" :rows="4" />
    <ErrorState v-else-if="groups.error.value" :error="groups.error.value" @retry="groups.reload" />
    <template v-else-if="selected">
      <FormField v-if="(groups.data.value?.length ?? 0) > 1" :label="t('nav.hotelGroup')" class="mb-4 max-w-xs">
        <select v-model.number="selectedId" class="input">
          <option v-for="g in groups.data.value ?? []" :key="g.id" :value="g.id">
            {{ g.name }}
          </option>
        </select>
      </FormField>

      <div class="grid gap-6 lg:grid-cols-2">
        <DataCard :title="t('hotelGroup.profile')">
          <form class="space-y-3" novalidate @submit.prevent="saveProfile">
            <FormField :label="t('hotelGroup.name')" :error="profileErrors.name" required>
              <input v-model="profile.name" class="input" required>
            </FormField>
            <FormField :label="t('hotelGroup.slug')" :error="profileErrors.slug" required>
              <input v-model="profile.slug" class="input" required>
            </FormField>
            <label class="flex items-center gap-2 text-2sm">
              <input v-model="profile.is_active" type="checkbox"> {{ t('common.active') }}
            </label>
            <button type="submit" class="btn btn-primary" :disabled="savingProfile">
              {{ savingProfile ? t('common.saving') : t('common.save') }}
            </button>
          </form>
        </DataCard>

        <DataCard :title="t('hotelGroup.loyaltyRule')">
          <LoadingState v-if="ruleLoading" :rows="3" />
          <ErrorState v-else-if="ruleError" :error="ruleError" @retry="loadRule(selectedId!)" />
          <form v-else class="space-y-3" novalidate @submit.prevent="saveRule">
            <label class="flex items-center gap-2 text-2sm">
              <input v-model="ruleForm.is_active" type="checkbox"> {{ t('hotelGroup.loyaltyActive') }}
            </label>
            <FormField :label="t('hotelGroup.earnRate')" :error="ruleErrors.earn_points_per_currency">
              <input v-model="ruleForm.earn" type="text" inputmode="decimal" class="input" placeholder="—">
            </FormField>
            <FormField :label="t('hotelGroup.redeemRate')" :error="ruleErrors.redeem_currency_per_point">
              <input v-model="ruleForm.redeem" type="text" inputmode="decimal" class="input" placeholder="—">
            </FormField>
            <div v-if="rule && rule.eligible_source_types.length" class="text-2xs text-muted-foreground">
              {{ t('hotelGroup.eligibleSources') }}: {{ rule.eligible_source_types.join(', ') }}
            </div>
            <p class="text-2xs text-muted-foreground">
              {{ t('hotelGroup.ruleNote') }}
            </p>
            <p v-if="rule && !rule.is_active" class="text-2xs text-warning">
              {{ t('hotelGroup.ruleInactiveHint') }}
            </p>
            <button type="submit" class="btn btn-primary" :disabled="savingRule">
              {{ savingRule ? t('common.saving') : t('common.save') }}
            </button>
          </form>
        </DataCard>
      </div>
    </template>
    <EmptyState v-else />
  </div>
</template>
