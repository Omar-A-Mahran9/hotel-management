<script setup lang="ts">
const auth = useAuthStore()
const { t } = useI18n()
const router = useRouter()
const app = useAppStore()

const initials = computed(() => {
  const n = auth.user?.name?.trim() ?? '?'
  return n.split(/\s+/).slice(0, 2).map(p => p[0]?.toUpperCase()).join('')
})

const roleName = computed(() => auth.user?.role?.name ?? '')

async function signOut() {
  await auth.logout()
  app.pushToast('info', t('auth.signOut'))
  router.push('/login')
}
</script>

<template>
  <AppDropdown width="15rem">
    <template #trigger>
      <button type="button" class="flex items-center gap-2 rounded-lg p-1 hover:bg-secondary">
        <span class="flex size-8 items-center justify-center rounded-full bg-primary/15 text-2sm font-bold text-primary">
          {{ initials }}
        </span>
        <span class="hidden text-start leading-tight sm:block">
          <span class="block text-2sm font-semibold text-foreground">{{ auth.user?.name }}</span>
          <span class="block text-2xs text-muted-foreground">{{ roleName }}</span>
        </span>
        <KtIcon name="down" class="hidden text-2xs sm:block" />
      </button>
    </template>

    <div class="px-2.5 py-2">
      <div class="text-2sm font-semibold text-foreground">
        {{ auth.user?.name }}
      </div>
      <div class="text-2xs text-muted-foreground">
        {{ auth.user?.email }}
      </div>
    </div>
    <div class="my-1 h-px bg-border" />
    <button
      type="button"
      class="flex w-full items-center gap-2 rounded-md px-2.5 py-2 text-start text-sm text-destructive hover:bg-secondary"
      @click="signOut"
    >
      <KtIcon name="exit-right" />
      {{ t('auth.signOut') }}
    </button>
  </AppDropdown>
</template>
