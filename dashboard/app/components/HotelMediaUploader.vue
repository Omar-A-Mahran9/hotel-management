<script setup lang="ts">
import type { HotelMedia } from '~/types/api'
import { hotelMediaService } from '~/services'
import { ApiError } from '~/utils/apiError'

type SingleCollection = 'logo' | 'cover'
type Collection = HotelMedia['collection']

interface StagedItem { file: File, preview: string }
interface GalleryTile {
  key: string
  url: string
  staged: boolean
  uploading: boolean
  media?: HotelMedia
  stagedIndex?: number
}

const props = defineProps<{
  // Absent/null => no hotel exists yet (create flow): files are held
  // locally and only uploaded once the caller has an id (see
  // `commitStaged`). Present => uploads happen immediately, as before.
  hotelId?: number | null
  logo?: HotelMedia | null
  cover?: HotelMedia | null
  gallery?: HotelMedia[]
}>()

// Bubble every successful server change so the parent reloads the hotel and
// keeps the embedded media relations current. Never fired for staged edits.
const emit = defineEmits<{ changed: [] }>()

const { t } = useI18n()
const app = useAppStore()

const staged = computed(() => !props.hotelId)

// Mirrors config/hotel_media.php — a soft client-side check only, the
// server remains the source of truth for both limits.
const MAX_FILE_MB = 5
const MAX_GALLERY = 12
const ACCEPTED_MIMES = ['image/jpeg', 'image/png', 'image/webp']
const ACCEPT_ATTR = ACCEPTED_MIMES.join(',')

const busy = ref<Collection | null>(null) // collection currently uploading/mutating

// ---- Staged (create-flow) state ----------------------------------------
const stagedLogo = ref<StagedItem | null>(null)
const stagedCover = ref<StagedItem | null>(null)
const stagedGallery = ref<StagedItem[]>([])

// ---- Live (edit-flow) optimistic-preview state -------------------------
const pendingPreview = ref<Record<SingleCollection, string | null>>({ logo: null, cover: null })
const pendingGalleryPreviews = ref<string[]>([])

const removeTarget = ref<HotelMedia | null>(null)
const dragOver = ref<Collection | null>(null)

function report(e: unknown) {
  if (e instanceof ApiError && e.kind === 'validation' && e.errors) {
    app.pushToast('error', Object.values(e.errors).flat()[0] ?? t('errors.validationTitle'))
  }
  else {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  }
}

function validate(file: File): string | null {
  if (!ACCEPTED_MIMES.includes(file.type)) return t('hotels.media.invalidType')
  if (file.size > MAX_FILE_MB * 1024 * 1024) return t('hotels.media.tooLarge', { max: MAX_FILE_MB })
  return null
}

function onDragEnter(zone: Collection) {
  dragOver.value = zone
}
function onDragLeave(zone: Collection, e: DragEvent) {
  const related = e.relatedTarget as Node | null
  const current = e.currentTarget as HTMLElement | null
  if (dragOver.value === zone && (!related || !current?.contains(related))) {
    dragOver.value = null
  }
}

// ---- Single collections (logo / cover) ---------------------------------
function liveMedia(col: SingleCollection): HotelMedia | null | undefined {
  return col === 'logo' ? props.logo : props.cover
}
function stagedItem(col: SingleCollection): StagedItem | null {
  return col === 'logo' ? stagedLogo.value : stagedCover.value
}
function setStagedItem(col: SingleCollection, item: StagedItem | null) {
  if (col === 'logo') stagedLogo.value = item
  else stagedCover.value = item
}
function tileUrl(col: SingleCollection): string | null {
  if (staged.value) return stagedItem(col)?.preview ?? null
  return pendingPreview.value[col] ?? liveMedia(col)?.url ?? null
}
function isUploading(col: SingleCollection): boolean {
  return !staged.value && !!pendingPreview.value[col]
}

async function uploadNow(collection: Collection, file: File) {
  busy.value = collection
  const previewUrl = URL.createObjectURL(file)
  if (collection === 'gallery') pendingGalleryPreviews.value.push(previewUrl)
  else pendingPreview.value[collection] = previewUrl

  try {
    await hotelMediaService.upload(props.hotelId!, collection, file)
    app.pushToast('success', t('hotels.media.uploaded'))
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = null
    if (collection === 'gallery') {
      pendingGalleryPreviews.value = pendingGalleryPreviews.value.filter(u => u !== previewUrl)
    }
    else {
      pendingPreview.value[collection] = null
    }
    URL.revokeObjectURL(previewUrl)
  }
}

