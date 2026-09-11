# Architecture Restructure — Proposal (for approval)

Status: **DRAFT — nothing changed yet.** Awaiting owner approval before any
file moves. Follows `dashboard/docs/CLAUDE_INSTRUCTIONS.md` (plan-before-code,
scope control, no big-bang rewrites) and the project rule *"do not rewrite
working architecture for style reasons."*

## 1. Scope (as agreed 2026-09-11)

| Area | Decision |
|---|---|
| **Backend** | **Keep `app/Domain/` structure as-is.** No structural change in this effort. Optional future notes recorded in §2, not scheduled. |
| **Dashboard** | **Keep the layered structure** (`app/{components,composables,services,stores,utils,types,pages}`). Only **split the monolith files** and **group `components/`** into subfolders. No move to `features/<domain>/`. |
| **Deliverable now** | This proposal. Execution happens after approval, in the slices in §6, each ending green (`lint` + `typecheck` + `test` + `build`) with its own commit. |
| **Mobile** | Untouched. |

Non-goals: renaming domains, changing any API contract, changing runtime
behaviour, touching business logic, dependency upgrades, test rewrites.

---

## 2. Backend — keep as-is (rationale + optional future notes)

The backend is already a clean DDD layout and matches
`HOTEL_ARCHITECTURE_RULES.md`:

```
app/Domain/<Context>/{Models,Services,Repositories,Policies,StateMachine,Exceptions,Provider,Enums,Events,Listeners}
```

16 bounded contexts, 141 test files, `Controller → FormRequest → Service →
Repository → Model` enforced. There is **no structural problem worth the risk**
of moving hundreds of files across a tested codebase with uncommitted phase
work on the tree.

**Optional, NOT scheduled** (raise separately if ever wanted):

1. **Confusing "access/identity" domain names.** Four contexts read alike:
   - `GuestAccess` → guest login + OTP
   - `IdentityAccess` → staff users + roles + permissions (RBAC)
   - `IdentityVerification` → document/selfie KYC
   - `DigitalAccess` → room keys

   A pure rename (`GuestAccess`→`GuestAuth`, `IdentityAccess`→`AccessControl`,
   `DigitalAccess`→`RoomAccess`) + a one-paragraph header in each domain would
   remove the ambiguity. Rename-only, no logic change — but still touches
   namespaces, `config/`, DI bindings, and ~30 test files. Deferred.
2. **HTTP layer is flat.** `Http/Controllers/Api/V1/` (25 controllers),
   `Http/Resources/V1/` (29), `Http/Requests/Api/V1/` do not mirror `Domain/`.
   Could become `…/V1/{Reservation,Payment,…}/`. Cosmetic; deferred.
3. **`routes/api.php` is one 235-line file.** Could split to `routes/api/*.php`
   included from `api.php`. Small, low-risk, but out of agreed scope.

If none of these ship, the backend section of this effort is simply "verified
no change needed."

---

## 3. Dashboard — current pain points

| # | Pain | Evidence |
|---|---|---|
| D1 | One API-wrapper file for the whole app | `app/services/index.ts` — 306 lines, 15 service objects, imported by 28 files |
| D2 | One types file for the whole API surface | `app/types/api.ts` — 472 lines, imported app-wide |
| D3 | Flat `components/` | 55 files in `app/components/` root; only `workspace/` is grouped |
| D4 | `utils/` mixes generic + domain helpers | `format.ts`, `apiError.ts` (generic) next to `reservationStateMachine.ts`, `reservationLifecycle.ts`, `statusMeta.ts`, `permissions.ts`, `navigation.ts` (domain) |

None of these are correctness bugs. They are navigability / merge-friction
costs that grow with every new module.

---

## 4. Dashboard — target structure

Same top-level layout. Each folder that is currently a monolith becomes a
**folder with a barrel** so existing import paths keep working.

### 4.1 `services/` — split, keep the barrel

