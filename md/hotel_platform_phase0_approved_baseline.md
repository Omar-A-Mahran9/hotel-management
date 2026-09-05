# Hotel Group Management Platform — Phase 0 APPROVED BASELINE (v3, Final)

**Status:** Phase 0 is approved as the baseline architecture and requirements package. This document incorporates all confirmed decisions from your latest instructions and **supersedes** both prior Phase 0 documents. It is self-contained — no need to cross-reference earlier files.

**No Laravel, Nuxt, Flutter, or database code has been created. No migrations. No packages installed. Implementation has not started.** This document stops at documentation, per your explicit instruction, and waits for Phase 1 authorization.

---

## 1. Requirements Matrix

Classification: **[A]** Approved (in source PDF) · **[O]** Project-Owner Addition · **[T]** Technical Decision · **[F]** Future · **[OPEN]** genuinely unresolved

| ID | Requirement | Class |
|---|---|---|
| R1 | Multi-hotel group, one owning entity, one control plane | A |
| R2 | Full per-hotel data isolation (rooms, bookings, guests) | A |
| R3 | Each hotel keeps its own operational team; group retains oversight | A |
| R4 | Cross-hotel performance comparison (occupancy, revenue, satisfaction) | A |
| R5 | Adding a new hotel is a simple registration step, no rebuild | A |
| R6 | Four actors: Group Owner/Manager, Hotel Manager, Reception, Guest | A |
| R7 | Reception is a support/fallback layer, not the default check-in/out path | A |
| R8–R13 | Central dashboard: hotel/room mgmt, live bookings, verification queue, payments/invoices, comparison reports | A |
| R14–R19 | Guest-facing: browse, book+pay, upload ID+selfie, digital check-in, in-stay requests, one-tap checkout | A |
| R20 | Guest journey: Browse→Book→Deposit→Verify→Digital Check-in→Stay/Services→Auto Checkout→E-Invoice | A |
| R21–R25 | Identity verification: live-selfie-vs-ID match, score-based auto-approve/manual-review split, human fallback always exists | A |
| R26–R31 | Payment: hold at booking → capture at check-in → accrue in-stay charges → single settlement at checkout → e-invoice; deposit-hold improves cancellation flexibility | A |
| R32 | Permission table: Owner (all hotels) / Hotel Manager (own hotel[s]) / Reception (assist + review, **no financial edit/delete**) / Guest (own data only) | A |
| R33–R37 | Five documented edge cases (processing-on-arrival, payment-fail-after-verify, unclear photos, concurrent same-room booking, system outage fallback) | A |
| R38–R42 | Security: private ID/selfie storage, no full payment data stored, full audit logging, auto access expiration, retention transparency | A |
| R43 | Loyalty program (group-wide ledger) | O — doc lists this under "future ideas" (§11); **you have explicitly promoted it to MVP** |
| R44 | Ratings & reviews (1–5 stars + optional text, eligibility-gated, moderated) | O — doc only hints at a "quick rating"; **you have explicitly defined and confirmed full MVP scope** |
| R45 | Metronic mandatory dashboard framework | O |
| R46 | Laravel / Vue-Nuxt / Flutter stack | O |
| R47 | Versioned REST API, `/api/v1` | T |
| R48 | State-machine-driven workflows, explicit allowed transitions only | T |
| R49 | Provider abstraction for Payment/Verification/Access/Notifications | T |
| R50 | **All third-party integrations dummy/mocked this phase, swappable later, zero domain-layer coupling to any vendor** | O |
| R51 | No loyalty point expiration in MVP | O |
| R52 | No category-based ratings in MVP | O |
| R53 | Cancellation policy configurable per hotel, no hardcoded % or deadlines | O |
| R54 | No dynamic/occupancy pricing; no unnecessary rate-plan complexity in MVP | O |
| R55 | Flutter is the sole authenticated guest app; no separate guest web app | O |
| R56 | Hotel Manager may be assigned to **one or multiple** hotels; access always scoped to assigned hotels | O — **now resolved** (was open in prior draft) |
| R57 | Verification confidence thresholds configurable, not hardcoded; retry count configurable | O |
| R58 | Identity data retention period configurable, not hardcoded | O |
| R59 | Loyalty redemption limited to eligible bookings only in MVP; no folio/service redemption | O |
| R60 | **Room-vs-Room-Type booking model** | **[OPEN]** — see §6 |

