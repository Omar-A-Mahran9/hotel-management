<script setup lang="ts">
import type { Facility } from "~/types/api";

definePageMeta({ permission: "facilities.manage" });

const { t } = useI18n();
const router = useRouter();

function onSaved(_facility: Facility) {
  router.push("/facilities");
}
</script>

<template>
  <div class="space-y-6">
    <!-- Header -->
    <PageHeader
      :title="t('facilities.new')"
      :subtitle="t('facilities.newDesc')"
    >
      <template #actions>
        <NuxtLink to="/facilities" class="btn btn-secondary">
          <KtIcon name="left" />
          {{ t("common.back") }}
        </NuxtLink>
      </template>
    </PageHeader>

    <!-- Content -->
    <div class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_300px]">
      <!-- Main -->
      <section
        class="min-w-0 overflow-hidden rounded-2xl border border-border bg-card"
      >
        <!-- Header -->
        <div class="border-b border-border px-5 py-5 sm:px-6">
          <div class="flex items-center gap-3">
            <div
              class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
            >
              <KtIcon name="office-bag" />
            </div>

            <div class="min-w-0">
              <h2 class="text-base font-semibold text-foreground">
                {{ t("facilities.new") }}
              </h2>

              <p class="mt-1 text-sm text-muted-foreground">
                {{ t("facilities.newDesc") }}
              </p>
            </div>
          </div>
        </div>

        <!-- Form -->
        <div class="px-5 py-6 sm:px-6">
          <FacilityForm @saved="onSaved" />
        </div>
      </section>

      <!-- Sidebar -->
      <aside class="space-y-4">
        <!-- Information -->
        <div class="rounded-2xl border border-border bg-card p-5">
          <div class="mb-5 flex items-center gap-3">
            <div
              class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
            >
              <KtIcon name="information" />
            </div>

            <div>
              <h3 class="text-sm font-semibold text-foreground">
                {{ t("common.information") }}
              </h3>

              <p class="mt-0.5 text-xs text-muted-foreground">
                {{ t("facilities.newDesc") }}
              </p>
            </div>
          </div>

          <div class="space-y-4">
            <!-- Step 1 -->
            <div class="flex items-start gap-3">
              <div
                class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-primary/10 text-xs font-semibold text-primary"
              >
                1
              </div>

              <div class="min-w-0">
                <p class="text-sm font-medium text-foreground">
                  {{ t("facilities.new") }}
                </p>

                <p class="mt-1 text-xs leading-5 text-muted-foreground">
                  {{ t("facilities.newDesc") }}
                </p>
              </div>
            </div>

            <!-- Connector -->
            <div class="ms-3.5 h-3 w-px bg-border" />

            <!-- Step 2 -->
            <div class="flex items-start gap-3">
              <div
                class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-secondary text-xs font-semibold text-muted-foreground"
              >
                2
              </div>

              <div class="min-w-0">
                <p class="text-sm font-medium text-foreground">
                  {{ t("common.save") }}
                </p>

                <p class="mt-1 text-xs leading-5 text-muted-foreground">
                  {{ t("facilities.newDesc") }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Security -->
        <div class="rounded-2xl border border-primary/20 bg-primary/5 p-5">
          <div class="flex items-start gap-3">
            <div
              class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
            >
              <KtIcon name="shield-tick" />
            </div>

            <div class="min-w-0">
              <h3 class="text-sm font-semibold text-foreground">
                {{ t("common.security") }}
              </h3>

              <p class="mt-1.5 text-xs leading-5 text-muted-foreground">
                {{ t("facilities.newDesc") }}
              </p>
            </div>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>
