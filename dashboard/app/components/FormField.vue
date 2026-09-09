<script setup lang="ts">
defineProps<{ label: string, error?: string[] | string | null, hint?: string, required?: boolean, forId?: string }>()
</script>

<template>
  <div class="flex flex-col gap-1.5">
    <label v-if="label" :for="forId" class="text-2sm font-medium text-foreground">
      {{ label }}
      <span v-if="required" class="text-destructive">*</span>
    </label>
    <slot />
    <p v-if="hint && !error" class="text-2xs text-muted-foreground">
      {{ hint }}
    </p>
    <template v-if="error">
      <p
        v-for="(msg, i) in (Array.isArray(error) ? error : [error])"
        :key="i"
        class="text-2xs font-medium text-destructive"
      >
        {{ msg }}
      </p>
    </template>
  </div>
</template>
