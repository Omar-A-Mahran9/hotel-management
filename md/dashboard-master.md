# Dashboard — Master Implementation

Builds on `md/dashboard-foundation.md` (Phase 12 foundation) and its audit
`md/dashboard-foundation-audit.md`. This document records the completion pass:
the unified `dashboard/` Nuxt 3 + Metronic 9 app extended from the foundation
slice to a full operational dashboard against the **existing, tested**
Laravel `/api/v1`.

**Build status:** ✅ lint · ✅ typecheck · ✅ 38 unit tests · ✅ production build ·
SPA server boots and serves 200.
**Backend changes:** none. **Mobile changes:** none. **Not committed.**

---

## 1. What changed vs the foundation

The foundation delivered login, overview, and read-only Hotels / Room types /
Rooms / Reservations / Users / Roles. This pass adds:

| Area | Added |
|---|---|
| Navigation | Rebuilt to the full information architecture: Main · Hotels · Operations · Finance · Customer · Reports · Administration · Settings. One `config/navigation.ts` with `permission` + `scope` + `backendGap` metadata. |
| Hotels | Create + edit forms (`hotels.manage`), activate/deactivate via `is_active`. |
| Room types | Full CRUD + activate / deactivate (`inventory.manage`). |
| Rooms | Create + edit + status transition (`available` / `under_maintenance`; backend state machine authoritative). |
| Stay services | New module: service **categories** + **services** CRUD + activate/deactivate, hotel-scoped (`services.view` / `services.manage`). |
| Reservation detail | Rebuilt as the **operational workspace**: tabbed panels for Payment, Identity verification, Digital access / check-in, Folio, Service orders, Checkout, Invoice, Loyalty, Notifications — each gated by its own backend permission, each calling only real reservation-scoped endpoints. Status transitions unchanged (UI mirror of the reservation state machine). |
| Users | Full CRUD (`users.manage`) incl. role + hotel assignment; hard delete with confirm. |
| Hotel group | New page: group profile edit + **loyalty rule** configuration (`hotel-groups.manage` / `loyalty.rules.manage`, Group Owner). |
| Roles | Added a role × permission **matrix** view alongside the card view. |
| Settings | New page: profile (read-only), language, theme, loyalty-rule shortcut. |
| Documented gaps | Honest "awaiting backend endpoint" pages for Guests, Digital access desk, Payments ledger, Invoices ledger, Settlements, Loyalty dashboard, Reviews, Notifications feed, Reports, Audit log — each naming the exact endpoint(s) required. Sidebar lists them under "Awaiting backend endpoint". |
| Shared UI | `AppTabs`, `FactGrid`, `GapState`, `workspace/PanelShell` + 9 workspace panels. |
| Utils | `utils/format.ts` (money / date — display only, never arithmetic), `utils/statusMeta.ts` (badge tones + UI transition mirrors for every backend status enum). |
| i18n | Full en/ar parity for all new strings; RTL preserved; Tajawal for Arabic. |

---

## 2. Route map

```
/                      overview
/login                 auth (layout: auth)
/hotels /hotels/:id    list + create · detail + edit
/room-types            hotel-scoped · CRUD + activate/deactivate
/rooms                 hotel-scoped · CRUD + status
/services              hotel-scoped · categories + services CRUD
/reservations          list (client filters, labelled) + walk-in gap note
/reservations/:id      operational workspace (permission-gated tabs)
/users                 CRUD
/roles                 matrix + cards (read-only)
/hotel-group           group profile + loyalty rule
/settings              profile / language / theme
/403                   forbidden

Gap routes (honest "endpoint missing" page, permission-gated):
/guests /digital-access /payments /invoices /settlements
/loyalty /reviews /notifications /reports /audit
```

Every route with a permission declares `definePageMeta({ permission })`;
`middleware/auth.global.ts` redirects an unauthorised direct hit to `/403`.

---

## 3. RBAC

