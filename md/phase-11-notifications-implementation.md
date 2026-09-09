# Phase 11 — Notifications — Implementation Report

**Status:** READY FOR REVIEW · not committed, not pushed
**Base:** working tree on `93fc4e8` (Phases 1–10 committed)
**Date:** 2026-09-08
**Scope:** backend only — no `mobile/` / Flutter file touched.

---

## 1. Objective

The backend notification foundation (Phase 0 §4 "Notifications" bounded
context, §15 dummy-integration architecture, R49/R50 provider abstraction).
A clean notification domain that records every notification, delivers it
through a **provider abstraction** with a **deterministic dummy provider**
(no real email/SMS/push, no credentials), and can later swap in real
adapters with zero business-logic change. Notifications are a **side
effect** — a delivery failure never changes business state.

---

## 2. Source of truth

- Phase 0 baseline: §4 (Notifications context), §15 (`NotificationProviderInterface`,
  dummy per channel, "event logged internally to `notification_events`; no
  external call", `NOTIFICATION_PROVIDER=dummy`), §7 (RBAC), §16 (`/api/v1`,
  API Resources, Form Request, Policy), §17 (security, rate limiting,
  redaction), §18 (deterministic dummies), R20 (approved guest journey:
  Browse → Book → Deposit → Verify → Digital Check-in → Stay → Auto Checkout
  → E-Invoice), R33 (payment-fail-after-verify edge case).
- Existing Phases 1–10 architecture and conventions: domain-namespaced,
  Controller → FormRequest → Policy → Service → Repository → Model,
  reservation-scoped guest resources (no guest auth in MVP), staged
  provider workflow (provider never called inside a DB transaction),
  pure-static state machines, `AuditLogger`, `ApiResponse` envelope,
  `X-Locale` middleware.

Classification: **[A]** approved · **[T]** technical decision · **[F]** future ·
**[C]** clarification.

---

## 3. Architecture — `App\Domain\Notification\`

```
app/Domain/Notification/
  Enums/
    NotificationChannel          in_app | email | sms
    NotificationType             the 5 implemented lifecycle types + the transition mapper
    NotificationStatus           pending | sending | sent | failed  (delivery lifecycle)
    NotificationRecipientType    guest  (staff_user reserved, never written — see §11)
  Exceptions/
    NotificationNotAllowedException            -> 422
    InvalidNotificationStatusTransitionException -> 422
  Listeners/
    SendReservationLifecycleNotifications       ReservationStatusChanged -> NotificationService
  Models/
    Notification                 table `notification_events`
  Policies/
    NotificationPolicy           viewAny / markRead  (permission `notifications.view`)
  Provider/
    Contracts/NotificationProviderInterface     send(NotificationDispatchRequest): NotificationDeliveryResult
    DummyNotificationProvider                   deterministic, no external call
    SimulationDirective          deliver | fail
    NotificationDeliveryOutcome  sent | failed   (provider-operation outcome)
    Data/NotificationDispatchRequest, NotificationDeliveryResult
    Support/NotificationSensitiveDataGuard      denylist for context keys
    Exceptions/Unsupported{Provider,SimulationDirective}Exception
  Repositories/
    Contracts/NotificationRepositoryInterface + EloquentNotificationRepository
  Services/
    NotificationService          the staged workflow + the in-app feed
    NotificationRecipient        server-side recipient value object
  StateMachine/
    NotificationDeliveryStateMachine

app/Domain/Reservation/Events/
    ReservationStatusChanged     emitted by ReservationService::transitionTo AFTER commit
```

Layering matches Phases 5–10 exactly: the service depends only on
`NotificationProviderInterface`, `NotificationRepositoryInterface`,
`AuditLogger`; the provider is bound from config; the controller is thin;
all DB access is in the repository; the transition rules live only in the
state machine (architecture-tested).

---

## 4. Data model — `notification_events`

Named `notification_events` (the §15 name), kept distinct from Laravel's
optional `notifications` table (the `User` model uses `Notifiable`).

One row per **(business event, recipient, channel)**.

