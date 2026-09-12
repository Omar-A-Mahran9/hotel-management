<script setup lang="ts">
import type { RoomMedia } from '~/types/api'
import { ApiError } from '~/utils/apiError'

interface StagedItem { file: File, preview: string }
interface GalleryTile {
  key: string
  url: string
  staged: boolean
  uploading: boolean
  media?: RoomMedia
  stagedIndex?: number
}

const props = defineProps<{
  // Absent/null => no Room/RoomType exists yet (create flow): files are
  // held locally and only uploaded once the caller has an id (see
  // `commitStaged`). Present => uploads happen immediately, as before.
  ownerId?: number | null
  gallery?: RoomMedia[]
  upload: (ownerId: number, file: File) => Promise<RoomMedia>
  remove: (ownerId: number, mediaId: number) => Promise<null>
  reorder: (ownerId: number, ids: number[]) => Promise<RoomMedia[]>
}>()

// Bubble every successful server change so the parent reloads and keeps the
// embedded media relation current. Never fired for staged edits.
const emit = defineEmits<{ changed: [] }>()

const { t } = useI18n()
const app = useAppStore()

const staged = computed(() => !props.ownerId)

// Mirrors config/room_media.php — a soft client-side check only, the
// server remains the source of truth for both limits.
const MAX_FILE_MB = 5
const MAX_GALLERY = 20
const ACCEPTED_MIMES = ['image/jpeg', 'image/png', 'image/webp']
const ACCEPT_ATTR = ACCEPTED_MIMES.join(',')

const busy = ref(false)

// ---- Staged (create-flow) state ----------------------------------------
const stagedGallery = ref<StagedItem[]>([])

// ---- Live (edit-flow) optimistic-preview state -------------------------
const pendingGalleryPreviews = ref<string[]>([])

const removeTarget = ref<RoomMedia | null>(null)
const dragOver = ref(false)

function report(e: unknown) {
  if (e instanceof ApiError && e.kind === 'validation' && e.errors) {
    app.pushToast('error', Object.values(e.errors).flat()[0] ?? t('errors.validationTitle'))
  }
  else {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  }
}

function validate(file: File): string | null {
  if (!ACCEPTED_MIMES.includes(file.type)) return t('media.invalidType')
  if (file.size > MAX_FILE_MB * 1024 * 1024) return t('media.tooLarge', { max: MAX_FILE_MB })
  return null
}

function onDragEnter() {
  dragOver.value = true
}
function onDragLeave(e: DragEvent) {
  const related = e.relatedTarget as Node | null
  const current = e.currentTarget as HTMLElement | null
  if (!related || !current?.contains(related)) dragOver.value = false
}

const galleryItems = computed<GalleryTile[]>(() => {
  if (staged.value) {
    return stagedGallery.value.map((item, i) => ({
      key: `staged-${i}`,
      url: item.preview,
      staged: true,
      uploading: false,
      stagedIndex: i,
    }))
  }
  const existing = (props.gallery ?? []).map(m => ({
    key: `media-${m.id}`,
    url: m.url,
    staged: false,
    uploading: false,
    media: m,
  }))
  const pending = pendingGalleryPreviews.value.map((url, i) => ({
    key: `pending-${i}`,
    url,
    staged: false,
    uploading: true,
  }))
  return [...existing, ...pending]
})

async function uploadNow(file: File) {
  busy.value = true
  const previewUrl = URL.createObjectURL(file)
  pendingGalleryPreviews.value.push(previewUrl)

  try {
    await props.upload(props.ownerId!, file)
    app.pushToast('success', t('media.uploaded'))
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = false
    pendingGalleryPreviews.value = pendingGalleryPreviews.value.filter(u => u !== previewUrl)
    URL.revokeObjectURL(previewUrl)
  }
}

async function pickGallery(files: File[]) {
  for (const file of files) {
    const err = validate(file)
    if (err) {
      app.pushToast('error', err)
      continue
    }
    if (staged.value) {
      if (stagedGallery.value.length >= MAX_GALLERY) {
        app.pushToast('error', t('media.galleryFull', { max: MAX_GALLERY }))
        break
      }
      stagedGallery.value.push({ file, preview: URL.createObjectURL(file) })
    }
    else {
      // Sequential (not Promise.all) so sort_order follows drop order.
      await uploadNow(file)
    }
  }
}

async function onGalleryInputChange(event: Event) {
  const input = event.target as HTMLInputElement
  const files = Array.from(input.files ?? [])
  input.value = ''
  await pickGallery(files)
}
async function onGalleryDrop(event: DragEvent) {
  dragOver.value = false
  await pickGallery(Array.from(event.dataTransfer?.files ?? []))
}

function galleryRemove(item: GalleryTile) {
  if (item.uploading || busy.value) return
  if (item.staged && item.stagedIndex !== undefined) {
    const removed = stagedGallery.value[item.stagedIndex]
    if (removed) URL.revokeObjectURL(removed.preview)
    stagedGallery.value.splice(item.stagedIndex, 1)
  }
  else if (item.media) {
    removeTarget.value = item.media
  }
}