```
app/services/
  index.ts        ← re-exports everything (unchanged import path: `~/services`)
  _client.ts      ← shared: `api()`, `cleanQuery()`, `LocationListParams`
  hotelGroups.ts  ← hotelGroupsService
  hotels.ts       ← hotelsService
  locations.ts    ← countriesService, citiesService
  inventory.ts    ← roomTypesService, roomsService
  serviceCatalog.ts ← serviceCategoriesService, servicesService
  reservations.ts ← reservationsService
  workspace.ts    ← paymentsService, folioService, serviceOrdersService,
                    identityVerificationService, digitalAccessService,
                    checkoutService, loyaltyService, notificationsService
  rbac.ts         ← rbacService
  users.ts        ← usersService
```

`index.ts` becomes:

```ts
export * from './hotelGroups'
export * from './hotels'
export * from './locations'
// …etc
```

**Every current `import { xxxService } from '~/services'` keeps working
unchanged.** Optionally, later, point call sites at the specific module; not
required and not in scope.

### 4.2 `types/` — split, keep the barrel

```
app/types/
  api.ts          ← re-exports everything (unchanged import path: `~/types/api`)
  common.ts       ← envelope, pagination meta, shared unions
  hotel.ts        ← Hotel, HotelGroup, Country, City
  inventory.ts    ← RoomType, Room, RoomStatus, ServiceCategory, HotelService
  reservation.ts  ← Reservation, ReservationStatus
  payment.ts      ← Payment, Folio, FolioCharge, CheckoutResult, Invoice
  identity.ts     ← IdentityVerification, AccessGrant
  loyalty.ts      ← LoyaltyAccount, LoyaltyRule, LoyaltyTransaction
  service-order.ts← ServiceOrder, ServiceOrderStatus
  notification.ts ← AppNotification
  rbac.ts         ← Role, Permission, StaffUser
```

`api.ts` re-exports all. Same zero-churn guarantee as §4.1.

### 4.3 `components/` — group into subfolders

Nuxt auto-imports `components/`. **Two ways to add subfolders:**

- **Option A (recommended): `pathPrefix: false`.** Add to `nuxt.config.ts`:
  ```ts
  components: [{ path: '~/components', pathPrefix: false }]
  ```
  Component names stay exactly as today (`<DataTable>`, `<HotelForm>`, …) even
  after moving into subfolders. **Only cost:** the 9 files using
  `<WorkspacePaymentPanel>` / `<WorkspacePanelShell>` etc. must drop the
  `Workspace` prefix (→ `<PaymentPanel>`, `<PanelShell>`). ~9 templates,
  mechanical, caught immediately by `typecheck` + `build`.
- **Option B: keep `pathPrefix: true` (default).** No `nuxt.config` change;
  `workspace/*` names stay. But every moved component gets a folder prefix
  (`components/hotels/HotelForm.vue` → `<HotelsHotelForm>`), so ~20 call sites
  change and names get awkward.

Recommend **Option A**.

Target grouping (55 → 7 folders):

```
components/
  layout/   AppHeader AppSidebar AppDrawer AppBreadcrumbs AppToaster AppLogo
            UserMenu ThemeToggle LanguageSelector
  ui/       DataTable DataCard Pagination FilterBar SearchField FormField
            FormSection DateRangeField EntitySelect ConfirmDialog KtIcon
            MoneyDisplay StatusBadge StatCard FactGrid PageHeader AppModal
            AppDropdown AppTabs AppTimeline AppImage
  states/   EmptyState ErrorState LoadingState ForbiddenState NotFoundState
            NeedHotelNotice GapState GapListPage UnavailablePanel InfoNote
  hotels/   HotelForm HotelSelector
  locations/ CityForm CountryForm
  rbac/     PermissionGate
  workspace/ (unchanged — 10 files already here)
```

