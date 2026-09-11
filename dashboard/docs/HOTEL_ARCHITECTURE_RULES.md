# Hotel Management System — Architecture Rules

## 1. Core Architecture

This project must follow:

- OOP
- Repository Pattern
- Service Pattern
- Controller Layer
- Form Request Validation
- API Resource / Response Card formatting
- State Machine Pattern for important workflows
- Provider / Adapter Pattern for replaceable third-party integrations
- Policy / Permission based authorization
- Automated testing
- Clear separation between Backend API, Dashboard, and Guest Mobile App

The architecture must keep business rules centralized in the Laravel backend.

The backend is the authoritative source for:

- availability
- reservations
- pricing
- payment state
- identity verification state
- digital access eligibility
- hotel services
- folio/accounting calculations
- checkout
- invoices
- loyalty accounting
- review eligibility/moderation
- permissions
- hotel scope
- audit history

Frontend and mobile applications may validate for UX, but must never become the authority for business correctness.

---

## 2. Technology Baseline

### Backend

- Laravel / PHP
- MySQL or MariaDB-compatible relational database
- Eloquent ORM
- REST API
- API prefix: `/api/v1`
- Laravel Sanctum for authenticated application users where applicable
- Queues / Jobs / Events / Notifications where justified

### Dashboard

- Nuxt 3 / Vue
- Pinia where state management is required
- Metronic-compatible structure
- Responsive desktop/tablet/mobile UI
- Arabic / English
- RTL / LTR
- Hotel System visual identity
- Tajawal for Arabic UI where the design system specifies it

### Guest Mobile

- Flutter
- Clean separation between presentation, state, domain/application, and data/API layers
- API-only production architecture
- No duplicated authoritative business rules

---

## 3. Layer Responsibilities

### Controllers

Controllers are responsible for:

- receiving HTTP requests
- delegating to Form Requests for validation
- calling application/domain services
- returning HTTP responses
- using API Resources / Response Cards
- translating domain/application outcomes into HTTP semantics

Controllers must NOT:

- contain business logic
- access Eloquent models directly
- execute direct database queries
- calculate authoritative prices/totals
- implement state-machine rules
- perform duplicated authorization logic
- contain large validation blocks
- call external providers directly when an abstraction exists

---

## 4. Form Requests

Form Requests are responsible for:

- request validation
- authorization where appropriate
- localized validation messages
- normalization of simple request input when appropriate

They must NOT:

- perform database business workflows
- create reservations
- calculate authoritative financial values
- call payment/identity/access providers
- implement domain state transitions

---

## 5. Services

Services are responsible for:

- business logic
- workflow orchestration
- domain decisions
- coordinating repositories
- transactions when required
- calling state machines
- calling provider abstractions
- enforcing application use cases
- composing domain operations without exposing HTTP concerns

Services must NOT:

- return HTTP response objects
- depend directly on HTTP controllers
- perform request validation
- access Eloquent models directly
- duplicate repository query logic
- expose provider implementation details to controllers

---

## 6. Repositories

Repositories are responsible for:

- all database access
- all Eloquent model interaction
- query construction
- persistence
- eager loading
- scoped lookup
- pagination/query composition
- row locking where required by a critical workflow

Repositories must NOT:

- contain business decisions
- perform request validation
- return HTTP responses
- decide whether a workflow transition is allowed
- call external providers

Preferred flow:

`Controller → Form Request → Service → Repository → Model`

For dashboard:

`Nuxt Page/Component → Composable/API Service → Laravel API → Controller → Service → Repository → Model`

For mobile:

`Flutter Presentation → State/Application → Repository → Data Source → Laravel API`

---

## 7. Models

Models represent entities and relationships.

Allowed:

- relationships
- casts
- scopes
- accessors/mutators
- small entity helpers
- constants describing stable vocabulary

Avoid:

- heavy business workflows
- payment orchestration
- authorization decisions
- provider calls
- complex calculations
- direct external integrations

---

## 8. Non-Negotiable Architecture Rules

- No direct model calls in controllers.
- No direct model calls in services.
- Eloquent models are accessed through repositories.
- No HTTP responses outside controllers.
- No large validation rules inside controllers.
- Business logic belongs in services/domain classes.
- State transition rules belong in state machines.
- External integrations belong behind interfaces/adapters.
- API and Dashboard responsibilities remain separated.
- API and Mobile business logic must not be duplicated.
- Dashboard must not become a second business engine.
- Frontend permissions are UX only; Laravel remains authoritative.
- Client-provided `hotel_id`, `user_id`, `role`, `permission`, or paid flags must never be trusted for authorization or business correctness.
- Critical financial and reservation workflows must be transactional and retry-safe.
- Important callbacks/webhooks must be idempotent.
- Unrelated code must not be changed during focused work.

