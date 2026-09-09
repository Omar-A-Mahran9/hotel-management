# Dashboard Foundation — Audit & Architecture (Phase: Foundation)

**Status:** Reconnaissance + backend/RBAC/API audit + architecture design **complete**.
**Build:** **DONE** — the unified `dashboard/` Nuxt 3 + Metronic 9 app has since been
scaffolded and wired to the real `/api/v1`. What was actually built (folder map,
auth/RBAC/hotel-scope/API-client implementation, Metronic integration, brand theme,
i18n/RTL/Tajawal, the first read-only modules, tests) is recorded in the companion
**`md/dashboard-foundation.md`**. The planning sections below (§3, §10–§25) are the
original design; where they say "planned" / "not done" / "none", read
`dashboard-foundation.md` for the delivered state. The **backend API inventory and
gap list (§4–§9, §29) remain current and authoritative** — no backend routes changed.
**Backend / mobile:** untouched by the dashboard work.

---

## 1. Repository state before work

```
hotel-management/
├── backend/     Laravel 12 REST API (PHP 8.2+, Sanctum), /api/v1, DDD domain layout
├── mobile/      Flutter Guest App (Riverpod + go_router + dio)
├── md/          project docs (Phase 0 baseline, per-phase implementation notes, mobile design)
└── postman/     Hotel-Management-API collection + Local environment
```

`backend/package.json` is only Laravel's default Vite toolchain (vite, axios, tailwindcss v4,
laravel-vite-plugin, concurrently). **It is not a dashboard.**

**Uncommitted work already on the tree (MUST NOT be touched by the dashboard phase):**
- `backend/app/Domain/Notification/**`, `backend/app/Domain/Reservation/Events/**`, notification
  controller/resource/provider/config/migration/lang/tests — Phase 11 (Notifications) in progress.
- `backend/app/Domain/Reservation/Services/ReservationService.php`, `AppServiceProvider`,
  `bootstrap/app.php`, `bootstrap/providers.php`, `RolePermissionSeeder`, `lang/*/api.php`,
  `routes/api.php`, `.env.example` — Phase 10/11 wiring.
- `mobile/**` — large design-system revamp (theme tokens, widgets, new `app_*` widgets,
  `mobile/Design/`, `mobile/assets/`, `mobile/docs/design-system.md`).
- `postman/Hotel-Management-API.postman_collection.json` — modified.

Recent commits: `fc59e8a` guest loyalty + reviews (mobile), `c8a1558` guest stay lifecycle 5–9,
`93fc4e8` checkout/invoice/loyalty, `94bdba7` phase 3–4, `79fc343` discovery.

## 2. Existing dashboard status

**None.** No `dashboard/`, `frontend/`, `central-dashboard/`, `hotel-dashboard/`, no Nuxt/Vue
project anywhere, no Metronic anywhere in the repo. This is a **greenfield** dashboard.

