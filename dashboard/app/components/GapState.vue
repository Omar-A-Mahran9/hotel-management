<script setup lang="ts">
// An honest "this module needs a backend endpoint that does not exist yet"
// state. NOT a fake page: it names exactly what the backend must expose.
// Used by the routes whose nav items carry `backendGap: true`.
defineProps<{
  title: string
  body: string
  endpoints: string[]
}>()
const { t } = useI18n()
</script>

<template>
  <div>
    <PageHeader :title="title" />
    <div class="card mx-auto max-w-xl p-8 text-center">
      <div class="mx-auto flex size-12 items-center justify-center rounded-full bg-warning/15 text-warning">
        <KtIcon name="cloud-add" />
      </div>
      <h2 class="mt-3 text-base font-semibold text-foreground">
        {{ t('gap.heading') }}
      </h2>
      <p class="mx-auto mt-1 max-w-md text-sm text-muted-foreground">
        {{ body }}
      </p>
      <div class="mt-4 rounded-lg border border-border bg-secondary/50 p-3 text-start">
        <div class="mb-1.5 text-2xs font-semibold uppercase tracking-wide text-muted-foreground">
          {{ t('gap.needed') }}
        </div>
        <ul class="space-y-1">
          <li v-for="e in endpoints" :key="e" class="font-mono text-2sm text-foreground">
            {{ e }}
          </li>
        </ul>
      </div>
      <p class="mt-3 text-2xs text-muted-foreground">
        {{ t('gap.noFake') }}
      </p>
    </div>
  </div>
</template>
