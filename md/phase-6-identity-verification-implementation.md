# Phase 6 — Identity Verification — Implementation Report

**Status:** READY FOR REVIEW · not committed, not pushed
**Base commit:** `bf332a0` (Phase 5 payment workflow)
**Date:** 2026-09-07

---

## 1. Objective

Implement the complete Identity Verification foundation and workflow as one
controlled phase, on the approved Phase 0 architecture and the existing
Phases 1–5 conventions, with a dummy provider only and no invented business
values.

---

## 2. Source of truth & an inspection note

- Primary source: `md/hotel_platform_phase0_approved_baseline.md` — §10
  (Identity Verification State Machine), §4, §6.4, §15, §16, §17, §18,
  R21–R25, R38–R42, R57, R58, §20 items 2/3/5.
- **`hotel_docs.pdf` is not present in the repository.** The Phase 0
  baseline states it "is self-contained … supersedes both prior Phase 0
  documents" and "incorporates all confirmed decisions", so it was used as
  the authoritative source. No contradiction could arise because the PDF
  was unavailable; if it is later supplied and conflicts with §10, the
  state machine and this report must be revisited.
- A `md/mobile/` directory (Flutter SRS/guides) appeared in the working
  tree during this phase. It was **not created by Phase 6 work**, is
  untracked, and was left untouched (mobile is explicitly out of scope).

---

## 3. Approved requirements used

| Ref | Requirement | How it is implemented |
|---|---|---|
| §10 | State machine `NOT_STARTED → DOCUMENT_UPLOADED → SELFIE_CAPTURED → MATCHING_IN_PROGRESS → {AUTO_APPROVED \| PENDING_MANUAL_REVIEW \| RETRY_ALLOWED}`, retry back to `DOCUMENT_UPLOADED`, manual review `→ STAFF_APPROVED \| STAFF_REJECTED` | `IdentityVerificationStateMachine` — stateless, the only place transitions are defined |
| §10 | HIGH/MEDIUM/LOW bands are **configuration**, never hardcoded (R57) | `config('verification.thresholds.auto_approve' / '.manual_review')`, both nullable |
| §10 | Retry count is **configurable**; once exceeded, permanently routed to `PENDING_MANUAL_REVIEW` (R57) | `config('verification.max_retries')`, nullable; `RETRY_ALLOWED → PENDING_MANUAL_REVIEW` edge |
| §10 | Manual review always reachable; no hard auto-reject | Every non-terminal status can reach `PENDING_MANUAL_REVIEW` (unit-tested); no `staff_rejected`/reject path is automated |
| §8 | `DEPOSIT_HELD → VERIFIED` on "verification passes" | Driven only through `ReservationService::transitionTo()` on `AUTO_APPROVED` / `STAFF_APPROVED` |
| §15 | `IdentityVerificationProviderInterface` + `DummyIdentityVerificationProvider`, deterministic, config-selected, dummy is the only binding | `AppServiceProvider::register()` `match()` — unknown provider throws, never falls back |
| §16 | `/api/v1/identity-verification/{reservation}/{documents\|selfie\|status\|review}` | Exactly these four routes, no more |
| §17 | Private ID/selfie storage, no full sensitive data stored, full audit, rate limiting on verification-upload | Private `local` disk only; safe audit snapshots; `throttle:identity-verification.submit` on the two upload routes |
| §7 | Owner / Hotel Manager / Reception may review-decide a pending verification; Guest may not | `IdentityVerificationPolicy` + three `identity-verification.*` permissions seeded to those three roles |
| R58 | Retention period configurable, not hardcoded | `config('verification.retention_days')` nullable placeholder; **no purge job** this phase (deferred) |

---

## 4. Technical decisions (classified [T])

1. **Score scale** is a provider-normalized integer `0..100`. The interface
   normalizes whatever a real provider returns into this range.
2. **No verification callback/webhook.** Phase 0 §16 defines no such route
   (unlike Payments §9/§16 which explicitly do). The provider interface is a
   single synchronous `verify()` method. An async/"processing" provider
   state is deferred.
