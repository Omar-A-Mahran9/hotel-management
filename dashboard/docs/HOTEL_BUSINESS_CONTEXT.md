# Hotel Management System — Business Context

## 1. Document Purpose

This document is the business reference for the Hotel Management System.

It covers:

- Hotel Group and Hotels
- Guests and authentication
- Room types and physical rooms
- Availability and reservations
- Payments
- Identity verification
- Digital check-in and access
- Hotel guest services
- Folio / guest charges
- Checkout and invoices
- Loyalty
- Ratings and reviews
- Notifications
- Users, roles and permissions
- Audit
- Reporting
- Central and hotel operations
- Guest mobile journey

This document describes what the system does and why.

Technical implementation rules are defined separately in:

- `HOTEL_ARCHITECTURE_RULES.md`
- `CLAUDE_INSTRUCTIONS.md`

---

## 2. Source of Truth Priority

When requirements conflict, use this priority:

1. Explicit current task requirement
2. `HOTEL_BUSINESS_CONTEXT.md`
3. `HOTEL_ARCHITECTURE_RULES.md`
4. `CLAUDE_INSTRUCTIONS.md`
5. Approved Phase 0 baseline / approved project decisions
6. Existing domain specifications and documentation
7. Database schema
8. Existing backend implementation
9. Existing API behavior
10. Dashboard/mobile implementation

Existing code is evidence of current behavior, not automatically the business requirement.

Never silently invent missing business rules.

---

## 3. Product Overview

The platform is a multi-hotel hotel management and guest-experience system.

It has three major application surfaces:

### Laravel Backend API

Authoritative business platform.

### Unified Nuxt/Metronic Dashboard

Used by authorized group and hotel staff.

### Flutter Guest Mobile Application

Used by authenticated guests for the guest journey.

The applications share the same backend business domain but have different responsibilities.

---

## 4. Organization Hierarchy

The core hierarchy is:

`Hotel Group → Hotels`

A hotel contains:

`Room Types → Physical Rooms`

A reservation belongs to:

- hotel
- room type
- optionally physical room
- guest

Group-level features such as loyalty belong to the hotel group rather than a single hotel.

---

## 5. Main Actors

### 5.1 Group Owner / Group Manager

May operate across the hotel group according to permissions.

Potential responsibilities:

- manage hotels
- manage hotel group settings
- manage users/roles/permissions where authorized
- manage group-wide loyalty rules
- view group-wide operational information
- access authorized financial/reporting information

### 5.2 Hotel Manager

May operate only within assigned hotels.

Potential responsibilities:

- rooms/inventory
- reservations
- guests
- services
- operational workflows
- identity review
- digital access operations
- checkout
- invoices
- reviews/moderation where authorized

### 5.3 Reception

Operational hotel role.

Reception access is permission-driven and hotel-scoped.

Reception must not automatically receive unrestricted access to:

- financial administration
- role management
- permission management
- group-wide settings
- other hotels

### 5.4 Guest

A guest may access only their own information and eligible actions:

- profile
- reservations
- payments
- identity verification
- digital check-in/access
- services
- folio
- checkout
- invoices
- loyalty
- reviews
- notifications

---

## 6. Guests and Authentication

A Guest is the customer identity used by the guest-facing mobile experience.

Guest information must be protected.

The guest should be able to:

- authenticate
- maintain profile information
- view own reservations
- perform eligible reservation actions
- submit identity verification
- access digital check-in/access
- request services
- view invoices
- access loyalty
- submit eligible reviews
- receive notifications

Guest ownership must always be resolved from authenticated server-side identity.

The client must not choose another guest by sending `guest_id`.

---

## 7. Hotels

Hotels belong to a Hotel Group.

Hotel management may include:

- name
- location
- status
- branding/media when supported
- room inventory
- services
- operational settings

Hotel images/media must use the approved backend storage/media architecture.

Do not invent media requirements where the backend contract does not yet exist.

---

## 8. Room Types and Rooms

### Room Type

Defines a category of room.

Examples of attributes:

- name
- capacity
- base price
- active status

### Room

