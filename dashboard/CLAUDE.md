# Dashboard (`dashboard/`) — Claude guidance

Unified **Nuxt 3 + Vue 3 + Metronic 9** internal dashboard for Central / Hotel
Group, Hotel, and Reception staff. One app — capabilities change by the signed-in
user's role, permissions, and hotel scope. There is **no** separate
central/hotel project.

The Laravel API (`../backend`, `/api/v1`) is the **only** source of business
truth. This app never duplicates business rules and never fakes an endpoint.

**Before starting any task in `dashboard/`, read the docs below first** — they are
the source of truth for what the system does, how it must be built, and how you
must work.

## `dashboard/docs/` — source-of-truth documents

Read all three before implementing or changing anything. Priority on conflict:
current task requirement → `HOTEL_BUSINESS_CONTEXT.md` → `HOTEL_ARCHITECTURE_RULES.md`
→ `CLAUDE_INSTRUCTIONS.md` → approved baseline → existing code.

- `docs/HOTEL_BUSINESS_CONTEXT.md` — **what the system does and why.** Org
  hierarchy (Hotel Group → Hotels → room types → physical rooms), the five
  actors (Group Owner/Manager, Hotel Manager, Reception, Guest), and every
  domain: guests/auth, availability, reservations, payments, identity
  verification, digital check-in/access, hotel services, folio, checkout,
  invoices, loyalty (group-wide, ledger-based), reviews, notifications,
  reporting, audit. Includes the approved **state machines** and the list of
  **open/configurable values you must never invent** (currency, deposit amount,
  cancellation penalties, hold timeout, identity thresholds, loyalty rates…).
- `docs/HOTEL_ARCHITECTURE_RULES.md` — **how it must be built.** 35 sections:
  layer responsibilities (Controller → Form Request → Service → Repository →
  Model on the backend), tech baseline, non-negotiable rules, response system,
  API design (`/api/v1`, guest- vs staff-scoped), **Dashboard architecture
  (§11–12)**, auth/authorization (§13), hotel scope (§14), state machines with
  exact enum values (§15), availability/payment/identity/access/folio/checkout/
  invoice/loyalty/reviews/notifications/audit rules, DB rules, financial safety,
  filtering/pagination, localization, error handling, testing.
- `docs/CLAUDE_INSTRUCTIONS.md` — **how you must work.** Role, mandatory
  source-of-truth rules, the before-coding checklist (objective → repo state →
  relevant files → reuse → proposed changes → risks → tests → expected result),
  the 12-point investigation rule, the no-assumption rule, scope control, git
  rules (no commit/push without explicit owner approval, no `git add .`),
  verification rule (never say "done"/"works" without actual verification), the
  required final report, and the Definition of Done.

## `dashboard/docs/metronic-v9.4.12/` — licensed vendor drop

The Metronic 9.4.12 package (HTML/Tailwind demos + starter kit, React
demos/concepts/starter kit, Next.js landings, `figma/Metronic_v9.4.12.fig`).
Git-ignored — a vendor reference, not committed. This app consumes only its
**design tokens, Tailwind 4 setup, KTUI component styles, and keenicons** —
re-skinned with the Hotel System identity. It does **not** use the React build
and introduces no second build system.

## What this dashboard is (current state)

See `../md/dashboard-foundation.md` (Phase 12 foundation), its audit
`../md/dashboard-foundation-audit.md`, and `../md/dashboard-master.md`
(completion pass) for the full write-up: auth, RBAC, hotel scope, the one API
client, Metronic integration, i18n/RTL, every implemented module, and the
**documented backend API gaps** (Guests, Payments/Invoices/Settlements ledgers,
Reviews domain, Reports, Audit read, list filter/sort params, Overview KPIs) —
each has an honest in-app "awaiting backend endpoint" page, never a fake.

Build status per `dashboard-master.md`: lint · typecheck · 38 unit tests ·
production build all green; not committed.

```
app/
  assets/        main.css (Metronic tokens re-skinned) + vendored keenicons
  components/    shared UI (DataTable, PageHeader, PermissionGate, HotelSelector,
                 AppTabs, FactGrid, GapState, workspace/PanelShell + panels)
  composables/   useApi, useCan, useNavigation, useResource
  config/        navigation.ts — the single nav definition (permission + scope + backendGap)
  layouts/       default (app shell), auth (login)
  middleware/    auth.global.ts (route + permission guard → /403)
  pages/         login, index(overview), hotels, room-types, rooms, services,
                 reservations/[id] (operational workspace), users, roles,
                 hotel-group, settings + gap pages (guests, payments, invoices,
                 settlements, loyalty, reviews, notifications, reports, audit,
                 digital-access, checkout, folio, countries, cities)
  plugins/       api.ts (the one API client), bootstrap.client.ts (session boot)
  services/      typed wrappers over real /api/v1 endpoints only
  stores/        auth, hotelContext, app (Pinia)
  types/         api.ts — mirrors the backend API Resources
  utils/         apiError, permissions, navigation, reservationStateMachine,
                 format (display only, never arithmetic), statusMeta
i18n/            en.json, ar.json (full parity, RTL preserved, Tajawal for Arabic)
tests/           vitest — guards, permission logic, error mapping, transition contract
```

## Working rules

- **Backend-first.** The dashboard renders forms, filters, navigation,
  permission-gated UI, loading/empty/error states, and presentation formatting.
  It must **never** calculate authoritative availability, prices, invoice totals,
  payment success, identity decisions, access issuance, folio totals, or loyalty
  balances — those come from the API. `utils/format.ts` is display only.
- **Never trust the client.** Permission slugs from `GET /auth/me` drive UI
  visibility only; the backend re-authorises every call and a `403` is final.
  Never send client `hotel_id` / `role` / `permission` / totals as authority.
  Transitions send `target_status`, never `status`.
- **RBAC:** `<PermissionGate>` for rendering, `useCan()` for logic, route
  `meta.permission` for page access, `config/navigation.ts` for the sidebar.
- **Hotel scope:** `stores/hotelContext.ts`. Hotel-scoped pages require a
  concrete hotel and show `NeedHotelNotice` until one is chosen (backend routes
  are `/hotels/{hotel}/…`).
- **No faked endpoints.** If the backend lacks a contract, add a documented
  `GapState` page naming the exact endpoint(s) required — do not invent data.
- **Metronic layout only.** Sidebar/header/toolbar come from the shared layout.
  Use the existing `.card` / `.btn` / `.input` / `.table-base` primitives and
  logical properties (`ps-/pe-`, `start-/end-`) so RTL mirrors. Keep light + dark.
- **Visual identity:** warm brown `--primary #875a34`, bronze/gold
  `--accent #b58343`, cream `--background #f6f1e9`, `--radius 0.625rem`, soft
  warm shadows, restrained borders — defined once in `app/assets/css/main.css`.
  `Inter` for Latin, `Tajawal` for Arabic.
- **i18n:** no hardcoded user-facing text; keep en/ar parity.
- **Git:** no commit or push without explicit owner approval; no `git add .`
  with unrelated work present; change only files the task needs.
- **Verification:** never claim "done"/"works" without lint + typecheck + test +
  build (and a browser check where relevant); state what was and was not
  verified; end with the required final report from `CLAUDE_INSTRUCTIONS.md §19`.

## Commands

```bash
cd dashboard
npm run dev        # http://localhost:3000
npm run lint && npm run typecheck && npm run test && npm run build
```

Needs a backend reachable at `NUXT_PUBLIC_API_BASE` (`…/api/v1`) with the
dashboard origin allowed via CORS.
