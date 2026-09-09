<script setup lang="ts">
// Shared image renderer: shows the image once loaded, a subtle skeleton
// while loading, and a brand-token monogram (initials) when there is no
// `src` or the image fails to load. Colours come only from the Hotel System
// token set — never a random hue.
const props = withDefaults(
  defineProps<{
    src?: string | null
    alt: string
    /** Name used to derive the fallback monogram; defaults to `alt`. */
    name?: string
    shape?: 'rounded' | 'square' | 'circle'
    /** Any CSS size, e.g. '2.5rem', '100%'. Applied to width & height for circle/square. */
    size?: string
    /** object-fit for a real image. */
    fit?: 'cover' | 'contain'
  }>(),
  { shape: 'rounded', fit: 'cover' },
)

const status = ref<'idle' | 'loading' | 'loaded' | 'error'>(props.src ? 'loading' : 'idle')

watch(() => props.src, (s) => {
  status.value = s ? 'loading' : 'idle'
})

const showImg = computed(() => !!props.src && status.value !== 'error')
const showFallback = computed(() => !props.src || status.value === 'error')

const initials = computed(() => {
  const base = (props.name ?? props.alt ?? '').trim()
  if (!base) return '—'
  return base
    .split(/\s+/)
    .slice(0, 2)
    .map(p => [...p][0]?.toUpperCase() ?? '')
    .join('') || base[0]!.toUpperCase()
})

const shapeClass = computed(() => ({
  rounded: 'rounded-lg',
  square: 'rounded-none',
  circle: 'rounded-full',
}[props.shape]))
</script>

<template>
  <div
    class="relative flex shrink-0 items-center justify-center overflow-hidden border border-border bg-secondary text-secondary-foreground"
    :class="shapeClass"
    :style="size ? { width: size, height: size } : undefined"
  >
    <img
      v-if="showImg"
      :src="src!"
      :alt="alt"
      class="h-full w-full"
      :class="fit === 'contain' ? 'object-contain' : 'object-cover'"
      loading="lazy"
      @load="status = 'loaded'"
      @error="status = 'error'"
    >
    <div
      v-if="status === 'loading'"
      class="absolute inset-0 animate-pulse bg-muted"
      aria-hidden="true"
    />
    <span
      v-if="showFallback"
      class="select-none px-1 text-center font-semibold uppercase text-muted-foreground"
      :style="{ fontSize: 'clamp(0.7rem, 40%, 1.1rem)' }"
      aria-hidden="true"
    >{{ initials }}</span>
  </div>
</template>
