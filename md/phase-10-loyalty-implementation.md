# Phase 10 — Loyalty — Implementation Report

**Status:** READY FOR REVIEW · not committed, not pushed
**Base:** working tree on `79fc343`, on top of the uncommitted Phase 9 (Checkout/Invoice)
**Date:** 2026-09-08

---

## 1. Objective

Backend foundation for the group-wide loyalty program (Phase 0 §13, R43):
a ledger-authoritative points account per guest, points **earned** from a
completed booking, points **redeemed** against an eligible booking, and a
per-hotel-group configurable rule. No expiration (R51), no tiers, no
folio/service redemption (R59), and **no rate is ever invented** (§13).

---

## 2. Source of truth

- Phase 0 baseline: §13 (Loyalty Model), §6.4 (`loyalty_accounts` /
  `loyalty_transactions` / `loyalty_rules`), §7 ("Configure loyalty rules" =
  Group-Owner-only), §16 (`/api/v1/loyalty/{account|transactions|redeem}`),
  §18 ("loyalty ledger math", "balance never mutated without a ledger row"),
  guardrail #8 (ledger authoritative, cache allowed).
- R43 (promoted to MVP), R51 (no expiration), R59 (redemption against
  eligible bookings only; no folio/service redemption), §20 item 6 (earn
  rate / conversion rate values genuinely unresolved).
- Existing Phases 1–9 architecture and conventions (domain-namespaced,
  Controller → FormRequest → Policy → Service → Repository → Model,
  reservation-scoped access, `AuditLogger`).

Classification: **[A]** approved · **[T]** technical decision · **[F]** future ·
**[C]** clarification required.

---

## 3. Domain model — `App\Domain\Loyalty\`

| Entity | Table | Role |
|---|---|---|
| `LoyaltyAccount` | `loyalty_accounts` | One per guest, group-wide. `points_balance` is a **cache**. |
| `LoyaltyTransaction` | `loyalty_transactions` | Append-only ledger — the authoritative balance. Signed `points` delta. |
| `LoyaltyRule` | `loyalty_rules` | One per hotel group. On/off switch + earn/redeem rates. **Nothing seeded/defaulted.** |

### Repositories
`LoyaltyAccountRepositoryInterface`, `LoyaltyTransactionRepositoryInterface`,
`LoyaltyRuleRepositoryInterface` (+ `Eloquent*`), bound in
`AppServiceProvider::$bindings`. All DB access lives here (architecture-tested).

### Services
- `LoyaltyService` — account resolution, ledger read, `recomputeBalance`,
  `earnForReservation`, `redeemForReservation`.
- `LoyaltyRuleService` — `ruleFor` (get-or-create inactive), `update` (Group
  Owner config).

### Policies
- `LoyaltyPolicy` (acts on the resolved `Reservation`) — `view` / `manage`.
- `LoyaltyRulePolicy` (acts on `HotelGroup`) — `view` / `manage`.

---

## 4. Database schema

MariaDB 10.4.28 verified (`migrate:fresh`, `migrate:rollback --step=3` +
re-migrate, `migrate:fresh --seed`). Integer points (points are counts —
**never `DECIMAL`/`FLOAT`**), `DECIMAL(12,4)` rates, `enum` + plain indexes.

### `loyalty_accounts` (`2026_09_07_160000`)
`id`; `guest_id` **UNIQUE** FK→guests **restrictOnDelete**;
`points_balance` `BIGINT` default 0 (signed — a future reverse/adjust could
go negative); `is_active` bool default true (reserved — no MVP path sets it
false); timestamps.

### `loyalty_rules` (`2026_09_07_160001`)
`id`; `hotel_group_id` **UNIQUE** FK **restrict**; `is_active` bool
**default false**; `earn_points_per_currency` `DECIMAL(12,4)` **null**
(never defaulted — §20 item 6); `redeem_currency_per_point` `DECIMAL(12,4)`
**null**; `eligible_source_types` json null (structural — `["reservation"]`
is the only implemented source); timestamps.

### `loyalty_transactions` (`2026_09_07_160002`) — append-only
`id`; `loyalty_account_id` FK **restrict**; `type`
enum(`earn`,`redeem`,`reverse`,`adjust`,`expire`); `points` `BIGINT` (signed
delta); `source_type` enum(`reservation`) null; `source_id`
unsignedBigInteger null; `reverses_transaction_id` nullable self-FK
**restrict** (for a future `reverse`); `description` string(500) null;
`created_by_user_id` FK→users **nullOnDelete** null; `metadata` json null;
`created_at` `useCurrent` (**no `updated_at`** — mirrors `audit_logs`).
Indexes: **`unique(loyalty_account_id, type, source_type, source_id)`** (the
idempotency guard — one `earn` and one `redeem` per booking; NULL-source
`adjust`/`reverse` rows are unconstrained), `index(loyalty_account_id, id)`
(newest-first ledger listing).

