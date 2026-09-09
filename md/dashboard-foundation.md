# Dashboard Foundation — Implementation (Phase 12)

Companion to `md/dashboard-foundation-audit.md` (the audit). This document
records what was **built**: one unified Nuxt 3 + Metronic 9 dashboard wired to
the real Laravel `/api/v1`, plus the first API-backed operational modules.

**Build status:** ✅ builds, typechecks, lints, tests green. SPA.
**Backend / mobile:** untouched. **Not committed.**

---

## 1. Architecture

```
Laravel /api/v1  ──►  Sanctum bearer token  ──►  RBAC (role → permissions)
                                              ──►  hotel scope (user_hotel_access)
        │
        ▼
Nuxt 3 (SPA, ssr:false) ── Pinia ── @nuxtjs/i18n (en/ar, RTL) ── Metronic 9 tokens/KTUI/keenicons
        │
        ▼
One app: Central (group) + Hotel + Reception surfaces, gated by permission + scope
```

- **SPA** (`ssr: false`): the API is token-based, there is no SEO surface, and
  an SSR server holding tokens would add risk for no gain.
- **Node 20+**, npm, Vite. One build system. No React.
- Nuxt 4 file layout (`app/` srcDir, `future.compatibilityVersion: 4`).

### Folder map

| Path | Contents |
|---|---|
| `app/plugins/api.ts` | The single API client (base URL, bearer, `X-Locale`, envelope unwrap, `ApiError`, 401 handling) |
| `app/plugins/bootstrap.client.ts` | Session boot: restore token → `/auth/me` → seed hotel context + UI prefs (awaited before routing) |
| `app/stores/{auth,hotelContext,app}.ts` | Pinia stores |
| `app/middleware/auth.global.ts` | Route protection + `meta.permission` guard |
| `app/composables/{useApi,useCan,useNavigation,useResource}.ts` | |
| `app/services/index.ts` | Typed wrappers — **real endpoints only** |
| `app/config/navigation.ts` | Single nav definition (permission + backend-gap flags) |
| `app/utils/{apiError,permissions,navigation,reservationStateMachine}.ts` | Pure, unit-tested logic |
| `app/types/api.ts` | Mirrors the backend API Resources exactly |
| `i18n/locales/{en,ar}.json` | |

---

## 2. Metronic 9.4.12 integration

The licensed package is at `dashboard/metronic-v9.4.12/` (git-ignored vendor
drop). Metronic 9 is **Tailwind 4 + KTUI + keenicons**, and its theme contract
is a set of shadcn-style CSS variables (`--primary`, `--card`, `--border`, …)
exposed to Tailwind via `@theme inline`.

Integration approach — **tokens & styles, not the HTML kit wholesale**:

| Taken from Metronic | How |
|---|---|
| Design-token contract (`config.ktui.css`) | Reproduced in `app/assets/css/main.css`, values re-skinned to the Hotel identity |
| Tailwind 4 setup | `@tailwindcss/vite` + `@import 'tailwindcss'` |
| KTUI component styles | `@import '@keenthemes/ktui/styles.css'` (npm dep) |
| Keenicons (outline + duotone) | Font files + CSS **vendored** into `app/assets/keenicons/`, wrapped by `<KtIcon>` |
| Layout metrics (demo1: 270px sidebar, 64px header, fixed shell) | `app/layouts/default.vue` + `.app-shell` CSS vars |
| Component patterns (cards, tables, badges, dropdowns, modals) | Re-implemented as Vue SFCs using Metronic class conventions |

Not used: Metronic's webpack build, jQuery, the React kit, KTUI's imperative
JS (menus/dropdowns/modals are Vue-native for clean hydration).

---

## 3. Visual identity (same product as the Guest Mobile App)

Defined once in `app/assets/css/main.css`, light + dark:

| Token | Light | Role |
|---|---|---|
| `--primary` | `#875a34` | warm brown |
| `--accent` | `#b58343` | bronze / gold |
| `--background` | `#f6f1e9` | warm paper |
| `--card` | `#fffdf9` | |
| `--foreground` | `#2c241d` | warm near-black |
| `--secondary` / `--muted` | `#efe6d8` | warm neutral surface |
| `--border` | `#e4d8c6` | restrained |
| `--radius` | `0.625rem` | rounded |

Soft warm shadows on `.card`. Desktop-administration layout (fixed sidebar +
header, dense tables) — not a literal port of the mobile screens.