Unchanged model: permission slugs from `GET /auth/me`
(`user.role.permissions[].slug`) drive UI visibility only; the backend
re-authorises every call and a `403` is final. Roles are context, never the
gate. `<PermissionGate>` for conditional rendering, `useCan()` for logic,
route `meta.permission` for page access, `config/navigation.ts` for the
sidebar.

Permission → surface added this pass:

| Permission | Unlocks |
|---|---|
| `hotels.manage` | Hotel create/edit |
| `inventory.manage` | Room-type CRUD + activate, room CRUD + status |
| `services.view` / `services.manage` | Stay services module (view / edit) |
| `payments.manage` | Deposit-hold action in the reservation workspace |
| `folio.view` | Folio + payment panels |
| `identity-verification.view` / `.review` | Identity panel / approve-reject |
| `digital-access.view` / `.revoke`, `check-in.perform` | Access panel / revoke / check-in |
| `service-orders.view` / `.manage` | Service-orders panel / create + transition |
| `checkout.perform` | Checkout panel |
| `invoice.view` | Invoice panel |
| `loyalty.view` / `.manage` | Loyalty panel / accrue + redeem |
| `notifications.view` | Notifications panel |
| `hotel-groups.manage` / `loyalty.rules.manage` | Hotel group page / loyalty rule |
| `users.manage` | User CRUD |

Reception (operational only) therefore sees: reservations, the reservation
workspace (identity review, check-in, access revoke, service orders, folio,
checkout, invoice, loyalty view, notifications), stay-services catalogue
(read-only), rooms/room-types (read-only), settings. It does **not** see
users, roles, hotel group, hotel/room management, payments-manage actions,
or loyalty accrue/redeem — matching `RolePermissionSeeder`.

---

## 4. Hotel scope

Unchanged: `stores/hotelContext.ts`. Central "All hotels" is a Group-Owner
convenience; hotel-scoped pages (room types, rooms, services) require a
concrete hotel and render `NeedHotelNotice` until one is chosen (the backend
routes are `/hotels/{hotel}/…` with no group variant). The reservation list
has no server-side `hotel_id` filter — the client filter is labelled
"loaded page only". Every scoped request is re-authorised server-side against
`user_hotel_access`; the selector is query context, never authorisation.

---

## 5. API endpoints consumed (all pre-existing, all tested)

Auth: `POST /auth/login`, `POST /auth/logout`, `GET /auth/me`.
Hotels: `GET /hotels` (paginated), `GET/POST /hotels`, `PUT /hotels/{id}`.
Hotel groups: `GET /hotel-groups`, `GET/PUT /hotel-groups/{id}`,
`GET|PATCH /hotel-groups/{id}/loyalty-rule`.
Inventory: `GET/POST /hotels/{h}/room-types`, `GET|PATCH …/{id}`,
`PATCH …/{id}/{activate|deactivate}`; same shape for `/rooms` plus
`PATCH …/rooms/{id}/status`.
Service catalogue: `GET/POST /hotels/{h}/service-categories` + update/activate/
deactivate; same for `/services`.
Reservations: `GET /reservations` (paginated), `GET /reservations/{id}`,
`POST /reservations/{id}/transition`.
Reservation workspace: `POST /reservations/{id}/payment/hold`;
`GET /reservations/{id}/folio`; `GET/POST /reservations/{id}/service-orders`,
`POST …/{so}/transition`; `GET /identity-verification/{id}/status`,
`POST …/review`; `GET /access/{id}`, `POST /access/{id}/revoke`,
`POST /check-in/{id}`; `POST /reservations/{id}/checkout`,
`GET /reservations/{id}/invoice`; `GET /reservations/{id}/loyalty`,
`GET …/loyalty/transactions`, `POST …/loyalty/{earn|redeem}`;
`GET /reservations/{id}/notifications`, `PATCH …/{n}/read`,
`POST …/read-all`.
RBAC: `GET /roles`, `GET /permissions`.
Users: `GET/POST /users`, `GET/PUT/DELETE /users/{id}`.

