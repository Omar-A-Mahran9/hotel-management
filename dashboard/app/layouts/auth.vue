<script setup lang="ts">
import authHeroImage from "~/assets/08_aa952c3af5525787e169a59be6585c8c5e0280ee.jpg";

const { t } = useI18n();
</script>

<template>
  <div class="min-h-screen bg-background">
    <div class="grid min-h-screen lg:grid-cols-[42%_58%]">
      <!-- ================================================================ -->
      <!-- Authentication                                                    -->
      <!-- ================================================================ -->

      <section
        class="relative flex min-h-screen items-center justify-center overflow-hidden bg-background px-6 py-10 sm:px-10 lg:px-12 xl:px-20"
      >
        <!-- Subtle background decoration -->
        <div
          class="pointer-events-none absolute -start-32 -top-32 size-72 rounded-full bg-primary/5 blur-3xl"
        />

        <div
          class="pointer-events-none absolute -bottom-40 -end-40 size-96 rounded-full bg-primary/[0.03] blur-3xl"
        />

        <div class="relative z-10 w-full max-w-[420px]">
          <!-- Logo -->
          <div class="mb-10">
            <AppLogo />
          </div>

          <!-- Page content -->
          <div>
            <slot />
          </div>

          <!-- Footer -->
          <div
            class="mt-10 flex items-center justify-center gap-2 text-center text-2xs text-muted-foreground"
          >
            <span class="size-1.5 rounded-full bg-primary/70" />
            <span>
              {{ t("auth.platformName") }}
            </span>
          </div>
        </div>
      </section>

      <!-- ================================================================ -->
      <!-- Hero                                                              -->
      <!-- ================================================================ -->

      <section class="relative hidden min-h-screen overflow-hidden lg:block">
        <!-- Image -->
        <img
          :src="authHeroImage"
          alt=""
          aria-hidden="true"
          class="absolute inset-0 h-full w-full object-cover"
        />

        <!-- Primary brand overlay -->
        <div
          class="absolute inset-0"
          style="
            background: linear-gradient(
              135deg,
              color-mix(in oklab, var(--primary), black 18%) 0%,
              color-mix(in oklab, var(--primary), transparent 22%) 55%,
              color-mix(in oklab, var(--primary), black 28%) 100%
            );
          "
        />

        <!-- Dark cinematic gradient -->
        <div
          class="absolute inset-0 bg-gradient-to-t from-black/65 via-black/10 to-black/20"
        />

        <!-- Soft highlight -->
        <div
          class="pointer-events-none absolute -end-32 -top-32 size-[420px] rounded-full bg-white/10 blur-3xl"
        />

        <!-- Content -->
        <div
          class="relative z-10 flex min-h-screen flex-col justify-between p-10 xl:p-14 2xl:p-16"
        >
          <!-- Top branding -->
          <div class="flex items-center justify-between">
            <div
              class="inline-flex items-center gap-2.5 rounded-full border border-white/15 bg-white/10 px-3.5 py-2 text-xs font-medium text-white shadow-sm backdrop-blur-md"
            >
              <span
                class="size-2 rounded-full bg-white shadow-[0_0_0_3px_rgba(255,255,255,0.12)]"
              />

              {{ t("auth.platformName") }}
            </div>
          </div>

          <!-- Hero copy -->
          <div class="max-w-[620px]">
            <!-- Icon -->
            <div
              class="mb-7 flex size-14 items-center justify-center rounded-2xl border border-white/15 bg-white/10 text-white shadow-xl backdrop-blur-md"
            >
              <KtIcon name="bank" variant="duotone" class="text-[28px]" />
            </div>

            <!-- Heading -->
            <h1
              class="max-w-[580px] text-3xl font-bold leading-[1.15] tracking-tight text-white xl:text-4xl 2xl:text-[44px]"
            >
              {{ t("auth.heroTitle") }}
            </h1>

            <!-- Description -->
            <p
              class="mt-5 max-w-[560px] text-sm leading-7 text-white/75 xl:text-base"
            >
              {{ t("auth.heroDescription") }}
            </p>

            <!-- Capabilities -->
            <div class="mt-8 flex flex-wrap gap-2">
              <span
                class="rounded-full border border-white/15 bg-white/10 px-3.5 py-2 text-xs font-medium text-white/90 backdrop-blur-sm"
              >
                {{ t("auth.hotels") }}
              </span>

              <span
                class="rounded-full border border-white/15 bg-white/10 px-3.5 py-2 text-xs font-medium text-white/90 backdrop-blur-sm"
              >
                {{ t("auth.rooms") }}
              </span>

              <span
                class="rounded-full border border-white/15 bg-white/10 px-3.5 py-2 text-xs font-medium text-white/90 backdrop-blur-sm"
              >
                {{ t("auth.reservations") }}
              </span>

              <span
                class="rounded-full border border-white/15 bg-white/10 px-3.5 py-2 text-xs font-medium text-white/90 backdrop-blur-sm"
              >
                {{ t("auth.frontDesk") }}
              </span>
            </div>
          </div>

          <!-- Bottom -->
          <div
            class="flex items-center justify-between gap-6 border-t border-white/10 pt-5 text-2xs text-white/55"
          >
            <span>
              {{ t("auth.secureManagement") }}
            </span>

            <span>
              {{ t("auth.allInOnePlatform") }}
            </span>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>