function galleryMove(index: number, delta: number) {
  if (busy.value) return
  if (staged.value) {
    const items = stagedGallery.value
    const target = index + delta
    if (target < 0 || target >= items.length) return
    ;[items[index], items[target]] = [items[target]!, items[index]!]
    return
  }
  moveLive(index, delta)
}

async function moveLive(index: number, delta: number) {
  const items = [...(props.gallery ?? [])]
  const target = index + delta
  if (target < 0 || target >= items.length) return
  ;[items[index], items[target]] = [items[target]!, items[index]!]

  busy.value = true
  try {
    await props.reorder(props.ownerId!, items.map(m => m.id))
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = false
  }
}

// ---- Removal (persisted media only — staged removal needs no confirmation) ----
async function confirmRemove() {
  const media = removeTarget.value
  if (!media || busy.value) return
  busy.value = true
  try {
    await props.remove(props.ownerId!, media.id)
    app.pushToast('success', t('media.removed'))
    removeTarget.value = null
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = false
  }
}

// ---- Create-flow hand-off: called by the parent form once the Room/
// RoomType has been saved and a real id exists. Uploads run sequentially
// (gallery order follows selection order) and failures are swallowed here
// — the caller decides how to surface "some images failed" as a single
// summary toast, rather than one toast per file.
async function commitStaged(ownerId: number): Promise<boolean> {
  let allOk = true
  for (const item of stagedGallery.value) {
    try {
      await props.upload(ownerId, item.file)
    }
    catch {
      allOk = false
    }
  }

  stagedGallery.value.forEach(item => URL.revokeObjectURL(item.preview))
  stagedGallery.value = []

  return allOk
}

const hasStaged = computed(() => stagedGallery.value.length > 0)

defineExpose({ commitStaged, hasStaged })

onBeforeUnmount(() => {
  stagedGallery.value.forEach(item => URL.revokeObjectURL(item.preview))
})
</script>

<template>
  <div class="space-y-3">
    <InfoNote v-if="staged">
      {{ t('media.stagedHint') }}
    </InfoNote>

    <div class="flex items-center justify-between">
      <p class="text-2sm font-medium text-foreground">
        {{ t('media.gallery') }}
      </p>
      <label v-if="galleryItems.length" class="btn btn-secondary btn-sm cursor-pointer">
        <input type="file" :accept="ACCEPT_ATTR" multiple class="hidden" :disabled="busy" @change="onGalleryInputChange">
        <KtIcon name="plus" /> {{ t('media.addMore') }}
      </label>
    </div>
    <div
      class="rounded-lg border border-dashed p-4 transition-colors"
      :class="dragOver ? 'border-primary bg-primary/5' : 'border-border'"
      @dragenter.prevent="onDragEnter"
      @dragover.prevent
      @dragleave="onDragLeave"
      @drop.prevent="onGalleryDrop"
    >
      <label v-if="!galleryItems.length" class="flex cursor-pointer flex-col items-center gap-1 py-2 text-center text-2sm text-muted-foreground">
        <input type="file" :accept="ACCEPT_ATTR" multiple class="hidden" :disabled="busy" @change="onGalleryInputChange">
        <KtIcon name="cloud-add" class="text-xl" />
        <span>{{ t('media.dropHintGallery') }}</span>
      </label>
      <ul v-else class="grid gap-3 sm:grid-cols-3">
        <li v-for="(item, i) in galleryItems" :key="item.key" class="relative overflow-hidden rounded-lg border border-border">
          <img :src="item.url" alt="" class="aspect-video w-full object-cover" :class="item.uploading && 'opacity-60'">
          <div v-if="item.uploading" class="absolute inset-0 flex items-center justify-center bg-black/10">
            <KtIcon name="loading" class="animate-spin text-white" />
          </div>
          <div v-else-if="item.staged" class="absolute end-1 top-1 rounded bg-black/60 px-1.5 py-0.5 text-2xs text-white">
            {{ t('media.pending') }}
          </div>
          <div class="flex items-center justify-between gap-1 p-1.5">
            <div class="flex gap-1">
              <button type="button" class="btn btn-icon btn-sm btn-secondary" :disabled="item.uploading || busy || i === 0" :aria-label="t('common.moveUp')" @click="galleryMove(i, -1)">
                <KtIcon name="up" />
              </button>
              <button type="button" class="btn btn-icon btn-sm btn-secondary" :disabled="item.uploading || busy || i === galleryItems.length - 1" :aria-label="t('common.moveDown')" @click="galleryMove(i, 1)">
                <KtIcon name="down" />
              </button>
            </div>
            <button type="button" class="btn btn-icon btn-sm btn-secondary text-destructive" :disabled="item.uploading || busy" :aria-label="t('common.remove')" @click="galleryRemove(item)">
              <KtIcon name="trash" />
            </button>
          </div>
        </li>
      </ul>
    </div>

    <ConfirmDialog
      :open="removeTarget !== null"
      :title="t('common.remove')"
      :message="t('media.removeConfirm')"
      tone="destructive"
      :busy="busy"
      @update:open="(v: boolean) => !v && (removeTarget = null)"
      @confirm="confirmRemove"
    />
  </div>
</template>