Never sent: card data, `status` (transitions use `target_status`),
client `hotel_id` / `role` / totals as authority.

---

## 6. Backend API gaps (documented, never faked)

Each gap has an honest in-app page naming the required endpoint(s).

| Module | Missing endpoint(s) | Note |
|---|---|---|
| Guests | `GET /guests`, `GET /guests/{id}`, `GET /guests/{id}/reservations` | Also blocks walk-in reservation creation (`POST /reservations` needs an existing `guest_id`). |
| Digital-access desk | `GET /hotels/{h}/{arrivals\|departures\|in-house}` | Per-reservation check-in/access works in the workspace. |
| Payments ledger | `GET /hotels/{h}/payments` or `GET /payments` | Per-reservation payment visible via folio/checkout. |
| Invoices ledger | `GET /hotels/{h}/invoices` or `GET /invoices` | Per-reservation invoice works in the workspace. |
| Settlements | `GET /hotels/{h}/settlements` | Settlement runs inside checkout. |
| Loyalty dashboard | `GET /guests/{id}/loyalty(/transactions)` | Reservation-scoped loyalty works; rule config works. |
| Reviews | whole domain (`GET /hotels/{h}/reviews`, `PATCH /reviews/{id}/moderate`) | No `Review` model/route/controller on the backend. |
| Notifications feed | `GET /notifications` staff-wide | Reservation-scoped feed works in the workspace. |
| Reports | `GET /reports/{occupancy\|revenue\|hotel-comparison}` | No reporting endpoints; Overview shows only real counts. |
| Audit log | `GET /audit` (+ filters) | Written on every sensitive action, no read endpoint. |
| List filter/sort/search + `per_page` | query params on `GET /reservations`, `/users` | Tables paginate at 15; client filters are labelled "loaded page only". |
| Overview / KPI stats | `GET /overview?hotel_id=` | No occupancy/revenue/ADR; the KPI panel says so explicitly. |

Closing these is a backend phase (repository → service → resource →
form-request → policy → hotel scope → tests), out of scope here because no
running MySQL/backend was available in this environment to verify against.

---

## 7. Visual design

Unchanged identity: warm brown `--primary #875a34`, bronze/gold `--accent
#b58343`, cream `--background #f6f1e9`, rounded `--radius 0.625rem`, soft warm
shadows, restrained borders — defined once in `app/assets/css/main.css`
(light + dark), Metronic 9 token contract re-skinned. `Inter` for Latin UI,
**`Tajawal`** for Arabic (`:lang(ar)` / `[dir=rtl]`). New surfaces use the
same `.card` / `.btn` / `.input` / `.table-base` primitives and logical
properties (`ps-/pe-`, `start-/end-`) so RTL mirrors correctly. Dark mode
preserved. Shared components: `AppTabs`, `FactGrid`, `GapState`,
`workspace/PanelShell`.

---

## 8. How to run

```bash
cd dashboard
cp .env.example .env          # set NUXT_PUBLIC_API_BASE (…/api/v1)
npm install
npm run dev                   # http://localhost:3000
npm run lint && npm run typecheck && npm run test && npm run build
```

The backend must be reachable and must permit the dashboard origin (CORS —
still an open backend gap for a cross-origin deployment).

---

## 9. Verification performed

| Check | Result |
|---|---|
| `npm run lint` | ✅ clean |
| `npm run typecheck` (`vue-tsc`) | ✅ no errors |
| `npm run test` (vitest) | ✅ 38/38 |
| `npm run build` (SPA) | ✅ built (428 kB gzip total) |
| `node .output/server/index.mjs` | ✅ boots, serves `/` 200 |

Not performed (no MySQL / running Laravel backend in this environment):
live login round-trip, per-role browser walkthrough, the reservation
workspace against real data, RTL visual pass in a browser. These need a
running backend + seeded demo data (`php artisan migrate --seed`).