---

## 2. MVP vs. Future

### MVP
Everything in R1–R59 above. Specifically for the three areas you narrowed further this round:
- **Identity verification:** dummy provider, configurable confidence bands (high/medium/low), configurable retry count, manual review always available, full state machine (§9).
- **Loyalty:** ledger-based, earn from eligible completed bookings, redeem against eligible bookings only, no expiration, no tiers, no folio/service redemption.
- **Ratings & Reviews:** 1–5 stars, optional text, eligibility tied to a completed/stayed booking, dashboard moderation, no invented extra moderation rules (e.g. no auto-flagging, no reviewer reputation scoring, no appeals workflow — none of that is documented or requested, so none of it is built).

### Future (explicitly out of MVP, unchanged)
- Loyalty tiers, loyalty expiration
- Category-based ratings
- Loyalty redemption against folio/service charges
- "Trusted guest" — skip repeated verification
- Personalized/preference-based automation
- Occupancy-based dynamic pricing, complex rate plans
- In-app FAQ/AI assistant
- Marketing-style post-checkout summary (distinct from the mandatory e-invoice)
- Simplified multi-room/family bookings
- Advanced cross-hotel analytics beyond basic comparison reports
- Separate authenticated guest web app
- Any real third-party integration (payment, verification, access, notifications, maps, invoicing, storage) — stays Future until you explicitly approve a specific one

---

## 3. Project Owner Additions (explicitly tracked, never conflated with PDF-approved scope)

| Addition | Confirmed MVP shape |
|---|---|
| Loyalty | Ledger; earn from completed bookings; redeem against bookings only; no expiration; no tiers |
| Ratings & Reviews | 1–5 stars; optional text; eligibility = completed/stayed booking; dashboard moderation only |
| Metronic | Mandatory dashboard UI/design system |
| Stack | Laravel, Vue/Nuxt, Flutter |
| Dummy-first integration policy | Mandatory for all external providers this phase |
| Flutter-only guest auth surface | No separate guest web app |
| Hotel Manager multi-hotel assignment | Confirmed: one manager may hold 1..N hotel assignments |
| Configurable-not-hardcoded posture | Verification thresholds/retry count, cancellation policy, pricing, retention period, loyalty rules — all deferred to configuration |

---

## 4. Domain Map

Unchanged (13 bounded contexts): Identity & Access · Inventory · Reservations · Payments · Identity Verification · Digital Access · Guest Services & Folio · Checkout & Invoicing · Loyalty · Ratings & Reviews · Notifications · Audit & Compliance · Reporting.

---

## 5. Architecture

```
                    Central Admin (Group-wide scope)
                                │
        ┌───────────────────────┼───────────────────────┐
     Hotel A                 Hotel B                  Hotel N
  (own team,              (own team,               (own team,
   own data,               own data,                own data,
   own scope)              own scope)               own scope)
```

- Single modular Laravel monolith, domain-namespaced (`app/Domain/{Context}`), not microservices.
- Every hotel-scoped table carries `hotel_id`. A server-side `HotelScope` resolves access from the **authenticated user's stored `user_hotel_access` records** — never from a client-supplied `hotel_id`, header, or route parameter treated as proof of authorization. A route parameter may *select* which hotel's data to view; the policy layer independently re-verifies the authenticated user actually holds that hotel assignment.
- Group Owner/Manager "all hotels" access is an explicit, policy-checked bypass path, not a relaxed/missing scope.
- `user_hotel_access` is a **many-to-many pivot** (`user_id`, `hotel_id`) — supports R56 (a Hotel Manager assigned to 1..N hotels) without any special-casing.
- RBAC + hotel scope are enforced exclusively at the **application/domain layer** (Policies, Form Requests, domain services) — the UI (Dashboard/Flutter) only reflects what the API already permits; it is never a security boundary.
- Three frontend clients — Public Nuxt (anonymous discovery), Dashboard Nuxt+Metronic (authenticated staff), Flutter (authenticated guest) — all consume the same `/api/v1`, zero duplicated business logic on any client.

---

## 6. ERD

### 6.1 Explicit entity distinctions (per your guardrail #2)

