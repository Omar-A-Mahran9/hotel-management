# Extend Stay — Implementation Report

**Status:** implemented, tests green · not committed, not pushed
**Date:** 2026-09-11

## 0. What this is

A guest currently occupying a room (`checked_in` / `in_stay`) can push their
checkout date out. Requested as part of the Mobile 11 (Bookings, Account &
Services) work — the Services tab's `STAY_Home` Figma board has an
"تمديد الإقامة" (Extend Stay) action with no prior backend capability at all.

Every computation (availability, pricing, folio/invoice accounting) reuses
services that already exist; this feature only introduces the one workflow
that ties them together plus its own audit ledger.

## 1. Eligibility & rule

- Only `Reservation::STATUS_CHECKED_IN` / `STATUS_IN_STAY` may be extended —
  `ReservationExtensionNotAllowedException` (422) otherwise.
- `new_check_out` must be strictly after the reservation's *current*
  `check_out` — enforced by `ReservationExtensionService` (reuses
  `ReservationNotAvailableException`, the same "this date range doesn't work"
  business error `ReservationService::create()` uses), not duplicated in the
  FormRequest (mirrors `RedeemLoyaltyRequest`'s split: the FormRequest only
  rejects structurally bad input — `new_check_out` must be a real date after
  today — reservation-state-dependent facts stay in the Service).

## 2. Availability

Re-runs `ReservationService::create()`'s exact approved Phase 3D
lock-then-count design against **only the added window**
`[old_check_out, new_check_out)`:

1. Lock the Room Type row (`RoomTypeRepositoryInterface::findForUpdate`),
   then the specific Room if one is assigned
   (`RoomRepositoryInterface::findForUpdate`).
2. If a Room is assigned: reject if `countOverlappingForRoom` > 0 for the
   added window (someone else already has that exact room next).
3. Always: reject if `countOverlappingForRoomType` ≥ the Room Type's total
   physical Room count for the added window.

No repository interface changed. The reservation's own stay
(`[check_in, old_check_out)`) can never overlap `[old_check_out,
new_check_out)` under the canonical checkout-exclusive predicate, so it never
counts against itself — no "exclude self" parameter was needed.

## 3. Pricing

`unit_price = room_types.base_price` (the same authoritative rate every
reservation is priced from), `nights_added = old_check_out.diffInDays(new_check_out)`,
`amount = nights_added * unit_price` (bcmath, DECIMAL(12,2)). No tax, fee, or
discount — none is approved anywhere else in the codebase either.

`reservation.check_out` and `reservation.price_snapshot` (+= amount) are
updated in the same transaction. `price_snapshot` remains "the authoritative
running accommodation total for this reservation", consistent with how it is
read everywhere else (folio, invoice, loyalty context).

## 4. Accounting — no new payment call

The incremental amount is posted as a **folio charge**
(`FolioCharge::SOURCE_STAY_EXTENSION`, a new enum value added by migration
`2026_09_11_130001` — the Phase 8 migration's `source_type` enum already
anticipated a follow-up, same as the Phase 9 `accommodation` addition).
`source_id` is the new `reservation_extensions` row's own id, **not** the
reservation id: `SOURCE_ACCOMMODATION` is UNIQUE per reservation (one
accommodation charge ever), but a reservation may be extended more than once,
so each extension needs its own idempotency identity.

`FolioService` / `CheckoutService` / `InvoiceService` are **unchanged** — they
already sum every `posted` `FolioCharge` for the reservation, so the new
charge is immediately part of `charges_total` / `outstanding_total`, and later
the invoice, with zero changes to that math. This mirrors how a service-order
charge already "accrues to the account" (see `Design/Check in & Stay/caption.png`)
and is settled through the existing checkout/settlement flow — this is *why*
there is no separate "charge the guest now" endpoint. `payments.amount` and
`payment_transactions` history are never read or written by this feature.

## 5. Idempotency & concurrency

One `DB::transaction`, no external provider call (unlike
`PaymentWorkflowService` this needs no A/B/C split):

- `Idempotency-Key` header → `idempotency_key` (mirrors
  `InitiateGuestPaymentHoldRequest` exactly).
- The reservation row is locked first; if the key is already recorded
  (`ReservationExtensionRepositoryInterface::findByIdempotencyKey`), the
  request is a replay — `assertIdempotentMatch` requires the same reservation
  and the same `new_check_out`, else `ReservationExtensionIdempotencyKeyConflictException`
  (422, mirrors Payment's `IdempotencyKeyConflictException`).
- A concurrent insert racing on the same key is caught
  (`UniqueConstraintViolationException`) and re-read as the winner — same
  pattern `FolioChargeService::postAccommodationCharge()` and
  `PaymentWorkflowService::openHoldAttempt()` already use.
- The folio charge itself is separately idempotent via the existing
  `(source_type, source_id)` UNIQUE + pre-check (new
  `FolioChargeService::postStayExtensionCharge()`, same body as
  `postAccommodationCharge()`).

## 6. New pieces

| Layer | File |
|---|---|
| Migration | `database/migrations/2026_09_11_130000_create_reservation_extensions_table.php` |
| Migration | `database/migrations/2026_09_11_130001_add_stay_extension_to_folio_charge_source_type.php` |
| Model | `App\Domain\Reservation\Models\ReservationExtension` |
| Repository | `ReservationExtensionRepositoryInterface` / `EloquentReservationExtensionRepository` |
| Service | `App\Domain\Reservation\Services\ReservationExtensionService::extend()` |
| Exceptions | `ReservationExtensionNotAllowedException`, `ReservationExtensionIdempotencyKeyConflictException` (renderable → 422, registered in `bootstrap/app.php`) |
| Guest endpoint | `POST /api/v1/guest/reservations/{reservation}/extend` (`GuestReservationController::extend`, `ExtendGuestReservationRequest`) |
| Staff endpoint | `POST /api/v1/reservations/{reservation}/extend` (`ReservationController::extend`, `ExtendReservationRequest`, new `ReservationPolicy::extend` ability — same `reservations.manage` + hotel-scope shape as `transition()`) |
| Response | `{ reservation, extension, folio }` — `ReservationExtensionResource` + the existing `FolioResource`, mirroring `CheckoutController`'s composite-response shape |
| Resource fields | `GuestReservationResource` gained `room_type.base_price` and `room { id, room_number }` (also now eager-loaded on `paginateOwnedByGuest`, `show`, `cancel`) — needed by the mobile Account screen's real "per-night" figure and the room number shown once checked in |

## 7. Tests

- `tests/Feature/Guest/GuestReservationExtendTest.php` (9 tests): happy path
  (amount, folio, DB rows), not-eligible status, `new_check_out` not after
  current `check_out`, overlap rejection, idempotent replay (single folio
  charge row), idempotency conflict, `Payment.amount` preserved, cross-guest
  404, unauthenticated 401.
- `tests/Feature/Reservation/ReservationExtendApiTest.php` (4 tests): manager
  in assigned hotel, manager in unassigned hotel → 404, reception forbidden
  → 403, not-eligible status → 422.
- Full suite: **1740 passed / 7760 assertions**, no regressions.

## 8. Dashboard

An "Extend stay" action on the reservation detail view (enabled only for
`checked_in`/`in_stay`) calling the new staff endpoint; see
`dashboard/` reservation detail page changes.

## 9. Mobile

See `mobile/docs/mobile-phase-11-bookings-account.md` — the Services tab's
`ExtendStayPage` calls this endpoint through
`ReservationRepository.extend()`.