FK delete behaviour: financial/history rows use `restrictOnDelete`; the
actor reference uses `nullOnDelete`. No cascades.

---

## 5. Ledger & balance semantics

- **The ledger is authoritative.** `points_balance` is only ever changed
  inside one `DB::transaction` that **locks the account row**, alongside the
  ledger insert, by exactly the entry's signed `points` delta
  (`LoyaltyService::appendLedgerEntry` — the single mutation path;
  architecture-tested). `recomputeBalance()` re-derives the cache as
  `SUM(points)` from the ledger (drift-healing / reconciliation).
- `SUM(points)` over the ledger always equals `points_balance` after any
  operation (asserted in `LoyaltyServiceTest`).

---

## 6. Earn

`LoyaltyService::earnForReservation(Reservation, ?User): LoyaltyTransaction`

- **Eligibility:**
  1. The reservation's **hotel group** has a rule that is `is_active` — else
     `LoyaltyNotAllowedException::programInactive()` (422).
  2. The rule has a non-null `earn_points_per_currency` — else
     `earnRateNotConfigured()` (422). **No rate is invented.**
  3. `reservation.status ∈ {CHECKED_OUT, INVOICED}` (a completed/stayed
     booking — matches the §14 definition used for review eligibility) —
     else `reservationNotCompleted(status)` (422). **[T]**
  4. `reservation.price_snapshot` is set and `> 0` — else `nothingToEarn()`.
- **Points:** `floor(earn_points_per_currency × reservation.price_snapshot)`
  — `bcmul` for the multiplication, integer truncation for the result
  (points are whole counts; never rounds up; never float). **[T]** — the
  earn base is `price_snapshot` (the reservation's own booking value), so
  Loyalty has no dependency on the Checkout/Invoice domain. If it computes to
  `0` → `nothingToEarn()`.
- **Idempotent:** one `earn` per `(account, reservation)` — the
  `(loyalty_account_id, type, source_type, source_id)` UNIQUE + a pre-check +
  a `UniqueConstraintViolationException` catch. A second call returns the
  existing entry, never a second accrual.
- Audit `loyalty.earned` (safe snapshot: type, points, source, balance_after).

**[C] — the earn trigger.** The baseline says "earn from a completed booking"
but does not define *when* it fires. Phase 10 exposes an explicit,
idempotent `POST …/loyalty/earn` endpoint. Auto-triggering it from
`CheckoutService` on `→ INVOICED` is a clean, isolated follow-up (one guarded
call) — deliberately **not** wired in Phase 10 to keep the checkout workflow
untouched.

---

## 7. Redeem

`LoyaltyService::redeemForReservation(Reservation, int $points, ?User): LoyaltyTransaction`

- `$points ≥ 1` — else `InvalidLoyaltyPointsException` (422). The Form
  Request also caps it at 10,000,000 (a technical bound so `points × rate`
  cannot overflow `DECIMAL` — not a business rule).
- The rule is `is_active` with a non-null `redeem_currency_per_point` — else
  `programInactive()` / `redeemRateNotConfigured()` (422).
- `reservation.status ∈ {PENDING, DEPOSIT_HELD, VERIFIED, CHECKED_IN,
  IN_STAY}` — an active, not-yet-completed, not-cancelled booking — else
  `reservationNotRedeemable(status)` (422). **[T/C]** — §13/R59 do not define
  "eligible booking" precisely; this is the conservative reading (you spend
  points on an upcoming/current stay, having earned them on past ones).
- Account balance `≥ $points` (under the row lock) — else
  `insufficientBalance()` (422). **A redemption can never take the balance
  negative.**
- **Idempotent / conflict:** one `redeem` per `(account, reservation)`. A
  repeated call with the **same** points is an idempotent replay (returns the
  existing entry); a call with **different** points is
  `alreadyRedeemed()` (422).
- Ledger entry: `points = -$points`, `metadata.notional_value =
  points × redeem_currency_per_point` (bcmath, 2dp). Audit `loyalty.redeemed`.

**[F] — the monetary effect.** §13 says "no folio/service redemption" and
defines no discount mechanism. Phase 10 records the ledger movement and the
**notional** redeemed value only; how that value reduces a booking's
price/payment is a deferred integration point.

---

## 8. Rule configuration

`GET|PUT|PATCH /api/v1/hotel-groups/{hotel_group}/loyalty-rule` — Group Owner
only (§7). `ruleFor()` creates the row **inactive & unconfigured** on first
read (so the endpoint always has something to show); `update()` is a partial
patch of `is_active` / `earn_points_per_currency` /
`redeem_currency_per_point`, audited as `loyalty_rule.updated`.
`hotel_group_id` and `eligible_source_types` are never client-set.

---

## 9. API endpoints

All `auth:sanctum`, standard `{ success, message, data, meta? }` envelope,
Form Request validation, Policy authorization, API Resources.

### Reservation-scoped loyalty — `/api/v1/reservations/{reservation}`

| Method | Path | Permission | Purpose |
|---|---|---|---|
| GET | `/loyalty` | `loyalty.view` | The guest's loyalty account + balance (created on first access) |
| GET | `/loyalty/transactions` | `loyalty.view` | The guest's ledger, newest first (paginated) |
| POST | `/loyalty/earn` | `loyalty.manage` | Accrue for this completed booking (idempotent) → 201 |
| POST | `/loyalty/redeem` | `loyalty.manage` | Redeem `points` against this booking → 201 |

`{reservation}` is an int id resolved through
`ReservationService::findAccessibleBy()` — a cross-hotel or missing id is an
identical plain **404**. Guest identity is the reservation's guest (guest
auth does not exist in the MVP). Business failures → **422** (fixed safe
messages). No 409 convention (consistent with Phases 4–9).