**Fonts:** `Inter` for the Latin UI, **`Tajawal`** for Arabic (loaded from
Google Fonts in `app/app.vue`; `:lang(ar)` / `[dir=rtl]` switches the family).
Only Tajawal is used for Arabic — no second Arabic font.

---

## 4. Authentication

`app/stores/auth.ts` + `app/plugins/bootstrap.client.ts`.

| Concern | Implementation |
|---|---|
| Login | `POST /auth/login {email,password}` → `{ user, token }`; token stored in a `hm_token` cookie (SameSite=Lax, Secure in prod, 14-day) + memory |
| Current user | `GET /auth/me` on every boot; `role.permissions[]` + `hotels[]` cached for UI only |
| Logout | `POST /auth/logout` then clear auth + hotelContext + app stores |
| Token in transit | `Authorization: Bearer …` header only — never a URL, never logged |
| Expiry / invalid | Any `401` → clear session → redirect `/login?redirect=…` |
| Guest accounts | Rejected at login (no staff permissions) — they use the mobile app |
| Inactive account | Backend `403` on login → "account not active" message |

No refresh flow — backend tokens don't expire (`sanctum.expiration = null`);
a `401` mid-session means full re-login.

---

## 5. RBAC

- `app/utils/permissions.ts` — pure `hasPermission / hasAny / hasAll`.
- `app/composables/useCan.ts` — `can() / canAny() / canAll()` over
  `auth.user.role.permissions[].slug`; `isGroupOwner` / `roleSlug` for
  **context only**.
- `<PermissionGate permission="…" mode="any|all">` — conditional rendering
  with a `#fallback` slot.
- `app/middleware/auth.global.ts` — a route may declare
  `definePageMeta({ permission: 'x' })` (string or array = any-of); a user
  without it is redirected to `/403` **even on direct URL entry**.
- Navigation items carry their required permission; the sidebar renders only
  what `canAny()` allows.

Roles are never the gate — only permission slugs are. The backend
Policies/Gates remain authoritative; every `403` from the API is final and
surfaced by `ErrorState`.

**Permission → surface (this phase):**

| Permission | Unlocks |
|---|---|
| `hotels.view` | Hotels list + detail, overview hotel count |
| `inventory.view` | Room types, Rooms, overview inventory snapshot |
| `inventory.manage` | Room status change |
| `reservations.view` | Reservations list + detail, overview recent list |
| `reservations.manage` | Reservation status transitions |
| `users.view` | Users list |
| `roles.view` | Roles & permissions matrix |

---

## 6. Hotel scope

`app/stores/hotelContext.ts`.

- Available hotels = `auth.user.hotels` (from `/auth/me`). Group Owner also
  gets a synthetic **"All hotels"** scope.
- `currentScope`: a hotel id, or `ALL_HOTELS`, or `null`. Persisted per user
  in `localStorage` (`hm_hotel_scope`) as a **preference only**; on boot it is
  re-validated against the user's own hotel list and dropped if stale.
- `setScope()` silently ignores a hotel the user isn't assigned / "All hotels"
  for a non-Group-Owner.
- `reset()` on logout.
- Hotel-scoped pages (Room types, Rooms) require a **concrete** hotel — they
  render `NeedHotelNotice` until one is picked, because the backend endpoints
  are `/hotels/{hotel}/…` and there is no group-wide variant.
- Every hotel-scoped request is still authorised server-side against
  `user_hotel_access`; the selector is query context, never authorisation.

---

## 7. Navigation

`app/config/navigation.ts` → `app/utils/navigation.ts` (pure filter) →
`app/composables/useNavigation.ts` (reactive) → `AppSidebar.vue`.

A nav item shows only when: permission held **and** `backendGap !== true`
**and** (if `scope: 'hotel'`) the user has at least one hotel. Items blocked
purely by a missing endpoint are listed **disabled** under "Awaiting backend
endpoint" — visible roadmap, never a dead link.

Live sections: Overview · Reservations · Hotels · Room types · Rooms · Users ·
Roles & permissions.
Gap items: Guests · Check-in/out · Payments · Loyalty · Reviews · Reports ·
Audit log.

---

## 8. API client

`app/plugins/api.ts` — one `ofetch` instance, injected as `$api` / `useApi()`.

- `baseURL` from `runtimeConfig.public.apiBase`; `Accept: application/json`.
- Adds `Authorization: Bearer` (unless `skipAuth`) and `X-Locale` (current i18n
  locale).
- Unwraps `{ success, message, data, meta }` → returns `data`;
  `withMeta()` returns `{ data, meta }` for paginated lists.
