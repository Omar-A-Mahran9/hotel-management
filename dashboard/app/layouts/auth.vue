<template>
  <div class="flex min-h-screen bg-background">
    <div class="flex w-full flex-col justify-center px-6 py-12 sm:px-12 lg:w-[46%] lg:px-20">
      <div class="mx-auto w-full max-w-sm">
        <AppLogo class="mb-10" />
        <slot />
      </div>
    </div>
    <div
      class="relative hidden flex-1 lg:block"
      style="background: linear-gradient(150deg, var(--primary), color-mix(in oklab, var(--accent), black 8%));"
    >
      <div class="absolute inset-0 flex flex-col justify-end p-16 text-primary-foreground">
        <div class="mb-4 flex size-12 items-center justify-center rounded-xl bg-white/15">
          <KtIcon name="bank" variant="duotone" class="text-2xl" />
        </div>
        <p class="max-w-md text-2xl font-semibold leading-snug">
          One dashboard for the whole group — hotels, rooms, reservations and the front desk.
        </p>
      </div>
    </div>
  </div>
</template>
