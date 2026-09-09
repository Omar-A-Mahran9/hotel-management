<script setup lang="ts">
// An honest inline "the data for this area needs a backend endpoint that
// does not exist yet" panel. Drop it where a table/chart would render on a
// page whose surrounding structure (filters, columns, layout) is already
// built. Names the exact endpoint(s) — never shows placeholder data.
withDefaults(
  defineProps<{
    title?: string
    body: string
    endpoints?: string[]
    /** A real, working alternative route (e.g. the per-reservation flow). */
    alternativeTo?: string
    alternativeLabel?: string
  }>(),
  { endpoints: () => [] },
)
const { t } = useI18n()
</script>

<template>
  <div class="card flex flex-col items-center gap-3 p-10 text-center">
    <div class="flex size-11 items-center justify-center rounded-full bg-warning/15 text-warning">
      <KtIcon name="cloud-add" />
    </div>
    <div class="text-sm font-semibold text-foreground">
      {{ title ?? t('gap.heading') }}
    </div>
    <p class="max-w-md text-sm text-muted-foreground">
      {{ body }}
    </p>
    <div v-if="endpoints.length" class="w-full max-w-md rounded-lg border border-border bg-secondary/50 p-3 text-start">
      <div class="mb-1.5 text-2xs font-semibold uppercase tracking-wide text-muted-foreground">
        {{ t('gap.needed') }}
      </div>
      <ul class="space-y-1">
        <li v-for="e in endpoints" :key="e" class="break-all font-mono text-2xs text-foreground">
          {{ e }}
        </li>
      </ul>
    </div>
    <NuxtLink v-if="alternativeTo" :to="alternativeTo" class="btn btn-secondary mt-1">
      <KtIcon name="arrow-right" /> {{ alternativeLabel ?? t('common.view') }}
    </NuxtLink>
    <p class="text-2xs text-muted-foreground">
      {{ t('gap.noFake') }}
    </p>
  </div>
</template>
