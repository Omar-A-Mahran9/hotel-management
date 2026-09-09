<script setup lang="ts">
import { rbacService } from '~/services'

definePageMeta({ permission: 'roles.view' })

const { t } = useI18n()
const roles = useResource(() => rbacService.roles())
</script>

<template>
  <div>
    <PageHeader :title="t('roles.title')" :subtitle="t('roles.subtitle')" />

    <LoadingState v-if="roles.pending.value" :rows="4" />
    <ErrorState v-else-if="roles.error.value" :error="roles.error.value" @retry="roles.reload" />
    <div v-else class="space-y-4">
      <DataCard v-for="role in roles.data.value ?? []" :key="role.id">
        <template #header>
          <div class="flex items-center gap-2">
            <KtIcon name="shield-tick" class="text-primary" />
            <span>{{ role.name }}</span>
            <code class="rounded bg-secondary px-1.5 py-0.5 text-2xs text-muted-foreground">{{ role.slug }}</code>
          </div>
        </template>
        <p v-if="role.description" class="mb-3 text-sm text-muted-foreground">
          {{ role.description }}
        </p>
        <div class="flex flex-wrap gap-1.5">
          <span
            v-for="p in role.permissions ?? []"
            :key="p.id"
            class="rounded-md bg-primary/10 px-2 py-0.5 text-2xs font-medium text-primary"
            :title="p.description ?? ''"
          >
            {{ p.slug }}
          </span>
          <span v-if="(role.permissions?.length ?? 0) === 0" class="text-2xs text-muted-foreground">
            {{ t('common.none') }}
          </span>
        </div>
      </DataCard>
    </div>
  </div>
</template>
