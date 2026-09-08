# Phase 9 — Checkout + Final Settlement + Invoice — Implementation Report

**Status:** READY FOR REVIEW (review round 2) · not committed, not pushed
**Base commit:** `79fc343` (working tree)
**Date:** 2026-09-07

---

## 0. Review-round-2 fixes (2 blockers)

### Blocker 1 — accommodation in the final folio/invoice

- New `folio_charges.source_type` value **`accommodation`** (migration
  `2026_09_07_150004`, raw `ALTER … MODIFY ENUM` — MariaDB 10.4-safe). The
  Phase 8 migration already anticipated this ("the checkout phase will add
  its own source(s) via a follow-up migration").
- New `App\Domain\StayServices\Services\FolioChargeService::postAccommodationCharge()`
  — follows the Phase 8 folio-charge pattern (`ServiceOrderService` posts
  service-order charges the same way): idempotent, audited, decimal-safe.
- `CheckoutService` STEP A posts it once per reservation:
  `source_type = accommodation`, **`source_id = reservation.id`**,
  `unit_amount = total_amount = reservation.price_snapshot` used **exactly**
  (quantity 1 — no nights maths, no tax, no second pricing calculation).
- It is now part of `charges_total`, the invoice `subtotal`,
  `outstanding_total`, and appears as an invoice item. The existing
  `folio_charges (source_type, source_id)` UNIQUE + a `findBySourceForUpdate`
  pre-check + a `UniqueConstraintViolationException` catch make it
  **impossible to duplicate on a checkout retry**.
- A null / zero `price_snapshot` posts nothing (there is no accommodation
  amount to bill — exactly like a folio with no service orders has no
  service lines); a real reservation always has `price_snapshot > 0`.

### Blocker 2 — payment accounting (no history destruction)

- New nullable **`payment_transactions.amount`** DECIMAL(12,2) (migration
  `2026_09_07_150003`). Each money-moving provider operation records its
  amount on its append-only transaction row.
- **`payments.amount` is NO LONGER overwritten.** It keeps its Phase 5
  meaning — the deposit requested at booking.
- The final-settlement transaction records `amount` = the **server-calculated
  outstanding** actually being collected (e.g. `950`, not the folio total
  `1150`, not the client's value).
- `FolioService::payments_total` is now
  `SUM(payment_transactions.amount)` over the payment's **SUCCEEDED**
  `capture` + `settlement` transactions (`PaymentTransaction::COLLECTED_TYPES`).
  A prior capture (`200`) and this settlement (`950`) are counted as two
  separate rows → `payments_total = 1150`, `outstanding_total = 0`.
- `PaymentSettlementService::settle()` / `applySettlementResult()` lost their
  `collectedTotal` parameter.

Both fixes have explicit tests — `tests/Unit/Checkout/CheckoutAccountingTest`
(Scenarios A–E). Phase 8's `FolioServiceTest` / `FolioApiTest` were updated to
the transaction-based `payments_total` semantics (the review authorised
correcting the accounting, not patching around it).

Full suite after the fixes: **1383 passed**, 0 failed. Pint clean. Migrations
+ rollback + `--seed` verified on MariaDB 10.4.28.

---

## 1. Objective

Complete backend checkout: validate eligibility, drive
`IN_STAY → CHECKOUT_IN_PROGRESS`, calculate the final folio, collect the
outstanding amount through the existing payment gateway when one is owed,
finalize `CHECKOUT_IN_PROGRESS → CHECKED_OUT → INVOICED`, and issue a final
invoice — idempotently and retry-safely. **A reservation never becomes
`CHECKED_OUT` / `INVOICED` while a required final settlement has failed or is
pending.**

---

## 2. Source of truth

- Phase 0 baseline: §8 (Reservation SM), §9 (Payment SM), §12 (Checkout SM),
  §6.4 (`invoices`), §16 (API map), §17 (security), R20/R26–R31.
- Existing Phases 4 (`ReservationStateMachine` / `ReservationService`),
  5 (`Payment` / `PaymentStateMachine` / `PaymentGatewayInterface` /
  `DummyPaymentGateway`), 8 (`FolioService` / `folio_charges` /
  `Payment::CAPTURED_STATUSES`).
- The staged provider pattern (Phase 5C/7): **the external provider is never
  called inside an open DB transaction.**

Classification: **[A]** approved · **[T]** technical decision · **[F]** future ·
**[C]** clarification required.

---

## 3. Domain model — `App\Domain\Checkout\`

| Entity | Table | Role |
|---|---|---|
| `Checkout` | `checkouts` | The checkout process record. 1:1 with reservation. Holds the lifecycle status, the folio snapshot, a link to the settlement transaction, and the checkout timestamps. **[T]** — the baseline names no such table; it is the natural home for checkout state + retry safety + the folio snapshot. |
| `Invoice` | `invoices` | The final invoice. 1:1 with reservation. **[A]** (§6.4). |
| `InvoiceItem` | `invoice_items` | A frozen line snapshotted from a posted folio charge at checkout time. **[A]** (§6.4 "invoice_lines"). |

No existing invoice/checkout/billing code was found — all three tables are new.

### Repositories
`CheckoutRepositoryInterface` + `InvoiceRepositoryInterface` (+ `Eloquent*`),
bound in `AppServiceProvider::$bindings`.

### Services
- `CheckoutService` — the orchestrator (9A/9C/9D/9F).
- `InvoiceService` — invoice generation/finalization (9E).
- `PaymentSettlementService` — the final-settlement payment workflow (9C), a
  sibling of `PaymentWorkflowService` in the **Payment** domain (reuses its
  repos, `PaymentGatewayInterface`, `PaymentStateMachine`).
- `CheckoutResult` / `Folio` DTOs.

Controller → Form Request → Policy → Service → Repository → Model throughout
(architecture-tested: no `DB::`, no `::query(`, no state machine, no model
access in controllers; services never touch the query builder / model
statics; the gateway is reached only from `PaymentSettlementService`).

---

## 4. Database schema

MariaDB 10.4.28 verified (`migrate:fresh`, `migrate:rollback --step=3` +
re-migrate, `migrate:fresh --seed`). `enum` + plain indexes only, `DECIMAL(12,2)`
money, ≤64-char identifiers, no MySQL-8 features.

### `checkouts`
`id`; `reservation_id` **UNIQUE** FK restrict; `hotel_id` FK restrict;
`status` enum(`in_progress`,`awaiting_settlement`,`settlement_failed`,`completed`)
default `in_progress`; `charges_total` / `payments_total` / `outstanding_total`
DECIMAL(12,2) default 0; `currency` CHAR(3) null; `settlement_transaction_id`
FK→payment_transactions **nullOnDelete** null; `started_at` / `completed_at`
timestamps null; `created_by_user_id` FK→users nullOnDelete null; timestamps.
Index: `(hotel_id, status)`.

### `invoices`
`id`; `reservation_id` **UNIQUE** FK restrict; `hotel_id` FK restrict;
`invoice_number` string **UNIQUE** nullable; `status` enum(`draft`,`issued`)
default `draft`; `currency` CHAR(3) null; `subtotal` / `payments_total` /
`outstanding_total` DECIMAL(12,2) default 0; `issued_at` timestamp null;
`created_by_user_id` FK→users nullOnDelete null; timestamps.
Index: `(hotel_id, status)`.

### `invoice_items`
`id`; `invoice_id` FK restrict; `source_type` enum(`folio_charge`);
`source_id` unsignedBigInteger null; `description` string(500); `quantity`
unsignedInteger; `unit_amount` / `total_amount` DECIMAL(12,2); timestamps.
**UNIQUE `(invoice_id, source_type, source_id)`** — the idempotency guard for
item snapshotting.

**Invoice number** (**[T]** — no legal format is defined by the business):
`INV-<zero-padded row id>` (e.g. `INV-000123`). Set immediately after insert
from the autoincrement id, so it is deterministic and DB-unique under
concurrency. `invoice_number` column is `UNIQUE`.

---

## 5. State-machine changes

**None to `ReservationStateMachine` or `PaymentStateMachine`.** Phase 9 only
*drives* the existing approved transitions:

- Reservation: `IN_STAY → CHECKOUT_IN_PROGRESS → CHECKED_OUT → INVOICED`,
  each hop via `ReservationService::transitionTo()`.
- Payment (when a settlement is owed): `{HOLD_ACTIVE → CAPTURE_REQUESTED →
  CAPTURED →} FINAL_SETTLEMENT_REQUESTED → {SETTLED | SETTLEMENT_FAILED}`,
  each hop guarded by `PaymentStateMachine::assertCanTransition()`.

**New:** `CheckoutStateMachine` (mirrors the other state machines) —
`in_progress`/`awaiting_settlement`/`settlement_failed` form a retry cluster;
`completed` is terminal.

---

## 6. Payment integration

`PaymentSettlementService::settle(reservation, settlementAmount, currency, idempotencyKey?, directive?, actor?)`:

- **STEP A** (DB txn): lock Reservation → Payment. Guard the payment is in a
  settleable state (`HOLD_ACTIVE` / `CAPTURED` / `FINAL_SETTLEMENT_REQUESTED`
  / `SETTLEMENT_FAILED`) — else `PaymentSettlementNotAllowedException` (422).
  Advance the payment to `FINAL_SETTLEMENT_REQUESTED` through the state
  machine. Create ONE `settlement` `PaymentTransaction` (`pending`, keyed by
  the idempotency key, **`amount = settlementAmount`** = the server-calculated
  outstanding). Audit `payment.final_settlement_requested`. COMMIT.
- **STEP B** (no txn): `PaymentGatewayInterface::settle(...)` — the existing
  gateway method; `DummyPaymentGateway` already implements it. For a pending
  retry it calls `verify(...)` instead (the recovery path — see §12).
- **STEP C** (DB txn): re-lock Reservation → Payment → transaction, apply the
  result idempotently:
  - `Succeeded` → settlement transaction `succeeded` (its `amount` now counts
    toward `payments_total`), Payment `→ SETTLED`. **`payments.amount` is NOT
    touched** — it keeps its Phase 5 meaning (the deposit requested at
    booking). Audit `payment.settled`.
  - `Failed` → transaction `failed`, Payment `→ SETTLEMENT_FAILED`. Audit
    `payment.settlement_failed`.
  - `Pending` → transaction stays `pending`, Payment stays
    `FINAL_SETTLEMENT_REQUESTED`. Audit `payment.settlement_pending`.
  - `Cancelled` / `Expired` → transaction records the exact outcome, Payment
    `→ SETTLEMENT_FAILED` (the machine has no cancelled/expired edge from
    `FINAL_SETTLEMENT_REQUESTED`). Audit `payment.settlement_failed`.

**[T] — single settle call + state-machine walk.** The whole outstanding
balance is collected with ONE provider `settle()` operation. When the deposit
hold was never captured (**capture-at-check-in is an approved baseline step
that Phase 7 did not implement** — see §12/§C1), the Payment is walked
`HOLD_ACTIVE → CAPTURE_REQUESTED → CAPTURED → FINAL_SETTLEMENT_REQUESTED`
inside STEP A — every hop guarded, **no fabricated enum value**, no second
provider call. A production gateway adapter would issue the provider capture
during that leg; the dummy models the collection as a single settle.

**Settlement amount is 100% server-derived** — the checkout request carries
no `amount` and the Form Request has no `amount` field or accessor
(architecture-tested). `settlementAmount` = `folio.outstanding_total` =
`charges_total − payments_total` (payments_total = the already-collected
capture/settlement transaction amounts).

---

## 7. Folio integration

Reuses **`FolioService::folioFor()`** — no folio logic is duplicated in
checkout. `charges_total` = posted folio charges only (now including the
accommodation charge). `payments_total` = **`SUM(payment_transactions.amount)`
over the payment's SUCCEEDED `capture` + `settlement` rows** (Phase 9 review
fix — the payment history, not `payments.amount`). `outstanding_total` =
`charges − payments`. A `hold` / pending / failed attempt collects nothing
and counts as `0.00`.

- **`outstanding > 0`** → a final settlement is required.
- **`outstanding == 0`** → finalize directly, no provider call.
- **`outstanding < 0`** (a captured deposit exceeds charges) → finalize, no
  provider call, **no fabricated charge, no invented refund**. The negative
  amount is preserved on `invoice.outstanding_total` and
  `checkout.outstanding_total` for reconciliation. Automatic refund is
  deferred (**[F]** — see §12).

---

## 8. Checkout orchestration

`CheckoutService::checkout(reservation, idempotencyKey?, directive?, actor?): CheckoutResult`

- **STEP A** (DB txn): lock Reservation. If already `INVOICED` → idempotent
  replay. If not `IN_STAY` / `CHECKOUT_IN_PROGRESS` / `CHECKED_OUT` →
  `CheckoutNotAllowedException` (422). If `IN_STAY` →
  `transitionTo(CHECKOUT_IN_PROGRESS)`. Create / reopen the `Checkout`
  record. Compute the folio, snapshot it, decide `needsSettlement`. If a
  settlement is needed but no currency resolves →
  `CheckoutCurrencyMissingException` (422, whole STEP A rolls back — the
  reservation stays `IN_STAY`). COMMIT. Audit `checkout.started`.
- **STEP B** (no txn): `PaymentSettlementService::settle(...)` when
  `needsSettlement`.
- **STEP C** (DB txn): re-lock Reservation → Payment → Checkout, re-read the
  folio.
  - Settlement owed & payment `FINAL_SETTLEMENT_REQUESTED` → checkout
    `awaiting_settlement`, audit `checkout.settlement_pending`, **stop**
    (reservation stays `CHECKOUT_IN_PROGRESS`).
  - Settlement owed & payment `SETTLEMENT_FAILED` (or unexpected) → checkout
    `settlement_failed`, audit `checkout.settlement_failed` (`blocked_by:
    final_settlement`), **stop**.
  - Otherwise (no settlement owed, or it SETTLED) → **finalize**:
    `InvoiceService::finalizeFor()`, `transitionTo(CHECKED_OUT)`,
    `transitionTo(INVOICED)`, checkout `completed`, audit
    `checkout.completed`.

**Lock order everywhere:** `Reservation → Payment → Checkout / settlement
transaction`. `ReservationService::transitionTo()` and
`PaymentSettlementService` open their own nested transactions (savepoints)
and re-lock/re-read — the Phase 4 stale-model rule is honoured (every
critical decision is made on a freshly locked read).

---

## 9. Invoice generation

`InvoiceService::finalizeFor(reservation, totals, currency, actor)` — runs
**inside** CheckoutService's finalize transaction (opens none of its own,
calls no provider):