Represents a physical room.

Examples:

- room number
- room type
- status

Approved room statuses:

- available
- booked
- under_maintenance

Phase-specific workflows may restrict which transitions are allowed.

Do not add unnecessary room states without approval.

---

## 9. Availability

Availability is a backend business rule.

Reservations overlap when:

`existing.check_in < new.check_out AND new.check_in < existing.check_out`

Blocking reservation statuses are all statuses except:

`CANCELLED`

For a selected physical room:

- lock relevant inventory records
- recheck overlap
- reject if unavailable

For room-type reservations without a room assignment:

- lock room type
- count physical inventory
- count overlapping blocking reservations
- reject when capacity is exhausted

Frontend availability is informational only and must be revalidated during reservation creation.

---

## 10. Reservation

A reservation represents a guest stay request.

Core data includes:

- hotel
- room type
- optional room
- guest
- check-in
- check-out
- status
- price snapshot
- creator/staff reference where applicable
- cancellation information

Check-out date is exclusive.

`check_out > check_in`

Reservation price must be snapshotted.

Never silently recalculate historical reservation price from a later room-type base price.

---

## 11. Reservation State Machine

Approved lifecycle:

`PENDING`
→ `DEPOSIT_HELD`
→ `VERIFIED`
→ `CHECKED_IN`
→ `IN_STAY`
→ `CHECKOUT_IN_PROGRESS`
→ `CHECKED_OUT`
→ `INVOICED`

Cancellation is allowed from:

- PENDING
- DEPOSIT_HELD
- VERIFIED

Hold failure/timeout leads to:

`CANCELLED`

Checkout failure has a safe:

`CHECKOUT_BLOCKED`

branch.

Invalid transitions must be rejected.

Important transitions must be audited.

---

## 12. Booking Flow

Typical guest flow:

`Discovery`
→ `Hotel Selected`
→ `Dates`
→ `Room Selection`
→ `Reservation Initiated`
→ `Payment`
→ `Identity Verification`
→ `Check-in`
→ `Stay`
→ `Services`
→ `Checkout`
→ `Invoice`
→ `Loyalty / Review`

The exact backend state machine is authoritative.

Do not use scattered booleans where a state machine represents the real workflow.

---

## 13. Cancellation

Cancellation behavior is configurable.

Approved cancellation policy structure includes:

- notice period hours
- penalty type
- penalty value

Do not invent default cancellation deadlines or penalty percentages.

Cancellation behavior must be applied by the backend.

---

## 14. Payments

Payment is a business-critical domain.

The platform must support:

- initiation
- pending
- success
- failure
- cancellation
- expiration
- verification
- transaction reference
- idempotency
- webhook/callback
- reconciliation
- audit

Never trust frontend payment status.

No card data should be stored.

Payment provider is configurable and initially dummy.

---

## 15. Payment State Machine

Core lifecycle:

`NOT_STARTED`
→ `HOLD_REQUESTED`
→ `HOLD_ACTIVE`
→ `CAPTURE_REQUESTED`
→ `CAPTURED`
→ `FINAL_SETTLEMENT_REQUESTED`
→ `SETTLED`

Failure/cancellation/refund/expiration branches follow the approved payment specification.

Important accounting rule:

Historical `Payment.amount` represents its own historical payment amount and must not be overwritten with a later folio total.

Final settlement must consider:

`authoritative final total - previously captured/settled amount`

Do not automatically create refunds or credits unless the approved workflow explicitly requires them.

---

## 16. Identity Verification

Identity verification is a core requirement.

Guest flow may include:

1. document upload
2. selfie capture/upload
3. matching
4. confidence/result
5. automatic approval where threshold permits
6. manual review where required
7. retry where permitted
8. final staff decision

Identity state machine:

`NOT_STARTED`
→ `DOCUMENT_UPLOADED`
→ `SELFIE_CAPTURED`
→ `MATCHING_IN_PROGRESS`

Possible outcomes:

- AUTO_APPROVED
- PENDING_MANUAL_REVIEW
- RETRY_ALLOWED

Manual review:

- STAFF_APPROVED
- STAFF_REJECTED

Rejected verification may return to document upload according to the approved state machine.

Thresholds, retry counts, and retention values remain configurable/open where not explicitly approved.

---

## 17. Identity Security

Identity data includes:

- identity documents
- selfies
- verification decisions
- verification results

It must be:

- privately stored
- access controlled
- auditable
- protected from public URLs
- excluded from logs
- retained according to configured retention policy

Do not assume a specific real identity provider.

---

## 18. Digital Check-in and Digital Access

Digital access is reservation-bound.

It must:

- belong to the correct reservation
- be scoped correctly
- expire
- be revocable
- be auditable
- remain unavailable before eligibility conditions are met

Approved check-in eligibility requires:

- reservation is `VERIFIED`
- payment is `HOLD_ACTIVE`
- identity is `AUTO_APPROVED` or `STAFF_APPROVED`
- current time is before the checkout boundary

Physical room assignment is not necessarily required for the current check-in eligibility rule.

Access provider is initially dummy.

Provider failure must not incorrectly transition the reservation.

---

## 19. Hotel Services

Guests may request hotel services during their stay.

Services belong to the correct hotel.

A service order may have:

- service
- reservation
- quantity
- notes
- status
- price/charge information where applicable

Service state machine:

`REQUESTED → CONFIRMED → FULFILLED`

Cancellation branches:

- REQUESTED → CANCELLED
- CONFIRMED → CANCELLED

Guest cancellation is limited according to the approved state/permission rules.

---

## 20. Folio / Guest Account

The guest folio is the authoritative stay financial view.

It may include:

- accommodation
- confirmed service charges
- eligible additional charges
- captured/settled payments
- outstanding balance

The system must prevent duplicate source charges.

Accommodation must be represented deterministically from the reservation price snapshot.

Do not create a large hotel ERP/accounting system unless explicitly required.

---

## 21. Checkout

Checkout starts from an eligible stay.

The backend must:

- lock/re-read relevant records
- calculate the authoritative folio
- determine outstanding amount
- perform final settlement only when needed
- preserve historical payment amounts
- safely handle failure/pending outcomes
- avoid duplicate charges
- generate invoice only when finalization rules are satisfied

A failed settlement must not produce an incorrectly finalized stay.

Retries must be safe.

---

## 22. Invoice

Invoices are electronic and auditable.

Invoice generation should be deterministic.

An invoice should preserve the final financial snapshot rather than depending on future mutable data.

Invoice line items may reference:

- accommodation
- hotel services
- additional eligible charges

Avoid duplicate invoice items on retry.

Invoice numbering must follow the approved implementation.

---

## 23. Loyalty

Loyalty is group-wide.

One guest has one group-level loyalty account.

Support:

- points balance
- points earned
- points redeemed
- transaction history
- source reference
- audit trail

Ledger vocabulary:

- earn
- redeem
- reverse
- adjust
- expire

MVP should implement only approved earn/redeem behavior.

No loyalty rate, conversion, expiry, tier, or stacking rule may be invented.

Balance must never be mutated without a corresponding ledger entry.

---

## 24. Ratings and Reviews

A guest may review an eligible completed/stayed reservation according to the approved eligibility rules.

MVP review supports:

- rating 1–5
- optional text
- reservation reference
- guest reference
- hotel reference
- moderation state

Only approved/published reviews should be public.

Prevent duplicate submissions.

Hotel staff may moderate according to permission but must not directly rewrite the customer's rating as an ordinary edit.

Moderation actions must be auditable.

---

## 25. Notifications

Notifications are a reusable system.

Potential channels:

- in-app
- push
- email
- SMS

Potential events:

- reservation created
- payment success/failure
- identity verification requested
- identity verification approved
- identity verification rejected
- digital access issued
- check-in
- service update
- checkout
- invoice generated
- loyalty points earned
- loyalty redemption
- review reminder

Do not assume every channel is required for MVP.

Notifications should support deterministic/idempotent processing and asynchronous delivery where appropriate.

---

## 26. Dashboard Business Responsibilities