### Rule config — `/api/v1/hotel-groups/{hotel_group}`

| Method | Path | Permission | Purpose |
|---|---|---|---|
| GET | `/loyalty-rule` | `loyalty.rules.manage` | Read the group's loyalty rule |
| PUT/PATCH | `/loyalty-rule` | `loyalty.rules.manage` | Configure it (Group Owner) |

---

## 10. Permissions

3 new (RolePermissionSeeder; Group Owner gets all via `array_keys`):

| Permission | Group Owner | Hotel Manager | Reception | Guest |
|---|:-:|:-:|:-:|:-:|
| `loyalty.view` | ✅ | ✅ | ✅ | ❌ |
| `loyalty.manage` | ✅ | ✅ | ❌ | ❌ |
| `loyalty.rules.manage` | ✅ | ❌ | ❌ | ❌ |

Rationale: front-desk staff routinely tell a guest their balance/history
(operational, R7 → `loyalty.view` incl. Reception). Redeeming points has a
monetary effect on a booking, so `loyalty.manage` follows the §32 "Reception
has no financial edit" split (same reasoning Phases 8/9 used). Configuring
loyalty rules is Group-Owner-only per §7. Guest: none (no guest auth).

---

## 11. Audit actions

Via the central `AuditLogger`, safe flat snapshots (type, signed points,
source, balance_after — never a secret; a loyalty entry carries no payment
data): `loyalty.earned`, `loyalty.redeemed`, `loyalty_rule.updated`.

---

## 12. Concurrency

- One account per guest (`UNIQUE guest_id`) + `findByGuestForUpdate` lock +
  a `UniqueConstraintViolationException` catch on the get-or-create.
- Every earn/redeem is one `DB::transaction` that locks the account row
  before reading the balance and appending the entry, so two concurrent
  mutations for the same guest serialize.
- One earn / one redeem per `(account, reservation)` — the composite UNIQUE
  is authoritative; a concurrent duplicate re-reads the winner.

---

## 13. Tests

MariaDB 10.4.28, `RefreshDatabase`, `RolePermissionSeeder`.

**Phase 10 focused — 86 passed:**

- `Unit/Loyalty/LoyaltyServiceTest` (39) — account get-or-create idempotent;
  earn maths (`floor(rate × price_snapshot)`), cache == ledger, idempotent,
  program-inactive / rate-not-configured / not-completed / zero-value /
  rounds-to-zero rejections, `CHECKED_OUT` allowed; redeem debit + notional
  value, insufficient balance, non-positive points, non-redeemable-status
  matrix, idempotent replay vs. conflicting-points, "every mutation writes
  exactly one ledger row and moves the balance by its delta",
  `recomputeBalance` heals a drifted cache.
- `Unit/Loyalty/LoyaltySchemaTest` — tables, `UNIQUE(guest_id)`,
  `UNIQUE(hotel_group_id)`, `UNIQUE(account,type,source)` (earn+redeem for the
  same source OK, second earn rejected), source-less adjust unconstrained,
  signed integers, 4-dp rates, no `updated_at`, restrict deletes on
  guest/group.
- `Unit/Loyalty/LoyaltyModelsTest` — relations, `canEarn`/`canRedeem`/
  `sourceTypes`, `expire` reserved.
- `Unit/Loyalty/LoyaltyRuleServiceTest` — created inactive/unconfigured,
  update audits, client `hotel_group_id`/`eligible_source_types` ignored,
  partial update.
