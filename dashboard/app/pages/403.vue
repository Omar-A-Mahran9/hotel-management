<script setup lang="ts">
// Reached by the global auth middleware when a route's meta.permission is
// not held. The backend remains the real authority on every request.
</script>

<template>
  <ForbiddenState />
</template>
