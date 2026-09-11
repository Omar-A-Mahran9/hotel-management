<script setup lang="ts">
import { hotelGroupsService, hotelsService } from "~/services";
import type { Hotel } from "~/types/api";

definePageMeta({
  permission: "hotels.manage",
});

const { t } = useI18n();
const route = useRoute();
const router = useRouter();

const id = Number(route.params.id);

const hotel = useResource(() => hotelsService.get(id));
const groups = useResource(() => hotelGroupsService.list());

function onSaved(saved: Hotel) {
  router.push(`/hotels/${saved.id}`);
}
</script>

<template>
  <div class="space-y-6">
    <!-- ================================================================== -->
    <!-- Header                                                             -->
    <!-- ================================================================== -->

    <header
      class="flex flex-col gap-4 border-b border-border pb-5 lg:flex-row lg:items-end lg:justify-between"
    >
      <div class="min-w-0">
        <!-- Breadcrumb -->

        <nav class="mb-2 flex items-center gap-2 text-xs text-muted-foreground">
          <NuxtLink
            to="/hotels"
            class="transition-colors hover:text-foreground"
          >
            {{ t("nav.hotels") }}
          </NuxtLink>

          <KtIcon name="right" class="shrink-0 text-[10px]" />

          <span class="truncate">
            {{ hotel.data.value?.name || t("common.edit") }}
          </span>
        </nav>

        <!-- Title -->

        <div class="flex min-w-0 items-center gap-3">
          <div
            class="hidden h-11 w-11 shrink-0 items-center justify-center overflow-hidden rounded-xl border border-border bg-secondary sm:flex"
          >
            <AppImage
              v-if="hotel.data.value"
              :alt="hotel.data.value.name"
              :name="hotel.data.value.name"
              :src="hotel.data.value.logo?.url"
              size="2.75rem"
            />

            <KtIcon v-else name="office-bag" class="text-muted-foreground" />
          </div>

          <div class="min-w-0">
            <h1
              class="truncate text-2xl font-semibold tracking-tight text-foreground sm:text-3xl"
            >
              {{
                hotel.data.value
                  ? t("hotels.editTitleNamed", {
                      name: hotel.data.value.name,
                    })
                  : t("hotels.editTitle")
              }}
            </h1>

            <p class="mt-1 max-w-2xl text-sm text-muted-foreground">
              {{ t("hotels.editDesc") }}
            </p>
          </div>
        </div>
      </div>

      <!-- Actions -->

      <div class="flex shrink-0 gap-2">
        <NuxtLink :to="`/hotels/${id}`" class="btn btn-secondary">
          <KtIcon name="eye" />
          {{ t("common.view") }}
        </NuxtLink>

        <NuxtLink to="/hotels" class="btn btn-secondary">
          <KtIcon name="left" />
          {{ t("common.back") }}
        </NuxtLink>
      </div>
    </header>

    <!-- ================================================================== -->
    <!-- Loading                                                            -->
    <!-- ================================================================== -->

    <LoadingState v-if="hotel.pending.value" :rows="8" />

    <!-- ================================================================== -->
    <!-- Hotel Error                                                        -->
    <!-- ================================================================== -->

    <ErrorState
      v-else-if="hotel.error.value"
      :error="hotel.error.value"
      @retry="hotel.reload"
    />

    <!-- ================================================================== -->
    <!-- Content                                                            -->
    <!-- ================================================================== -->

    <template v-else-if="hotel.data.value">
      <div class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_300px]">
        <!-- ============================================================ -->
        <!-- Main Form                                                     -->
        <!-- ============================================================ -->

        <main
          class="min-w-0 overflow-hidden rounded-2xl border border-border bg-card"
        >
          <!-- Form intro -->

          <div
            class="flex items-center justify-between gap-4 border-b border-border px-5 py-4 sm:px-6"
          >
            <div class="flex min-w-0 items-center gap-3">
              <div
                class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
              >
                <KtIcon name="pencil" />
              </div>

              <div class="min-w-0">
                <h2 class="text-sm font-semibold text-foreground">
                  {{ t("common.edit") }}
                </h2>

                <p class="truncate text-xs text-muted-foreground">
                  {{ hotel.data.value.name }}
                </p>
              </div>
            </div>

            <!-- Status -->

            <StatusBadge
              :label="
                hotel.data.value.is_active
                  ? t('common.active')
                  : t('common.inactive')
              "
              :tone="hotel.data.value.is_active ? 'success' : 'neutral'"
            />
          </div>

          <!-- Form -->

          <div class="px-5 py-6 sm:px-6 lg:px-8">
            <ErrorState
              v-if="groups.error.value"
              :error="groups.error.value"
              @retry="groups.reload"
            />

            <HotelForm
              v-else
              :hotel="hotel.data.value"
              :groups="groups.data.value ?? []"
              :groups-pending="groups.pending.value"
              @saved="onSaved"
            />
          </div>
        </main>

        <!-- ============================================================ -->
        <!-- Sidebar                                                       -->
        <!-- ============================================================ -->

        <aside class="space-y-4">
          <!-- Hotel Preview -->

          <section
            class="overflow-hidden rounded-2xl border border-border bg-card"
          >
            <!-- Cover -->

            <div class="relative h-32 overflow-hidden bg-secondary">
              <img
                v-if="hotel.data.value.cover?.url"
                :src="hotel.data.value.cover.url"
                :alt="hotel.data.value.name"
                class="h-full w-full object-cover"
              />

              <div v-else class="flex h-full items-center justify-center">
                <KtIcon name="picture" class="text-2xl text-muted-foreground" />
              </div>

              <div
                class="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent"
              />
            </div>

            <div class="px-5 pb-5">
              <div class="-mt-7 flex items-end gap-3">
                <div
                  class="flex h-14 w-14 shrink-0 items-center justify-center overflow-hidden rounded-xl border-4 border-card bg-card shadow-sm"
                >
                  <AppImage
                    :alt="hotel.data.value.name"
                    :name="hotel.data.value.name"
                    :src="hotel.data.value.logo?.url"
                    size="3rem"
                  />
                </div>
              </div>

              <div class="mt-3">
                <h3 class="truncate text-sm font-semibold text-foreground">
                  {{ hotel.data.value.name }}
                </h3>

                <p
                  v-if="hotel.data.value.slug"
                  class="mt-1 truncate text-xs text-muted-foreground"
                >
                  /hotels/{{ hotel.data.value.slug }}
                </p>
              </div>

              <div
                class="mt-4 flex items-center justify-between border-t border-border pt-4"
              >
                <span class="text-xs text-muted-foreground">
                  {{ t("common.status") }}
                </span>

                <StatusBadge
                  :label="
                    hotel.data.value.is_active
                      ? t('common.active')
                      : t('common.inactive')
                  "
                  :tone="hotel.data.value.is_active ? 'success' : 'neutral'"
                />
              </div>
            </div>
          </section>

          <!-- Editing guidance -->

          <section class="rounded-2xl border border-border bg-card p-5">
            <div class="flex items-start gap-3">
              <div
                class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground"
              >
                <KtIcon name="information-2" />
              </div>

              <div class="min-w-0">
                <h3 class="text-sm font-semibold text-foreground">
                  {{ t("common.information") }}
                </h3>

                <p class="mt-1.5 text-xs leading-5 text-muted-foreground">
                  {{ t("hotels.editDesc") }}
                </p>
              </div>
            </div>
          </section>

          <!-- Quick navigation -->

          <section class="rounded-2xl border border-border bg-card p-2">
            <NuxtLink
              :to="`/hotels/${id}`"
              class="group flex items-center gap-3 rounded-xl px-3 py-3 transition-colors hover:bg-secondary/60"
            >
              <div
                class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground group-hover:text-primary"
              >
                <KtIcon name="eye" />
              </div>

              <div class="min-w-0">
                <p class="text-sm font-medium text-foreground">
                  {{ t("common.view") }}
                </p>

                <p class="truncate text-xs text-muted-foreground">
                  {{ hotel.data.value.name }}
                </p>
              </div>

              <KtIcon
                name="right"
                class="ms-auto shrink-0 text-muted-foreground"
              />
            </NuxtLink>
          </section>
        </aside>
      </div>
    </template>
  </div>
</template>