---

## 9. Response System

The API must use a consistent response system.

Use:

- shared response trait/helpers
- API Resources
- Response Cards where appropriate
- consistent success/error envelopes
- localized messages

Do not return inconsistent ad-hoc JSON structures from different controllers.

Resources should expose only the data appropriate to the consumer.

Sensitive/internal information must not leak through public/customer resources.

---

## 10. API Architecture

The Laravel API should be organized around:

- Controllers
- Form Requests
- Resources / Response Cards
- Services
- Repositories
- Policies / permission checks
- State Machines
- Events / Listeners
- Provider Interfaces / Adapters
- Shared response and security infrastructure

Base API path:

`/api/v1`

Customer/Guest APIs must be explicitly guest-scoped.

Dashboard/staff APIs must enforce role/permission and hotel scope.

Do not make a staff endpoint guest-accessible merely because mobile needs the same information. Add a proper guest-facing contract when required.

---

## 11. Dashboard Architecture

The Hotel Dashboard is a single unified Nuxt application.

Do NOT create separate codebases for:

- Central Dashboard
- Hotel Dashboard

Instead, use one dashboard whose capabilities change according to:

- authenticated user
- role
- permissions
- hotel assignments
- selected hotel context

Conceptual flow:

`Dashboard Page/Component → Composable/API Service → Laravel API`

The Dashboard must not contain Laravel business rules.

The Dashboard may provide:

- filters
- forms
- optimistic UX only when safe
- loading/empty/error states
- permission-based visibility
- hotel context selection
- table interactions
- client-side presentation formatting

The Dashboard must NOT:

- calculate authoritative reservation availability
- calculate authoritative invoice totals
- decide payment success
- approve identity verification without backend authorization
- issue digital access directly
- mutate loyalty balances directly
- bypass backend policies

---

## 12. Metronic and Dashboard UI

The dashboard must use a shared Metronic-compatible layout containing:

- persistent sidebar
- header
- toolbar/breadcrumb
- content wrapper
- standard page headers
- standard table/action patterns

The sidebar must be rendered by the shared layout only.

Use the existing licensed/available Metronic implementation rather than inventing a second design system.

Hotel visual identity should align with the approved Hotel System design:

- warm brown
- bronze/gold accent
- cream/paper surfaces
- warm neutrals
- restrained borders
- soft shadows
- Tajawal Arabic typography
- Arabic RTL and English LTR

---

## 13. Authentication and Authorization

Authorization is server-side.

Minimum business roles:

- Group Owner / Group Manager
- Hotel Manager
- Reception
- Guest

Rules:

### Group Owner / Group Manager

May have group-wide access according to assigned permissions.

### Hotel Manager

May access only assigned hotels and only permitted operations.

### Reception

Operational hotel access only according to permissions.

Reception must not automatically receive unrestricted access to:

- financial administration
- role management
- permission management
- group-wide settings
- unrelated hotel data

### Guest

May access only their own:

- profile
- reservations
- payments
- identity verification
- digital access
- service requests
- invoices
- loyalty
- reviews
- notifications

Never trust authorization data from the client.

---

## 14. Hotel Scope

The platform hierarchy is:

`Hotel Group → Hotels → Hotel-scoped resources`

Central/group-level users may operate across the group when authorized.

Hotel-level users must be restricted to assigned hotels.

Guest resources must be scoped to the authenticated guest.

Cross-hotel access must be rejected.

Do not rely only on a frontend hotel selector.

---

## 15. State Machines

Important workflows must be state-driven.

### Reservation

Approved lifecycle:

`PENDING → DEPOSIT_HELD → VERIFIED → CHECKED_IN → IN_STAY → CHECKOUT_IN_PROGRESS → CHECKED_OUT → INVOICED`

Cancellation may occur from:

- PENDING
- DEPOSIT_HELD
- VERIFIED

Failure/timeout branches may lead to:

`CANCELLED`

`CHECKOUT_BLOCKED` is a preserved safe branch for checkout failure and is terminal until a future approved recovery rule exists.

### Payment

Core lifecycle:

`NOT_STARTED → HOLD_REQUESTED → HOLD_ACTIVE → CAPTURE_REQUESTED → CAPTURED → FINAL_SETTLEMENT_REQUESTED → SETTLED`

Failure/refund/cancel/expired branches must follow the approved payment state machine.

### Identity Verification

Core states include:

- NOT_STARTED
- DOCUMENT_UPLOADED
- SELFIE_CAPTURED
- MATCHING_IN_PROGRESS
- AUTO_APPROVED
- PENDING_MANUAL_REVIEW
- RETRY_ALLOWED
- STAFF_APPROVED
- STAFF_REJECTED

### Digital Access