- `findByReservationForUpdate` → reuse an existing invoice; an already-`issued`
  one is returned untouched (idempotent). Otherwise create a `draft` (catches
  `UniqueConstraintViolationException` on the concurrent race).
- Snapshot every **posted** folio charge as an `invoice_item` (idempotent via
  the `(invoice_id, source_type, source_id)` UNIQUE + a pre-check).
- **Assert** `Σ items.total_amount == charges_total` (bcmath) — else
  `InvoiceGenerationException`.
- Set `invoice_number` (from the row id), totals (from the passed folio
  snapshot — never the client), `status = issued`, `issued_at = now`. Audit
  `invoice.created` (first time) + `invoice.issued`.

One invoice per reservation (`UNIQUE reservation_id`); a repeated checkout
never creates a second invoice or duplicate items.

**Accommodation IS in the invoice** (review round 2). `CheckoutService` STEP
A posts a `folio_charges` row (`source_type = accommodation`,
`source_id = reservation.id`, amount = `reservation.price_snapshot` used
exactly) which `syncItems()` then snapshots as an invoice item alongside the
service-order items. The `(source_type, source_id)` UNIQUE + a pre-check
prevent any duplication on retry.

---

## 10. API endpoints

| Method | Path | Auth | Permission | Purpose |
|---|---|---|---|---|
| POST | `/api/v1/reservations/{reservation}/checkout` | sanctum | `checkout.perform` | Perform / retry / idempotently replay checkout. `Idempotency-Key` header; `throttle:checkout.perform`. |
| GET | `/api/v1/reservations/{reservation}/invoice` | sanctum | `invoice.view` | Read the issued invoice with line items. |

