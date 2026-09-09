<script setup lang="ts" generic="T">
import type { ApiMeta } from '~/types/api'

export interface Column {
  key: string
  label: string
  align?: 'start' | 'end' | 'center'
  nowrap?: boolean
}

const props = withDefaults(
  defineProps<{
    columns: Column[]
    rows: T[]
    rowKey?: string | ((row: T) => string | number)
    loading?: boolean
    error?: unknown
    meta?: ApiMeta | null
    emptyTitle?: string
    emptyBody?: string
    clickableRows?: boolean
  }>(),
  { rowKey: 'id', meta: null },
)

const emit = defineEmits<{ retry: [], page: [n: number], rowClick: [row: T] }>()

function cellValue(row: T, key: string): unknown {
  return (row as Record<string, unknown>)[key]
}

function keyFor(row: T, i: number): string | number {
  if (typeof props.rowKey === 'function') return props.rowKey(row)
  const v = cellValue(row, props.rowKey)
  return (v as string | number | undefined) ?? i
}

const alignClass = (a?: Column['align']) =>
  a === 'end' ? 'text-end' : a === 'center' ? 'text-center' : 'text-start'
</script>

<template>
  <div class="card overflow-hidden">
    <LoadingState v-if="loading" />
    <ErrorState v-else-if="error" :error="error" @retry="emit('retry')" />
    <EmptyState v-else-if="rows.length === 0" :title="emptyTitle" :body="emptyBody" />
    <template v-else>
      <div class="overflow-x-auto">
        <table class="table-base">
          <thead>
            <tr>
              <th
                v-for="col in columns"
                :key="col.key"
                :class="[alignClass(col.align), col.nowrap ? 'whitespace-nowrap' : '']"
              >
                {{ col.label }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(row, i) in rows"
              :key="keyFor(row, i)"
              :class="clickableRows ? 'cursor-pointer' : ''"
              @click="clickableRows && emit('rowClick', row)"
            >
              <td
                v-for="col in columns"
                :key="col.key"
                :class="[alignClass(col.align), col.nowrap ? 'whitespace-nowrap' : '']"
              >
                <slot :name="`cell-${col.key}`" :row="row" :value="cellValue(row, col.key)">
                  {{ cellValue(row, col.key) ?? '—' }}
                </slot>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="meta && (meta.last_page ?? 1) > 1" class="border-t border-border px-4 py-3">
        <Pagination :meta="meta" @page="n => emit('page', n)" />
      </div>
    </template>
  </div>
</template>