| Column | Notes |
|---|---|
| `id` | |
| `reservation_id` | FK, nullable, `restrictOnDelete` (nullable for a future non-reservation notification) |
| `hotel_id` | FK, nullable, `restrictOnDelete` — denormalized server-side |
| `recipient_type` | enum(`guest`,`staff_user`) — only `guest` written this phase |
| `recipient_id` | the guest id, resolved from the reservation |
| `type` | enum — the 5 implemented types (§7) |
| `channel` | enum(`in_app`,`email`,`sms`) |
| `status` | enum(`pending`,`sending`,`sent`,`failed`), default `pending` |
| `locale` | rendered locale, snapshotted |
| `subject`, `body` | the **rendered** localized template text (see §12) |
| `provider` | `dummy` this phase |
| `provider_reference`, `provider_code` | normalized, non-sensitive |
| `failure_reason` | fixed machine string (`provider_declined`), never a raw provider error |
| `idempotency_key` | **UNIQUE** — `reservation:{id}:{toStatus}:{channel}` |
| `context` | json, safe scalars only (from/to status, reference) |
| `sent_at`, `failed_at`, `read_at` | timestamps; `read_at` = in-app read state |
| `created_at`, `updated_at` | |

Indexes: `idempotency_key` UNIQUE · `(reservation_id, channel, id)` (feed) ·
`(reservation_id, channel, read_at)` (unread filter) ·
`(recipient_type, recipient_id)` · `(hotel_id, status)` · `status`.
MariaDB 10.4-compatible (enum + plain indexes only).

**Not stored:** the recipient's email/phone (resolved at send time, handed
to the provider as an opaque routing token, never persisted), any secret,
credential, identity document, payment data, or raw provider payload.

---

## 5. Delivery state machine

`NotificationDeliveryStateMachine` (pure static):

```
PENDING ──► SENDING ──► SENT   (terminal)
                 │
                 └────► FAILED ──► SENDING   (safe retry)
```

Every status change goes through `assertCanTransition()`; the transition
table lives only here.

---

## 6. Provider abstraction

`NotificationProviderInterface::send(NotificationDispatchRequest): NotificationDeliveryResult`
— one operation, DTOs in and out, never touches a model / transaction /
audit / authorization.