`{reservation}` is an int id resolved via `ReservationService::findAccessibleBy()`
(not route-model binding) — a cross-hotel or missing id is an identical plain
**404**. Standard `{ success, message, data }` envelope.

**HTTP mapping** (`CheckoutController`):
- completed / idempotent-completed → **200** with `CheckoutResource`
  (reservation ref + status, checkout status + timestamps, totals, currency,
  payment status/amount, invoice id/number/status).
- pending settlement → **422** `errors.checkout_status = awaiting_settlement`.
- failed settlement → **422** `errors.checkout_status = settlement_failed`.
- wrong reservation state / currency missing / settlement not allowed →
  **422** (fixed safe message).
- unauthenticated **401**, unauthorized **403**, cross-hotel/missing **404**,
  rate limited **429**.

**Why a separate invoice endpoint** (**[T]**): the invoice is retrieved long
after checkout (guest re-opening the e-invoice, staff review) and carries the
full line-item detail the checkout summary omits.

`CheckoutResource` / `InvoiceResource` expose totals and status only — never
a provider reference, raw gateway payload, card data, credential, or
`created_by_user_id` (security-tested).

---

## 11. Permissions & rate limiting

New permissions (RolePermissionSeeder): `checkout.perform`, `invoice.view` →
Group Owner (all), Hotel Manager, **Reception**. Checkout is the guest-facing
one-tap checkout (R14–R19) with Reception as the operational fallback (R7) —
the same reasoning Phases 7/8 used for check-in / service orders; every
checkout is audited. Guest: none (no guest auth in the MVP — **[F]**).