| Entity | Definition | Key relationships |
|---|---|---|
| **Hotel** | A single physical property belonging to a Hotel Group. Owns its Room Types, Physical Rooms, staff assignments, Services catalog, cancellation-policy config, and pricing config. | `hotel_group_id`; has many Room Types, Rooms, Reservations, Services, Reviews |
| **Room Type** | A *category/class* of accommodation within one Hotel (e.g. "Deluxe Double," "Suite"). Carries base price, capacity, amenities, description. Represents a class of inventory, not an individually addressable unit. | belongs to Hotel; has many Physical Rooms |
| **Physical Room** | An individually addressable room unit within a Hotel, belonging to exactly one Room Type. Carries a room number and an **operational status** (`available` / `booked` / `under_maintenance`) used for housekeeping/ops visibility regardless of the booking model chosen. | belongs to Room Type (and transitively to Hotel) |
| **Availability** | The computed answer to "can this be booked for this date range?" Its definition depends on the booking-model decision in §6.2 (still open): either (a) a count of unbooked Physical Rooms within a Room Type, or (b) a specific Physical Room's free/occupied calendar. | derived, not a stored entity by itself (may be cached/materialized later for performance) |
| **Booking / Reservation** | A Guest's confirmed or in-progress intent to occupy inventory for a date range. Always references `hotel_id` and `room_type_id`. May or may not reference a specific `room_id` at creation time, depending on §6.2. | belongs to Guest, Hotel, Room Type; optionally Physical Room; has one Payment record, one Verification session, one Access grant, one Folio, at most one Review |
| **Guest / Customer** | The person-account making bookings — distinct from staff `Users` (Group Owner/Hotel Manager/Reception, who are internal accounts with role/permission assignments). A Guest has many Reservations, one Loyalty Account, many Reviews. | separate table/auth guard from staff `users` |

### 6.2 Room-vs-Room-Type booking model — **[OPEN]**

Per your guardrail #3, here are the three options, re-checked against the document text (unchanged conclusion from the prior round — the document still does not resolve this):

- **(A) Specific-Physical-Room booking:** the guest books an exact room; availability is a per-room calendar.
- **(B) Room-Type/category booking with later physical-room allocation:** the guest books a class of room; a specific Physical Room is assigned by staff (or by a system rule) at or before check-in; availability is a count against Room-Type capacity.
- **(C) Hybrid/allocation model:** Room Type is always required at booking; Physical Room assignment is optional at booking time and can happen later — the same schema supports either (A) or (B) as an *operating mode* per hotel, without a schema change.

**This remains genuinely unresolved and is not being decided here.** The recommended default schema (Option C shape) keeps the door open in both directions:

```
room_types   (id, hotel_id, name, base_price, capacity, amenities, description)
rooms        (id, room_type_id, hotel_id, room_number, status[available|booked|under_maintenance])

reservations (id, hotel_id, room_type_id NOT NULL, room_id NULLABLE,
              check_in, check_out, status, ...)
```

This is a **[OPEN]** item — flagged again in §19 — and must be explicitly decided by you before the `reservations`/`rooms` migrations are finalized (i.e., before Phase 2, not before Phase 1).

### 6.3 Concurrency / double-booking protection (per guardrail #4)

Regardless of which mode (A) or (B) is eventually chosen, the architecture requires:
- A database-level exclusion/uniqueness constraint preventing two overlapping date ranges from being confirmed against the same inventory unit (a specific `room_id` in mode A, or a capacity-counted constraint against `room_type_id` in mode B).
- Application-level locking (DB transaction + row lock, or an equivalent atomic check-and-reserve operation) at the moment a reservation moves into `PENDING`, so two simultaneous booking attempts cannot both succeed — this directly satisfies the document's edge case R36 ("lock the slot on first attempt").
- Availability must be **re-validated inside the same transaction that creates/confirms the reservation** — never trusted from an earlier read (e.g., a stale "available" response shown in the app 30 seconds ago).

### 6.4 Remaining entities (unchanged from prior drafts)
`reservation_guests`, `payments`/`payment_transactions`, `verification_sessions`/`verification_attempts`/`verification_decisions`, `access_grants`, `hotel_services`/`service_orders`/`guest_folios`/`guest_charges`, `checkout_sessions`/`invoices`/`invoice_lines`, `loyalty_accounts`/`loyalty_transactions`/`loyalty_rules`, `reviews`/`review_moderation_logs`/`hotel_rating_aggregates`, `audit_logs`, `hotel_cancellation_policies` (new — field shape only, see §12), `user_hotel_access` (pivot, §5).

