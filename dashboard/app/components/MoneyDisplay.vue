<script setup lang="ts">
// Renders a backend-provided decimal money string with its currency. The
// backend is authoritative for every amount — this only formats, never
// computes.
import { money } from '~/utils/format'

withDefaults(
  defineProps<{
    amount: string | number | null | undefined
    currency?: string | null
    /** Visually emphasise (totals). */
    strong?: boolean
    /** Tone the number when it represents money owed / paid. */
    tone?: 'default' | 'positive' | 'negative' | 'muted'
  }>(),
  { tone: 'default' },
)

const toneClass: Record<string, string> = {
  default: 'text-foreground',
  positive: 'text-success',
  negative: 'text-warning',
  muted: 'text-muted-foreground',
}
</script>

<template>
  <span
    class="tabular-nums"
    :class="[toneClass[tone], strong ? 'font-semibold' : '']"
  >{{ money(amount, currency) }}</span>
</template>