- `Unit/Loyalty/LoyaltyPolicyTest` — 4-role matrix (both policies),
  cross-hotel denied with permission, Group Owner bypass.
- `Unit/Loyalty/LoyaltyArchitectureTest` — thin controllers, services never
  touch the query builder/models, **balance moves only via the
  ledger-writing helper**, integer/bcmath only (no float), `expire` never
  written, redeem request never reads amount/balance.
- `Feature/Loyalty/LoyaltyApiTest` — auth (401/404), read shapes, earn
  (accrual, idempotent over HTTP, wrong-state 422, program-off 422), redeem
  (debit, points validation, insufficient 422, completed-booking 422),
  client can't set balance/delta, no leaked internals.
- `Feature/Loyalty/LoyaltyRuleApiTest` — Group Owner read/configure,
  rate validation, clear-to-null, non-owner 403, 401.
- `Feature/Loyalty/LoyaltyAuthorizationTest` — role matrix over the
  endpoints, Reception view-but-not-manage, client `hotel_id` cannot widen
  scope.

**Full backend suite:** `1469 passed` (6384 assertions), **0 failed, 0
skipped**.

**Laravel Pint** `--test`: **passed** (clean, whole repo).

**Migrations:** `migrate:fresh`, `migrate:rollback --step=3` + re-migrate,
`migrate:fresh --seed` — all succeed on MariaDB 10.4.28.

---

## 14. Files

**New (`App\Domain\Loyalty\`, 16):** `Models/{LoyaltyAccount,LoyaltyTransaction,LoyaltyRule}`,
`Exceptions/{LoyaltyNotAllowedException,InvalidLoyaltyPointsException}`,
`Repositories/Contracts/*` (3) + `Eloquent*` (3),
`Services/{LoyaltyService,LoyaltyRuleService}`,
`Policies/{LoyaltyPolicy,LoyaltyRulePolicy}`.

**New HTTP (8):** `Controllers/Api/V1/{LoyaltyController,LoyaltyRuleController}`,
`Requests/Api/V1/Loyalty/{RedeemLoyaltyRequest,UpdateLoyaltyRuleRequest}`,
`Resources/V1/{LoyaltyAccountResource,LoyaltyTransactionResource,LoyaltyRuleResource}`.

**New migrations (3), factories (3):** `Loyalty{Account,Transaction,Rule}Factory`.

**New tests (9):** `tests/Unit/Loyalty/*` (6), `tests/Feature/Loyalty/*` (3).

**Modified (7):** `routes/api.php` (6 routes), `app/Providers/AppServiceProvider.php`
(3 repo bindings + 2 policies), `bootstrap/app.php` (2 renderable → 422),
`database/seeders/RolePermissionSeeder.php` (3 permissions), `lang/en/api.php`
(`loyalty.*`), `.env.example` (Phase 10 note), `app/Domain/Reservation/Models/Guest.php`
(`loyaltyAccount()` relation).

**Doc:** `md/phase-10-loyalty-implementation.md`.

---

## 15. Known limitations

- `points_balance` sign is `BIGINT` (signed) but the MVP has no path that
  makes it negative (`reverse`/`adjust`/`expire` are reserved enum values
  with no endpoint).
- The earn base is `reservation.price_snapshot` (the room rate), not the
  full invoice subtotal (accommodation + services). Using the invoice would
  couple Loyalty → Checkout; the room rate is the conventional loyalty base
  and keeps the domains isolated. **[C]** if the business wants service spend
  to earn points.
- Redemption records the ledger movement + a notional value; the monetary
  discount is deferred (§13 "no folio/service redemption").
- No auto-earn at checkout (see §6 **[C]**).

---

## 16. Deferred business clarifications

- **[C]** The exact earn **trigger** (manual endpoint vs. auto at checkout).
- **[C]** The earn **base amount** (room rate vs. total spend).
- **[C]** What makes a booking "eligible" for **redemption** (implemented as
  non-terminal, non-cancelled).
- **[F]** How a redeemed **notional value** applies to a booking's cost.
- **[C]** Earn rate / conversion rate **values** (§20 item 6 — genuinely
  unresolved; nothing seeded).
- **[F]** `reverse` / `adjust` staff-correction endpoints; account closure;
  `expire` (all reserved enum values, no MVP behaviour).

---

## 17. Scope confirmation

Not implemented (correctly out of scope per §13): loyalty tiers, point
expiration (R51), multi-rule stacking, folio/service redemption (R59),
redemption-value application to pricing, a loyalty guest-app auth surface,
reverse/adjust/expire operations, mobile/dashboard/frontend.

**Verdict: READY FOR REVIEW.** No commit, no push.
