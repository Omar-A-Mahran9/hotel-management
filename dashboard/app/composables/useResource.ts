// Minimal async-resource helper: tracks data / pending / error and exposes
// a reload(). Keeps every list/detail page consistent without pulling in a
// data-fetching library. SPA-only, so a plain ref lifecycle is enough.
export function useResource<T>(
  loader: () => Promise<T>,
  options: { immediate?: boolean } = {},
) {
  const data = ref<T | null>(null) as Ref<T | null>
  const pending = ref(false)
  const error = ref<unknown>(null)

  async function reload() {
    pending.value = true
    error.value = null
    try {
      data.value = await loader()
    } catch (e) {
      error.value = e
    } finally {
      pending.value = false
    }
  }

  if (options.immediate !== false) {
    void reload()
  }

  return { data, pending, error, reload }
}
