# Phase 8 — Stay Services + Folio — Implementation Report

**Status:** READY FOR REVIEW · not committed, not pushed
**Base commit:** `9715693` (working tree; the last *backend* commit is `d96f9cf` Phase 7)
**Date:** 2026-09-07

---

## 1. Objective

Backend foundation for hotel services consumed/requested during a reservation
and the resulting charges recorded against the reservation's folio. The
backend stays the source of truth. This phase prepares the financial data
the later Checkout phase will consume; it does **not** implement checkout,
settlement, capture, or invoicing.

---

## 2. Source-of-truth references

- `md/hotel_platform_phase0_approved_baseline.md`:
  - §4 domain map — "Guest Services & Folio" bounded context.
  - §6.1 — "Hotel … owns its … Services catalog".
  - §6.4 — anticipated entities `hotel_services` / `service_orders` /
    `guest_folios` / `guest_charges`.
  - §7 / §32 — RBAC matrix; Reception has **no financial edit/delete**.
  - §9 — Payment State Machine (used read-only for the folio's payments total).
  - §16 — API map: `/api/v1/hotels/{hotel}/services`,
    `/api/v1/reservations/{reservation}/service-orders`.
  - §17 — security (no card data stored, full audit, no internal detail in
    responses).
  - R14–R20 — guest journey "… Digital Check-in → Stay/Services → …".
  - R54 — "no dynamic/occupancy pricing; no unnecessary rate-plan complexity".
- Existing Phase 4 (`ReservationStateMachine`), Phase 5 (`Payment` /
  `PaymentStateMachine`), Phase 7 (`DigitalAccessService` staged-transaction
  pattern) architecture is followed exactly.
- `md/mobile/` and the Flutter app were **not created, modified, or touched**.

Decision classification key: **[A]** approved · **[T]** technical decision ·
**[O]** owner addition · **[F]** future · **[C]** clarification required.

---

## 3. Domain model

New bounded context `App\Domain\StayServices\`.

| Entity | Table | Role |
|---|---|---|
| `ServiceCategory` | `service_categories` | Optional, hotel-scoped grouping for the catalog. **[O/T]** — the baseline lists no category table; kept rule-free and un-seeded. |
| `HotelService` | `hotel_services` | A thing a guest can request/consume; carries the price. **[A]** (§6.4). |
| `ServiceOrder` | `service_orders` | A service ordered for one reservation, with a historical price snapshot. **[A]** (§6.4 `service_orders`). Named `ServiceOrder` (not the prompt's suggested `ReservationService`) to avoid colliding with the existing `App\Domain\Reservation\Services\ReservationService` class, and to match the §16 route `service-orders`. **[T]** |
| `FolioCharge` | `folio_charges` | A financial amount owed on a reservation's folio. **[A]** (§6.4 `guest_charges`). |

**No `folios` / `guest_folios` table.** A folio is exactly "one reservation +
its folio charges + the money maths", so it is a **read model**
(`App\Domain\StayServices\Services\Folio` DTO built by `FolioService`) keyed
by `reservation_id`, not a stored entity. **[T]** — a physical folio row
(e.g. an `open`/`locked` status for checkout's `CHARGES_LOCKED`) is a clean
extension point for the Checkout phase; nothing here blocks it.

### Repositories (all DB access lives here)

`ServiceCategoryRepositoryInterface`, `HotelServiceRepositoryInterface`,
`ServiceOrderRepositoryInterface`, `FolioChargeRepositoryInterface` +
`Eloquent*` implementations, bound in `AppServiceProvider::$bindings`.

### Services (orchestration)

- `ServiceCatalogService` — category + service CRUD + activate/deactivate.
- `ServiceOrderService` — order creation, state transitions, folio-charge
  posting/voiding.
- `FolioService` — read-only folio maths → `Folio` DTO.

Controller → Service → Repository → Model is preserved throughout; an
architecture test enforces "no `DB::`, no `::query(`, no state machine, no
model access" in controllers and "no query builder / model statics" in
services.

---

## 4. Database schema

MariaDB 10.4-compatible: `enum` + plain B-tree indexes only, `DECIMAL` money,
identifier names ≤ 64 chars, no MySQL-8-only features, no CHECK-constraint
reliance. Verified on **MariaDB 10.4.28** with `migrate:fresh`,
`migrate:rollback --step=4`, re-migrate, and `migrate:fresh --seed`.

### `service_categories`
`id`; `hotel_id` FK→hotels **restrictOnDelete**; `name` string(255);
`description` string(500) null; `is_active` bool default `true`; timestamps.
Indexes: `unique(hotel_id, name)`, `index(hotel_id, is_active)`.
FK column auto-indexed by MariaDB — not re-indexed.

### `hotel_services`
`id`; `hotel_id` FK **restrict**; `service_category_id` FK→service_categories
**nullOnDelete**, nullable; `name` string(255); `description` string(1000)
null; `price` **DECIMAL(12,2)** (non-negative; Form Request caps magnitude);
`currency` **CHAR(3)** null (never defaulted — mirrors `payments.currency`);
`is_active` bool default `true`; timestamps.
Indexes: `unique(hotel_id, name)`, `index(hotel_id, is_active)`.

### `service_orders`
`id`; `reservation_id` FK **restrict**; `hotel_id` FK **restrict**
(denormalized from the reservation, never client); `service_id`
FK→hotel_services **restrict** (a service with orders is deactivated, never
deleted); `quantity` unsignedInteger; `unit_price_snapshot` **DECIMAL(12,2)**;
`currency_snapshot` CHAR(3) null; `total_amount` **DECIMAL(12,2)**;
`status` enum(`requested`,`confirmed`,`fulfilled`,`cancelled`) default
`requested`; `notes` string(500) null; `requested_by_user_id`
FK→users **nullOnDelete** null; `requested_at` / `confirmed_at` /
`fulfilled_at` / `cancelled_at` timestamps null; `cancellation_reason`
string(500) null; timestamps.
Indexes: `index(reservation_id, status)`, `index(hotel_id, status)`.

### `folio_charges`
`id`; `reservation_id` FK **restrict**; `hotel_id` FK **restrict**;
`source_type` enum(`service_order`); `source_id` unsignedBigInteger null
(soft reference — the source table varies by type, so not a DB FK);
`description` string(500); `quantity` unsignedInteger; `unit_amount`
**DECIMAL(12,2)**; `total_amount` **DECIMAL(12,2)**; `currency` CHAR(3) null;
`status` enum(`posted`,`cancelled`) default `posted`; `charged_at` /
`cancelled_at` timestamps null; `created_by_user_id` FK→users
**nullOnDelete** null; `metadata` json null; timestamps.
Indexes: **`unique(source_type, source_id)`** (the duplicate-charge guard),
`index(reservation_id, status)`, `index(hotel_id, status)`.

FK delete behaviour is deliberate everywhere: financial / historical rows use
`restrictOnDelete`; the optional category link and the actor references use
`nullOnDelete`. No cascades.

---

## 5. Service lifecycle

`ServiceOrderStateMachine` is the single transition authority (mirrors
`PaymentStateMachine`). **[T]** — the approved baseline defines no explicit
service lifecycle, so the smallest practical one is used and documented:

```
requested ──▶ confirmed ──▶ fulfilled        (fulfilled = terminal)
    │             │
    └──▶ cancelled◀┘                          (cancelled = terminal)
```

- **`requested`** — the order is recorded; **no financial effect**.
- **`confirmed`** — staff acknowledge the order will be provided; this is the
  point it becomes financially chargeable → a `folio_charge` is posted.
- **`fulfilled`** — pure fulfilment marker; **no financial effect**.
- **`cancelled` from `requested`** — clean, no charge exists.
- **`cancelled` from `confirmed`** — the folio charge is **voided**
  (`status = cancelled`), **never negated**. No refund behaviour is invented
  (see §12).

`assertCanTransition()` guards every persisted status change in the service;
the map is never duplicated elsewhere. Exhaustively unit-tested (allowed set,
forbidden matrix incl. self-transition and unknown status, terminal
detection, "confirmed is unreachable without passing requested", map ==
model vocabulary).

---

## 6. Folio behaviour

`FolioService::folioFor(Reservation): Folio` returns:

- `reservation` reference (id, hotel_id, guest_id, status),
- `charges` — every `folio_charge` for the reservation (posted **and**
  cancelled are listed; the resource never hides a charge),
- `totals`:
  - `charges_total` = `SUM(total_amount)` over **`posted`** charges only
    (DB `SUM` over the `DECIMAL` column, normalised with `bcadd` — no float),
  - `payments_total` = the reservation `Payment.amount` **only when**
    `Payment.status ∈ {captured, settled}` (`Payment::CAPTURED_STATUSES`),
    else `0.00`,
  - `outstanding_total` = `bcsub(charges_total, payments_total)` — may be
    negative when a captured deposit exceeds charges (returned raw, not
    clamped),
- `payment_summary` — `{status, amount, currency, is_captured}` or `null`.

All money values are canonical `DECIMAL(12,2)` strings; **bcmath only, never
float arithmetic** (architecture-tested).

---

## 7. Payment integration behaviour

- The folio's `payments_total` **reuses Phase 5 state semantics** — it never
  redefines them. `Payment::CAPTURED_STATUSES = [captured, settled]` was
  added **beside** the existing status vocabulary on the `Payment` model so
  there is exactly one home for "which statuses mean money in". **[T]**
- A deposit **hold** (`hold_active`), a **pending** capture
  (`capture_requested` / `final_settlement_requested`), and any **failed**
  payment (`hold_failed` / `capture_failed`) all contribute **0.00** — a hold
  is an authorization, not money received. Tested against every one of those
  statuses.
- Phase 8 performs **no** capture, settlement, refund, or reservation
  transition. `FolioCharge` and `Payment` stay strictly separate:
  FolioCharge = what is owed; Payment = money movement. The
  `PaymentWorkflowService` and `ReservationService` gained **zero** dependency
  on stay services (architecture-tested).

---

## 8. Authorization (RBAC)

Five new permissions (RolePermissionSeeder; Group Owner gets all via the
existing `array_keys`):

| Permission | Group Owner | Hotel Manager | Reception | Guest |
|---|:-:|:-:|:-:|:-:|
| `services.view` | ✅ | ✅ | ✅ | ❌ |
| `services.manage` | ✅ | ✅ | ❌ | ❌ |
| `service-orders.view` | ✅ | ✅ | ✅ | ❌ |
| `service-orders.manage` | ✅ | ✅ | ✅ | ❌ |
| `folio.view` | ✅ | ✅ | ✅ | ❌ |

Rationale:
- `services.manage` sets service **pricing** = financial configuration →
  §7/§32 excludes Reception. **[A]**
- `service-orders.manage` (recording/transitioning an in-stay request) is an
  **operational** action — R7/R14–R19 make Reception the operational fallback
  for guest-facing flows; it is not a "financial edit/delete" of a payment or
  invoice record, and every mutation is audited. Same reasoning the Phase 7
  report used to include Reception on digital access. **[T]**
- `folio.view` — reading the "what does the guest owe?" summary is
  operational; §32's Reception restriction is on financial **edit/delete**,
  not read. **[T]**

Policies: `ServiceCategoryPolicy`, `HotelServicePolicy` (both permission +
`HotelAccessService::canAccessHotel`), `ServiceOrderPolicy` /`FolioPolicy`
(both act on the resolved `Reservation`, hotel scope from the user's own
stored access — never a client `hotel_id`). Group Owner is an explicit
policy-checked bypass. Cross-hotel is denied even **with** the permission
(tested).

**Guest:** no permissions — guest authentication does not exist in this MVP.
Guest-initiated service requests are a documented future integration point
(§17), not invented here.

---

## 9. Hotel scoping

- Catalog endpoints are nested under `/hotels/{hotel}` (route-model bound,
  same as room-types). `hotel_id` on every created row comes from the
  authorized route `Hotel`; a body `hotel_id` is stripped and ignored
  (tested). A category/service belonging to another hotel is an identical
  plain **404** via `ensureBelongsToHotel()`.
- `ServiceCategory` / `HotelService` use the shared `HotelScoped` trait;
  repository list queries call `->accessibleBy($user)`.
- Service-order / folio endpoints resolve `{reservation}` as an **int id**
  through `ReservationService::findAccessibleBy()` (not route-model binding),
  so a cross-hotel or missing id is an identical plain **404** — no existence
  leak. `{serviceOrder}` is re-checked to belong to that reservation (404
  otherwise).
- `ServiceOrderService` re-derives `hotel_id` from the locked reservation and
  requires `service.hotel_id === reservation.hotel_id` (422 mismatch).

---

## 10. API endpoints

All under `/api/v1`, `auth:sanctum`, standard `{ success, message, data,
meta? }` envelope, Form Request validation, Policy authorization, API
Resources.

### Service catalog — `/api/v1/hotels/{hotel}`

| Method | Path | Permission | Purpose |
|---|---|---|---|
| GET | `/service-categories` | `services.view` | List hotel service categories |
| POST | `/service-categories` | `services.manage` | Create a category |
| PUT/PATCH | `/service-categories/{serviceCategory}` | `services.manage` | Update name/description |
| PATCH | `/service-categories/{serviceCategory}/activate` | `services.manage` | Activate |
| PATCH | `/service-categories/{serviceCategory}/deactivate` | `services.manage` | Deactivate |
| GET | `/services` | `services.view` | List hotel services (`?active=1|0` filter) |
| POST | `/services` | `services.manage` | Create a service |
| GET | `/services/{service}` | `services.view` | Show a service |
| PUT/PATCH | `/services/{service}` | `services.manage` | Update name/description/price/currency/category |
| PATCH | `/services/{service}/activate` | `services.manage` | Activate |
| PATCH | `/services/{service}/deactivate` | `services.manage` | Deactivate |

No delete endpoint — historical references are preserved by deactivation
(a `DELETE` returns 405, tested).

### Reservation service orders & folio — `/api/v1/reservations/{reservation}`

| Method | Path | Permission | Purpose |
|---|---|---|---|
| GET | `/service-orders` | `service-orders.view` | List the reservation's service orders |
| POST | `/service-orders` | `service-orders.manage` | Order a service (`service_id`, `quantity`, `notes?`) |
| GET | `/service-orders/{serviceOrder}` | `service-orders.view` | Show one order |
| POST | `/service-orders/{serviceOrder}/transition` | `service-orders.manage` | `target_status` ∈ {confirmed, fulfilled, cancelled} (+ `reason?`) |
| GET | `/folio` | `folio.view` | The reservation folio (charges + totals + payment summary) |

HTTP mapping: create → 201; transition → 200; business-rule failures
(wrong reservation state, inactive/cross-hotel service, illegal transition,
amount out of range) → **422** with the safe fixed message (the project has
no 409 convention — every domain exception maps to 422, consistent with
Phases 4–7).

---

## 11. Validation

| Field | Rule |
|---|---|
| category `name` | required, ≤255, `unique(hotel_id, name)` |
| category `description` | nullable string ≤500 |
| service `name` | required, ≤255, `unique(hotel_id, name)` |
| service `price` | required, numeric, `min:0`, `max:1000000`, `decimal:0,2` |
| service `currency` | nullable, `size:3`, `alpha`, `uppercase` (never defaulted) |
| service `service_category_id` | nullable, `exists` scoped to the route hotel |
| order `service_id` | required integer ≥ 1 |
| order `quantity` | required integer, `min:1`, `max:1000` (no zero, no negative) |
| order `notes` | nullable string ≤500 |
| transition `target_status` | required, `in:[confirmed, fulfilled, cancelled]` |
| transition `reason` | nullable string ≤500 |

The `price` `max` and `quantity` `max` are **technical boundaries so
`price × quantity` always fits `DECIMAL(12,2)`** — not invented business
rules. `ServiceOrderService` re-guards the computed total with `bcmul` + a
range regex (`FolioChargeAmountException` → 422) and never trusts a
client-supplied `hotel_id`, `unit_price`, `total_amount`, `status`, or
`requested_by_user_id` — all are derived server-side (security-tested).

`is_active` / `hotel_id` are never accepted on any create/update body.

---

## 12. Audit behaviour

Every mutation is recorded via the central `AuditLogger` with a safe, flat
business snapshot:

`service_category.created` / `.updated` / `.activated` / `.deactivated`,
`service.created` / `.updated` / `.activated` / `.deactivated`,
`service_order.created` / `.confirmed` / `.fulfilled` / `.cancelled`,
`folio_charge.created`, `folio_charge.cancelled`.

Snapshots carry status, ids, quantity, snapshot amounts, currency, and
timestamps only. **Never** logged: card data, provider secrets, the
free-text cancellation reason, a stack trace, or a SQLSTATE (tested — every
audit row is scanned).

---

## 13. Concurrency considerations

- **Lock order everywhere:** `Reservation → ServiceOrder → FolioCharge`
  (`HotelService` is locked with `Reservation` only during order creation,
  for a consistent price snapshot; no cycle with any other domain).
- **Order creation** runs in one `DB::transaction`: the reservation is
  `findForUpdate`-locked (state re-read under the lock), the service is
  `findForUpdate`-locked (price snapshot is race-free against a concurrent
  price edit).
- **Transition** runs in one transaction: the order is `findForUpdate`-locked
  and its status re-read before `assertCanTransition`, so two concurrent
  transitions cannot both act on the same start state.
- **Duplicate folio charge prevention:** `folio_charges (source_type,
  source_id)` **UNIQUE** + a `findBySourceForUpdate` pre-check + a
  `UniqueConstraintViolationException` catch that re-reads the winner. A
  retried / concurrent confirm never double-charges (tested: exactly one
  charge row per order under repeated confirm/fulfil).
- A cancelled `confirmed` order voids its charge under the same lock; repeated
  cancel is a safe no-op.

The provider-boundary staged-transaction rule from Phases 5–7 does not apply
— Phase 8 has **no external provider**.

---

## 14. Tests

MariaDB 10.4.28, `RefreshDatabase`, `RolePermissionSeeder`.

**Phase 8 focused — 115 passed (388 assertions):**

- `Unit/StayServices/ServiceOrderStateMachineTest` — allowed/forbidden
  matrix, terminals, unreachable-`confirmed`, map == vocabulary.
- `Unit/StayServices/ServiceCatalogServiceTest` — hotel derivation,
  `is_active` ignored, cross-hotel category nulled, no delete path, audit.
- `Unit/StayServices/ServiceOrderServiceTest` — price snapshot, snapshot
  frozen against later price change, server-side total, inactive/cross-hotel
  service, missing service, non-serviceable reservation state, in-stay OK,
  confirm→one posted charge, idempotent confirm, one charge per source under
  repost, cancel→void (never negative, no reversal row), cancel-requested→no
  charge, fulfilled terminal.
- `Unit/StayServices/FolioServiceTest` — zero/zero, multi-charge exact
  decimals, cancelled charge excluded (still listed), captured & settled
  count, **every non-captured payment status contributes 0.00**, negative
  outstanding, currency resolved-not-invented.
- `Unit/StayServices/StayServicesSchemaTest` — all tables, unique per hotel
  (not across), one charge per source, DECIMAL round-trips exactly, restrict
  deletes on hotel/reservation, category delete nulls the link.
- `Unit/StayServices/StayServicesRepositoryTest` — hotel scoping + Group
  Owner bypass, active filter (null/true/false), lock helper, reservation
  isolation, `findBySource`, `sumTotalForReservation` (posted only, empty
  statuses, missing reservation).
- `Unit/StayServices/StayServicesPolicyTest` — 4-role matrix across all 4
  policies, cross-hotel denied with permission, Group Owner bypass.
- `Unit/StayServices/StayServicesArchitectureTest` — thin controllers,
  services never touch the query builder/models, state-machine-guarded
  transitions, **no float money maths**, folio reuses `Payment::CAPTURED_STATUSES`,
  Reservation/Payment domains have no StayServices dependency.
- `Unit/StayServices/StayServicesSecurityAndAuditTest` — client
  financial/identity fields ignored, every mutation audited with a safe
  snapshot (no secret/trace/reason leak).
- `Feature/StayServices/ServiceCatalogApiTest` — CRUD, duplicate name 422,
  activate/deactivate, cross-hotel 404, price bounds/decimals, category must
  belong to hotel, `?active` filter, no DELETE route (405), no leaked
  internals.
- `Feature/StayServices/ServiceOrderApiTest` — server-derived price/total
  (client values ignored), quantity bounds, inactive/cross-hotel/wrong-state
  422, confirm posts a charge, illegal transition 422, `target_status`
  validation, foreign order 404, cross-hotel reservation 404, 401.
- `Feature/StayServices/FolioApiTest` — shape + totals, hold-only payment not
  counted, **no payment secret in the response**, empty folio, cross-hotel
  404.
- `Feature/StayServices/StayServicesAuthorizationTest` — catalog view/manage
  matrix (Reception view-only), service-order/folio matrix, Reception can
  take an order but not configure the catalog, client cannot forge hotel
  scope via body.

**Full backend suite:** `1281 passed` (5745 assertions), 0 failed, 0 skipped
(was `1164` at the Phase 7 report; **+117**).

**Laravel Pint** `--test`: **passed** (clean).

**Migration verification:** `migrate:fresh`, `migrate:rollback --step=4` +
re-migrate, and `migrate:fresh --seed` all succeed on **MariaDB 10.4.28**.

---

## 15. Known limitations

- **[T]** `payments_total` is derived from the single 1:1 `Payment.amount`
  when captured/settled. Phase 5 implements only the hold; capture/settlement
  execution is a later phase, so in practice `payments_total` is `0.00` today
  for every reservation. The folio maths is already correct for when capture
  lands.
- **[T]** `outstanding_total` can be negative (captured deposit > charges).
  It is returned raw; whether/how to surface "guest is owed" is a Checkout
  concern.
- **[T]** `folio_charges.source_type` is an `enum` with the single value
  `service_order`. Checkout will add its own charge source(s) via a
  follow-up migration when defined.
- **[T]** No `folios` table (folio is a read model). If Checkout needs a
  lockable folio (`CHARGES_LOCKED`), that is a small additive migration.
- A process kill mid-transaction leaves no partial state (each operation is a
  single `DB::transaction`); there is no A→B→C provider gap here.

---

## 16. Deferred business clarifications

- **[C]** **Exact reservation-status window for ordering a service.** The
  baseline says only "Digital Check-in → Stay/Services" (R20). Implemented
  conservatively as `CHECKED_IN` or `IN_STAY`
  (`ServiceOrderService::SERVICEABLE_RESERVATION_STATUSES`). Whether pre-stay
  add-ons (from `VERIFIED`) or post-checkout adjustments should be allowed is
  a business decision.
- **[C]** **Who may confirm / fulfil an order, and whether staff may create
  an order already `confirmed`.** Currently any `service-orders.manage`
  holder may drive every transition, and orders always start `requested`.
- **[C]** **Cancellation / refund semantics for a charged service.** A
  cancelled `confirmed` order voids its charge; there is deliberately no
  negative charge and no refund. Real reversal behaviour (partial fulfilment,
  post-payment refund) is undefined in the baseline.
- **[C]** **Currency.** No business currency exists platform-wide (§20 item
  7). Service `currency` is nullable and never defaulted; the folio surfaces
  whatever the payment/charges carry, or `null`.
- **[C]** **Whether service categories are part of the approved scope at
  all**, and if hotels need category-level activation.

---

## 17. Future integration points

- **Guest-authenticated service requests.** When guest auth lands, the
  service-order endpoints gain a "guest owns their reservation" authorization
  branch; the request shape (`service_id`, `quantity`, `notes`) already suits
  a guest client. No guest endpoint is invented now.
- **Checkout phase** consumes `FolioService::folioFor()` unchanged
  (`charges_total` / `payments_total` / `outstanding_total`), and may add a
  `folios` lock row + new `folio_charges.source_type` values.
- **Room / stay charges, taxes, discounts, service provider integration,
  inventory deduction, POS** — all explicitly out of Phase 8; `folio_charges`
  is the extension surface.
- **Mobile / dashboard** consume the documented endpoints later; no client
  code was touched.

---

## 18. Scope confirmation

Not implemented (correctly out of scope): checkout workflow, invoice
generation/numbering, final payment settlement/capture orchestration,
loyalty, ratings/reviews, notifications, real payment/service/access
providers, room-service integration, inventory deduction, dynamic pricing,
taxes, discounts, commissions, housekeeping automation, POS, guest chat,
mobile/dashboard/frontend.

**Mobile / dashboard / frontend: untouched by Phase 8.** (The working tree
contains unrelated in-progress `mobile/` changes from a separate Flutter
"discovery" workstream that predate this task — see the final report §10.)

**Verdict: READY FOR REVIEW.** No commit, no push.