3. **Fail-safe on missing configuration.** When `thresholds.auto_approve` is
   unset the workflow routes to `PENDING_MANUAL_REVIEW` (never auto-approve,
   never auto-reject). When `max_retries` is unset a `RETRY_ALLOWED` session
   likewise routes to `PENDING_MANUAL_REVIEW`; a retry from `STAFF_REJECTED`
   with no configured limit raises a safe 422. No number is ever assumed.
4. **`max_retries` semantics:** maximum number of RETRY attempts beyond the
   initial attempt (`max_retries = 2` → 3 total attempts).
5. **Three tables** (`identity_verification_sessions` / `_attempts` /
   `_decisions`) — the names and shape anticipated by Phase 0 §6.4.
6. **Files are write-only this phase.** Stored on the private disk,
   referenced by the domain, never served back (no download route in §16).
7. **Document re-upload** replaces the file on the current pending attempt;
   it does not start a new attempt or consume retry budget.
8. **Idempotency** is on the selfie/match operation only
   (`identity_verification_attempts.idempotency_key` UNIQUE); a document
   submission is naturally idempotent (re-upload replaces).
9. **HTTP mapping:** `documents` → 201; `selfie` / `status` / `review` →
   200 with `data.status` carrying the workflow outcome. A low/medium match
   or a provider error is a *state*, not an error, so it is 200 — only
   auth/validation/wrong-state failures are 4xx (all business errors 422,
   matching the project's no-409 convention).

---

## 5. Owner additions

None. Reception's inclusion on `identity-verification.review` is directly
from the Phase 0 §7 matrix (✅ for Reception), not an addition.

---

## 6. Files changed

### New — domain (`app/Domain/IdentityVerification/`, 33 files)

- `Provider/Contracts/IdentityVerificationProviderInterface.php`
- `Provider/DummyIdentityVerificationProvider.php`
- `Provider/SimulationDirective.php`, `Provider/MatchOutcome.php`
- `Provider/Data/VerificationRequest.php`, `Provider/Data/VerificationResult.php`
- `Provider/Support/IdentitySensitiveDataGuard.php`
- `Provider/Exceptions/UnsupportedIdentityVerificationProviderException.php`
- `Provider/Exceptions/UnsupportedIdentityVerificationSimulationDirectiveException.php`
- `StateMachine/IdentityVerificationStateMachine.php`
- `Models/IdentityVerificationSession.php`, `…Attempt.php`, `…Decision.php`
- `Repositories/Contracts/…SessionRepositoryInterface.php`, `…AttemptRepositoryInterface.php`, `…DecisionRepositoryInterface.php`
- `Repositories/EloquentIdentityVerificationSessionRepository.php`, `…AttemptRepository.php`, `…DecisionRepository.php`
- `Services/IdentityVerificationService.php`
- `Support/IdentityFileStore.php`
- `Policies/IdentityVerificationPolicy.php`
- `Exceptions/`: `InvalidIdentityVerificationStatusTransitionException`, `IdentityVerificationNotAllowedException`, `IdentityVerificationActionNotAllowedException`, `IdentityVerificationRetryNotAllowedException`, `IdentityVerificationConfigurationMissingException`, `IdentityVerificationIdempotencyKeyConflictException`

### New — HTTP

- `app/Http/Controllers/Api/V1/IdentityVerificationController.php`
- `app/Http/Requests/Api/V1/IdentityVerification/SubmitIdentityDocumentRequest.php`, `SubmitIdentitySelfieRequest.php`, `ReviewIdentityVerificationRequest.php`
- `app/Http/Resources/V1/IdentityVerificationResource.php`

### New — config / migrations / factories

- `config/verification.php`
- `database/migrations/2026_09_07_120000_create_identity_verification_sessions_table.php`
- `database/migrations/2026_09_07_120001_create_identity_verification_attempts_table.php`
- `database/migrations/2026_09_07_120002_create_identity_verification_decisions_table.php`
- `database/factories/IdentityVerificationSessionFactory.php`, `…AttemptFactory.php`, `…DecisionFactory.php`

### Modified (6)

- `routes/api.php` — 4 routes under `/identity-verification/{reservation}` inside the `auth:sanctum` group
- `app/Providers/AppServiceProvider.php` — 3 repo bindings, 1 policy, provider singleton, `identity-verification.submit` rate limiter
- `bootstrap/app.php` — 6 renderable exception → 422 mappings
- `database/seeders/RolePermissionSeeder.php` — 3 permissions → Group Owner / Hotel Manager / Reception
- `lang/en/api.php` — `identity_verification.*` message block
- `.env.example` — Phase 6 keys, all business values left blank

### Tests (19 new files, 176 tests)

`tests/Unit/IdentityVerification/…` (state machine, provider, binding,
sensitive-data guard, workflow: document/matching/review/retry/idempotency,
architecture, security), `tests/Unit/Models/IdentityVerificationModelsTest`,
`tests/Unit/Policies/IdentityVerificationPolicyTest`,
`tests/Unit/Repositories/IdentityVerificationRepositoryTest`,
`tests/Feature/IdentityVerification/…` (API, integration, hardening).

### Postman

`postman/Hotel-Management-API.postman_collection.json` — new folder
**"10 Identity Verification"** (Submit ID Document, Submit Live Selfie, Get
Verification Status, Manual Review Decision), each with description + test
scripts, no secrets.

---

## 7. Database changes

All three tables are new; **no existing table was altered**. MariaDB
10.4.28-compatible (enum + plain indexes, explicit short index names where
the auto-generated name exceeded 64 chars).

**`identity_verification_sessions`** — `reservation_id` UNIQUE FK (restrict),
`guest_id` FK (restrict), `hotel_id` FK (restrict, denormalized from the
reservation), `status` enum(9) default `not_started`, `provider`,
`attempts` uint, `latest_outcome`, `latest_score` utinyint, `decided_at`.
Indexes: `guest_id`, `status`, `(hotel_id,status)`.

**`identity_verification_attempts`** — `session_id` FK (cascade),
`attempt_number` uint, `status` enum(4), `provider`, `provider_reference`
(nullable), `idempotency_key` UNIQUE, `document_type`, `document_path` /
`selfie_path` (private relative paths, `$hidden`), `outcome`, `score`
utinyint, `metadata` json (safe keys only), `submitted_at`, `completed_at`.
Unique: `(session_id,attempt_number)`, `(provider,provider_reference)`.

**`identity_verification_decisions`** — append-only (`created_at` only),
`session_id` FK (cascade), `attempt_id` FK (nullable, nullOnDelete),
`type` enum(automated|manual), `result` enum(6), `decided_by_user_id` FK
(nullable, nullOnDelete), `score`, `band` enum(high|medium|low), `reason`
string(500). Indexes: `(session_id,created_at)`, `decided_by_user_id`.

No raw provider payload is stored anywhere.

---

## 8. API changes

All under `auth:sanctum`, all resolve `{reservation}` through
`ReservationService::findAccessibleBy()` (cross-hotel / missing → plain 404,
no existence leak).

| Method | Path | Permission | Notes |
|---|---|---|---|
| POST | `/api/v1/identity-verification/{reservation}/documents` | `identity-verification.submit` | multipart `document` (jpg/jpeg/png/pdf), optional `document_type`; `throttle:identity-verification.submit`; 201 |
| POST | `/api/v1/identity-verification/{reservation}/selfie` | `identity-verification.submit` | multipart `selfie` (jpg/jpeg/png); `Idempotency-Key` header; `X-Identity-Simulate` header (local/testing only); `throttle:identity-verification.submit`; 200 with `data.status` |
| GET | `/api/v1/identity-verification/{reservation}/status` | `identity-verification.view` | safe fields only; transient `not_started` payload when no session exists |
| POST | `/api/v1/identity-verification/{reservation}/review` | `identity-verification.review` | body `decision` (approve\|reject), optional `reason`; only from `PENDING_MANUAL_REVIEW` |

Retry has no dedicated endpoint (§16 defines none): a retry is a fresh
`documents` submission while the session is `RETRY_ALLOWED` / `STAFF_REJECTED`.

---

## 9. State machine

`IdentityVerificationStateMachine` — stateless, non-instantiable, the single
authority. Terminal: `auto_approved`, `staff_approved`. `staff_rejected` is
non-terminal (retry edge per §10). Fully unit-tested: every approved
transition, a matrix of forbidden transitions, terminal detection,
map-matches-approved-table, statuses-match-model-constants, and a
reachability proof that `pending_manual_review` is reachable from every
non-terminal status.

---

## 10. Provider abstraction & dummy provider

`IdentityVerificationProviderInterface::verify(VerificationRequest): VerificationResult`
— provider-side only, no persistence / models / DB / audit / files, DTOs in
and out. `DummyIdentityVerificationProvider` is deterministic: directive →
outcome (`high_match`→90, `medium_match`→55, `low_match`→20, `error`→null),
`dummy_idv_<sha256-slice>` reference, no HTTP / clock / randomness /
container. The fixed scores are simulation outputs, not thresholds — the
auto-approve/manual-review decision is made by the workflow against
`config('verification.thresholds')`. An architecture test scans the whole
provider package for forbidden references and asserts zero DB queries.

---

## 11. Workflow, transaction boundaries, idempotency, retry

**Selfie/match — three stages (mirrors Payment §5C):**
`STEP A` (DB txn: lock Reservation → Session → Attempt, validate, store the
private selfie reference, transition to `MATCHING_IN_PROGRESS`, audit,
commit) → `STEP B` (`provider->verify()` **outside any transaction**) →
`STEP C` (`applyMatchResult()`: re-lock in the same order, classify against
the configured thresholds/retry budget, transition the session, append a
decision, drive `ReservationService` when approved, audit, commit). A
runtime test with a transaction-level-checking provider proves the provider
is never called inside a nested transaction.

**Idempotency:** `identity_verification_attempts.idempotency_key` UNIQUE. A
replayed key returns the current session with no second provider call and no
duplicate attempt/decision (unit + feature tested). A key reused across
verifications is a 422 conflict. `applyMatchResult()` is idempotent — a
duplicate result for a `completed` attempt is a no-op.

**Retry:** `RETRY_ALLOWED` iff `attempts - 1 < config('verification.max_retries')`.
On exhaustion (or missing config) the session goes to
`PENDING_MANUAL_REVIEW` (`RETRY_ALLOWED` path) or a safe 422
(`STAFF_REJECTED` path). Retry never resets payment or reservation state.

**Reservation integration:** only `DEPOSIT_HELD → VERIFIED`, only via
`ReservationService::transitionTo()`. A reservation that already left
`DEPOSIT_HELD` (late approval after cancellation) is left exactly as-is and
the divergence is audited (`identity_verification.approved_reservation_not_ready`,
`requires_reconciliation: true`) — mirrors Payment's late-success handling.
`ReservationService` still has zero dependency on the Identity domain
(architecture-tested).

---

## 12. Security controls

- **Private storage only.** `IdentityFileStore` reads
  `config('verification.storage.disk')` and **throws if it is `public`**.
  Files land under `identity-verification/{sessionId}/…` on the `local`
  (private) disk. Laravel's `ServeFile` guard means the `storage/{path}`
  route rejects any unsigned request (403/404); Phase 6 never generates a
  signed URL for these files.
- **No PII in logs / audit / responses.** Audit snapshots carry status,
  attempt number, provider (name), provider reference, band, score — never a
  file path, `document_type`, document number, selfie, or raw payload
  (tests scan every audit row). `IdentityVerificationResource` exposes only
  status fields + a compact `latest_decision`; `document_path` / `selfie_path`
  are also `$hidden` on the model.
- **Sensitive-data guard.** `IdentitySensitiveDataGuard` rejects any
  metadata key resembling a document number, MRZ, DOB, image, secret, etc.,
  before a `VerificationRequest` is built.
- **No secrets in source, config, `.env.example`, Postman, or tests.**
- **Error envelope.** Six domain exceptions → fixed safe 422 strings; no
  provider internals, SQLSTATE, or stack traces (feature-tested).
- **Rate limiting** on the two upload routes
  (`config('verification.rate_limits.submit.per_minute')`, default 20).
- **Simulation directive** honoured only in `local`/`testing`; silently
  ignored elsewhere (feature-tested against a forced `production` env).

---

## 13. Authorization / hotel scope

Server-side only. `IdentityVerificationPolicy` checks the permission **and**
`HotelAccessService::canAccessHotel()` against the reservation's own
`hotel_id`. Client-supplied `hotel_id` / role / user id are ignored.
Group Owner is an explicit policy-checked bypass. Guest-role users hold no
permission → resolved out of scope → 404. Reception has view + submit +
review (Phase 0 §7) but no financial capability.

Permissions seeded: `identity-verification.view`, `.submit`, `.review` →
Group Owner, Hotel Manager, Reception.

---

## 14. Audit

Reuses `AuditLogger`. Actions: `session_started`, `document_submitted`,
`selfie_submitted`, `auto_approved`, `manual_review_required`,
`retry_allowed`, `retry_exhausted`, `staff_approved`, `staff_rejected`,
`reservation_verified`, `approved_reservation_not_ready`. Every meaningful
transition writes actor + hotel + safe metadata. No parallel audit system.

---

## 15. Tests & results

- **Phase 6 focused:** `176 passed` (956 assertions) — state machine (63),
  provider + binding + guard + architecture, workflow
  (document/matching/review/retry/idempotency/architecture/security),
  models, repositories, policy, API, integration, hardening.
- **Full backend suite:** **`1003 passed`, 0 failed, 0 skipped** (4435
  assertions) — was 827 before Phase 6 (+176).
- **Laravel Pint:** `--test` → **passed** (all changed files formatted; the
  run applied only ordered-imports / FQN / phpdoc-align style fixes).
- Related regressions specifically re-checked and green: all
  `tests/Feature/Payment/*`, `tests/Unit/Payment/*`,
  `tests/Feature/Reservation/*`, `tests/Unit/Reservation/*`,
  `tests/Unit/Services/Reservation*`.

---

## 16. Open questions / configuration intentionally left unresolved

| # | Item | State | Behaviour while unset |
|---|---|---|---|
| 1 | `verification.thresholds.auto_approve` (Phase 0 §20 #2) | **[OPEN]** — no number invented | Every match → `PENDING_MANUAL_REVIEW` |
| 2 | `verification.thresholds.manual_review` (§20 #2) | **[OPEN]** | Only affects the MEDIUM-vs-LOW band label; workflow outcome unchanged |
| 3 | `verification.max_retries` (§20 #3) | **[OPEN]** | `RETRY_ALLOWED` → `PENDING_MANUAL_REVIEW`; `STAFF_REJECTED` retry → safe 422 |
| 4 | `verification.retention_days` (§20 #5, §17) | **[OPEN]** | No purge job runs (none built) |
| 5 | Real identity/biometric provider (§20 #8) | **[OPEN]** — deferred to Future | Dummy is the only binding |
| 6 | Document-type vocabulary | not specified anywhere | Free short label, validated shape only |

These must be set by an authorized admin before production go-live; none is
finalized here.

---

## 17. Deferred work (not in Phase 6 scope)

- Retention **purge job/command** (needs the retention value + Phase 0
  says only that a job "reads" it; queues are out of scope this phase).
- **Async / "processing" provider** result + a verification callback/webhook
  endpoint (Phase 0 §16 defines no such route).
- Real KYC/OCR/biometric provider, real HTTP, signed document-download URLs.
- Guest-authenticated self-service submission (guest auth does not exist in
  this MVP; staff submit on the guest's behalf — R7/R33).
- Digital Access / check-in consumption of the `VERIFIED` state (Phase 7+).

---

## 18. Final architectural assessment

Controllers are thin (architecture-tested: no `DB::`, no `::query(`, no
state machine, no provider interface). Business logic lives in
`IdentityVerificationService`; transition rules live only in the state
machine; the provider is reached only through its interface; Reservation
status changes go only through `ReservationService`. No existing feature was
modified beyond additive wiring. No Phase 5 change was needed. Repository →
Service → Controller is preserved; no competing architecture introduced.

**Verdict: READY FOR REVIEW.** No commit and no push were performed.
