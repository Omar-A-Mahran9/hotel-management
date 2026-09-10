<script setup lang="ts" generic="T extends Record<string, any>">
import { ApiError } from '~/utils/apiError'

/**
 * API-backed entity / foreign-key selector. The single shared control for
 * "pick an existing record, submit its id" — never a free-text field and
 * never a hard-coded option list.
 *
 * Options always come from `fetcher` (a thin wrapper over a real backend
 * list endpoint). Supports debounced server-side search, a loading / empty
 * / error state, disabled + dependent behaviour (via `reloadKey`), clear,
 * and RTL. For a dependent select (Country -> City) the parent bumps
 * `reloadKey` when the parent value changes and clears this model itself.
 */
const props = withDefaults(defineProps<{
  /** Loads options. Receives the current search term when `serverSearch`. */
  fetcher: (params: { search?: string }) => Promise<T[]>
  /** Field used as the option value that gets submitted (default `id`). */
  valueKey?: string
  /** Field used as the human label, or a function for a computed label. */
  labelKey?: string
  labelFn?: (item: T) => string
  placeholder?: string
  /** Fallback label for the current value when it is not in the loaded list. */
  selectedLabel?: string | null
  disabled?: boolean
  /** Explanation shown in the control while disabled (e.g. "select a country first"). */
  disabledHint?: string
  clearable?: boolean
  required?: boolean
  searchable?: boolean
  /** When it changes the options reload (used for dependent selects). */
  reloadKey?: string | number | null
  /** false = filter the loaded list client-side instead of re-querying. */
  serverSearch?: boolean
  id?: string
  invalid?: boolean
}>(), {
  valueKey: 'id',
  labelKey: 'name',
  searchable: true,
  serverSearch: true,
  clearable: false,
  reloadKey: null,
})

const model = defineModel<string | number | null>({ default: null })

const { t } = useI18n()

const options = ref<T[]>([]) as Ref<T[]>
const loading = ref(false)
const error = ref<unknown>(null)
const open = ref(false)
const query = ref('')
const activeIndex = ref(-1)
const loadedOnce = ref(false)
const root = ref<HTMLElement | null>(null)
const searchInput = ref<HTMLInputElement | null>(null)

let seq = 0
let debounce: ReturnType<typeof setTimeout> | null = null

function labelOf(item: T): string {
  if (props.labelFn) return props.labelFn(item)
  return String(item?.[props.labelKey] ?? '')
}

const selectedItem = computed(() =>
  options.value.find(o => String(o[props.valueKey]) === String(model.value)) ?? null,
)

const displayLabel = computed(() => {
  if (selectedItem.value) return labelOf(selectedItem.value)
  if (model.value != null && model.value !== '') return props.selectedLabel || `#${model.value}`
  return ''
})

const filteredOptions = computed(() => {
  if (props.serverSearch || !query.value.trim()) return options.value
  const q = query.value.trim().toLowerCase()
  return options.value.filter(o => labelOf(o).toLowerCase().includes(q))
})

async function load() {
  if (props.disabled) {
    options.value = []
    return
  }
  const mine = ++seq
  loading.value = true
  error.value = null
  try {
    const result = await props.fetcher({
      search: props.serverSearch && query.value.trim() ? query.value.trim() : undefined,
    })
    if (mine !== seq) return
    options.value = result
    loadedOnce.value = true
  } catch (e) {
    if (mine !== seq) return
    error.value = e
  } finally {
    if (mine === seq) loading.value = false
  }
}

function scheduleLoad() {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(load, 300)
}

watch(() => props.reloadKey, () => {
  loadedOnce.value = false
  options.value = []
  query.value = ''
  if (!props.disabled && open.value) load()
})

watch(() => props.disabled, (v) => {
  if (v) {
    open.value = false
    options.value = []
    loadedOnce.value = false
  }
})

watch(query, () => {
  activeIndex.value = -1
  if (props.serverSearch) scheduleLoad()
})

watch(open, (v) => {
  if (v && !loadedOnce.value && !loading.value) load()
  if (v) nextTick(() => searchInput.value?.focus())
  else query.value = ''
})

function toggle() {
  if (props.disabled) return
  open.value = !open.value
}

function choose(item: T) {
  model.value = item[props.valueKey] as string | number
  open.value = false
}

function clear() {
  model.value = null
  open.value = false
}

