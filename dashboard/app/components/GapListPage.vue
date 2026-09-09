<script setup lang="ts">
// A fully-structured list page (header + filter bar + table columns) whose
// data area shows an honest "endpoint not available" panel. The layout is
// real and ready; only the rows wait on the backend.
withDefaults(
  defineProps<{
    title: string
    subtitle?: string
    columns: string[]
    body: string
    endpoints?: string[]
    alternativeTo?: string
    alternativeLabel?: string
    note?: string
  }>(),
  { endpoints: () => [] },
)
</script>

<template>
  <div>
    <PageHeader :title="title" :subtitle="subtitle">
      <template v-if="$slots.actions" #actions>
        <slot name="actions" />
      </template>
    </PageHeader>

    <slot name="filters" />

    <InfoNote v-if="note" class="mb-4">
      {{ note }}
    </InfoNote>

    <div class="card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="table-base">
          <thead>
            <tr>
              <th v-for="c in columns" :key="c">
                {{ c }}
              </th>
            </tr>
          </thead>
        </table>
      </div>
      <UnavailablePanel
        :body="body"
        :endpoints="endpoints"
        :alternative-to="alternativeTo"
        :alternative-label="alternativeLabel"
      />
    </div>
  </div>
</template>