Access must be:

- reservation-bound
- scope-bound
- expirable
- revocable
- auditable

### Service Order

`REQUESTED → CONFIRMED → FULFILLED`

and:

- REQUESTED → CANCELLED
- CONFIRMED → CANCELLED

### Checkout

Checkout must be state-driven and safe to retry.

Invalid transitions must be rejected by the backend.

---

## 16. Reservation / Availability Rules

Room architecture is hybrid:

- Room Type = category/product definition
- Room = physical inventory unit

Reservation requires:

- hotel_id
- room_type_id
- guest_id
- check_in
- check_out
- status
- price_snapshot

`room_id` is nullable because a room type may be reserved before a physical room is assigned.

Checkout date is exclusive.

Required rule:

`existing.check_in < new.check_out AND new.check_in < existing.check_out`

All reservation statuses except `CANCELLED` block inventory.

When a physical room is selected, use appropriate locking and recheck overlap.

When room_id is not selected, validate room-type capacity against overlapping blocking reservations.

Never trust frontend availability alone.

---

## 17. Payment Architecture

Payment is business-critical.

Use:

`PaymentWorkflowService → PaymentGatewayInterface → Provider Adapter`

Default provider is Dummy.

The domain must support future replacement with a real provider without rewriting reservation/business workflows.

Required concerns:

- initiation
- pending
- success
- failure
- cancellation
- expiration
- webhook/callback
- verification
- provider reference
- idempotency
- reconciliation
- audit
- safe retries

Never store card data.

Never trust a client-side paid flag.

Historical payment amounts must not be overwritten by later folio totals.

---

## 18. Third-Party Provider Rule

Default integrations are dummy implementations.

Examples:

- `DummyPaymentGateway`
- `DummyIdentityVerificationProvider`
- `DummyAccessControlProvider`
- `DummyNotificationProvider`

Provider implementations must be deterministic for tests.

The business domain must depend on interfaces, not concrete vendors.

Before replacing a dummy provider with a real provider, explicitly approve:

1. business workflow
2. state machine
3. API contract
4. provider
5. integration contract
6. security
7. errors
8. retries
9. webhooks/callbacks
10. production credentials/configuration

---

## 19. Identity Security

Identity documents and selfies are sensitive.

Requirements:

- private storage
- authorization before access
- signed/private URLs where appropriate
- secure retention/cleanup strategy
- audit trail
- throttling
- no sensitive values in logs
- no public storage URLs

Identity verification provider must remain replaceable.

---

## 20. Digital Access Security

Digital access credentials must:

- belong to the correct reservation
- belong to the correct hotel/access scope
- expire
- be revocable
- be auditable
- remain unavailable before eligibility conditions are satisfied
- not be exposed to unauthorized users

Provider failure must not silently create a valid access state.

---

## 21. Services and Folio

Hotel services belong to the correct hotel and reservation/stay context.

Service orders may generate charges.

The folio must account for:

- accommodation charge
- confirmed service charges
- eligible additional charges
- captured/settled payments
- outstanding balance

Do not build a full ERP/POS/accounting system unless explicitly required.

Accounting calculations must live in the backend.

---

## 22. Checkout and Invoice

Checkout must:

- validate reservation state
- calculate authoritative folio through the backend
- include accommodation
- include eligible service/additional charges
- account for previous captured/settled payments
- perform final settlement only when required
- be retry-safe
- generate a deterministic invoice
- preserve an auditable snapshot

A failed/pending settlement must not incorrectly mark a reservation final.

Do not overwrite historical payment amounts.

No duplicate invoice/charge should be created by a retry.

---

## 23. Loyalty

Loyalty is group-wide.

A guest has one loyalty account at group level, not one account per hotel.

Use an immutable ledger.

Supported transaction vocabulary includes:

- earn
- redeem
- reverse
- adjust
- expire

MVP implements only approved earning/redemption behavior.

Rules must be configurable.

No points balance mutation without a corresponding ledger transaction.

Do not invent:

- earning rates
- redemption rates
- expiry periods
- tiers
- stacking rules

unless explicitly approved.

---

## 24. Ratings and Reviews

Reviews belong to an eligible stay/reservation.

Support:

- rating 1–5
- optional written text
- reservation reference
- guest reference
- hotel reference
- moderation state
- approved/published state
- rejected state
- rating average/count

Prevent:

- unauthorized reviews
- duplicate submissions
- public display of unapproved reviews
- hotel staff directly changing customer ratings

Moderation must be authorized and audited.

---

## 25. Notifications

Notifications are reusable and provider-independent.

Potential channels:

- in-app
- push
- email
- SMS

Only implement channels justified by approved requirements.

Relevant events may include:

