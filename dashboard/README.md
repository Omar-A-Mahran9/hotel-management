# Hotel Management Dashboard

One unified internal dashboard (Nuxt 3 + Vue 3, Metronic 9 design system) for
Central / Hotel Group, Hotel, and Reception staff. Central and Hotel
capabilities live in **this single app**, switched by the signed-in user's
permissions and hotel scope — there is no separate central/hotel project.

The Laravel API (`../backend`, `/api/v1`) is the only source of business
truth. This app never duplicates business rules and never fakes an endpoint.

## Requirements

- Node 20+ (developed on Node 23)
- A running backend at `http://localhost:8000` (or set `NUXT_PUBLIC_API_BASE`)

## Setup

```bash
cd dashboard
cp .env.example .env          # point NUXT_PUBLIC_API_BASE at your API
npm install
npm run dev                   # http://localhost:3000
```

## Scripts

| Script | Purpose |
|---|---|
| `npm run dev` | Dev server (SPA) |
| `npm run build` | Production build (`.output/`) |
| `npm run preview` | Serve the production build |
| `npm run lint` | ESLint (`@nuxt/eslint`) |
| `npm run typecheck` | `vue-tsc` via `nuxt typecheck` |
| `npm run test` | Vitest unit tests |

## Environment

| Var | Default | Notes |
|---|---|---|
| `NUXT_PUBLIC_API_BASE` | `http://localhost:8000/api/v1` | Must include `/api/v1`, no trailing slash |

The backend must allow the dashboard origin via CORS (see the API-gap note in
`md/dashboard-foundation.md`).

## Architecture

See **`../md/dashboard-foundation.md`** for the full write-up: authentication,
RBAC, hotel scope, API client, Metronic integration, i18n/RTL, the modules
that are implemented, and the backend API gaps that block the rest.

```
app/
  assets/        main.css (Metronic tokens re-skinned) + vendored keenicons
  components/     shared UI (DataTable, PageHeader, PermissionGate, HotelSelector, …)
  composables/    useApi, useCan, useNavigation, useResource
  config/         navigation.ts — the single nav definition
  layouts/        default (app shell), auth (login)
  middleware/     auth.global.ts (route + permission guard)
  pages/          login, overview, hotels, room-types, rooms, reservations, users, roles
  plugins/        api.ts (the one API client), bootstrap.client.ts (session boot)
  services/       typed wrappers over real /api/v1 endpoints only
  stores/         auth, hotelContext, app (Pinia)
  types/          api.ts — mirrors the backend API Resources
  utils/          apiError, permissions, navigation, reservationStateMachine
i18n/locales/     en.json, ar.json
tests/            vitest — guards, permission logic, error mapping, transition contract
```

## Metronic

The licensed package lives at `dashboard/metronic-v9.4.12/` (git-ignored — a
vendor drop, not committed). This app consumes its **design tokens, Tailwind 4
setup, KTUI component styles and keenicons** — re-skinned with the Hotel
System identity (warm brown / cream / bronze, Tajawal for Arabic). It does
**not** use the React build and introduces no second build system.