Rate limit: `config/checkout.php` → `checkout.perform` limiter, 12/min
(**[T]** — no project convention; conservative, headroom for a retry),
env-overridable `CHECKOUT_PERFORM_RATE_LIMIT`, keyed by user id (IP
fallback), mirroring `payments.hold`.

Policies: `CheckoutPolicy` / `InvoicePolicy` (both act on the resolved
`Reservation`; hotel scope from the user's own stored access via
`HotelAccessService` — never a client `hotel_id`; Group Owner bypass).
Cross-hotel is denied even with the permission (tested).

---

## 12. Audit actions

Via the central `AuditLogger`, safe flat snapshots only (status, ids,
DECIMAL totals, timestamps, invoice number):
`checkout.started`, `checkout.settlement_pending`, `checkout.settlement_failed`
(`blocked_by: final_settlement`), `checkout.completed`,
`payment.final_settlement_requested`, `payment.settled`,
`payment.settlement_pending`, `payment.settlement_failed`,
`invoice.created`, `invoice.issued`. **Never** logged: card data, raw
gateway payloads, provider secrets, credentials, stack traces, SQLSTATE
(security-tested).

---

## 13. Idempotency & concurrency

- **One checkout per reservation** (`UNIQUE reservation_id`); **one invoice
  per reservation** (`UNIQUE reservation_id`); **one item per source**
  (`UNIQUE (invoice_id, source_type, source_id)`); the settlement
  `PaymentTransaction.idempotency_key` is `UNIQUE`.