function onKeydown(e: KeyboardEvent) {
  if (props.disabled) return
  if (!open.value && (e.key === 'Enter' || e.key === 'ArrowDown' || e.key === ' ')) {
    e.preventDefault()
    open.value = true
    return
  }
  if (!open.value) return
  const list = filteredOptions.value
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    activeIndex.value = Math.min(activeIndex.value + 1, list.length - 1)
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    activeIndex.value = Math.max(activeIndex.value - 1, 0)
  } else if (e.key === 'Enter') {
    e.preventDefault()
    const item = list[activeIndex.value]
    if (item) choose(item)
  } else if (e.key === 'Escape') {
    open.value = false
  }
}

function onDocClick(e: MouseEvent) {
  if (root.value && !root.value.contains(e.target as Node)) open.value = false
}

onMounted(() => document.addEventListener('click', onDocClick))
onBeforeUnmount(() => {
  document.removeEventListener('click', onDocClick)
  if (debounce) clearTimeout(debounce)
})

// Reload from the parent (e.g. after creating a new option elsewhere).
defineExpose({ reload: load })
</script>

<template>
  <div ref="root" class="relative">
    <button
      :id="id"
      type="button"
      class="input flex items-center gap-2 text-start"
      :class="[
        disabled ? 'cursor-not-allowed opacity-60' : 'cursor-pointer',
        invalid ? 'border-destructive' : '',
      ]"
      :disabled="disabled"
      :aria-expanded="open"
      aria-haspopup="listbox"
      role="combobox"
      @click="toggle"
      @keydown="onKeydown"
    >
      <span class="min-w-0 flex-1 truncate" :class="{ 'text-muted-foreground': !displayLabel }">
        {{ displayLabel || (disabled && disabledHint ? disabledHint : (placeholder || t('common.search'))) }}
      </span>
      <button
        v-if="clearable && model != null && model !== '' && !disabled"
        type="button"
        class="shrink-0 text-muted-foreground hover:text-foreground"
        :aria-label="t('common.clear')"
        @click.stop="clear"
      >
        <KtIcon name="cross" class="text-2xs" />
      </button>
      <KtIcon name="down" class="shrink-0 text-2xs text-muted-foreground" />
    </button>

    <Transition name="dd">
      <div
        v-if="open"
        class="card absolute z-40 mt-1 w-full overflow-hidden p-1 shadow-lg"
        role="listbox"
      >
        <div v-if="searchable" class="p-1">
          <input
            ref="searchInput"
            v-model="query"
            type="search"
            class="input text-2sm"
            :placeholder="t('common.search')"
            @keydown="onKeydown"
          >
        </div>

        <div class="max-h-60 overflow-y-auto">
          <div v-if="loading" class="px-2.5 py-3 text-center text-2sm text-muted-foreground">
            <KtIcon name="loading" class="animate-spin" /> {{ t('common.loading') }}
          </div>
          <div v-else-if="error" class="px-2.5 py-3 text-center text-2sm">
            <p class="text-destructive">
              {{ error instanceof ApiError ? error.message : t('errors.genericBody') }}
            </p>
            <button type="button" class="btn btn-ghost mt-1 px-2 py-1 text-2xs" @click="load">
              <KtIcon name="arrows-circle" /> {{ t('common.retry') }}
            </button>
          </div>
          <div v-else-if="filteredOptions.length === 0" class="px-2.5 py-3 text-center text-2sm text-muted-foreground">
            <slot name="empty">
              {{ t('common.noResults') }}
            </slot>
          </div>
          <ul v-else>
            <li
              v-for="(item, i) in filteredOptions"
              :key="String(item[valueKey])"
              role="option"
              :aria-selected="String(item[valueKey]) === String(model)"
              class="flex cursor-pointer items-center gap-2 rounded-md px-2.5 py-2 text-2sm"
              :class="[
                i === activeIndex ? 'bg-secondary' : 'hover:bg-secondary',
                String(item[valueKey]) === String(model) ? 'font-semibold text-primary' : 'text-foreground',
              ]"
              @click="choose(item)"
              @mouseenter="activeIndex = i"
            >
              <span class="min-w-0 flex-1 truncate">{{ labelOf(item) }}</span>
              <KtIcon
                v-if="String(item[valueKey]) === String(model)"
                name="check"
                class="shrink-0 text-2xs"
              />
            </li>
          </ul>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.dd-enter-active,
.dd-leave-active {
  transition: opacity 0.12s ease, transform 0.12s ease;
}
.dd-enter-from,
.dd-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}
</style>