- reservation created
- payment success/failure
- identity requested/approved/rejected
- digital access issued
- check-in
- service update
- checkout
- invoice generated
- loyalty points earned/redeemed
- review reminder

Notification delivery should be idempotent and queueable where appropriate.

---

## 26. Audit Logging

Important actions must be auditable.

Audit records should capture where appropriate:

- actor
- hotel scope
- action
- entity
- entity identifier
- timestamp
- relevant safe metadata

Never log:

- payment secrets
- card data
- identity documents
- access secrets
- authentication secrets

Reuse the existing audit infrastructure instead of creating parallel audit systems.

---

## 27. Database Rules

Use a normalized relational schema.

Before creating migrations:

- inspect existing schema
- inspect foreign keys
- inspect indexes
- inspect enum/status conventions
- inspect deletion behavior
- inspect existing data dependencies

Use appropriate:

- foreign keys
- unique constraints
- composite indexes
- decimal money fields
- timestamps
- nullable fields only where semantically justified

Do not introduce redundant tables or duplicate concepts.

Use soft delete only where appropriate. Do not automatically add soft deletes to financial/payment/audit tables.

---

## 28. Financial Safety

Financial modules include:

- payments
- payment transactions
- folio charges
- checkout settlement
- invoices
- loyalty redemption where value is involved

Rules:

- use DECIMAL for money
- never FLOAT/DOUBLE for monetary values
- preserve historical snapshots
- use idempotency
- use transactions and locks where needed
- never silently rewrite historical financial records
- do not auto-refund or create credit behavior unless explicitly approved
- audit financial state changes
- prevent duplicate charges/settlements

---

## 29. Filtering and Pagination

Dashboard lists should support appropriate filtering.

Filters must be enforced server-side where they affect authorization or large datasets.

Client-side filtering may be used only as presentation behavior for already-authorized loaded data.

Preserve endpoint-specific pagination behavior unless explicitly changing the contract.

---

## 30. Localization

Support:

- Arabic
- English
- RTL
- LTR

Do not hardcode user-facing text in one language.

Validation messages must be localized.

API Resources should follow the project's localization strategy.

Dashboard and mobile strings must be translation-ready.

Use Tajawal for Arabic UI where the approved design system requires it.

---

## 31. Error Handling

Use meaningful domain/application exceptions.

Business failures should be represented consistently.

Do not return raw strings from services.

Controllers map exceptions to standardized API responses.

Do not expose internal stack traces or sensitive exception details in production.

---

## 32. Testing

Testing is mandatory.

Important tests include:

- authorization
- cross-hotel isolation
- guest ownership
- availability
- concurrent double-booking prevention
- state transitions
- payment success/failure/pending/cancelled/expired
- webhook idempotency
- late payment reconciliation
- identity verification outcomes
- digital access eligibility
- service order lifecycle
- folio calculations
- checkout settlement safety
- invoice determinism
- loyalty ledger integrity
- duplicate review prevention
- notification behavior
- localization where relevant

Business-critical workflows require feature/integration tests in addition to unit tests.

---

## 33. Frontend Rules

Dashboard and mobile must support:

- Arabic / English
- RTL / LTR
- responsive layouts
- accessibility where applicable
- loading states
- empty states
- error states
- skeleton states where appropriate
- proper form validation
- server-side validation display

Frontend validation improves UX.

Backend validation enforces correctness.

Do not implement authoritative business calculations in the frontend.

---

## 34. Engineering Rules

1. Do not over-engineer.
2. Do not create abstractions without a real reason.
3. Do not create unnecessary files.
4. Do not duplicate business logic.
5. Do not hardcode configurable business rules.
6. Do not guess unclear requirements.
7. Do not silently change approved requirements.
8. Do not implement future features without approval.
9. Do not modify unrelated code during focused tasks.
10. Do not bypass validation.
11. Do not bypass authorization.
12. Do not trust frontend state for security decisions.
13. Do not claim something works without verification.
14. Read existing code before modifying it.
15. Preserve good existing conventions.
16. Prefer simple maintainable solutions.
17. Keep business logic testable.
18. Keep integrations replaceable.
19. Keep hotel scope explicit.
20. Keep important workflows state-driven.
21. Use database transactions for critical workflows.
22. Make external callbacks/webhooks idempotent.
23. Do not commit or push unless explicitly requested by the project owner.
24. Never use `git add .` in a repository containing unrelated uncommitted work.

---

## 35. Definition of Done

A feature is complete only when:

- requirements are understood
- architecture is consistent
- database is correct
- authorization is correct
- validation is correct
- API is implemented
- Dashboard is implemented where required
- Mobile is implemented where required
- tests exist
- tests pass
- edge cases are handled
- documentation is updated where needed
- no obvious security issue remains
- no unrelated regression is introduced
- actual verification was performed