function pickSingle(col: SingleCollection, file: File | null | undefined) {
  if (!file || busy.value) return
  const err = validate(file)
  if (err) {
    app.pushToast('error', err)
    return
  }
  if (staged.value) {
    const prev = stagedItem(col)
    if (prev) URL.revokeObjectURL(prev.preview)
    setStagedItem(col, { file, preview: URL.createObjectURL(file) })
  }
  else {
    uploadNow(col, file)
  }
}

function onSingleInputChange(col: SingleCollection, event: Event) {
  const input = event.target as HTMLInputElement
  pickSingle(col, input.files?.[0])
  input.value = ''
}
function onSingleDrop(col: SingleCollection, event: DragEvent) {
  dragOver.value = null
  pickSingle(col, event.dataTransfer?.files?.[0])
}
function onSingleRemove(col: SingleCollection) {
  if (busy.value) return
  if (staged.value) {
    const item = stagedItem(col)
    if (item) URL.revokeObjectURL(item.preview)
    setStagedItem(col, null)
  }
  else {
    const media = liveMedia(col)
    if (media) removeTarget.value = media
  }
}

// ---- Gallery -------------------------------------------------------------
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

async function pickGallery(files: File[]) {
  for (const file of files) {
    const err = validate(file)
    if (err) {
      app.pushToast('error', err)
      continue
    }
    if (staged.value) {
      if (stagedGallery.value.length >= MAX_GALLERY) {
        app.pushToast('error', t('hotels.media.galleryFull', { max: MAX_GALLERY }))
        break
      }
      stagedGallery.value.push({ file, preview: URL.createObjectURL(file) })
    }
    else {
      // Sequential (not Promise.all) so sort_order follows drop order.
      await uploadNow('gallery', file)
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
  dragOver.value = null
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

  busy.value = 'gallery'
  try {
    await hotelMediaService.reorderGallery(props.hotelId!, items.map(m => m.id))
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = null
  }
}

// ---- Removal (persisted media only — staged removal needs no confirmation) ----
async function confirmRemove() {
  const media = removeTarget.value
  if (!media || busy.value) return
  busy.value = media.collection
  try {
    await hotelMediaService.remove(props.hotelId!, media.id)
    app.pushToast('success', t('hotels.media.removed'))
    removeTarget.value = null
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = null
  }
}

// ---- Create-flow hand-off: called by the parent form once the hotel has
// been saved and a real id exists. Uploads run sequentially (gallery order
// follows selection order) and failures are swallowed here — the caller
// decides how to surface "some images failed" as a single summary toast,
// rather than one toast per file.
async function commitStaged(hotelId: number): Promise<boolean> {
  const tasks: Array<[Collection, File]> = []
  if (stagedLogo.value) tasks.push(['logo', stagedLogo.value.file])
  if (stagedCover.value) tasks.push(['cover', stagedCover.value.file])
  for (const item of stagedGallery.value) tasks.push(['gallery', item.file])

  let allOk = true
  for (const [collection, file] of tasks) {
    try {
      // Sequential (not Promise.all) so gallery sort_order follows selection order.
      await hotelMediaService.upload(hotelId, collection, file)
    }
    catch {
      allOk = false
    }
  }

  if (stagedLogo.value) URL.revokeObjectURL(stagedLogo.value.preview)
  if (stagedCover.value) URL.revokeObjectURL(stagedCover.value.preview)
  stagedGallery.value.forEach(item => URL.revokeObjectURL(item.preview))
  stagedLogo.value = null
  stagedCover.value = null
  stagedGallery.value = []

  return allOk
}

const hasStaged = computed(() =>
  !!stagedLogo.value || !!stagedCover.value || stagedGallery.value.length > 0,
)

defineExpose({ commitStaged, hasStaged })

onBeforeUnmount(() => {
  if (stagedLogo.value) URL.revokeObjectURL(stagedLogo.value.preview)
  if (stagedCover.value) URL.revokeObjectURL(stagedCover.value.preview)
  stagedGallery.value.forEach(item => URL.revokeObjectURL(item.preview))
})
</script>

<template>
  <div class="space-y-5">
    <InfoNote v-if="staged">
      {{ t('hotels.media.stagedHint') }}
    </InfoNote>

    <!-- Logo + cover: single image each -->
    <div class="grid gap-4 sm:grid-cols-2">
      <div v-for="col in (['logo', 'cover'] as const)" :key="col">
        <p class="mb-1.5 text-2sm font-medium text-foreground">
          {{ t(`hotels.media.${col}`) }}
        </p>
        <div
          class="flex items-center gap-3 rounded-lg border p-3 transition-colors"
          :class="dragOver === col ? 'border-primary bg-primary/5' : 'border-border bg-secondary/30'"
          @dragenter.prevent="onDragEnter(col)"
          @dragover.prevent
          @dragleave="onDragLeave(col, $event)"
          @drop.prevent="onSingleDrop(col, $event)"
        >
          <div class="relative flex size-16 shrink-0 items-center justify-center overflow-hidden rounded-md bg-muted">
            <img
              v-if="tileUrl(col)"
              :src="tileUrl(col)!"
              :alt="t(`hotels.media.${col}`)"
              class="size-full object-cover"
              :class="isUploading(col) && 'opacity-60'"
            >
            <KtIcon v-else name="picture" class="text-muted-foreground" />
            <div v-if="isUploading(col)" class="absolute inset-0 flex items-center justify-center">
              <KtIcon name="loading" class="animate-spin text-primary" />
            </div>
          </div>
          <div class="flex flex-1 flex-wrap items-center gap-2">
            <label class="btn btn-secondary btn-sm cursor-pointer">
              <input
                type="file"
                :accept="ACCEPT_ATTR"
                class="hidden"
                :disabled="busy === col"
                @change="onSingleInputChange(col, $event)"
              >
              {{ tileUrl(col) ? t('hotels.media.replace') : t('hotels.media.upload') }}
            </label>
            <button
              v-if="tileUrl(col) && !isUploading(col)"
              type="button"
              class="btn btn-secondary btn-sm text-destructive"
              :disabled="busy === col"
              @click="onSingleRemove(col)"
            >
              {{ t('common.remove') }}
            </button>
            <span class="text-2xs text-muted-foreground">{{ t('hotels.media.dropHint') }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Gallery: ordered many -->
    <div>
      <div class="mb-1.5 flex items-center justify-between">
        <p class="text-2sm font-medium text-foreground">
          {{ t('hotels.media.gallery') }}
        </p>
        <label v-if="galleryItems.length" class="btn btn-secondary btn-sm cursor-pointer">
          <input type="file" :accept="ACCEPT_ATTR" multiple class="hidden" :disabled="busy === 'gallery'" @change="onGalleryInputChange">
          <KtIcon name="plus" /> {{ t('hotels.media.addMore') }}
        </label>
      </div>
      <div
        class="rounded-lg border border-dashed p-4 transition-colors"
        :class="dragOver === 'gallery' ? 'border-primary bg-primary/5' : 'border-border'"
        @dragenter.prevent="onDragEnter('gallery')"
        @dragover.prevent
        @dragleave="onDragLeave('gallery', $event)"
        @drop.prevent="onGalleryDrop"
      >
        <label v-if="!galleryItems.length" class="flex cursor-pointer flex-col items-center gap-1 py-2 text-center text-2sm text-muted-foreground">
          <input type="file" :accept="ACCEPT_ATTR" multiple class="hidden" :disabled="busy === 'gallery'" @change="onGalleryInputChange">
          <KtIcon name="cloud-add" class="text-xl" />
          <span>{{ t('hotels.media.dropHintGallery') }}</span>
        </label>
        <ul v-else class="grid gap-3 sm:grid-cols-3">
          <li v-for="(item, i) in galleryItems" :key="item.key" class="relative overflow-hidden rounded-lg border border-border">
            <img :src="item.url" alt="" class="aspect-video w-full object-cover" :class="item.uploading && 'opacity-60'">
            <div v-if="item.uploading" class="absolute inset-0 flex items-center justify-center bg-black/10">
              <KtIcon name="loading" class="animate-spin text-white" />
            </div>
            <div v-else-if="item.staged" class="absolute end-1 top-1 rounded bg-black/60 px-1.5 py-0.5 text-2xs text-white">
              {{ t('hotels.media.pending') }}
            </div>
            <div class="flex items-center justify-between gap-1 p-1.5">
              <div class="flex gap-1">
                <button type="button" class="btn btn-icon btn-sm btn-secondary" :disabled="item.uploading || !!busy || i === 0" :aria-label="t('common.moveUp')" @click="galleryMove(i, -1)">
                  <KtIcon name="up" />
                </button>
                <button type="button" class="btn btn-icon btn-sm btn-secondary" :disabled="item.uploading || !!busy || i === galleryItems.length - 1" :aria-label="t('common.moveDown')" @click="galleryMove(i, 1)">
                  <KtIcon name="down" />
                </button>
              </div>
              <button type="button" class="btn btn-icon btn-sm btn-secondary text-destructive" :disabled="item.uploading || !!busy" :aria-label="t('common.remove')" @click="galleryRemove(item)">
                <KtIcon name="trash" />
              </button>
            </div>
          </li>
        </ul>
      </div>
    </div>

    <ConfirmDialog
      :open="removeTarget !== null"
      :title="t('common.remove')"
      :message="t('hotels.media.removeConfirm')"
      tone="destructive"
      :busy="busy === removeTarget?.collection"
      @update:open="(v: boolean) => !v && (removeTarget = null)"
      @confirm="confirmRemove"
    />
  </div>
</template>