`DummyNotificationProvider` — **deterministic**: outcome is a pure function
of (channel, directive, destination reference). No randomness, no clock, no
HTTP, no SDK, no persistence, no credentials. `deliver` → `sent`, `fail` →
`failed`. Configured default `deliver`. It **records** a notification; it
never claims a real message was sent (the success message reads "No
external message was sent").

`§15`'s "one adapter per channel" sketch is realized as one deterministic
simulator this phase; the per-channel real adapters are the documented
future path (§ Future).

Bound in `NotificationServiceProvider` from `config('notifications.provider')`
— `dummy` is the only registered implementation; an unknown value throws
`UnsupportedNotificationProviderException` (fails loudly, like the payment /
identity / access bindings).

---

## 7. Notification types actually implemented

Five — each maps **1:1 to an already-approved Reservation state transition**
that is a milestone in the approved guest journey (R20) or the payment-fail
edge case (R33). **No business event is invented.**

| Type | Transition | Basis |
|---|---|---|
| `reservation_deposit_held` | `* → DEPOSIT_HELD` | R20 "Deposit", R26–R31 |
| `identity_verified` | `DEPOSIT_HELD → VERIFIED` | R20 "Verify", R21–R25 |
| `reservation_checked_in` | `VERIFIED → CHECKED_IN` | R20 "Digital Check-in", §11 |
| `reservation_invoiced` | `CHECKED_OUT → INVOICED` | R20 "E-Invoice", R14–R19 |
| `reservation_cancelled` | `* → CANCELLED` | R33 payment-fail-after-verify |

Every other transition (e.g. `CHECKED_IN → IN_STAY`) produces **nothing** —
the listener is a no-op with zero writes.

Payment / identity / access / service-order / checkout / loyalty have **no
dedicated notification type** this phase: their user-facing outcomes are
already reflected by the reservation transition they drive
(`DEPOSIT_HELD` / `VERIFIED` / `CHECKED_IN` / `INVOICED` / `CANCELLED`), so a
separate type would be duplication. Direct integration into those services
is a documented future item (§ Future) — it would be additive event
emission only.

---

## 8. Event flow

```
ReservationService::transitionTo()               (Phase 4 — unchanged workflow)
  └─ DB::transaction { lock, assertCanTransition, update, audit }   COMMIT
  └─ ReservationStatusChanged::dispatch(reservation, fromStatus, actor, locale)   ← AFTER commit
        │
        ▼
SendReservationLifecycleNotifications  (registered in NotificationServiceProvider::boot)
  └─ NotificationType::forReservationTransition(from, to)  → null? return.
  └─ resolve recipient = NotificationRecipient::fromGuest($reservation->guest)   ← server-side
  └─ try { NotificationService::dispatchForReservation(...) } catch (Throwable) { report(); }   ← never rethrows
        │
        ▼
NotificationService::dispatchForReservation(type, reservation, recipient, eventKey, context, locale, actor)
  └─ render localized subject/body
  └─ for each routed+enabled+reachable channel:
       STEP A  DB txn: idempotency pre-check (lockForUpdate) → create PENDING → advance SENDING → audit `notification.created`   COMMIT
       STEP B  (no txn) NotificationProviderInterface::send(...)
       STEP C  DB txn: SENDING → SENT|FAILED → audit `notification.sent` / `notification.failed`   COMMIT
```

The **only** change to a Phase 1–10 workflow service is one post-commit
`ReservationStatusChanged::dispatch(...)` line in
`ReservationService::transitionTo` (a same-domain event, no new constructor
dependency — the 5-arg constructor and every existing test that `new
ReservationService(...)` are untouched). The Reservation domain has **no
knowledge of any listener**.

---

## 9. Recipient resolution

100% server-side. `NotificationRecipient::fromGuest($reservation->guest)` —
the guest is derived from the reservation, which was itself resolved through
`ReservationService::findAccessibleBy` (hotel scope). No client
`user_id` / `guest_id` / `hotel_id` / `recipient_id` is ever read. The
recipient's real email/phone is used only to decide channel reachability
and to build an opaque hash routing token for the provider — never
persisted, never logged, never in an audit row.

`recipient_type = guest` for every notification this phase. `staff_user` is
a reserved enum value (the loyalty-ledger reserved-type precedent) — never
written; wiring a staff-facing operational notification (e.g. the
manual-review queue) is a future item.

---

## 10. Idempotency

- Deterministic key: `reservation:{id}:{toStatus}:{channel}`.
- **Database-enforced:** `notification_events.idempotency_key` UNIQUE.
- **Application pre-check** under `lockForUpdate` in STEP A, plus a
  `UniqueConstraintViolationException` catch that re-reads the winner.
- A repeated event, a listener re-run, and a concurrent double all collide
  on the same key → the existing row is returned, never a duplicate.
- Replay semantics: `SENT` → no-op; `SENDING` → return (another attempt in
  flight); `FAILED` → retried (advance to `SENDING`, audit
  `notification.retry_requested`, call provider again). A `SENT` row is
  never delivered twice; a `FAILED` row settles on exactly one success.

Verified by `NotificationServiceTest` (repeated dispatch, never-twice,
retry-settles-once, concurrent-insert-safe) and
`ReservationLifecycleNotificationTest` (re-fire the same event → no dupe).

---

## 11. Failure handling

- The listener wraps the whole dispatch in `try { } catch (Throwable) {
  report($e); }` — a notification problem is reported and swallowed.
- The event is emitted **after** the reservation transaction commits, so a
  listener never runs inside it and can never roll it back.
- A provider failure is recorded as a `failed` row (`failure_reason =
  provider_declined`, `failed_at` set) and is safely retryable.
- Proven by `ReservationLifecycleNotificationTest::test_a_notification_delivery_failure_never_blocks_the_transition`
  (provider forced to `fail` → reservation still `DEPOSIT_HELD`, 2 `failed`
  rows).

---

## 12. Localization

- Templates: `lang/en/notifications.php` + `lang/ar/notifications.php`, one
  `subject` + `body` per type, `:reference` the only placeholder. Factual
  statements only — **no invented business promise**, no marketing copy.
- The notification is **rendered at dispatch time** in the locale of the
  triggering request (`app()->getLocale()`, set by the `X-Locale`
  middleware) and the rendered `subject` / `body` are **snapshotted** on the
  row, so history stays stable if a template later changes. `locale` is
  stored alongside.
- Unsupported locale → falls back to `config('notifications.locale')` →
  `config('app.locale')` (`en`).
- `[C]` a **per-guest locale preference** does not exist (the `Guest` model
  has no profile field) — a future enhancement; documented, not invented.
- `api.notifications.*` envelope keys added to `lang/en/api.php` and
  `lang/ar/api.php`.
- Verified by `NotificationLocalizationTest` (en / ar / fr-fallback) and
  `ReservationLifecycleNotificationTest::test_the_locale_of_the_triggering_request_is_used`
  (`X-Locale: ar` → Arabic subject snapshotted).

---

## 13. API endpoints

Reservation-scoped (same pattern as folio / loyalty / invoice — resolved
through `ReservationService`, cross-hotel / missing id = identical plain
404), `throttle:notifications.read` (60/min, config-driven):

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/v1/reservations/{reservation}/notifications` | list the `in_app` feed, newest first, paginated (`?per_page`, 1–100), `?unread=1` filter |
| `PATCH` | `/api/v1/reservations/{reservation}/notifications/{notification}/read` | mark one read (idempotent; `in_app` only → 422 otherwise; wrong-reservation id → 404) |
| `POST` | `/api/v1/reservations/{reservation}/notifications/read-all` | mark every unread `in_app` row for the reservation read → `{ marked_read: <count> }` |

`email` / `sms` rows are delivery bookkeeping and are **not** exposed in the
feed. Notifications are never **created** over HTTP — only by the approved
Reservation lifecycle.

Response: standard `ApiResponse` envelope. `NotificationResource` exposes
`id, reservation_id, hotel_id, type, channel, status, locale, subject, body,
context, is_read, read_at, sent_at, failed_at, created_at` — never the
idempotency key or the provider reference.

---

## 14. Authorization

- `auth:sanctum` on every route.
- Permission `notifications.view` gates the whole feed (list + mark-read):
  a routine front-desk support action, no financial effect → same
  Owner / Manager / Reception split as `folio.view` / `loyalty.view`
  (seeded: Group Owner via `array_keys`, Hotel Manager, Reception; **not**
  Guest).
- `NotificationPolicy::viewAny` / `markRead` resolve hotel scope from the
  user's own stored access via `HotelAccessService` — never a client
  `hotel_id`.
- Guest-role users hold no staff permission and never resolve the
  reservation scope → identical plain **404** (no leak).
- `[C]` no guest authentication exists in the MVP — a "guest reads their
  own notifications" surface would need guest auth (not in scope). The
  feed is the backend foundation the Flutter guest app will consume via
  staff-mediated / future guest-auth access, consistent with every other
  guest resource.
- Verified by `NotificationAuthorizationTest` (role matrix, missing
  permission → 403, cross-hotel → 404, client `hotel_id` cannot widen
  scope) and `NotificationApiTest`.

---

## 15. Security (§17, §19)

- Server-side recipient resolution; no client-controlled ids.
- No secrets / credentials / SDKs / API keys added (`.env.example` documents
  `NOTIFICATION_PROVIDER=dummy` only).
- `NotificationSensitiveDataGuard` denylist rejects any `context` key
  matching `password / secret / token / otp / pin / card / cvv / credential
  / private_key / api_key / authorization / access_code` and any non-scalar
  value, at the DTO boundary.
- No recipient contact value persisted; no raw provider payload / SQLSTATE /
  stack trace in `failure_reason`, `context`, an audit row, or an API
  response.
- Domain exceptions render as fixed 422 business strings (no 409 convention
  in this project).
- `throttle:notifications.read` on the feed endpoints (Phase 0 §17).
- Verified by `NotificationApiTest::test_the_feed_never_leaks_the_idempotency_key_or_provider_reference`,
  `NotificationServiceTest::test_audit_rows_carry_no_secret_no_key_and_no_address`,
  and the provider architecture test (no clock / randomness / HTTP / models).

---

## 16. Audit

Via the central `AuditLogger` with safe flat snapshots (status, type,
channel, recipient_type, locale, provider, provider_reference,
failure_reason, timestamps — **never** the idempotency key, a recipient
address, a raw payload, or a secret):

`notification.created`, `notification.sent`, `notification.failed`,
`notification.retry_requested`.

Mark-read is a low-value UI action and is **not** audited (avoids noise, per
§17 "do not create excessive audit noise").

---

## 17. Queues / async — decision

`[T]` **Synchronous.** The project has **no queue infrastructure** in use
(no jobs, no `ShouldQueue`, `QUEUE_CONNECTION` unconfigured). Per the
instruction not to introduce a queue system unnecessarily, the listener
runs synchronously after commit. The architecture already makes async
delivery a drop-in later: the event is post-commit, the provider call is
staged outside the transaction, every row is idempotent, and the state
machine has an explicit `SENDING` pending state. Moving the listener body
into a queued job (dispatched `afterCommit`) is the only change required —
documented as a future item.

---

## 18. Files

### Created (backend only)

```
app/Domain/Notification/Enums/NotificationChannel.php
app/Domain/Notification/Enums/NotificationType.php
app/Domain/Notification/Enums/NotificationStatus.php
app/Domain/Notification/Enums/NotificationRecipientType.php
app/Domain/Notification/Exceptions/NotificationNotAllowedException.php
app/Domain/Notification/Exceptions/InvalidNotificationStatusTransitionException.php
app/Domain/Notification/Listeners/SendReservationLifecycleNotifications.php
app/Domain/Notification/Models/Notification.php
app/Domain/Notification/Policies/NotificationPolicy.php
app/Domain/Notification/Provider/Contracts/NotificationProviderInterface.php
app/Domain/Notification/Provider/DummyNotificationProvider.php
app/Domain/Notification/Provider/SimulationDirective.php
app/Domain/Notification/Provider/NotificationDeliveryOutcome.php
app/Domain/Notification/Provider/Data/NotificationDispatchRequest.php
app/Domain/Notification/Provider/Data/NotificationDeliveryResult.php
app/Domain/Notification/Provider/Support/NotificationSensitiveDataGuard.php
app/Domain/Notification/Provider/Exceptions/UnsupportedNotificationProviderException.php
app/Domain/Notification/Provider/Exceptions/UnsupportedNotificationSimulationDirectiveException.php
app/Domain/Notification/Repositories/Contracts/NotificationRepositoryInterface.php
app/Domain/Notification/Repositories/EloquentNotificationRepository.php
app/Domain/Notification/Services/NotificationService.php
app/Domain/Notification/Services/NotificationRecipient.php
app/Domain/Notification/StateMachine/NotificationDeliveryStateMachine.php
app/Domain/Reservation/Events/ReservationStatusChanged.php
app/Http/Controllers/Api/V1/NotificationController.php
app/Http/Resources/V1/NotificationResource.php
app/Providers/NotificationServiceProvider.php
config/notifications.php
database/factories/NotificationFactory.php
database/migrations/2026_09_08_120000_create_notification_events_table.php
lang/en/notifications.php
lang/ar/notifications.php
tests/Unit/Notification/NotificationArchitectureTest.php
tests/Unit/Notification/NotificationDeliveryStateMachineTest.php
tests/Unit/Notification/NotificationServiceTest.php
tests/Unit/Notification/Provider/DummyNotificationProviderArchitectureTest.php
tests/Unit/Notification/Provider/DummyNotificationProviderTest.php
tests/Feature/Notification/NotificationApiTest.php
tests/Feature/Notification/NotificationAuthorizationTest.php
tests/Feature/Notification/NotificationLocalizationTest.php
tests/Feature/Notification/NotificationSchemaTest.php
tests/Feature/Notification/ReservationLifecycleNotificationTest.php
md/phase-11-notifications-implementation.md
```

### Modified (backend only)

```
app/Domain/Reservation/Services/ReservationService.php   +1 post-commit event dispatch (no constructor change)
app/Providers/AppServiceProvider.php                     repo binding + policy + notifications.read rate limiter
bootstrap/app.php                                        2 renderable exception mappings -> 422
bootstrap/providers.php                                  register NotificationServiceProvider
config-less wiring only
database/seeders/RolePermissionSeeder.php                +permission `notifications.view` (Owner/Manager/Reception)
lang/en/api.php, lang/ar/api.php                         +`notifications` envelope block
routes/api.php                                           +3 reservation-scoped routes (throttle:notifications.read)
.env.example                                             +Notifications block (dummy, no secrets)
postman/Hotel-Management-API.postman_collection.json     +"13 Notifications" folder (5 requests, +161 / -0)
```

---

## 19. Testing

Focused Notification suite (`tests/Unit/Notification` + `tests/Feature/Notification`):
**68 passed**, covering: state-machine transitions + rejections; dummy
provider determinism / failure / no-DB-query / interface shape; sensitive-data
guard; service (per-channel fan-out, idempotency, retry-settles-once,
never-twice, staged provider call outside a transaction, recipient
resolution, audit redaction, mark-read in-app-only, concurrent-insert
safety); schema (columns, unique, indexes, FK restrict, enum values,
nullability); lifecycle integration (each milestone → its type, non-milestone
→ nothing, sms skipped without a phone, dupe event → no dupe, failure never
blocks the transition, request locale used); API (list, pagination, unread
filter, in_app-only feed, mark one / mark all, cross-reservation 404,
422 on email row, no leak); authorization (role matrix, missing permission
→ 403, guest → 404, cross-hotel → 404).

Full backend suite and Pint were green at the last run (numbers in the
task response). `migrate:fresh --seed` clean; migration rollback + re-migrate
clean.

---

## 20. Known limitations / deferred

- **Synchronous delivery** — queued after-commit dispatch is the documented
  next step (§17). `[T]`
- **In-app is the only fully-realized channel** — `email` / `sms` are
  simulated end-to-end by the dummy provider (recorded, no external
  message). Real per-channel adapters are future. `[F]`
- **No per-guest locale** — the `Guest` model has no profile; rendering uses
  the triggering request's locale. `[C]`
- **No guest-authenticated notification surface** — the feed is
  reservation-scoped and staff-authorized (no guest auth in the MVP). `[C]`
- **No dedicated payment / identity / access / checkout / loyalty
  notification types** — their user-facing outcomes are already carried by
  the reservation transition they drive; direct event integration into
  those services is a future additive change. `[T]`
- **`staff_user` recipient** reserved but never produced — a staff
  operational feed (e.g. verification manual-review queue) is future. `[F]`
- **Roadmap note `[C]`:** the Phase 0 §19 roadmap sequences Ratings & Reviews
  (R44) as Phase 11 and Notifications as Phase 12; the current owner roadmap
  places Notifications at 11 and omits Ratings & Reviews. This report
  implements Notifications per the current instruction. Ratings & Reviews
  (R44) remains **unimplemented** — recommend confirming its sequencing.

---

## 21. Future real-provider integration

1. Add `App\Domain\Notification\Provider\{Twilio,Ses,Fcm}NotificationProvider`
   implementing `NotificationProviderInterface` (one per channel, or a
   router that fans to per-channel adapters).
2. Register it in `NotificationServiceProvider::register()` behind a new
   `config('notifications.provider')` value; add credentials to `.env`
   (never committed).
3. Move `SendReservationLifecycleNotifications::handle` body into a queued
   `ShouldQueue` job dispatched `afterCommit`.
4. Nothing in `NotificationService`, the state machine, the schema, the API,
   or any business workflow changes.
