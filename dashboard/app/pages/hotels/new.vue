<script setup lang="ts">
import { hotelGroupsService } from "~/services";
import type { Hotel } from "~/types/api";

definePageMeta({
  permission: "hotels.manage",
});

const { t } = useI18n();
const router = useRouter();

const groups = useResource(() => hotelGroupsService.list());

function onSaved(hotel: Hotel) {
  router.push(`/hotels/${hotel.id}`);
}
</script>

<template>
  <div class="space-y-6">
    <!-- ================================================================ -->
    <!-- Header                                                           -->
    <!-- ================================================================ -->

    <header
      class="flex flex-col gap-4 border-b border-border pb-5 sm:flex-row sm:items-end sm:justify-between"
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

          <span>
            {{ t("hotels.new") }}
          </span>
        </nav>

        <!-- Title -->

        <div class="flex items-center gap-3">
          <div
            class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
          >
            <KtIcon name="office-bag" />
          </div>

          <div class="min-w-0">
            <h1
              class="text-2xl font-semibold tracking-tight text-foreground sm:text-3xl"
            >
              {{ t("hotels.new") }}
            </h1>

            <p class="mt-1 text-sm text-muted-foreground">
              {{ t("hotels.newDesc") }}
            </p>
          </div>
        </div>
      </div>

      <!-- Back -->

      <NuxtLink to="/hotels" class="btn btn-secondary shrink-0">
        <KtIcon name="left" />
        {{ t("common.back") }}
      </NuxtLink>
    </header>

    <!-- ================================================================ -->
    <!-- Groups Error                                                      -->
    <!-- ================================================================ -->

    <ErrorState
      v-if="groups.error.value"
      :error="groups.error.value"
      @retry="groups.reload"
    />

    <!-- ================================================================ -->
    <!-- Content                                                           -->
    <!-- ================================================================ -->

    <template v-else>
      <div class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_300px]">
        <!-- ============================================================ -->
        <!-- Main Form                                                     -->
        <!-- ============================================================ -->

        <main
          class="min-w-0 overflow-hidden rounded-2xl border border-border bg-card"
        >
          <!-- Form header -->

          <div
            class="flex items-center gap-3 border-b border-border px-5 py-4 sm:px-6"
          >
            <div
              class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground"
            >
              <KtIcon name="add-circle" />
            </div>

            <div class="min-w-0">
              <h2 class="text-sm font-semibold text-foreground">
                {{ t("hotels.new") }}
              </h2>

              <p class="mt-0.5 text-xs text-muted-foreground">
                {{ t("hotels.newDesc") }}
              </p>
            </div>
          </div>

          <!-- Form -->

          <div class="px-5 py-6 sm:px-6 lg:px-8">
            <HotelForm
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
          <!-- Creation flow -->

          <section class="rounded-2xl border border-border bg-card p-5">
            <div class="flex items-center gap-3">
              <div
                class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
              >
                <KtIcon name="clipboard-text" />
              </div>

              <div>
                <h2 class="text-sm font-semibold text-foreground">
                  {{ t("hotels.new") }}
                </h2>

                <p class="text-xs text-muted-foreground">
                  {{ t("hotels.newDesc") }}
                </p>
              </div>
            </div>

            <div class="mt-5 space-y-4">
              <!-- Step 1 -->

              <div class="flex gap-3">
                <div
                  class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-foreground"
                >
                  1
                </div>

                <div class="pt-0.5">
                  <p class="text-sm font-medium text-foreground">
                    {{ t("hotels.information") }}
                  </p>

                  <p class="mt-0.5 text-xs leading-5 text-muted-foreground">
                    {{ t("hotels.newDesc") }}
                  </p>
                </div>
              </div>

              <!-- Connector -->

              <div class="ms-3.5 h-3 border-s border-border" />

              <!-- Step 2 -->

              <div class="flex gap-3">
                <div
                  class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-secondary text-xs font-semibold text-muted-foreground"
                >
                  2
                </div>

                <div class="pt-0.5">
                  <p class="text-sm font-medium text-foreground">
                    {{ t("hotels.facilitiesLabel") }}
                  </p>

                  <p class="mt-0.5 text-xs leading-5 text-muted-foreground">
                    {{ t("hotels.facilitiesLabel") }}
                  </p>
                </div>
              </div>

              <div class="ms-3.5 h-3 border-s border-border" />

              <!-- Step 3 -->

              <div class="flex gap-3">
                <div
                  class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-secondary text-xs font-semibold text-muted-foreground"
                >
                  3
                </div>

                <div class="pt-0.5">
                  <p class="text-sm font-medium text-foreground">
                    {{ t("hotels.sectionSeo") }}
                  </p>

                  <p class="mt-0.5 text-xs leading-5 text-muted-foreground">
                    {{ t("hotels.sectionSeo") }}
                  </p>
                </div>
              </div>
            </div>
          </section>

          <!-- Hotel group -->

          <section class="rounded-2xl border border-border bg-card p-5">
            <div class="flex items-start gap-3">
              <div
                class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground"
              >
                <KtIcon name="category" />
              </div>

              <div class="min-w-0">
                <p class="text-sm font-semibold text-foreground">
                  {{ t("hotels.group") }}
                </p>

                <p class="mt-1 text-xs leading-5 text-muted-foreground">
                  {{
                    groups.pending.value
                      ? t("common.loading")
                      : `${groups.data.value?.length ?? 0} ${t("hotels.group")}`
                  }}
                </p>
              </div>
            </div>
          </section>

          <!-- Security / status -->

          <section
            class="rounded-2xl border border-primary/15 bg-primary/5 p-5"
          >
            <div class="flex items-start gap-3">
              <div
                class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
              >
                <KtIcon name="shield-tick" />
              </div>

              <div>
                <p class="text-sm font-semibold text-foreground">
                  {{ t("common.security") }}
                </p>

                <p class="mt-1 text-xs leading-5 text-muted-foreground">
                  {{ t("hotels.newDesc") }}
                </p>
              </div>
            </div>
          </section>
        </aside>
      </div>
    </template>
  </div>
</template>