---

## 7. RBAC / Permissions

Enforced exclusively at application/domain level (guardrail #6) — Policies + Form Requests + domain-service checks, never UI-only.

| Capability | Group Owner/Manager | Hotel Manager (1..N hotels) | Reception | Guest |
|---|---|---|---|---|
| All-hotels visibility & management | ✅ | ❌ (assigned hotels only) | ❌ | ❌ |
| Room/booking management | ✅ all | ✅ assigned hotel(s) | view + manual-assist, own hotel | own bookings only |
| Financial edit/delete | ✅ | ⚠️ assigned hotel(s), no delete | ❌ | ❌ |
| Review/decide pending verification | ✅ | ✅ | ✅ | ❌ |
| Issue/revoke digital access | ✅ | ✅ | manual-assist, logged | system-issued only |
| Moderate review status (never content/score) | ✅ | ✅ (own hotel's reviews) | ❌ | ❌ |
| Configure loyalty/cancellation/pricing/verification-threshold rules | ✅ | ❌ | ❌ | ❌ |
| Cross-hotel comparison reports | ✅ | ❌ | ❌ | ❌ |

`user_hotel_access` (many-to-many) is the single source of truth for "which hotel(s) can this Hotel-Manager/Reception user touch" — resolved server-side on every request.

---

## 8. Booking / Reservation State Machine

```
PENDING ──(deposit hold succeeds)──► DEPOSIT_HELD ──(verification passes)──► VERIFIED
   │                                                                            │
   └──(hold fails/timeout)──► CANCELLED                          (access issued)▼
                                                                            CHECKED_IN
                                                                                 │
                                                                             IN_STAY
                                                                                 │
                                                                    CHECKOUT_IN_PROGRESS
                                                                          │           │
                                                              (settlement OK)   (settlement fails)
                                                                          ▼           ▼
                                                                    CHECKED_OUT   CHECKOUT_BLOCKED
                                                                          │        (staff-resolved)
                                                                          ▼
                                                                      INVOICED

Any of PENDING / DEPOSIT_HELD / VERIFIED → CANCELLED (guest/staff, per hotel cancellation policy)
```

Explicit allowed transitions only (guardrail #7) — every arrow above is the complete transition table; any other transition attempt is rejected server-side. Hard rules preserved: `CHECKED_IN` requires **both** payment-confirmed and `VERIFIED`; room/inventory lock applied the instant `PENDING` is entered (§6.3).

---

## 9. Payment State Machine (dummy-provider-driven)

```
NOT_STARTED → HOLD_REQUESTED ─┬─► HOLD_ACTIVE → CAPTURE_REQUESTED ─┬─► CAPTURED
                               └─► HOLD_FAILED                      └─► CAPTURE_FAILED (blocks CHECKED_IN)

CAPTURED → FINAL_SETTLEMENT_REQUESTED ─┬─► SETTLED (terminal)
                                        └─► SETTLEMENT_FAILED (blocks checkout)

Any state → REFUND_REQUESTED ─┬─► REFUNDED
                               └─► REFUND_FAILED
```

- `DummyPaymentGateway` deterministically simulates every branch (initiated/pending/success/failure/cancelled/expired + a simulated async webhook callback hitting the exact same handler code a real webhook would).
- Provider-agnostic: `PaymentGatewayInterface` is the only thing domain code depends on; `PAYMENT_PROVIDER=dummy` is the only binding registered this phase.
- Webhook handling is idempotent by provider transaction reference, regardless of provider.

---

## 10. Identity Verification State Machine (dummy-provider-driven, provider-agnostic)

```
NOT_STARTED → DOCUMENT_UPLOADED → SELFIE_CAPTURED (live capture only) → MATCHING_IN_PROGRESS
                                                                              │
                    ┌─────────────────────┬───────────────────────────────────┼──────────────┐
              score ≥ HIGH          score in MEDIUM/LOW band              provider error   
                    ▼                        ▼                                 ▼
             AUTO_APPROVED          PENDING_MANUAL_REVIEW                RETRY_ALLOWED
             (terminal)                 │          │
                                STAFF_APPROVED  STAFF_REJECTED
                                (terminal)          │
                                              (retry, if under configured retry-count limit)
                                                     ▼
                                          DOCUMENT_UPLOADED (new attempt)
```

- **HIGH/MEDIUM/LOW confidence bands are configuration values** (`config('verification.thresholds')` or an equivalent DB-backed settings table) — never hardcoded in domain code, satisfying R57.
- **Retry count is configurable** (`config('verification.max_retries')`) — once exceeded, the reservation is routed to `PENDING_MANUAL_REVIEW` permanently rather than allowing further auto-retry (still human-resolvable, never a hard dead-end).
- Manual review is always reachable — no code path allows a hard auto-reject that bypasses staff review, preserving the document's explicit rule.
- `DummyIdentityVerificationProvider` can simulate every named outcome (document submitted, selfie submitted, processing, high/medium/low match, failed, manual review required, approved, rejected, retry) via deterministic test triggers.

---

## 11. Digital Access State Machine (dummy-provider-driven, provider-agnostic)

```
NOT_ISSUED ──(eligibility met: payment confirmed + verified + correct time window)──► ISSUED (active)
                                                                                            │
                                        ┌───────────────────────────────────────────────────┤
                              (stay end reached, auto)                          (staff/system, any time)
                                        ▼                                                    ▼
                                    EXPIRED (terminal)                                   REVOKED (terminal)
```

- `access_mode` field distinguishes `pin_code` (the initial dummy implementation, per your instruction — an app-delivered code) from `smart_lock` (future, same interface, different adapter) — no schema change needed to switch later.
- Eligibility rules (payment + verification + time window) live entirely in the application/domain layer, never inside the provider adapter — the dummy provider only simulates the external credential lifecycle (creation, activation, validation, expiration, revocation, failure).
- Access validity is **re-checked server-side at every access attempt**, never trusted from a cached client-side flag.

---

## 12. Checkout State Machine

```
NOT_ELIGIBLE → ELIGIBLE → CHARGES_LOCKED → SETTLEMENT_IN_PROGRESS ─┬─► INVOICE_GENERATION → COMPLETE
                                                                     └─► BLOCKED (staff-resolved fallback)
```

Cancellation-policy note (per your §4 this round): a `hotel_cancellation_policies` table exists with a **field shape only** — e.g. `notice_period_hours`, `penalty_type[percentage|flat|none]`, `penalty_value` — but **no default values are populated or hardcoded**; each hotel's policy is configured explicitly by an authorized admin before it can affect a real cancellation flow. The booking domain reads this config at cancellation time rather than embedding any rule directly in code, so future policy variations (e.g. tiered by notice window) don't require redesigning the booking state machine.

---

## 13. Loyalty Model

- `loyalty_accounts`: one per Guest, group-wide (not per-hotel).
- `loyalty_transactions`: append-only ledger. Types: `earn`, `redeem`, `reverse`, `adjust` (`expire` reserved in the enum for painless future activation, but unused in MVP per "no expiration").
- **MVP capabilities:** earn points from an eligible **completed** booking; view balance (derived from the ledger, may be cached but ledger is authoritative — guardrail #8); view transaction history; redeem points **against an eligible booking only** — no folio/service redemption (explicitly deferred).
- `loyalty_rules`: exists as a configurable table (earn rate, eligible source types, redemption conversion rate) — **no values invented**; must be populated by an admin before go-live.
- No tiers, no expiration, no multi-rule stacking in MVP.

---

## 14. Ratings & Reviews Model

- `reviews`: `reservation_id` (unique — one review per eligible completed/stayed booking, guardrail #9), `customer_id`, `hotel_id`, `rating` (integer 1–5, required), `body` (optional), `status[pending|approved|rejected]`.
- **Eligibility:** only a Guest whose Reservation reached a terminal completed/stayed state (`CHECKED_OUT`/`INVOICED`) may submit a review for that reservation — server-enforced.
- **Duplicate prevention:** DB unique constraint on `reservation_id`.
- **Moderation:** dashboard capability for Hotel Manager (own hotel) / Group Owner (all) to change `status` only. The guest's `rating` and `body` are immutable once submitted — staff cannot edit content or score.
- **No additional moderation rules invented** (no auto-flagging, no reviewer reputation, no appeal workflow) — none of this is documented or requested, per your explicit instruction not to invent beyond what's specified.
- `hotel_rating_aggregates`: recomputed from `approved` reviews only.

---

## 15. Dummy Integration Architecture

| Interface | Dummy Implementation | Simulated states |
|---|---|---|
| `PaymentGatewayInterface` | `DummyPaymentGateway` | initiated, pending, success, failure, cancelled, expired, webhook callback |
| `IdentityVerificationProviderInterface` | `DummyIdentityVerificationProvider` | document submitted, selfie submitted, processing, high/medium/low match, failed, manual review, approved, rejected, retry |
| `AccessControlProviderInterface` | `DummyAccessControlProvider` (mode: `pin_code` now, `smart_lock`-ready) | creation, activation, validation, expiration, revocation, failure |
| `NotificationProviderInterface` (email/SMS/push, one adapter per channel) | `DummyEmailProvider`, `DummySmsProvider`, `DummyPushProvider` | event logged internally to `notification_events`; no external call |

**Governing rules (guardrail #10, all four confirmed):**
- Config-driven selection, dummy is the default and only registered implementation this phase:
  ```
  PAYMENT_PROVIDER=dummy
  IDENTITY_PROVIDER=dummy
  ACCESS_PROVIDER=dummy
  NOTIFICATION_PROVIDER=dummy
  ```
- Domain services (`PaymentService`, `VerificationService`, `AccessService`, notification dispatch) depend only on the interface — swapping to a real provider later is a new adapter class + a container-binding change, with **zero change to domain/business logic**.
- What stays fully real regardless of dummy mode: all state-machine transitions, all authorization/policy checks, all database writes/ledger entries/audit logs, all business eligibility rules (e.g., access is never issued without real payment + real verification state — only the *external confirmation* is simulated).
- No real API keys, secrets, or production endpoints introduced this phase.

---

## 16. API Architecture

Unchanged endpoint map (versioned REST, `/api/v1`, JSON, API Resources, Form Request validation, Policy authorization, standard status codes, pagination/filtering/sorting on list endpoints):

```
/api/v1/auth/*
/api/v1/hotel-group/hotels        /api/v1/hotels/{hotel}/rooms        /api/v1/hotels/{hotel}/room-types
/api/v1/availability
/api/v1/reservations, /{id}, /{id}/cancel
/api/v1/payments/{reservation}/{hold|capture}, /api/v1/payments/webhooks/{provider}
/api/v1/identity-verification/{reservation}/{documents|selfie|status|review}
/api/v1/check-in/{reservation}
/api/v1/access/{reservation}, /{reservation}/revoke
/api/v1/hotels/{hotel}/services, /api/v1/reservations/{reservation}/service-orders
/api/v1/checkout/{reservation}, /api/v1/invoices/{reservation}
/api/v1/loyalty/{account|transactions|redeem}
/api/v1/hotels/{hotel}/reviews (public, approved only), /api/v1/reservations/{reservation}/review, /api/v1/reviews/{review}/moderate
/api/v1/reports/{occupancy|revenue|hotel-comparison}
```

Webhook endpoints (`/api/v1/payments/webhooks/{provider}` where `{provider}=dummy` this phase) are signature-verified and idempotent regardless of provider — identical code path whether dummy or real later.

---

## 17. Security

- ID documents/selfies: private storage, short-lived signed URLs only, never a public path.
- Payment data: never persisted in full; only provider references/tokens stored.
- Authorization: Policies/Gates on every write and sensitive read; hotel scope resolved server-side only (guardrail #6).
- Audit: every access-data read/write and every moderation/financial action logged (actor, action, before/after, sensitive fields redacted).
- Access expiration: enforced server-side at time-of-use, not just at issuance.
- Webhooks: signature-verified, idempotent by provider transaction reference.
- Rate limiting on auth, verification-upload, and payment endpoints.
- No internal exception detail exposed in production responses.
- Identity data retention: **configurable**, not hardcoded (R58) — a scheduled cleanup job reads a retention-period config value (currently unset/placeholder) rather than a baked-in number.

---

## 18. Testing Strategy

| Layer | Focus |
|---|---|
| Unit | State-machine transition guards (§8–§12, guardrail #7 — every transition explicit, every non-listed transition rejected); loyalty ledger math; rating aggregate calculation |
| Feature/API | Every endpoint: auth required, policy enforcement, validation errors, correct status codes, hotel-scope isolation (a Hotel-A manager token must never read Hotel-B data, even across their own multiple assigned hotels vs. an unassigned one) |
| Integration | Dummy payment webhook idempotency (double-fire → single effect); dummy verification provider contract tests covering every confidence band and retry-limit boundary; dummy access provider lifecycle (issue/validate/expire/revoke) |
| Security/Authorization | Every write endpoint attempted with an unauthorized role → 403; cross-hotel access attempts → 403/404; Reception attempting financial edit/delete → 403 |
| Business-critical scenarios | Concurrent double-booking prevention (§6.3); payment failure never produces `CHECKED_IN`; digital access denied before both payment+verification complete; checkout blocked on settlement failure with a staff-resolvable state; duplicate review rejected; loyalty balance never mutated without a ledger row; verification retry-limit routes to permanent manual review, never a dead-end |
| Regression | Golden-path guest journey (Discovery → Invoice) as an end-to-end feature test, using dummy providers throughout |

Every dummy adapter scenario is deterministic/test-selectable — never randomized — so CI can assert every branch.

---

## 19. Implementation Roadmap

Unchanged phase sequence:
`Phase 1 Foundation/RBAC/HotelGroup/Hotels/Users/Roles/Permissions → 2 Rooms/Availability (blocked on §6.2 decision) → 3 Discovery APIs → 4 Reservations → 5 Payments (dummy) → 6 Identity Verification (dummy) → 7 Digital Access (dummy) → 8 Services/Folio → 9 Checkout/Invoices → 10 Loyalty → 11 Ratings/Reviews → 12 Notifications (dummy) → 13 Central Dashboard (Metronic) → 14 Hotel Dashboard → 15 Nuxt Public Site → 16 Flutter App → 17 Reports/Audit/Hardening → 18 QA/Security/Perf/Deploy/Docs`

**Phase 1 can begin immediately upon your authorization** — it does not touch reservations/rooms and is unaffected by the §6.2 open item. Phase 2 must not start until §6.2 is resolved.

---

## 20. Open Questions — Genuinely Unresolved

| # | Item | Status |
|---|---|---|
| 1 | **Room-vs-Room-Type booking model** (§6.2) — the document does not conclusively answer this, and this round's instructions did not resolve it either | **[OPEN]** — blocks Phase 2, not Phase 1 |
| 2 | Verification confidence threshold **numeric values** (only the fact that they must be configurable is confirmed — actual default numbers are not) | **[OPEN]** — blocks Phase 6 config, not Phase 1 |
| 3 | Verification retry-count **numeric limit** (confirmed configurable; number not specified) | **[OPEN]** — blocks Phase 6 config, not Phase 1 |
| 4 | Cancellation policy **field values** per hotel (field shape is defined in §12; actual notice periods/penalty values are not) | **[OPEN]** — blocks real cancellation behavior in Phase 4, not the schema itself |
| 5 | Identity data retention **period value** (confirmed configurable; number not specified) | **[OPEN]** — blocks Phase 6 production behavior, not Phase 1 |
| 6 | Loyalty earn rate / redemption conversion rate values | **[OPEN]** — blocks a fully realistic Phase 10 demo; ledger/schema itself is unaffected |
| 7 | Real payment gateway selection | **[OPEN]**, explicitly deferred to Future by your instruction — not expected to resolve soon |
| 8 | Real identity verification/biometric provider selection | **[OPEN]**, deferred to Future |
| 9 | Real digital access/smart-lock vendor, or PIN-only confirmed as permanently final | **[OPEN]**, deferred to Future |
| 10 | Exact licensed Metronic version/package | **[OPEN]** — blocks Phase 13, not Phase 1 |

No answer has been invented for any of the above, per your instruction.

---

## Summary — status and next step

- Phase 0 is approved.
- All 12 confirmed-decision areas from your latest instructions are reflected above.
- Exactly **one item blocks Phase 2** (§6.2/§20 item 1); **nothing blocks Phase 1**.
- No code, migrations, packages, or scaffolding of any kind have been created.

Waiting for your explicit authorization to begin **Phase 1: Laravel Foundation — Database, Authentication, RBAC, Hotel Group, Hotels, Users, Roles, Permissions.**