(Exact bucket for a couple of borderline components — `AppModal`, `KtIcon` —
can be settled during execution; it doesn't affect names under Option A.)

### 4.4 `utils/` — optional light grouping

Low value, higher churn (every `~/utils/x` import moves). **Proposal: skip**
unless you want it. If wanted: `utils/` for generic (`format`, `apiError`),
`utils/domain/` for the rest, with a barrel.

### 4.5 `composables/`, `stores/`, `config/`, `pages/`

No change. They are already small and correctly scoped.

---

## 5. Migration map (what moves where)

| From | To | Import path after |
|---|---|---|
| `services/index.ts` (split) | `services/*.ts` + barrel `services/index.ts` | `~/services` (unchanged) |
| `types/api.ts` (split) | `types/*.ts` + barrel `types/api.ts` | `~/types/api` (unchanged) |
| `components/<X>.vue` (43 files) | `components/<group>/<X>.vue` | `<X>` unchanged (Option A) |
| `components/workspace/*` (10) | unchanged location | `<X>` **loses** `Workspace` prefix (Option A) |
| `nuxt.config.ts` | `+ components: [{ path, pathPrefix: false }]` | — |

Tests in `tests/` import from `~/services`, `~/utils/*`, `~/types/api` — all
barrel-preserved, so **no test file moves or changes** except any that
reference a `Workspace`-prefixed component name (grep shows none in `tests/`).

---

## 6. Execution slices (each: green gates + own commit)

| Slice | Content | Files touched | Risk |
|---|---|---|---|
| **S1** | Split `services/index.ts` → modules + barrel | ~11 new, 1 rewritten | very low (barrel) |
| **S2** | Split `types/api.ts` → modules + barrel | ~11 new, 1 rewritten | very low (barrel) |
| **S3** | `nuxt.config` `pathPrefix: false` + de-prefix the 9 `Workspace*` usages | 1 + 9 | low (compiler-caught) |
| **S4** | Move `components/` into `layout/ ui/ states/ hotels/ locations/ rbac/` | 43 moved | low (Option A = no rename) |
| **S5** | (optional) `utils/` grouping — only if approved | ~7 + call sites | medium |

Gate after every slice:
```bash
cd dashboard && npm run lint && npm run typecheck && npm run test && npm run build
```
Stop and report if any gate is not green. Commit per slice (message names the
slice). No `git add .` — the tree has unrelated uncommitted work.

Backend: a separate, optional slice **B1** only if §2 items are approved
later. Not part of this effort unless you say so.

---

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Auto-import name collision after moving components | Option A keeps names identical; `build` fails loudly on any dup |
| A `Workspace*` reference missed in S3 | `typecheck` + `build` catch unknown components; grep sweep first |
| Barrel re-export misses a symbol | `typecheck` fails on any unresolved import across 28 consumer files |
| Circular import via barrels | Split modules import from `_client.ts` / `types/common.ts`, never from the barrel |
| Merge conflict with uncommitted phase work | Slices are small and commit fast; run after the current tree is committed if possible |
| i18n / RTL / theme regression | None of these slices touch CSS, i18n JSON, or templates beyond component tags |

---

## 8. Verification plan

- Per slice: the 4 gates above (`lint`, `typecheck` = `vue-tsc`, `test` =
  38 vitest, `build` = SPA).
- After S4: `node .output/server/index.mjs` boots and serves `/` 200.
- Manual: open 3–4 representative pages in dev (`overview`, `hotels`,
  `reservations/[id]` workspace, a gap page) — confirm no missing-component
  warnings in the console.
- Final report per `CLAUDE_INSTRUCTIONS.md §19`.

---

## 9. Open questions for the owner

1. **Option A vs B** for `components/` subfolders — confirm **A** (recommended,
   less churn, keeps names).
2. **Slice S5 (`utils/` grouping)** — do it, or skip? (Proposal: skip.)
3. **Backend §2 items** — leave all deferred (proposal), or schedule the
   domain rename / HTTP grouping / route split as a follow-up?
4. Should execution wait until the **current uncommitted tree is committed**
   (mobile + backend phase work), to keep these slices isolable?
5. Commit style: one commit per slice on `main`, or a `chore/dashboard-restructure`
   branch? (Repo rule: branch off `main` unless told otherwise.)
