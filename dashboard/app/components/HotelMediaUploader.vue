<script setup lang="ts">
import type { HotelMedia } from '~/types/api'
import { hotelMediaService } from '~/services'
import { ApiError } from '~/utils/apiError'

const props = defineProps<{
  hotelId: number
  logo?: HotelMedia | null
  cover?: HotelMedia | null
  gallery?: HotelMedia[]
}>()

// Bubble every successful change so the parent reloads the hotel and keeps
// the embedded media relations current.
const emit = defineEmits<{ changed: [] }>()

const { t } = useI18n()
const app = useAppStore()

const busy = ref<string | null>(null) // collection currently uploading/mutating

function report(e: unknown) {
  if (e instanceof ApiError && e.kind === 'validation' && e.errors) {
    app.pushToast('error', Object.values(e.errors).flat()[0] ?? t('errors.validationTitle'))
  }
  else {
    app.pushToast('error', e instanceof ApiError ? e.message : t('errors.genericBody'))
  }
}

async function upload(collection: HotelMedia['collection'], event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  input.value = ''
  if (!file || busy.value)
    return

  busy.value = collection
  try {
    await hotelMediaService.upload(props.hotelId, collection, file)
    app.pushToast('success', t('hotels.media.uploaded'))
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = null
  }
}

async function remove(media: HotelMedia) {
  if (busy.value || !window.confirm(t('hotels.media.removeConfirm')))
    return
  busy.value = media.collection
  try {
    await hotelMediaService.remove(props.hotelId, media.id)
    app.pushToast('success', t('hotels.media.removed'))
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = null
  }
}

async function move(index: number, delta: number) {
  const items = [...(props.gallery ?? [])]
  const target = index + delta
  if (busy.value || target < 0 || target >= items.length)
    return
  ;[items[index], items[target]] = [items[target]!, items[index]!]

  busy.value = 'gallery'
  try {
    await hotelMediaService.reorderGallery(props.hotelId, items.map(m => m.id))
    emit('changed')
  }
  catch (e) {
    report(e)
  }
  finally {
    busy.value = null
  }
}
</script>

<template>
  <div class="space-y-5">
    <!-- Logo + cover: single image each -->
    <div class="grid gap-4 sm:grid-cols-2">
      <div v-for="col in (['logo', 'cover'] as const)" :key="col">
        <p class="mb-1.5 text-2sm font-medium text-foreground">
          {{ t(`hotels.media.${col}`) }}
        </p>
        <div class="flex items-center gap-3 rounded-lg border border-border bg-secondary/30 p-3">
          <div class="flex size-16 shrink-0 items-center justify-center overflow-hidden rounded-md bg-muted">
            <img
              v-if="col === 'logo' ? logo : cover"
              :src="(col === 'logo' ? logo : cover)!.url"
              :alt="t(`hotels.media.${col}`)"
              class="size-full object-cover"
            >
            <KtIcon v-else name="picture" class="text-muted-foreground" />
          </div>
          <div class="flex flex-wrap gap-2">
            <label class="btn btn-secondary btn-sm cursor-pointer">
              <input type="file" accept="image/*" class="hidden" :disabled="busy === col" @change="(e) => upload(col, e)">
              {{ (col === 'logo' ? logo : cover) ? t('hotels.media.replace') : t('hotels.media.upload') }}
            </label>
            <button
              v-if="col === 'logo' ? logo : cover"
              type="button"
              class="btn btn-secondary btn-sm text-destructive"
              :disabled="busy === col"
              @click="remove((col === 'logo' ? logo : cover)!)"
            >
              {{ t('common.remove') }}
            </button>
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
        <label class="btn btn-secondary btn-sm cursor-pointer">
          <input type="file" accept="image/*" class="hidden" :disabled="busy === 'gallery'" @change="(e) => upload('gallery', e)">
          <KtIcon name="plus" />
          {{ t('hotels.media.addImage') }}
        </label>
      </div>
      <p v-if="!(gallery && gallery.length)" class="rounded-lg border border-dashed border-border p-4 text-center text-2sm text-muted-foreground">
        {{ t('hotels.media.galleryEmpty') }}
      </p>
      <ul v-else class="grid gap-3 sm:grid-cols-3">
        <li v-for="(m, i) in gallery" :key="m.id" class="overflow-hidden rounded-lg border border-border">
          <img :src="m.url" alt="" class="aspect-video w-full object-cover">
          <div class="flex items-center justify-between gap-1 p-1.5">
            <div class="flex gap-1">
              <button type="button" class="btn btn-icon btn-sm btn-secondary" :disabled="i === 0 || !!busy" :aria-label="t('common.moveUp')" @click="move(i, -1)">
                <KtIcon name="up" />
              </button>
              <button type="button" class="btn btn-icon btn-sm btn-secondary" :disabled="i === gallery.length - 1 || !!busy" :aria-label="t('common.moveDown')" @click="move(i, 1)">
                <KtIcon name="down" />
              </button>
            </div>
            <button type="button" class="btn btn-icon btn-sm btn-secondary text-destructive" :disabled="!!busy" :aria-label="t('common.remove')" @click="remove(m)">
              <KtIcon name="trash" />
            </button>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