Phase 0 baseline mandates it (R45 Metronic, R46 Laravel/Vue-Nuxt/Flutter, §5 "Dashboard
Nuxt+Metronic (authenticated staff)"), and the roadmap places it at Phases 13 (Central) + 14
(Hotel) — **this phase unifies those two into one `dashboard/` app** per the current instruction.

**Open blocker (already tracked in Phase 0 §20, item 10):** *"Exact licensed Metronic
version/package — [OPEN] — blocks Phase 13."* Still open. Build paused here for that reason.

---

## 3. Dashboard architecture (planned — to execute once Metronic is supplied)

**One** app: `dashboard/`. Central (group) and Hotel capabilities live in the same codebase,
switched by permissions + hotel scope, never by a separate project.

| Decision | Choice | Rationale |
|---|---|---|
| Framework | **Nuxt 3**, **SPA mode** (`ssr: false`) | Internal tool, Sanctum **Bearer token** (not SPA-cookie), no SEO. SPA avoids putting tokens through an SSR server. Public marketing site (Phase 15) stays a separate SSR Nuxt app. |
| Package manager / Node | npm, Node 20 LTS | Matches Laravel toolchain; no existing lockfile to honour. |
| UI system | **Metronic (Vue/Nuxt, Vite build)** once supplied; its layout (aside + header + toolbar + content), SCSS layer, KeenIcons | R45 mandatory. |
| Theming | Override Metronic SCSS tokens with **hotel-brand** values pulled from `mobile/lib/core/theme/*.dart` | Same product identity as the Guest App. |
| State | **Pinia** stores (`auth`, `hotelContext`, `ui`) | Nuxt-native. |
| Data fetching | Single API client plugin + typed `services/` modules; no raw `$fetch` in components | Phase 9 requirement. |
| i18n | `@nuxtjs/i18n` — `en` (LTR) / `ar` (RTL), **Tajawal** for Arabic | R + Phase 20. |
| Routing guards | Global `auth` middleware + `permission` middleware (route `meta.permission`) | UI guard is UX only; backend stays authoritative. |
| Tests | Vitest + `@vue/test-utils` for guards/stores/api-client mapping | Phase 24 "minimum appropriate". |

Proposed structure (create only what's used):

```
dashboard/
├── nuxt.config.ts
├── app.vue
├── assets/scss/          # brand tokens + Metronic overrides
├── layouts/              # default (authed shell), auth (login), error
├── middleware/           # auth.global.ts, permission.ts
├── pages/                # overview, hotels/, reservations/, users/, ... (added in later phases)
├── components/
│   ├── ui/               # Metronic-wrapped primitives
│   └── shared/           # PageHeader, DataTable, HotelSelector, PermissionGate, ...
├── composables/          # useAuth, useCan, useHotelContext, useApi
├── stores/               # auth.ts, hotelContext.ts, ui.ts
├── services/             # api/client.ts + auth.ts, hotels.ts, reservations.ts, ...
├── i18n/locales/         # en.json, ar.json
├── types/                # api envelope, User, Role, Permission, Hotel, ...
└── utils/
```

---

## 4. Backend API audit

Laravel 12, DDD (`app/Domain/<Context>/{Models,Services,Repositories,Policies,StateMachine}`),
thin controllers in `app/Http/Controllers/Api/V1/`, Form Requests, API Resources, Policies/Gates.

**Global conventions**
- Base path `/api/v1`. All JSON (`ForceJsonResponse` middleware).
- **Auth:** Laravel Sanctum **personal access token**, `Authorization: Bearer <token>`.
  `config/sanctum.php` `expiration => null` → tokens **do not expire**; dashboard must treat any
  `401` as "session gone → route to login".
- **Locale:** `X-Locale: en|ar` header (or `?lang=`); `APP_LOCALES=en,ar`.
- **Response envelope**
  - success: `{ "success": true, "message": "...", "data": <any>, "meta": {...}? }`
  - failure: `{ "success": false, "message": "...", "errors": {field: [..]}? }`
- **Status codes:** `200/201` ok · `401` unauthenticated · `403` forbidden · `404` not_found
  (also used for cross-scope resources so existence never leaks) · `422` validation **and every
  domain business-rule error** (there is **no `409` convention**) · `429` throttled · `500`
  server_error (no internal detail in prod).
- **Pagination:** list endpoints return `LengthAwarePaginator` → envelope `meta` carries
  `current_page / last_page / per_page / total / links`. `?page=N` works. **`per_page` is
  hard-coded to 15** — not overridable from the request.
- **Filtering / sorting / search: not implemented on any list endpoint** (only exception:
  `GET /hotels/{hotel}/rooms?room_type_id=`). Phase 0 §16 promises "pagination/filtering/sorting
  on list endpoints" — **this is a gap for the dashboard**.

### Endpoint inventory (what actually exists in `routes/api.php`)

| Area | Method & path | Auth | Permission / scope | Notes |
|---|---|---|---|---|
| Auth | `POST /auth/login` | public | — | body `{email,password}` → `{user (role.permissions+hotels), token}` |
| Auth | `POST /auth/logout` | sanctum | — | revokes current token |
| Auth | `GET /auth/me` | sanctum | — | `UserResource` w/ `role.permissions` + `hotels` |
| Roles | `GET /roles` | sanctum | `roles.view` | all roles + permissions, **not paginated** |
| Permissions | `GET /permissions` | sanctum | `permissions.view` | all permissions, **not paginated** |
| Hotel Groups | `GET /hotel-groups` | sanctum | Policy `viewAny` | list (`HotelGroupService::list()`) |
| Hotel Groups | `POST /hotel-groups` | sanctum | Policy `create` (`hotel-groups.manage`) | |
| Hotel Groups | `GET/PUT /hotel-groups/{id}` | sanctum | Policy `view`/`update` | route-model bound |
| Loyalty rule | `GET /hotel-groups/{id}/loyalty-rule` | sanctum | `loyalty.rules.manage` (Group Owner) | created inactive on first read |
| Loyalty rule | `PUT|PATCH /hotel-groups/{id}/loyalty-rule` | sanctum | `loyalty.rules.manage` | |
| Hotels | `GET /hotels` | sanctum | `hotels.view` | **scoped to caller's hotels** (Group Owner = all); paginated 15 |
| Hotels | `POST /hotels` | sanctum | `hotels.manage` | |
| Hotels | `GET/PUT /hotels/{hotel}` | sanctum | Policy `view`/`update` + hotel scope | |
| Users | `GET /users` | sanctum | `users.view` | paginated 15, **no filters/search** |
| Users | `POST /users` | sanctum | `users.manage` | accepts `hotel_ids[]` (syncs `user_hotel_access`) |
| Users | `GET/PUT/DELETE /users/{user}` | sanctum | Policy | delete = hard delete + audit |
| Reservations | `GET /reservations` | sanctum | `reservations.view` | **scoped to caller's hotels**; paginated 15; **no status/date/hotel/guest filter** |
| Reservations | `POST /reservations` | sanctum | `reservations.manage` (against room-type's hotel) | staff walk-in create |
| Reservations | `GET /reservations/{id}` | sanctum | resolve-then-authorize; cross-scope = 404 | |
| Reservations | `POST /reservations/{id}/transition` | sanctum | Policy `transition` | body `{target_status}`; state machine enforced |
| Payments | `POST /reservations/{id}/payment/hold` | sanctum | `payments.manage` | throttled |
| Payments | `POST /payments/webhooks/{provider}` | **public** (HMAC) | — | throttled `payments.webhook` |
| Identity Verif. | `POST /identity-verification/{res}/documents` · `/selfie` | sanctum | `identity-verification.submit` | throttled |
| Identity Verif. | `GET /identity-verification/{res}/status` | sanctum | `identity-verification.view` | |
| Identity Verif. | `POST /identity-verification/{res}/review` | sanctum | `identity-verification.review` | manual decision |
| Check-in | `POST /check-in/{res}` | sanctum | `check-in.perform` | throttled; drives VERIFIED→CHECKED_IN |
| Digital Access | `GET /access/{res}` | sanctum | `digital-access.view` | |
| Digital Access | `POST /access/{res}/revoke` | sanctum | `digital-access.revoke` | throttled |
| Room Types | `GET/POST /hotels/{hotel}/room-types` | sanctum | `inventory.view` / `inventory.manage` | |
| Room Types | `GET /hotels/{hotel}/room-types/{rt}` · `PUT|PATCH` · `PATCH .../activate` · `.../deactivate` | sanctum | Policy | no delete |
| Rooms | `GET/POST /hotels/{hotel}/rooms` | sanctum | Policy | `?room_type_id=` filter |
| Rooms | `GET /…/rooms/{room}` · `PUT|PATCH` · `PATCH .../status` | sanctum | Policy | status = state machine |
| Service Catalog | `GET/POST /hotels/{hotel}/service-categories` · `PUT|PATCH` · `activate`/`deactivate` | sanctum | `services.view` / `services.manage` | |
| Service Catalog | `GET/POST /hotels/{hotel}/services` · `GET /{service}` · `PUT|PATCH` · `activate`/`deactivate` | sanctum | `services.*` | |
| Service Orders | `GET/POST /reservations/{res}/service-orders` · `GET /{so}` · `POST /{so}/transition` | sanctum | `service-orders.view` / `service-orders.manage` | accrues folio |
| Folio | `GET /reservations/{res}/folio` | sanctum | `folio.view` | read-only |
| Checkout | `POST /reservations/{res}/checkout` | sanctum | `checkout.perform` | throttled; `Idempotency-Key` header |
| Invoice | `GET /reservations/{res}/invoice` | sanctum | `invoice.view` | |
| Loyalty | `GET /reservations/{res}/loyalty` · `/loyalty/transactions` | sanctum | `loyalty.view` | |
| Loyalty | `POST /reservations/{res}/loyalty/earn` · `/redeem` | sanctum | `loyalty.manage` | |
| Notifications | `GET /reservations/{res}/notifications` · `PATCH /{n}/read` · `POST /read-all` | sanctum | `notifications.view` | throttled; **uncommitted (Phase 11 WIP)** |

Controllers present: Auth, CheckIn, Checkout, DigitalAccess, Folio, Hotel, HotelGroup,
IdentityVerification, Invoice, Loyalty, LoyaltyRule, Notification, Payment, PaymentWebhook,
Permission, Reservation, Role, Room, RoomType, ServiceCategory, Service, ServiceOrder, User.

## 5. Existing dashboard-ready APIs

**A. Existing and ready to consume as-is:**
- Auth: `login`, `logout`, `me` — complete session foundation.
- `roles`, `permissions` — for permission-matrix UI and user forms.
- Hotel Groups CRUD (`GET/POST/GET/PUT`) + loyalty-rule show/update.
- Hotels CRUD (list scoped, create, show, update) — powers **HotelSelector** directly.
- Users CRUD incl. `hotel_ids[]` assignment.
- Room Types + Rooms CRUD + activate/deactivate + room status transition.
- Service catalog (categories + services) CRUD + activate/deactivate.
- Reservation show + transition; Service Orders; Folio; Checkout; Invoice; Loyalty
  (reservation-scoped); Identity Verification status/review; Digital Access show/revoke;
  Check-in. All usable from a reservation-detail workspace.

## 6. API gaps

**B. Exists but needs adaptation (backend change, later phase — do NOT fake in frontend):**
1. **List filtering / sorting / search** on `reservations`, `users`, `hotels`, `rooms`,
   `service-orders` — none accept filter/sort/`q` params. Dashboard tables need at least:
   reservations by `status`, `hotel_id`, date range, guest name/ref; users by `role`,
   `hotel_id`, `is_active`, `q`; rooms by `status`, `room_type_id` (partial).
2. **Configurable `per_page`** — currently fixed 15; dashboard tables need 25/50/100.
3. **`roles` / `permissions`** returned unpaginated & unfiltered — fine now, note for scale.
4. Reservation list carries no embedded guest/room summary confirmed — Resource shape needs a
   review against table columns (see `ReservationResource`).

**C. Missing entirely (Phase 0 promises them; not yet built — document as gaps, build in a
backend phase, never fake):**
1. **Reports** — `GET /reports/{occupancy|revenue|hotel-comparison}` (Phase 0 §16, roadmap
   Phase 17). Nothing exists. Blocks the "Reports" nav section and any real KPI cards.
2. **Reviews / moderation** — `GET /hotels/{hotel}/reviews`, `POST /reviews/{id}/moderate`
   (Phase 0 §14, roadmap Phase 11). **No backend routes or controller** (the `review` in
   routes is *identity-verification* review, unrelated). Mobile has a reviews feature but the
   staff side is unbuilt. Blocks the "Reviews" nav section.
3. **Guests as a first-class resource** — `Guest` / `ReservationGuest` models exist only inside
   the Reservation domain; **no `GET /guests`, no guest search, no guest profile/history**
   endpoint. Blocks the "Guests" nav section.
4. **Audit log read** — `AuditLogger` writes `audit` records on every sensitive action, but
   there is **no read endpoint**. Blocks the "Audit" nav section.
5. **Dashboard overview / KPIs** — no `GET /overview` / stats endpoint (occupancy today,
   arrivals/departures, pending verifications, outstanding folio, revenue). Overview page can
   only show placeholder tiles until this exists.
6. **Hotel-level reservation list** — `GET /reservations` is scoped to the *user's* hotels with
   no `hotel_id` filter; a Group Owner cannot yet ask "reservations for Cairo only" server-side.
7. **Arrivals / departures / in-house lists** for the Check-in/Check-out desk views — no
   dedicated endpoint; would today require client-side filtering of a paginated list (not
   acceptable).
8. **Payments / invoices list** — only reservation-scoped; no hotel/group payments ledger.
9. **Notification feed is reservation-scoped only** — no staff-wide operational feed (may be
   intentional for MVP).

## 7. RBAC findings

- **One role per user** (`users.role_id` → `roles`), role ⇄ permissions many-to-many
  (`permission_role`). No direct user-permission grants, no multi-role.
- `User::hasPermission($slug)` → `role->permissions->contains('slug', …)`.
  `User::isGroupOwner()` → `role->slug === 'group_owner'`.
- **Hotel scope = `user_hotel_access` pivot** (`User::hotels()`), resolved server-side on every
  request via `HotelAccessService` / `HotelScoped::scopeAccessibleBy`. Group Owner is an
  **explicit all-hotels bypass**, not an absence of scoping.
- Enforcement points: Policies (`$this->authorize(...)`), `Gate::authorize('slug')` for
  role/permission list endpoints, `HotelScoped` query scope, and domain services re-deriving
  `hotel_id` from the entity (never from the request body — client `hotel_id` is explicitly
  ignored, verified by Postman "Ignored" cases).
- 4 seeded roles: `group_owner`, `hotel_manager`, `reception`, `guest`.
  **Guest has zero permissions** → the dashboard login screen should reject Guests (they use
  the mobile app).
- 29 permissions (authoritative list = `RolePermissionSeeder`).

## 8. Permission matrix (from `RolePermissionSeeder` — authoritative)

`GO` = Group Owner (also all-hotels bypass), `HM` = Hotel Manager (assigned hotels),
`RC` = Reception (single assigned hotel), `G` = Guest.

| Permission | GO | HM | RC | G |
|---|:--:|:--:|:--:|:--:|
| `hotel-groups.manage` | ✅ | ❌ | ❌ | ❌ |
| `hotels.view` | ✅ | ✅ | ✅ | ❌ |
| `hotels.manage` | ✅ | ❌ | ❌ | ❌ |
| `users.view` / `users.manage` | ✅ | ❌ | ❌ | ❌ |
| `roles.view` / `permissions.view` | ✅ | ❌ | ❌ | ❌ |
| `inventory.view` | ✅ | ✅ | ✅ | ❌ |
| `inventory.manage` | ✅ | ✅ | ❌ | ❌ |
| `reservations.view` | ✅ | ✅ | ✅ | ❌ |
| `reservations.manage` | ✅ | ✅ | ❌ | ❌ |
| `payments.manage` | ✅ | ✅ | ❌ | ❌ |
| `identity-verification.view` | ✅ | ✅ | ✅ | ❌ |
| `identity-verification.submit` | ✅ | ✅ | ✅ | ❌ |
| `identity-verification.review` | ✅ | ✅ | ✅ | ❌ |
| `check-in.perform` | ✅ | ✅ | ✅ | ❌ |
| `digital-access.view` | ✅ | ✅ | ✅ | ❌ |
| `digital-access.revoke` | ✅ | ✅ | ✅ | ❌ |
| `services.view` | ✅ | ✅ | ✅ | ❌ |
| `services.manage` | ✅ | ✅ | ❌ | ❌ |
| `service-orders.view` | ✅ | ✅ | ✅ | ❌ |
| `service-orders.manage` | ✅ | ✅ | ✅ | ❌ |
| `folio.view` | ✅ | ✅ | ✅ | ❌ |
| `checkout.perform` | ✅ | ✅ | ✅ | ❌ |
| `invoice.view` | ✅ | ✅ | ✅ | ❌ |
| `loyalty.view` | ✅ | ✅ | ✅ | ❌ |
| `loyalty.manage` | ✅ | ✅ | ❌ | ❌ |
| `loyalty.rules.manage` | ✅ | ❌ | ❌ | ❌ |
| `notifications.view` | ✅ | ✅ | ✅ | ❌ |

Reception = operational only: **no** `*.manage` that carries a financial/config effect
(`payments.manage`, `services.manage`, `loyalty.manage`, `inventory.manage`, `users.*`), but
**does** hold `checkout.perform`, `identity-verification.review`, `digital-access.revoke`,
`service-orders.manage` (Phase 0 §7 "manual-assist, logged").

## 9. Hotel-scope findings

- User is assigned hotels via `user_hotel_access` (set on `POST/PUT /users` with `hotel_ids[]`).
- `GET /auth/me` returns `hotels: [{id, hotel_group_id, name, slug, country, city, timezone,
  is_active}]` — this is the **exact source for the dashboard HotelSelector options**.
- Central/Group Owner: `hotels` may be empty in `me` yet `isGroupOwner` grants all — the
  selector must add a synthetic **"All hotels"** entry and fetch the full list from
  `GET /hotels` (which returns everything for a Group Owner).
- Hotel Manager: selector = exactly their `me.hotels` (may be several).
- Reception: selector = their single `me.hotels[0]` (lock it).
- **The selector is never authorization** — every scoped request is re-validated server-side;
  a hand-entered unauthorized `hotel_id` yields `403`/`404`. Frontend just sets query context.

## 10. Authentication architecture (planned)

- `POST /auth/login {email,password}` → store `token` (Pinia + `localStorage` mirror for
  reload; acceptable for an internal token that the API returns in plaintext anyway).
- On app boot: if token present → `GET /auth/me`; on `401` clear + redirect `/login`.
- `auth.global.ts` middleware: no token / no `me` → redirect `/login` (except `/login`).
- `POST /auth/logout` then clear stores (auth + hotelContext + ui) and redirect.
- No refresh flow (tokens don't expire); a `401` mid-session = full re-login.
- Never log the token; never render it; keep it out of URLs and non-`Authorization` headers.

## 11. API client architecture (planned)

Single `services/api/client.ts` (ofetch instance via Nuxt plugin):
- `baseURL` from `runtimeConfig.public.apiBase`; `Accept: application/json`.
- request: inject `Authorization: Bearer`, `X-Locale` from i18n, `Idempotency-Key` where needed.
- response: unwrap `{success,data,meta}`; on `success:false` throw a normalized `ApiError`
  `{status, message, errors, retryAfter}`.
- status handling: `401` → auth store logout + redirect · `403` → forbidden view/toast ·
  `404` → not-found view · `422` → return field `errors` to the form · `429` → toast with
  `Retry-After` · `5xx`/network → error state + retry affordance.
- Typed `services/*.ts` per resource; **components never call `$fetch` directly**.

## 12. Hotel context implementation (planned)

`stores/hotelContext.ts`: `availableHotels` (from `me` + Group Owner "All hotels"),
`currentHotelId` (persisted per-user), `setHotel(id)` validates against `availableHotels`,
`reset()` on logout. Scoped `services/*` read `currentHotelId` for `/hotels/{hotel}/...` routes.

## 13. Permission architecture (planned)

`composables/useCan.ts`: `can(slug)`, `canAny([...])`, `canAll([...])` off
`auth.me.role.permissions[].slug`. `<PermissionGate permission="x">` component. Route
`meta.permission` enforced by `permission.ts` middleware → `403` view if missing. `isGroupOwner`
/ role used only for **context** (which nav group, "All hotels" option), never as the gate.

## 14. Navigation architecture (planned)

Single `config/navigation.ts` array; each item `{ key, labelKey, to, icon, permission?,
scope?: 'group' | 'hotel' }`. Rendered list = items where `can(permission)` **and** scope
matches current context. Central section (Overview, Hotels, Reservations, Guests, Payments,
Loyalty, Reviews, Reports, Users, Audit, Settings) and Hotel section (Overview, Rooms,
Reservations, Guests, Check-in/out, Services, Folio, Reviews, Reports) are the same array
filtered differently — **no `if role===`**. Items whose backing API is a documented gap
(Guests, Reviews, Reports, Audit) are added but feature-flagged off until the endpoint ships.

## 15. Metronic integration

**Not done — package not available.** Plan: add Metronic Vue/Nuxt (Vite) as the layout +
component base; keep its `KTComponent` scripts, KeenIcons, SCSS 7-1 structure; wire its
layout config (aside fixed, header fixed, RTL-aware). All Metronic demo content/data removed.

## 16. Hotel System visual identity

To be pulled from `mobile/lib/core/theme/*.dart` (warm brown primary, cream/paper backgrounds,
bronze/gold accent, warm neutrals, soft warm shadows, rounded corners, restrained borders) and
mapped onto Metronic SCSS tokens (`$primary`, `$body-bg`, `$card-*`, `$border-color`,
`$border-radius*`, `$font-family-sans-serif`). Desktop-adapted, not a literal mobile copy.
*(Reading those theme files is the first task of the build session.)*

## 17. Tajawal implementation

Planned: self-host **Tajawal** (`@fontsource/tajawal` weights 400/500/700) as the Arabic font
family; Latin/dashboard default stays Metronic's (Inter). Applied via `:lang(ar)` / `[dir=rtl]`.

## 18. Arabic / English implementation

Planned: `@nuxtjs/i18n`, `en.json` + `ar.json`, lazy-loaded; all nav, tables, forms, buttons,
alerts, validation labels, empty/error states keyed. Backend messages already localize via
`X-Locale`. Numbers/dates via `Intl` with locale.

## 19. RTL / LTR implementation

Planned: `<html dir>` + `lang` switch on locale change; Metronic RTL SCSS bundle; logical CSS
properties in custom components; table/drawer/menu direction verified in a guard test.

## 20. Shared components created

**None this session.** Planned set (build only when first used): `PageHeader`, `Breadcrumbs`,
`StatCard`, `DataTable` (server pagination/sort/filter), `SearchInput`, `FilterBar`,
`Pagination`, `StatusBadge`, `EmptyState`, `ErrorState`, `LoadingState`, `ConfirmDialog`,
`FormField`, `DateRangePicker`, `HotelSelector`, `PermissionGate`, `ActionMenu`, `Toast`,
`Modal`, `Drawer`.

## 21. Screens / pages actually implemented

**None.** Build paused before scaffolding.

## 22. Screens intentionally NOT implemented

Everything: login, overview, and all Central/Hotel/Reception CRUD (hotels, hotel groups, rooms,
room types, reservations, guests, users, roles, payments/folio, services, check-in/out,
checkout/invoice, loyalty, reviews, audit, reports, settings). Per the phase's STOP condition
these belong to the next controlled phase **after** the foundation is built and reviewed.

## 23. Tests

None (no dashboard yet). Planned minimum: `auth` middleware redirect, `permission` middleware
`403`, hotelContext validation/reset, API client status→`ApiError` mapping, nav visibility by
permission, RTL `dir` toggle.

## 24. Typecheck / lint

N/A — no dashboard project. Planned: `nuxi typecheck` (vue-tsc), ESLint (`@nuxt/eslint`),
Prettier.

## 25. Production build

N/A — planned `nuxi build` (SPA) as the end-of-build-session validation gate.

## 26. Backend changes

**None.** No file under `backend/` was modified. The pre-existing uncommitted Phase 10/11 work
is untouched.

## 27. Mobile changes

**None.** No file under `mobile/` was modified.

## 28. Git status

Unchanged from session start (reads only). Pre-existing modifications/untracked files listed in
§1 remain exactly as they were. Nothing staged, nothing committed, nothing pushed.

## 29. Remaining API gaps (consolidated — for a future backend phase)

| # | Gap | Needed for | Suggested endpoint |
|---|---|---|---|
| 1 | List filter/sort/search + `per_page` | every dashboard table | query params on existing `index` actions + `ListQuery` form request |
| 2 | Reports | Overview KPIs, Reports section | `GET /reports/occupancy`, `/reports/revenue`, `/reports/hotel-comparison` |
| 3 | Reviews + moderation | Reviews section | `GET /hotels/{hotel}/reviews`, `PATCH /reviews/{id}/moderate` |
| 4 | Guests as a resource | Guests section, guest history | `GET /guests`, `GET /guests/{id}`, `GET /guests/{id}/reservations` |
| 5 | Audit log read | Audit section | `GET /audit` (filter by actor/action/entity/date) |
| 6 | Overview/stats | Overview page | `GET /overview?hotel_id=` |
| 7 | Hotel-filtered reservation list | Group Owner drill-down | `?hotel_id=` on `GET /reservations` |
| 8 | Arrivals/departures/in-house | Check-in / Check-out desk | `GET /hotels/{hotel}/arrivals`, `/departures`, `/in-house` (date) |
| 9 | Payments/invoices ledger | Payments section | `GET /hotels/{hotel}/payments`, `/invoices` |
| 10 | CORS config | dashboard on a different origin | add `config/cors.php` + `SANCTUM`/CORS env for the dashboard origin |

## 30. Recommended next phase

1. **User supplies the licensed Metronic Nuxt/Vue package** (unblocks everything).
2. Build session — deliver the running foundation only:
   - `dashboard/` Nuxt 3 SPA scaffold + Metronic layout + brand theme from `mobile` tokens.
   - API client plugin, `auth` + `hotelContext` + `ui` Pinia stores.
   - `auth.global` + `permission` middleware; `useCan`; `<PermissionGate>`.
   - `HotelSelector`, permission-driven navigation, the loading/empty/error/403/404 state set.
   - `en`/`ar` i18n + RTL + Tajawal.
   - **Two demo pages only**: `/login` and `/overview` (placeholder tiles clearly marked as
     awaiting the `/overview` endpoint) to prove the 16 acceptance points.
   - Vitest guard/store/client tests; `typecheck` + `lint` + `build` gate.
   - **STOP.** No CRUD modules.
3. Separate backend phase — close gaps #1–#10 above (especially list filtering + CORS, which
   every subsequent dashboard module depends on).
```