The unified dashboard may expose authorized areas such as:

- Overview
- Hotels
- Room Types
- Rooms / Inventory
- Reservations
- Guests
- Identity Verification
- Check-in / Digital Access
- Hotel Services
- Guest Charges / Folio
- Checkout
- Invoices
- Payments
- Loyalty
- Reviews
- Notifications
- Users
- Roles / Permissions
- Reports
- Audit
- Settings

Visibility depends on permission and hotel scope.

Central users may see group-level information.

Hotel managers see assigned hotels.

Reception sees only authorized operational functions.

---

## 27. Guest Mobile Responsibilities

The Flutter app is the guest-facing journey.

Core areas:

- onboarding
- authentication
- discovery
- hotel details
- search
- dates
- availability
- room selection
- reservation
- payment
- identity verification
- reservation details
- digital check-in
- digital access
- stay services
- checkout
- invoice
- loyalty
- reviews
- notifications
- profile

The mobile app must call real backend APIs for production workflows.

Dummy data is permitted only for explicitly defined development/test boundaries and must never become the production source of truth.

---

## 28. API vs Dashboard vs Mobile

### API

Owns:

- business correctness
- authorization
- hotel scope
- guest ownership
- state transitions
- financial calculations
- eligibility
- persistence
- integrations

### Dashboard

Owns:

- staff UX
- forms
- filtering
- navigation
- presentation
- permission-based UI
- hotel context UX

### Mobile

Owns:

- guest UX
- navigation
- local presentation state
- form UX
- API data handling

Neither frontend may bypass backend rules.

---

## 29. Reporting

Reporting must respect permissions and hotel scope.

Potential reports:

- occupancy overview
- booking statistics
- revenue/payment overview
- hotel performance
- guest/customer statistics
- loyalty statistics
- rating/review statistics
- arrivals/departures/in-house operational views

Do not invent accounting metrics that are not supported by the approved financial model.

---

## 30. Audit

Important actions should be auditable.

Examples:

- reservation transitions
- payment initiation/status changes
- payment webhook processing
- reconciliation
- identity decisions
- access issue/revoke
- checkout
- invoice creation
- loyalty earn/redeem
- review moderation
- permission-sensitive operations

Audit data must not expose secrets or sensitive identity/payment content.

---

## 31. Security

Sensitive data includes:

- guest information
- identity documents
- selfies
- verification results
- payment information
- access credentials
- invoices
- audit information

Apply:

- authentication
- authorization
- hotel isolation
- guest ownership
- private storage
- signed/private URLs
- encryption where appropriate
- validation
- throttling
- secure headers
- webhook signature verification
- idempotency
- audit logs
- least privilege
- secure password/token handling

Never expose secrets or sensitive files.

---

## 32. Future Enhancements

Keep the architecture extensible for:

- advanced loyalty program
- loyalty tiers
- trusted/reusable identity verification
- personalized guest experience
- occupancy-based dynamic pricing
- AI/FAQ assistant
- eco-friendly hotel features
- automatic post-checkout summaries
- group/family bookings
- advanced central analytics
- real payment provider
- real identity provider
- real access-control provider

These are future capabilities unless explicitly approved.

The MVP must not become bloated by hypothetical features.

---

## 33. Open / Configurable Business Decisions

Do not silently invent values for:

- currency
- deposit/hold amount calculation
- cancellation penalties/deadlines
- payment hold timeout duration
- identity thresholds
- identity retry limits
- identity retention
- loyalty earning rate
- loyalty redemption conversion
- notification channels beyond approved scope
- real third-party providers
- advanced dynamic pricing

If a value is required and not approved, flag it for project-owner confirmation.

---

## 34. Definition of Done

A business feature is not complete simply because code exists.

It is complete only when:

- business requirements are understood
- state/workflow is correct
- authorization is correct
- hotel scope is correct
- guest ownership is correct
- database integrity is correct
- API contract is correct
- UI/mobile behavior is correct where required
- tests cover important paths
- failure paths are handled
- security is reviewed
- documentation is updated
- actual verification was performed