- Normalises every failure to **`ApiError`** (`app/utils/apiError.ts`):
  `kind` ∈ `validation | unauthenticated | forbidden | not_found | conflict |
  rate_limited | server | network | unknown`, plus `status`, `message`,
  `errors` (422 field map), `retryAfter` (429).
- `401` → `auth.clearSession()` + redirect to `/login` (suppressible with
  `silent401` for the boot `/auth/me`).
- Components/stores never call `$fetch` directly — only `app/services/*`.

`ErrorState.vue` renders a tailored message + retry affordance per `kind`;
forms read `ApiError.errors` for inline 422 messages; `AppToaster` shows
transient failures.

---

## 9. Real API endpoints integrated

All from `md/dashboard-foundation-audit.md` §4 — nothing invented.

| Endpoint | Used by |
|---|---|
| `POST /auth/login`, `POST /auth/logout`, `GET /auth/me` | auth |
| `GET /hotels` (paginated), `GET /hotels/{id}` | Hotels list/detail, overview |
| `GET /hotel-groups/{id}` | Hotel detail (group name, Group Owner only) |
| `GET /hotels/{h}/room-types`, `GET …/{id}` | Room types, reservation detail enrichment |
| `GET /hotels/{h}/rooms` (`?room_type_id=`), `GET …/{id}`, `PATCH …/{id}/status` | Rooms list + status change |
| `GET /reservations` (paginated), `GET /reservations/{id}` | Reservations list/detail, overview |
| `POST /reservations/{id}/transition` `{ target_status }` | Reservation state transitions |
| `GET /roles` (with permissions), `GET /permissions` | Roles & permissions matrix |
| `GET /users` (paginated) | Users list |

**Reservation transitions** send `{ "target_status": "…" }` (never `status`),
and only offer transitions valid from the current status per the UI mirror of
`ReservationStateMachine` (`app/utils/reservationStateMachine.ts`). The backend
re-validates and a rejected transition surfaces as the standard 422 toast.

---

## 10. Modules implemented

| Module | Surface | Notes |
|---|---|---|
| **Login** | `/login` | brand split-screen, 401/403/422 handled |
| **Overview** | `/` | real: recent reservations, hotel count, per-hotel inventory snapshot. **KPI panel intentionally shows a "not available" notice — no fake occupancy/revenue** |
| **Hotels** | `/hotels`, `/hotels/[id]` | list (server pagination) + detail; client-side search over the loaded page (labelled) |
| **Room types** | `/room-types` | hotel-scoped; list with price/capacity/room counts |
| **Rooms** | `/rooms` | hotel-scoped; list + type filter + **status change** (`available / booked / under_maintenance` only) gated by `inventory.manage` |
| **Reservations** | `/reservations`, `/reservations/[id]` | list (server pagination) + detail; **state transitions** gated by `reservations.manage`; guest block shows the documented gap |
| **Users** | `/users` | list (server pagination) |
| **Roles & permissions** | `/roles` | read-only RBAC matrix from the backend |
| **403 / error / empty / loading** | everywhere | `ErrorState`, `EmptyState`, `LoadingState`, `/403`, `app/error.vue` |

### Intentionally NOT implemented (next controlled phase)

Hotels create/update forms, room-type / room CRUD, reservation create,
check-in/checkout/folio/invoice screens, payments, identity verification,
digital access, services, loyalty, reviews, reports, audit, user/role CRUD,
settings. Several are blocked by API gaps (below); the rest are deferred to
keep this phase to a reviewed vertical slice.

---

## 11. Backend API gaps (blocking further modules — do NOT fake)

Carried from the audit (§29), still open:

| # | Gap | Blocks | Needed |
|---|---|---|---|
| 1 | List **filter / sort / search** + configurable `per_page` (all list endpoints; `per_page` fixed at 15) | real server-side tables; client-side filters are labelled as page-only | query params + `ListQuery` form request |
| 2 | **Reports** (`/reports/occupancy|revenue|hotel-comparison`) | Overview KPIs, Reports section | new endpoints |
| 3 | **Reviews + moderation** | Reviews section | `GET /hotels/{h}/reviews`, `PATCH /reviews/{id}/moderate` |
| 4 | **Guests as a resource** | Guests section, reservation guest block | `GET /guests`, `GET /guests/{id}`, `GET /guests/{id}/reservations` |
| 5 | **Audit-log read** | Audit section | `GET /audit` |
| 6 | **Overview / stats** endpoint | Overview KPI tiles | `GET /overview?hotel_id=` |
| 7 | `hotel_id` filter on `GET /reservations` | Group-Owner drill-down | query param |
| 8 | **Arrivals / departures / in-house** lists | Check-in / Check-out desk | `GET /hotels/{h}/arrivals` etc. |
| 9 | **Payments / invoices ledger** (only reservation-scoped today) | Payments section | `GET /hotels/{h}/payments`, `/invoices` |
| 10 | **CORS config** for the dashboard origin | running the dashboard on a different host/port | `config/cors.php` + `SANCTUM_STATEFUL_DOMAINS` / CORS env |
| 11 | Reservation/Room/RoomType **embedded relations** in list resources (IDs only today) | richer tables without N+1 client fetches | add `whenLoaded` includes or `?include=` |

