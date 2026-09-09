<script setup lang="ts">
definePageMeta({ permission: 'users.view' })
const { t } = useI18n()

const filters = ref({ actor: '', action: '', entity: '' })
const range = ref({ from: '', to: '' })
</script>

<template>
  <div>
    <PageHeader :title="t('nav.audit')" :subtitle="t('auditPage.subtitle')" />

    <FilterBar>
      <FormField :label="t('auditPage.filterActor')">
        <input v-model="filters.actor" class="input min-w-40" disabled>
      </FormField>
      <FormField :label="t('auditPage.filterAction')">
        <input v-model="filters.action" class="input min-w-40" disabled>
      </FormField>
      <FormField :label="t('auditPage.filterEntity')">
        <input v-model="filters.entity" class="input min-w-40" disabled>
      </FormField>
      <DateRangeField v-model="range" />
    </FilterBar>

    <div class="card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="table-base">
          <thead>
            <tr>
              <th>{{ t('auditPage.time') }}</th>
              <th>{{ t('auditPage.actor') }}</th>
              <th>{{ t('auditPage.action') }}</th>
              <th>{{ t('auditPage.entity') }}</th>
              <th>{{ t('auditPage.hotel') }}</th>
              <th>{{ t('auditPage.metadata') }}</th>
            </tr>
          </thead>
        </table>
      </div>
      <UnavailablePanel
        :body="t('gap.auditBody')"
        :endpoints="['GET /api/v1/audit', 'GET /api/v1/audit?actor_id=&action=&auditable_type=&hotel_id=&from=&to=']"
      />
    </div>
  </div>
</template>