- The `Idempotency-Key` header flows to the settlement transaction. Same key
  after success → replay (no second provider call). Same key on a still-
  pending attempt → a provider `verify()` re-check (no blind second
  `settle()`). Same key on a failed attempt → returns the failed result;
  retry with a fresh key. No header → a fresh UUID each call (the payment-
  state + checkout-status guards still prevent a double settlement).
- **Completed replay**: any checkout request for an `INVOICED` reservation
  returns the existing result — no settlement, no new invoice.
- **Retry after failure/pending**: reopens the checkout to `in_progress`
  (`SETTLEMENT_FAILED → FINAL_SETTLEMENT_REQUESTED` is an approved payment
  transition) and re-drives — no second Payment record, no second invoice.
- **Concurrency**: the `Reservation` `findForUpdate` lock in STEP A and STEP
  C serializes concurrent checkouts. A second concurrent settlement attempt
  finds the pending transaction and re-checks it rather than starting a new
  one. Exactly one successful settlement and one invoice result (tested:
  repeated checkout, same-key replay).

---

## 14. Failure safety matrix (all tested)

| Case | Result |
|---|---|
| No outstanding | no provider call · reservation `CHECKED_OUT`→`INVOICED` · invoice `ISSUED` · payment untouched |
| Outstanding > 0, provider **success** | payment `SETTLED` (amount = folio total) · reservation `INVOICED` · invoice `ISSUED` |
| Outstanding > 0, provider **failure** | transaction `failed` · payment `SETTLEMENT_FAILED` · **reservation stays `CHECKOUT_IN_PROGRESS`** · no invoice · 422 · retryable |
| Outstanding > 0, provider **pending** | transaction `pending` · payment `FINAL_SETTLEMENT_REQUESTED` · **reservation stays `CHECKOUT_IN_PROGRESS`** · no invoice · 422 |
| Provider **cancelled** / **expired** | transaction records it · payment `SETTLEMENT_FAILED` · **no `CHECKED_OUT` / `INVOICED`** · 422 |
| Repeated successful checkout | same invoice_number · 1 invoice · 1 succeeded settlement · no double charge |
| Concurrent checkout | one authoritative settlement + invoice · serialized on the reservation lock |

