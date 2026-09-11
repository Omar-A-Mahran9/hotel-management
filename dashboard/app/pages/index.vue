```vue
<script setup lang="ts">
import {
  hotelsService,
  reservationsService,
  roomsService,
  roomTypesService,
} from "~/services";
import { RESERVATION_STATUS_TONE } from "~/utils/reservationStateMachine";
import { date, money } from "~/utils/format";

const { t } = useI18n();
const auth = useAuthStore();
const hotelCtx = useHotelContextStore();
const { can } = useCan();

// ---------------------------------------------------------------------
// Scope
// ---------------------------------------------------------------------

const scopeLabel = computed(() =>
  hotelCtx.isAllHotels || hotelCtx.currentHotelId == null
    ? t("overview.scopeAll")
    : t("overview.scopeHotel", {
        hotel: hotelCtx.currentHotel?.name ?? "",
      }),
);

const currentHotelName = computed(() => hotelCtx.currentHotel?.name ?? "");

// ---------------------------------------------------------------------
// Hotels
// ---------------------------------------------------------------------

const canSeeHotels = can("hotels.view");

const hotels = useResource(() => hotelsService.list({ page: 1 }), {
  immediate: canSeeHotels,
});

const hotelsTotal = computed(
  () => hotels.data.value?.meta.total ?? hotelCtx.availableHotels.length,
);

// ---------------------------------------------------------------------
// Reservations
// ---------------------------------------------------------------------

const canSeeReservations = can("reservations.view");

const reservations = useResource(() => reservationsService.list(1), {
  immediate: canSeeReservations,
});

const reservationRows = computed(() => reservations.data.value?.data ?? []);

const recentReservations = computed(() => reservationRows.value.slice(0, 8));

const reservationsTotal = computed(
  () => reservations.data.value?.meta.total ?? 0,
);

// Status breakdown for the currently loaded reservation page.
const statusBreakdown = computed(() => {
  const counts: Record<string, number> = {};

  for (const reservation of reservationRows.value) {
    counts[reservation.status] = (counts[reservation.status] ?? 0) + 1;
  }

  return Object.entries(counts).sort((a, b) => b[1] - a[1]);
});

const statusTotal = computed(() =>
  statusBreakdown.value.reduce((total, [, count]) => total + count, 0),
);

function statusPercentage(count: number) {
  if (!statusTotal.value) return 0;

  return Math.round((count / statusTotal.value) * 100);
}

// ---------------------------------------------------------------------
// Inventory
// ---------------------------------------------------------------------

const canSeeInventory = can("inventory.view");

const inventoryHotelId = computed(() => hotelCtx.currentHotelId);

const inventory = useResource(
  async () => {
    const hotelId = inventoryHotelId.value;

    if (hotelId == null) return null;

    const [roomTypes, rooms] = await Promise.all([
      roomTypesService.list(hotelId),
      roomsService.list(hotelId),
    ]);

    return {
      roomTypes: roomTypes.length,
      rooms: rooms.length,
      available: rooms.filter((room) => room.status === "available").length,
      maintenance: rooms.filter((room) => room.status === "under_maintenance")
        .length,
      other: rooms.filter(
        (room) =>
          room.status !== "available" && room.status !== "under_maintenance",
      ).length,
    };
  },
  {
    immediate: false,
  },
);

watch(
  inventoryHotelId,
  () => {
    if (canSeeInventory && inventoryHotelId.value != null) {
      inventory.reload();
    }
  },
  {
    immediate: true,
  },
);

const availabilityPercentage = computed(() => {
  const data = inventory.data.value;

  if (!data?.rooms) return 0;

  return Math.round((data.available / data.rooms) * 100);
});

// ---------------------------------------------------------------------
// Quick Actions
// ---------------------------------------------------------------------

const quickActions = computed(() => {
  const actions: Array<{
    to: string;
    label: string;
    icon: string;
    primary?: boolean;
  }> = [];

  if (can("hotels.manage")) {
    actions.push({
      to: "/hotels/new",
      label: t("hotels.new"),
      icon: "plus",
      primary: true,
    });
  }

  if (can("reservations.view")) {
    actions.push({
      to: "/reservations",
      label: t("nav.reservations"),
      icon: "calendar-tick",
    });
  }

  if (can("inventory.view")) {
    actions.push({
      to: "/rooms",
      label: t("nav.rooms"),
      icon: "home-2",
    });
  }

  if (can("services.view")) {
    actions.push({
      to: "/services",
      label: t("nav.services"),
      icon: "parcel",
    });
  }

  return actions;
});
</script>

<template>
  <div class="space-y-6">
    <!-- ============================================================= -->
    <!-- Header -->
    <!-- ============================================================= -->

    <div
      class="flex flex-col gap-5 border-b border-border pb-6 lg:flex-row lg:items-end lg:justify-between"
    >
      <div class="min-w-0">
        <div class="mb-2 flex items-center gap-2">
          <span class="h-2 w-2 shrink-0 rounded-full bg-success" />

          <span class="truncate text-xs font-medium text-muted-foreground">
            {{ scopeLabel }}
          </span>
        </div>

        <h1
          class="text-2xl font-semibold tracking-tight text-foreground sm:text-3xl"
        >
          {{ t("overview.title") }}
        </h1>

        <p class="mt-1.5 text-sm text-muted-foreground">
          {{
            t("overview.welcome", {
              name: auth.user?.name ?? "",
            })
          }}
        </p>
      </div>

      <!-- Quick Actions -->

      <div v-if="quickActions.length" class="flex flex-wrap gap-2">
        <NuxtLink
          v-for="action in quickActions"
          :key="action.to"
          :to="action.to"
          class="btn"
          :class="action.primary ? 'btn-primary' : 'btn-secondary'"
        >
          <KtIcon :name="action.icon" />
          {{ action.label }}
        </NuxtLink>
      </div>
    </div>

    <!-- ============================================================= -->
    <!-- Overview KPIs -->
    <!-- ============================================================= -->

    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      <!-- Hotels -->

      <div v-if="canSeeHotels" class="card p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm text-muted-foreground">
              {{ t("nav.hotels") }}
            </p>

            <p
              class="mt-3 text-3xl font-semibold tracking-tight text-foreground"
            >
              {{ hotelsTotal }}
            </p>

            <p class="mt-1 text-xs text-muted-foreground">
              {{ scopeLabel }}
            </p>
          </div>

          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
          >
            <KtIcon name="office-bag" />
          </div>
        </div>
      </div>

      <!-- Reservations -->

      <div v-if="canSeeReservations" class="card p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm text-muted-foreground">
              {{ t("overview.reservationsTotal") }}
            </p>

            <p
              class="mt-3 text-3xl font-semibold tracking-tight text-foreground"
            >
              {{ reservationsTotal }}
            </p>

            <p class="mt-1 text-xs text-muted-foreground">
              {{ t("overview.recentReservations") }}
            </p>
          </div>

          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-info/10 text-info"
          >
            <KtIcon name="calendar-tick" />
          </div>
        </div>
      </div>

      <!-- Room Types -->

      <div v-if="canSeeInventory && inventory.data.value" class="card p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm text-muted-foreground">
              {{ t("overview.roomTypes") }}
            </p>

            <p
              class="mt-3 text-3xl font-semibold tracking-tight text-foreground"
            >
              {{ inventory.data.value.roomTypes }}
            </p>

            <p class="mt-1 truncate text-xs text-muted-foreground">
              {{ currentHotelName }}
            </p>
          </div>

          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground"
          >
            <KtIcon name="category" />
          </div>
        </div>
      </div>

      <!-- Total Rooms -->

      <div v-if="canSeeInventory && inventory.data.value" class="card p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm text-muted-foreground">
              {{ t("overview.rooms") }}
            </p>

            <p
              class="mt-3 text-3xl font-semibold tracking-tight text-foreground"
            >
              {{ inventory.data.value.rooms }}
            </p>

            <p class="mt-1 text-xs text-muted-foreground">
              {{ currentHotelName }}
            </p>
          </div>

          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-secondary text-muted-foreground"
          >
            <KtIcon name="home-2" />
          </div>
        </div>
      </div>

      <!-- Available Rooms -->

      <div v-if="canSeeInventory && inventory.data.value" class="card p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm text-muted-foreground">
              {{ t("overview.available") }}
            </p>

            <p class="mt-3 text-3xl font-semibold tracking-tight text-success">
              {{ inventory.data.value.available }}
            </p>

            <p class="mt-1 text-xs text-muted-foreground">
              {{ availabilityPercentage }}%
              {{ t("overview.available") }}
            </p>
          </div>

          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-success/10 text-success"
          >
            <KtIcon name="check" />
          </div>
        </div>

        <div class="mt-4 h-1.5 overflow-hidden rounded-full bg-secondary">
          <div
            class="h-full rounded-full bg-success transition-all"
            :style="{
              width: `${availabilityPercentage}%`,
            }"
          />
        </div>
      </div>

      <!-- Maintenance -->

      <div v-if="canSeeInventory && inventory.data.value" class="card p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm text-muted-foreground">
              {{ t("overview.maintenance") }}
            </p>

            <p class="mt-3 text-3xl font-semibold tracking-tight text-warning">
              {{ inventory.data.value.maintenance }}
            </p>

            <p class="mt-1 text-xs text-muted-foreground">
              {{ currentHotelName }}
            </p>
          </div>

          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-warning/10 text-warning"
          >
            <KtIcon name="wrench" />
          </div>
        </div>
      </div>
    </div>

    <!-- ============================================================= -->
    <!-- Main Content -->
    <!-- ============================================================= -->

    <div class="grid gap-6 xl:grid-cols-3">
      <!-- =========================================================== -->
      <!-- Recent Reservations -->
      <!-- =========================================================== -->

      <div class="xl:col-span-2">
        <DataCard :title="t('overview.recentReservations')" no-pad>
          <template v-if="canSeeReservations">
            <LoadingState v-if="reservations.pending.value" :rows="6" />

            <ErrorState
              v-else-if="reservations.error.value"
              :error="reservations.error.value"
              @retry="reservations.reload"
            />

            <EmptyState v-else-if="recentReservations.length === 0" />

            <div v-else class="overflow-x-auto">
              <table class="table-base">
                <thead>
                  <tr>
                    <th>
                      {{ t("reservations.id") }}
                    </th>

                    <th>
                      {{ t("reservations.checkIn") }}
                    </th>

                    <th>
                      {{ t("reservations.checkOut") }}
                    </th>

                    <th class="text-end">
                      {{ t("reservations.price") }}
                    </th>

                    <th>
                      {{ t("reservations.status") }}
                    </th>
                  </tr>
                </thead>

                <tbody>
                  <tr
                    v-for="reservation in recentReservations"
                    :key="reservation.id"
                    class="group transition-colors hover:bg-secondary/40"
                  >
                    <td>
                      <NuxtLink
                        :to="`/reservations/${reservation.id}`"
                        class="font-semibold text-primary hover:underline"
                      >
                        #{{ reservation.id }}
                      </NuxtLink>
                    </td>

                    <td class="whitespace-nowrap text-sm">
                      {{ date(reservation.check_in) }}
                    </td>

                    <td class="whitespace-nowrap text-sm">
                      {{ date(reservation.check_out) }}
                    </td>

                    <td
                      class="whitespace-nowrap text-end text-sm font-semibold"
                    >
                      {{ money(reservation.price_snapshot) }}
                    </td>

                    <td>
                      <StatusBadge
                        :label="t(`status.${reservation.status}`)"
                        :tone="RESERVATION_STATUS_TONE[reservation.status]"
                      />
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </template>

          <EmptyState
            v-else
            :title="t('errors.forbiddenTitle')"
            :body="t('errors.forbiddenBody')"
            icon="lock-2"
          />

          <template
            v-if="canSeeReservations && recentReservations.length"
            #footer
          >
            <NuxtLink
              to="/reservations"
              class="text-sm font-medium text-primary hover:underline"
            >
              {{ t("common.view") }}
              {{ t("nav.reservations") }}
            </NuxtLink>
          </template>
        </DataCard>
      </div>

      <!-- =========================================================== -->
      <!-- Right Column -->
      <!-- =========================================================== -->

      <div class="space-y-6">
        <!-- Inventory -->

        <DataCard :title="t('overview.inventorySnapshot')">
          <template v-if="!canSeeInventory">
            <EmptyState
              :title="t('errors.forbiddenTitle')"
              :body="t('errors.forbiddenBody')"
              icon="lock-2"
            />
          </template>

          <template v-else-if="inventoryHotelId == null">
            <div
              class="rounded-lg border border-dashed border-border px-4 py-6 text-center"
            >
              <KtIcon name="home-2" class="mb-3 text-muted-foreground" />

              <p class="text-sm text-muted-foreground">
                {{ t("overview.noHotelForInventory") }}
              </p>
            </div>
          </template>

          <template v-else>
            <LoadingState v-if="inventory.pending.value" :rows="5" />

            <ErrorState
              v-else-if="inventory.error.value"
              :error="inventory.error.value"
              @retry="inventory.reload"
            />

            <div v-else-if="inventory.data.value" class="space-y-5">
              <!-- Availability -->

              <div>
                <div class="mb-2 flex items-center justify-between">
                  <span class="text-sm text-muted-foreground">
                    {{ t("overview.available") }}
                  </span>

                  <span class="text-sm font-semibold text-success">
                    {{ inventory.data.value.available }}
                    /
                    {{ inventory.data.value.rooms }}
                  </span>
                </div>

                <div class="h-2 overflow-hidden rounded-full bg-secondary">
                  <div
                    class="h-full rounded-full bg-success"
                    :style="{
                      width: `${availabilityPercentage}%`,
                    }"
                  />
                </div>

                <p class="mt-1.5 text-xs text-muted-foreground">
                  {{ availabilityPercentage }}%
                </p>
              </div>

              <!-- Stats -->

              <div class="grid grid-cols-2 gap-3">
                <div
                  class="rounded-lg border border-border bg-secondary/30 p-3"
                >
                  <p class="text-xs text-muted-foreground">
                    {{ t("overview.roomTypes") }}
                  </p>

                  <p class="mt-1 text-xl font-semibold">
                    {{ inventory.data.value.roomTypes }}
                  </p>
                </div>

                <div
                  class="rounded-lg border border-border bg-secondary/30 p-3"
                >
                  <p class="text-xs text-muted-foreground">
                    {{ t("overview.rooms") }}
                  </p>

                  <p class="mt-1 text-xl font-semibold">
                    {{ inventory.data.value.rooms }}
                  </p>
                </div>

                <div
                  class="rounded-lg border border-success/20 bg-success/5 p-3"
                >
                  <p class="text-xs text-muted-foreground">
                    {{ t("overview.available") }}
                  </p>

                  <p class="mt-1 text-xl font-semibold text-success">
                    {{ inventory.data.value.available }}
                  </p>
                </div>

                <div
                  class="rounded-lg border border-warning/20 bg-warning/5 p-3"
                >
                  <p class="text-xs text-muted-foreground">
                    {{ t("overview.maintenance") }}
                  </p>

                  <p class="mt-1 text-xl font-semibold text-warning">
                    {{ inventory.data.value.maintenance }}
                  </p>
                </div>
              </div>
            </div>
          </template>
        </DataCard>

        <!-- ========================================================= -->
        <!-- Reservation Status -->
        <!-- ========================================================= -->

        <DataCard
          v-if="canSeeReservations && statusBreakdown.length"
          :title="t('overview.statusBreakdown')"
        >
          <div class="space-y-4">
            <div v-for="[status, count] in statusBreakdown" :key="status">
              <div class="mb-2 flex items-center justify-between gap-3">
                <StatusBadge
                  :label="t(`status.${status}`)"
                  :tone="
                    RESERVATION_STATUS_TONE[
                      status as keyof typeof RESERVATION_STATUS_TONE
                    ]
                  "
                />

                <div class="flex items-center gap-2">
                  <span class="text-sm font-semibold text-foreground">
                    {{ count }}
                  </span>

                  <span class="text-xs text-muted-foreground">
                    {{ statusPercentage(count) }}%
                  </span>
                </div>
              </div>

              <div class="h-1.5 overflow-hidden rounded-full bg-secondary">
                <div
                  class="h-full rounded-full bg-primary"
                  :style="{
                    width: `${statusPercentage(count)}%`,
                  }"
                />
              </div>
            </div>

            <div class="border-t border-border pt-3">
              <p class="text-xs leading-5 text-muted-foreground">
                {{ t("overview.recentReservations") }}
              </p>
            </div>
          </div>
        </DataCard>
      </div>
    </div>
  </div>
</template>
