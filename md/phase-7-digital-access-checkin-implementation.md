# Phase 7 — Digital Access + Check-in — Implementation Report

**Status:** READY FOR REVIEW · not committed, not pushed
**Base commit:** `ec81b4c` (Phase 6 — identity verification)
**Date:** 2026-09-07

---

## 1. Objective

Implement Digital Access + Check-in on the approved Phase 0 baseline and the
existing Phases 1–6, dummy provider only, no invented business values.

Intended flow: `DEPOSIT_HELD → (identity) → VERIFIED → check-in → CHECKED_IN`
where check-in issues the digital access credential and, per §8's
"(access issued)" label on the `VERIFIED → CHECKED_IN` edge, a successful
issuance is what advances the reservation.

---

## 2. Source of truth

- `md/hotel_platform_phase0_approved_baseline.md` — §11 (Digital Access State
  Machine), §8 (Reservation SM, "CHECKED_IN requires both payment-confirmed
  and VERIFIED"), §15 (dummy integration), §16 (API map), §17 (security),
  §6.1/§6.4 (`access_grants`), R14–R19, R38–R42.
- The existing Payment (Phase 5) and Identity Verification (Phase 6) staged
  provider architecture is followed exactly.
- `md/mobile/` is present as an untracked directory. It was **not created,
  modified, staged, or committed** by Phase 7.

---

## 3. Interpretation of the two ambiguous points (documented, not invented)

| # | Ambiguity | Decision | Basis |
|---|---|---|---|
| A | Does issuance happen before or after `CHECKED_IN`? | The check-in workflow issues the credential; a **successful (ACTIVE)** result is the trigger for `VERIFIED → CHECKED_IN`. A provider failure leaves the reservation VERIFIED. | §8 labels the `VERIFIED → CHECKED_IN` edge "(access issued)". |
| B | Trigger for `CHECKED_IN → IN_STAY`? | **Not implemented in Phase 7.** §8 gives that edge no label. The user prompt's flow diagram implies "digital access → IN_STAY" but the baseline does not define it. | §8 has no labelled trigger — OPEN item, not invented. |

---

## 4. 7A — Digital Access domain + database

Single table **`access_grants`** — the exact name from §6.4 (Digital Access is
a single-table domain, unlike Payments/Identity which §6.4 splits). 1:1 with
`reservation` (unique FK). `hotel_id` / `guest_id` denormalized from the
reservation, never client-supplied.

`App\Domain\DigitalAccess\` package:
- `Models/AccessGrant` — status/mode constants, `credential` `encrypted` cast
  + `$hidden`, `metadata` array cast, timestamp casts, relations.
- `StateMachine/DigitalAccessStateMachine` — stateless, the sole transition
  authority (see §7).
- `Repositories/Contracts/AccessGrantRepositoryInterface` +
  `EloquentAccessGrantRepository` — all DB access; `findForUpdate` /
  `findByReservationForUpdate` for the staged locks.
- `Exceptions/` — `InvalidDigitalAccessStatusTransitionException`,
  `CheckInNotAllowedException`, `CheckInEligibilityException`,
  `DigitalAccessActionNotAllowedException`,
  `DigitalAccessIdempotencyKeyConflictException`.
- `Policies/AccessGrantPolicy`.
- `config/digital_access.php`, `database/factories/AccessGrantFactory`.

### Schema (`2026_09_07_130000_create_access_grants_table.php`)

`id`; `reservation_id` UNIQUE FK restrict; `hotel_id` FK restrict; `guest_id`
FK restrict; `status` enum(7) default `not_issued`; `access_mode`
enum(`pin_code`,`smart_lock`) default `pin_code`; `provider`;
`provider_reference` nullable; `credential` TEXT nullable (ciphertext);
`idempotency_key` UNIQUE; `issued_at`/`activated_at`/`expires_at`/`revoked_at`
timestamps nullable; `revocation_reason` / `failure_reason` string(500)
nullable; `metadata` json nullable; timestamps.

Indexes: `unique(reservation_id)`, `unique(provider,provider_reference)`
(`access_grants_provider_ref_unique`), `unique(idempotency_key)`,
`index(status)`, `index(hotel_id,status)`. FK columns are not re-indexed
(MariaDB auto-indexes them — matches the Phase 6 review outcome).

MariaDB 10.4: enum + plain indexes only; identifier names ≤ 64 chars;
`migrate:fresh` / `migrate:rollback` / re-migrate all verified.

---

## 5. Digital Access state machine

Business lifecycle (§11): `NOT_ISSUED → ISSUED(=ACTIVE) → {EXPIRED | REVOKED}`.

Full map (the three extra nodes are **architecture-derived pending/failure
states, not new business states** — they mirror Payment `HOLD_REQUESTED` /
`HOLD_FAILED`):

```
NOT_ISSUED       -> ISSUE_REQUESTED
ISSUE_REQUESTED  -> ACTIVE | FAILED
FAILED           -> ISSUE_REQUESTED        (retry check-in)
ACTIVE           -> REVOKE_REQUESTED | EXPIRED
REVOKE_REQUESTED -> REVOKED
EXPIRED / REVOKED -> (terminal)
```

`assertCanTransition()` guards every persisted status change in the service;
the map is never duplicated. Exhaustively unit-tested (approved transitions,
a forbidden-transition matrix, terminal detection, map-matches-constants,
"can never reach ACTIVE without ISSUE_REQUESTED").

---

## 6. 7B — Digital Access provider

`DigitalAccessProviderInterface` — two methods only:
`issue(AccessIssueRequest): AccessResult`, `revoke(AccessOperationRequest): AccessResult`.
§11's other simulated lifecycle events map elsewhere: creation+activation =
`issue` success; revocation = `revoke` success; expiration is
application-driven (no provider call); validation-at-a-door is future (no
endpoint). No callback/webhook (§16 defines none).

`DummyDigitalAccessProvider` — deterministic: directive → outcome
(`success`→Active/Revoked, `failure`→Failed); `dummy_access_{op}_{sha}`
reference; a **deterministic 6-digit PIN** derived from the grant reference.
No randomness / clock / HTTP / DB / container / audit / authorization
(architecture-tested; scans the whole `Provider/` package, asserts zero DB
queries).

**Explicit dummy-only property:** the PIN is deterministic — a simulation
value, not a secure credential. A real provider MUST mint a
cryptographically-random code. Called out in the class docblock and here.

`AccessSensitiveDataGuard` rejects secret-looking metadata keys
(`pin_code`, `passcode`, `credential`, `secret`, `token`, `otp`, …) before an
`AccessResult`/request DTO is built. The credential travels ONLY in the
dedicated `AccessResult::$credential` field, never in `context`/metadata.

Binding: `AppServiceProvider::register()` `match(config('digital_access.provider'))`
→ `dummy` only; unknown provider throws
`UnsupportedDigitalAccessProviderException`, never falls back.

---

## 7. 7C — Check-in workflow

`DigitalAccessService::checkIn(Reservation, ?directive, ?idempotencyKey, ?actor): AccessGrant`

**Eligibility (`assertCheckInEligible`, §8 + §11 — in the domain layer, never
the provider):**
1. `reservation.status === VERIFIED` → else `CheckInNotAllowedException`.
2. `Payment` for the reservation exists and is `HOLD_ACTIVE` → else
   `CheckInEligibilityException::paymentNotConfirmed`.
3. Identity session exists and is in `IdentityVerificationSession::APPROVED_STATUSES`
   (`auto_approved` / `staff_approved`) → else `…::identityNotVerified`.
4. Time window: `now() < reservation.check_out` end-of-day → else
   `…::outsideStayWindow`.

**No number invented.** The time-window bound is the reservation's own
`check_out` date. Room assignment is **not** a check-in prerequisite (not in
§11 eligibility). See §16 for the OPEN items.

### Staged transaction architecture + lock order

Lock order everywhere: **Reservation → AccessGrant**. `expire()` and the
status read take only the AccessGrant lock (they never transition the
reservation) so they cannot form a cycle.

```
STEP A  (DB txn)   lock Reservation -> AccessGrant; validate eligibility;
                   create the grant (or reuse FAILED on retry); guard
                   NOT_ISSUED|FAILED -> ISSUE_REQUESTED; audit
                   digital_access.issue_requested; COMMIT.
STEP B  (no txn)   DigitalAccessProviderInterface::issue(...).
STEP C  (DB txn)   re-lock Reservation -> AccessGrant; re-read.
                   ACTIVE  -> grant ISSUE_REQUESTED -> ACTIVE (encrypted PIN,
                             activated_at, expires_at = check_out end-of-day);
                             ReservationService::transitionTo(VERIFIED ->
                             CHECKED_IN); audit digital_access.issued.
                   FAILED  -> grant -> FAILED (failure_reason=provider_declined);
                             reservation UNTOUCHED; audit digital_access.issue_failed.
                   COMMIT.
```

Concurrency: `reservation_id` UNIQUE guarantees one grant per reservation;
`findForUpdate` locks serialize concurrent check-ins; a concurrent
`ISSUE_REQUESTED` with a different key is rejected; once ACTIVE any further
check-in (any key) returns the existing grant; once `CHECKED_IN` the
eligibility gate (`status !== VERIFIED`) blocks a second check-in.

A provider failure never triggers a refund, a cancellation, or any other
payment/reservation side effect — the grant is `FAILED` and check-in can be
retried.

---

## 8. 7D — Issuance + revocation + expiry

**Issuance** — part of check-in (§7). Retry after `FAILED` re-requests
issuance; on success the reservation advances then.

**Revocation** — `DigitalAccessService::revoke(Reservation, ?reason, ?directive, ?actor)`,
staged the same way (`ACTIVE → REVOKE_REQUESTED` → provider `revoke()` outside
txn → `REVOKE_REQUESTED → REVOKED`). **Local revocation is authoritative** — a
provider `failure` still results in `REVOKED` with the credential nulled and
`digital_access.revoked` audited with `provider_revoke_failed` +
`requires_reconciliation`. Repeated revoke on an already-revoked / expired
grant is a safe no-op (returns the grant, one lifecycle audited). Revoke of a
`FAILED` / never-issued grant is a 422. Revoking does **not** roll the
reservation back — it stays `CHECKED_IN`.

**Expiry** — §11 "stay end reached, auto". `expires_at` is set at activation
to `reservation.check_out` end-of-day (no invented duration). Expiry is
**application-driven, lazy**: `currentStatusFor()` (the status endpoint)
transitions an `ACTIVE` grant past `expires_at` to `EXPIRED` (own txn, re-check
under lock, null the credential, audit `digital_access.expired`) — §11
"Access validity is re-checked server-side at every access attempt". Idempotent
across repeated reads. No scheduled job (deferred — see §16).

**Idempotency** — `access_grants.idempotency_key` UNIQUE for the issue
operation. Same key → replays the grant, no second provider call, no duplicate
grant. Key reused across reservations → `DigitalAccessIdempotencyKeyConflictException`
(422). `applyIssueResult` / `applyRevokeResult` are idempotent (a duplicate
result on a resolved grant is a no-op). Provider retries never create
duplicate domain effects (the `reservation_id` UNIQUE + the state guards).

---

## 9. 7E — API + RBAC + hotel scope

All under `auth:sanctum`; `{reservation}` resolved via
`ReservationService::findAccessibleBy()` (cross-hotel / missing → plain 404,
no existence leak). Client-supplied `hotel_id` / `guest_id` / role are
ignored — scope is derived from the reservation.

| Method | Path | Permission | Notes |
|---|---|---|---|
| POST | `/api/v1/check-in/{reservation}` | `check-in.perform` | `Idempotency-Key` header; `X-Digital-Access-Simulate` (local/testing only); `throttle:check-in`. 201 = ACTIVE + reservation CHECKED_IN (`data.credential` = PIN). 422 = wrong state / eligibility / provider failure (`errors.status=failed`). |
| GET | `/api/v1/access/{reservation}` | `digital-access.view` | Lazy-expires on read. `data.credential` present only while ACTIVE. Transient `not_issued` when no grant. |
| POST | `/api/v1/access/{reservation}/revoke` | `digital-access.revoke` | optional `reason`; `throttle:digital-access.revoke`. 200 = REVOKED (idempotent). |

**Permissions** (RolePermissionSeeder): `check-in.perform`,
`digital-access.view`, `digital-access.revoke` → Group Owner, Hotel Manager,
Reception. Guest role: none (guest auth does not exist in the MVP; §7 Guest =
"system-issued only"). Reception is included per §7 ("issue/revoke digital
access = manual-assist, logged" for Reception) and R7/R14–R19 (check-in is
guest-facing, Reception is the fallback path). Cross-hotel is denied by
`HotelAccessService` even with the permission; Group Owner is an explicit
policy-checked bypass.

`AccessGrantResource` — safe fields only. `credential` (PIN) is the one secret
field, returned ONLY while `status === active` (nulled server-side on
revoke/expire, so a revoked/expired grant never carries it). `provider_reference`,
`idempotency_key`, `metadata` are absent.

---

## 10. 7F — Hardening summary

- Provider reached only through `DigitalAccessProviderInterface`;
  `DummyDigitalAccessProvider` named only in `Provider/` + `AppServiceProvider`
  (feature-tested). Provider call proven outside any nested transaction
  (transaction-level guard test on both `issue` and `revoke`).
- Credential: `encrypted` at rest (ciphertext verified in the DB), `$hidden`
  on the model, in the resource only while ACTIVE, nulled on revoke/expiry,
  and **never** in an audit row or a log line (tests scan every audit row for
  the PIN and the idempotency key). `metadata` holds only
  `provider_code` + `provider_message`.
- Six domain exceptions → fixed safe 422 strings (no secret, credential,
  SQLSTATE, provider internals, stack trace).
- Rate limiting on check-in and revoke; status read is not mutation-limited.
- Simulation directive honoured only in `local`/`testing` (tested against a
  forced `production` env).
- Reservation transitions only via `ReservationService::transitionTo()`;
  `ReservationService` has zero dependency on Digital Access
  (architecture-tested). Payment state never touched by check-in
  (no capture — Phase 5 has no capture execution and Phase 7 does not add it).

---

## 11. Transaction architecture / audit

Audit actions (via the central `AuditLogger`): `digital_access.issue_requested`,
`digital_access.issued`, `digital_access.issued_reservation_not_ready`
(late-success reconciliation flag), `digital_access.issue_failed`,
`digital_access.revoke_requested`, `digital_access.revoked`,
`digital_access.expired`. Each carries a safe snapshot (grant status, mode,
provider, provider reference, timestamps, failure_reason) + the reservation
status where relevant. Never the credential, the idempotency key, the
revocation reason free-text, an identity path, or a provider payload. The
reservation transition itself is audited by `ReservationService`
(`reservation.status_changed`) — no duplicate entry.

---

## 12. One pre-existing defect fixed (smallest compatible change)

`App\Support\Api\ApiResponse::success()` resolved a single `JsonResource` via
`$data->toArray(request())`, which **skips** the resource's conditional-
attribute filtering (`when()` / `whenLoaded()` / `MissingValue`). Conditional
fields therefore serialized as empty objects instead of being omitted.
Changed to `$data->resolve(request())` (= `toArray()` + `filter()`), matching
how the `ResourceCollection` branch already resolves. One line. Full suite
stays green (1164 tests). This is what makes `AccessGrantResource`'s
"PIN only while ACTIVE" work correctly; it also silently fixes latent cases
in `UserResource` / `RoleResource` / `IdentityVerificationResource`.

---

## 13. Files

### New — `app/Domain/DigitalAccess/` (17)
`Models/AccessGrant`, `StateMachine/DigitalAccessStateMachine`,
`Services/DigitalAccessService`, `Policies/AccessGrantPolicy`,
`Repositories/Contracts/AccessGrantRepositoryInterface`,
`Repositories/EloquentAccessGrantRepository`,
`Provider/Contracts/DigitalAccessProviderInterface`,
`Provider/DummyDigitalAccessProvider`, `Provider/SimulationDirective`,
`Provider/AccessResultStatus`, `Provider/Support/AccessSensitiveDataGuard`,
`Provider/Data/{AccessIssueRequest,AccessOperationRequest,AccessResult}`,
`Provider/Exceptions/{UnsupportedDigitalAccessProviderException,UnsupportedDigitalAccessSimulationDirectiveException}`,
`Exceptions/{InvalidDigitalAccessStatusTransitionException,CheckInNotAllowedException,CheckInEligibilityException,DigitalAccessActionNotAllowedException,DigitalAccessIdempotencyKeyConflictException}`.

### New — HTTP
`Controllers/Api/V1/CheckInController`, `Controllers/Api/V1/DigitalAccessController`,
`Requests/Api/V1/DigitalAccess/{CheckInRequest,RevokeAccessRequest}`,
`Resources/V1/AccessGrantResource`.

### New — config / migration / factory
`config/digital_access.php`, `2026_09_07_130000_create_access_grants_table.php`,
`database/factories/AccessGrantFactory.php`.

### New — tests (18 files)
`tests/Unit/DigitalAccess/DigitalAccessStateMachineTest`,
`tests/Unit/DigitalAccess/Provider/{DummyDigitalAccessProviderTest,DummyDigitalAccessProviderArchitectureTest,DigitalAccessProviderBindingTest,AccessSensitiveDataGuardTest}`,
`tests/Unit/DigitalAccess/Workflow/{DigitalAccessWorkflowTestCase,CheckInFlowTest,DigitalAccessRevocationTest,DigitalAccessExpiryTest,DigitalAccessIdempotencyTest,DigitalAccessArchitectureTest,DigitalAccessSecurityTest}`,
`tests/Unit/Models/AccessGrantModelTest`, `tests/Unit/Repositories/AccessGrantRepositoryTest`,
`tests/Unit/Policies/AccessGrantPolicyTest`,
`tests/Feature/DigitalAccess/{CheckInApiTest,DigitalAccessApiTest,DigitalAccessIntegrationTest,DigitalAccessHardeningTest}`.

### Modified (7)
`routes/api.php` (3 routes), `app/Providers/AppServiceProvider.php` (repo
binding, policy, provider singleton, 2 rate limiters),
`bootstrap/app.php` (5 renderable → 422), `database/seeders/RolePermissionSeeder.php`
(3 permissions), `lang/en/api.php` (`digital_access.*`), `.env.example`
(Phase 7 keys), `app/Support/Api/ApiResponse.php` (the `resolve()` fix, §12).
Postman: new folder **"11 Check-in & Digital Access"** (3 requests).

---

## 14. Tests & results

- **Phase 7 focused:** `161 passed`.
- **Full backend suite:** `1164 passed`, 0 failed, 0 skipped (was 1003 at the
  Phase 6 commit; +161).
- **Regression** (Payment + Reservation + Identity Verification suites):
  `593 passed`, 0 failed.
- **Laravel Pint** `--test`: **passed** (clean).
- Migrations: `migrate:fresh`, `migrate:rollback --step=1`, re-migrate — all OK.

---

## 15. Mobile (Flutter) consumption

Flutter is developed separately (currently `DummyDataSource`, later
`ApiDataSource`). No mobile files were touched. Phase 7 endpoints the guest
app will consume:

| Endpoint | Guest-app use |
|---|---|
| `POST /api/v1/check-in/{reservation}` | "Digital check-in" button once the reservation is VERIFIED; response carries the door PIN. |
| `GET /api/v1/access/{reservation}` | "My key" screen — poll for the current PIN / access status; server re-checks validity + expiry on each call. |
| `POST /api/v1/access/{reservation}/revoke` | Staff/host action (not guest-facing in the MVP — Guest is "system-issued only"). |

Guest authentication is not part of Phase 7 — staff perform check-in on the
guest's behalf today. When guest auth lands, the check-in / status endpoints
gain a guest-owns-their-own authorization branch.

---

## 16. Open / future items (documented, never invented)

| # | Item | Phase 7 behaviour |
|---|---|---|
| 1 | Trigger for `CHECKED_IN → IN_STAY` | Not implemented — §8 defines no trigger. The edge still exists in `ReservationStateMachine`. |
| 2 | Exact hotel checkout time-of-day | `expires_at` = `check_out` **end of day**. A per-hotel checkout-time config could refine it. |
| 3 | Early-check-in policy (a `now() >= check_in` lower bound) | Not enforced — no policy in the baseline. Only the upper bound (stay not over) is enforced. |
| 4 | Room assignment as a check-in precondition | Not required (not in §11 eligibility). The grant is reservation-scoped; `room_id` is passed to the provider as metadata when set. A real smart-lock provider may make room allocation a hard prerequisite. |
| 5 | Retention / purge job for expired-credential data | Not built (§17 retention is Identity-scoped; queues are out of Phase 7 scope). |
| 6 | Re-issuing access after a revoke | Rejected (`DigitalAccessActionNotAllowedException`) — no approved requirement. |
| 7 | `smart_lock` access mode | Enum value + config switch present; adapter is future. |
| 8 | Real access-control vendor | OPEN (§20 #9) — dummy is the only binding. |
| 9 | Async / "pending" issuance + a callback endpoint | Not implemented — §16 defines no digital-access webhook. |

---

## 17. Risks

- The dummy PIN is deterministic (required for CI per §18) — a real provider
  must use a CSPRNG. Documented in the provider class and §6.
- Files are not involved (no document storage in Phase 7), so no private-disk
  concerns beyond what Phase 6 already covers.
- The `ApiResponse::resolve()` fix (§12) is shared code; the full suite is
  green, but any consumer that *relied* on unfiltered `when()` output (none
  found) would change behaviour.
- A process kill between Stage A and Stage C leaves a grant in
  `ISSUE_REQUESTED` / `REVOKE_REQUESTED`; the data is not corrupted and a
  retry (issue) or the idempotent Step C resolves it. A reconciliation job is
  deferred, consistent with the accepted Phase 5C pattern.

---

## 18. Final architectural assessment

Controllers thin (architecture-tested: no `DB::`, no `::query(`, no state
machine, no provider interface). `DigitalAccessService` owns the workflow;
transition rules only in `DigitalAccessStateMachine`; provider only through
its interface; reservation changes only through `ReservationService`. No
existing feature modified beyond additive wiring + the one documented
`ApiResponse` fix. Repository → Service → Controller preserved; no competing
architecture. `md/mobile/` untouched.

**Verdict: READY FOR REVIEW.** No commit, no push.