Reservation detail currently resolves room-type/room names with extra
per-record calls (`GET /hotels/{h}/room-types/{id}`, `…/rooms/{id}`) —
acceptable for a detail page, but gap #11 would remove the need.

---

## 12. Arabic / English + RTL / LTR + Tajawal

- `@nuxtjs/i18n` v9, `strategy: 'no_prefix'`, cookie `hm_locale`.
- `i18n/locales/en.json` + `ar.json` — every visible string keyed (nav,
  tables, forms, buttons, statuses, errors, empty states).
- `app/app.vue` sets `<html dir>` + `lang` reactively from the active locale
  (`ar` → `rtl`).
- Layout uses logical properties / RTL-aware Tailwind (`ps-/pe-`, `start-/end-`,
  `text-start`) throughout, so the shell mirrors correctly.
- Backend messages localise via the `X-Locale` header the client already sends.
- Tajawal applied for Arabic via `:lang(ar)` / `[dir=rtl]` font-family.

---

## 13. Tests

Vitest (`tests/`), pure logic — no Nuxt runtime booted:

| File | Covers |
|---|---|
| `apiError.test.ts` | status → `kind` mapping (401/403/404/422/429/5xx/network), `ApiError` fields, `isRetryable` |
| `permissions.test.ts` | `hasPermission / hasAny / hasAll` |
| `navigation.test.ts` | nav visibility by permission (Reception vs Group Owner), backend-gap items never linked, hotel-scope hiding |
| `reservationStateMachine.test.ts` | UI mirror matches the approved transition table, terminals, no self-transition |
| `reservationTransition.test.ts` | transition request body is `{ target_status }`, never `{ status }` |

`npm run test` → **24 passing**.

Not automated (need a browser + live backend): full login round-trip, RTL
visual, 401 redirect in-app. Manual smoke: production server boots and serves
the SPA (`node .output/server/index.mjs` → 200).

---

## 14. Validation results

| Check | Result |
|---|---|
| `npm run lint` (`eslint .`) | ✅ clean |
| `npm run typecheck` (`vue-tsc`) | ✅ no errors |
| `npm run test` (vitest) | ✅ 24/24 |
| `npm run build` (`nuxt build`, SPA) | ✅ built; keenicons fonts bundled, brand tokens in CSS |

---

## 15. Security checklist

- Token: cookie (SameSite=Lax, Secure in prod) + memory; sent only as
  `Authorization` header; never logged, never in a URL.
- No role / hotel / permission value from the browser is trusted for access —
  all are re-checked server-side; UI hiding is cosmetic.
- Hand-entered unauthorised hotel/reservation ids → backend `403`/`404`,
  surfaced as a normal error (existence never leaked — matches backend's
  404-for-cross-scope convention).
- `401` always clears the local session.
- No secrets in source; `.env` git-ignored; `.env.example` carries only the
  API base URL.
- No payment card data touched anywhere.
- `metronic-v9.4.12/` (licensed) is git-ignored.

---

## 16. How to run

```bash
cd dashboard
cp .env.example .env          # set NUXT_PUBLIC_API_BASE
npm install
npm run dev                   # http://localhost:3000
```

Backend must be reachable and must permit the dashboard origin (gap #10).

---

## 17. Recommended next phase

1. **Backend**: close gaps #1 (list filter/sort/search + `per_page`) and #10
   (CORS) first — every future dashboard table depends on #1.
2. **Backend**: guests resource (#4), overview/stats (#6), reports (#2),
   reviews (#3), audit read (#5).
3. **Dashboard**: hotels + room-type + room **CRUD forms** (endpoints already
   exist), then reservation create, then the check-in → checkout → invoice
   operational flow, each against real endpoints, each gated by the permission
   matrix above.
```