---

## 15. Digital access & room status

- **Digital access (Phase 7):** the approved baseline does not say access
  MUST be revoked at checkout. Checkout does **not** touch digital access —
  left unchanged, documented as a deferred integration point. (§11's
  application-driven lazy expiry already expires the credential at the stay
  end.)
- **Room status (Phase 2):** the approved model defines no `booked →
  available` transition at checkout. Checkout does **not** manipulate room
  status. Deferred / documented.

---

## 16. Tests

MariaDB 10.4.28, `RefreshDatabase`, `RolePermissionSeeder`.

**Phase 9 focused — 97 passed** (`tests/Unit/Checkout` 69 + `tests/Feature/Checkout` 28):

- `CheckoutStateMachineTest` — allowed/forbidden matrix, terminal, map == vocabulary.
- `CheckoutServiceTest` — the full failure matrix (§14), eligibility from
  every non-`IN_STAY` status, already-invoiced replay, resume from
  `CHECKOUT_IN_PROGRESS`, retry after failure, retry after pending, negative
  outstanding (no fabricated charge / no refund), currency-missing safe
  failure, idempotent-key single-transaction.
- `PaymentSettlementServiceTest` — `HOLD_ACTIVE→…→SETTLED` walk, no-payment
  error, failed / pending outcomes, same-key replay with no 2nd provider
  call, hold-key conflict, **provider never called inside a DB transaction**
  (transaction-level guard).
- `InvoiceServiceTest` — issued only after a completed checkout, items
  snapshot posted charges only (cancelled excluded), unique invoice + unique
  number, no duplicate items on retry, empty-but-issued zero-charge invoice.
- `CheckoutSchemaTest` — tables, unique constraints, DECIMAL round-trip,
  restrict deletes.
- `CheckoutPolicyTest` — 4-role matrix, cross-hotel denied with permission,
  Group Owner bypass.
- `CheckoutArchitectureTest` — thin controllers, services never touch the
  query builder/models, provider only from the settlement service,
  reservation transitions only via `ReservationService`, state-machine-guarded
  transitions, no float money maths, client amount never read, Reservation /
  Payment / Folio domains have no `Checkout` dependency.
- `CheckoutApiTest` — auth (401/404/403), happy paths, failure matrix over
  HTTP (422 + `errors.checkout_status`), idempotent retry, malformed key,
  wrong state, client `amount`/`status`/`hotel_id` ignored, no leaked
  provider/internal detail, **rate limit (429)**.
- `InvoiceApiTest` — shape, 404 before checkout, no payment secret, cross-hotel 404.
- `CheckoutAuthorizationTest` — checkout + invoice role matrices, client
  `hotel_id` cannot widen scope.

**Review round 2** adds `tests/Unit/Checkout/CheckoutAccountingTest`
(Scenarios A–E: accommodation + previously-captured + settlement + credit
balance + idempotent retry + failed retry) and updates Phase 8's
`FolioServiceTest` / `FolioApiTest` to the transaction-based `payments_total`.

**Full backend suite:** `1383 passed` (6144 assertions), **0 failed, 0
skipped**.

**Laravel Pint** `--test`: **passed** (clean, whole repo).

**Migrations:** `migrate:fresh`, `migrate:rollback --step=5` + re-migrate,
`migrate:fresh --seed` — all succeed on **MariaDB 10.4.28** (including the
`folio_charges` enum `ALTER … MODIFY` up/down).

---

## 17. Known limitations

- **[T]** Accommodation is billed as `reservation.price_snapshot` **used
  exactly** (quantity 1). Whether the business ever wants nights × rate, a
  cancellation/no-show adjustment, or a different accommodation amount is a
  future pricing decision — Phase 9 invents none of it.
- **[T]** In the running system nothing performs capture-at-check-in yet
  (Phase 7 gap), so `payments_total` before checkout is `0.00` and the
  single final settlement collects the whole folio. Once a real
  capture-at-check-in phase lands it records a succeeded `capture`
  transaction and the settlement then collects only the remaining
  outstanding — the accounting already handles both (Scenario A vs. the
  default path).
- **[T]** A provider `pending` settlement is resolved by a **retry** (which
  issues a provider `verify()`), not by a webhook — Phase 5E's webhook path
  only handles `hold` transactions. A settlement webhook / scheduled
  reconciliation is deferred.
- A process kill between STEP A/B/C leaves a persisted `pending` settlement
  transaction and the reservation in `CHECKOUT_IN_PROGRESS` — recoverable by
  a checkout retry (idempotent), consistent with the accepted Phase 5C/7
  pattern.
- Concurrent Phase 8 `service_order` confirm/cancel during checkout STEP
  A→C can shift the folio; STEP C recomputes under the reservation lock and
  the invoice reflects that, but the provider call used STEP A's amount.
  Service orders still in `requested` at checkout are not billed.

---

## 18. Technical decisions

1. New `checkouts` table (the baseline names none) — home for checkout
   state, the folio snapshot, retry safety, the settlement pointer.
2. `CheckoutStateMachine` — mirrors the other state machines.
3. Single provider `settle()` call + guarded state-machine walk from
   `HOLD_ACTIVE` (see §6).
4. **(Review round 2)** `payments.amount` is never overwritten; the
   folio's `payments_total` is derived from the `payment_transactions.amount`
   history (succeeded `capture` + `settlement`). The settlement transaction
   records the outstanding it actually collects.
5. **(Review round 2)** Accommodation is a real `folio_charges` row
   (`source_type = accommodation`, `source_id = reservation.id`) posted at
   checkout STEP A — amount `= reservation.price_snapshot` used exactly.
7. Invoice number `INV-<row id>` — no legal format is defined.
8. Separate `GET .../invoice` endpoint (see §10).
9. `invoice_items` = a frozen snapshot of posted folio charges.
10. Checkout rate limit 12/min.
11. `cancelled` / `expired` provider settlement outcomes map the Payment to
    `SETTLEMENT_FAILED` (the state machine's only non-success edge from
    `FINAL_SETTLEMENT_REQUESTED`); the transaction records the exact outcome.
12. Pending-settlement recovery via a provider `verify()` on retry.

---

## 19. Deferred business clarifications

- **[C]** Whether the accommodation amount should ever be anything other
  than `reservation.price_snapshot` used exactly (nights × rate, no-show /
  cancellation adjustments) — Phase 9 bills the snapshot verbatim.
- **[C]** Refund of a credit balance (negative outstanding).
- **[C]** Whether digital access must be revoked at checkout.
- **[C]** Whether a room returns to `available` at checkout.
- **[C]** Whether unconfirmed (`requested`) service orders should block
  checkout or be auto-resolved.
- **[C]** A legal/sequential invoice-number format, per-hotel or group-wide.
- **[C]** Settlement currency (unresolved platform-wide — §20 item 7); a
  settlement with no resolvable currency fails safely.
- The `CHECKOUT_BLOCKED` reservation status stays terminal/open as Phase 4
  defined it — Phase 9 does not route into it (a failed settlement stays in
  `CHECKOUT_IN_PROGRESS`, which is retryable; `CHECKOUT_BLOCKED` has no
  approved trigger).

---

## 20. Scope confirmation

Not implemented (correctly out of scope): tax/VAT engine, discounts,
promotions, loyalty redemption, refunds/partial refunds, damage/minibar/
late-checkout charges, dynamic pricing, accounting integration, real payment
provider, PDF/email invoice delivery, invoice void/cancel states, room
release, digital-access revocation at checkout, mobile/dashboard/frontend.

**Mobile / dashboard / frontend: untouched by Phase 9.** The working tree
contains unrelated in-progress `mobile/` changes (a Flutter "discovery"
workstream — Mobile Phase 3) that predate this task and were **not** created
or modified here.

**Verdict: READY FOR REVIEW.** No commit, no push.
