# Integration Contract Matrix — Backend ↔ Dashboard ↔ Mobile

Single source of truth for the end-to-end integration. Backend Laravel `/api/v1`
is authoritative for every business rule, state, authorization and hotel scope.

Legend — **Status**: ✅ done · 🟡 partial · ❌ missing · 🔵 built this pass.
**Consumer**: D = Dashboard (staff), M = Mobile (guest).

---

## Auth guards

| Guard | Middleware | Provider model | Token name | Who |
|---|---|---|---|---|
| staff (existing) | `auth:sanctum` | `App\Domain\IdentityAccess\Models\User` | `api` | Dashboard |
| guest (new) | `auth:guest` | `App\Domain\Reservation\Models\Guest` | `guest-api` | Mobile |

Sanctum 4 `Guard::hasValidProvider()` enforces the token's tokenable type against
the guard's provider model — a guest token is rejected by `auth:sanctum` staff
routes and vice-versa. `config/auth.php` now declares an explicit `sanctum`
guard (`provider: users`) alongside the new `guest` guard (`provider: guests`).

---

## SLICE 0 — GUEST AUTH  🔵 (this pass)

| Feature | Route | Method | Auth | Payload | Response | Consumer | Status |
|---|---|---|---|---|---|---|---|
| Request OTP | `/guest/auth/otp/request` | POST | none · `throttle:guest.otp.request` | `{phone}` | `{challenge_id,phone,code_length,attempts_remaining,expires_in,resend_available_in}` | M | 🔵 |
| Resend OTP | `/guest/auth/otp/resend` | POST | none · `throttle:guest.otp.request` | `{challenge_id,phone}` | same as request | M | 🔵 |
| Verify OTP | `/guest/auth/otp/verify` | POST | none · `throttle:guest.otp.verify` | `{challenge_id,phone,code}` | `{outcome:"authenticated"\|"rejected"\|"locked_out", token?, guest?, profile_complete?, attempts_remaining?}` | M | 🔵 |
| Current guest | `/guest/auth/me` | GET | `auth:guest` | — | `{guest:GuestResource, profile_complete}` | M | 🔵 |
| Complete / edit profile | `/guest/profile` | PATCH | `auth:guest` | `{name,email}` | `{guest:GuestResource, profile_complete:true}` | M | 🔵 |
| Logout | `/guest/auth/logout` | POST | `auth:guest` | — | `null` | M | 🔵 |

- Wrong code / lock-out are **200 outcomes**, not errors (matches the Flutter
  `OtpVerifyResult` design). 422 only for malformed input or an
  expired/unknown challenge.
- Dev: `OTP_FIXED_CODE=123456` (`.env`, local only) makes the dummy sender
  deterministic and matches the Flutter dev screen. Prod leaves it unset →
  random 6-digit code, logged only in masked form by `DummyOtpSender`.
- `GuestResource` field is `name` (not `full_name`) — aligned with
  `UserResource`/`ReservationResource`. Flutter models updated to match.

---

## SLICE 1 — DISCOVERY  (next)

| Feature | Route | Method | Auth | Notes | Consumer | Status |
|---|---|---|---|---|---|---|
| Browse hotels (public) | `/guest/hotels` | GET | none | active hotels only, `?city=&q=&page=` | M (+ public site) | ❌ → planned |
| Hotel detail (public) | `/guest/hotels/{hotel}` | GET | none | active only; room types + amenities | M | ❌ → planned |
| Availability | `/guest/hotels/{hotel}/availability` | GET | none | `?check_in=&check_out=&adults=&children=` → room types with remaining count + `price_snapshot` preview, reuses `ReservationService` overlap math | M | ❌ → planned |
| Cities/filters | `/guest/hotels/cities` | GET | none | distinct active-hotel cities | M | ❌ → planned |

Staff already have `/hotels`, `/hotels/{h}/room-types`, `/hotels/{h}/rooms`
(permission + hotel scoped). The guest surface is read-only, active-only, no auth.

---

## SLICE 2 — RESERVATION  (after Discovery)

| Feature | Route | Method | Auth | Notes | Consumer | Status |
|---|---|---|---|---|---|---|
| Create reservation | `/guest/reservations` | POST | `auth:guest` · `Idempotency-Key` | `{hotel_id,room_type_id,check_in,check_out,adults,children}` → `guest_id` from token, never body; reuses `ReservationService::create` with `actor=null` | M | ❌ → planned |
| My reservations | `/guest/reservations` | GET | `auth:guest` | scoped `where guest_id = token guest` | M | ❌ → planned |
| Reservation detail | `/guest/reservations/{reservation}` | GET | `auth:guest` | 404 (not 403) if not owned — no existence leak | M | ❌ → planned |
| Cancel | `/guest/reservations/{reservation}/cancel` | POST | `auth:guest` | PENDING/DEPOSIT_HELD/VERIFIED → CANCELLED via state machine | M | ❌ → planned |

Dashboard already lists/opens every reservation (`/reservations`) — a
mobile-created reservation appears there with **no dashboard change**.

---

## SLICES 3–11 — remaining flows (backend endpoints exist but are staff-scoped; guest equivalents needed)

| Slice | Guest surface needed | Existing staff surface to reuse the service layer of | Consumer |
|---|---|---|---|
| 3 Payment | `POST /guest/reservations/{r}/payment/hold`, `GET .../payment` | `PaymentWorkflowService`, `PaymentController::hold` | M / D |
| 4 Identity | `POST /guest/reservations/{r}/identity/documents\|selfie`, `GET .../identity` | `IdentityVerificationService` (+ staff `review` stays staff) | M / D |
| 5 Check-in / access | `POST /guest/reservations/{r}/check-in`, `GET .../access` | `DigitalAccessService`, `CheckInController` | M / D |
| 6 Services / folio | `GET /guest/hotels/{h}/services`, `POST /guest/reservations/{r}/service-orders`, `GET .../folio` | `ServiceCatalogService`, `ServiceOrderService`, `FolioService` | M / D |
| 7 Checkout / invoice | `POST /guest/reservations/{r}/checkout`, `GET .../invoice` | `CheckoutService`, `InvoiceService` (accounting rules unchanged) | M / D |
| 8 Loyalty | `GET /guest/loyalty`, `GET /guest/loyalty/transactions`, `POST /guest/reservations/{r}/loyalty/redeem` | `LoyaltyService` (ledger authoritative) | M / D |
| 9 Reviews | **whole domain new**: `POST/GET /guest/reservations/{r}/review`, `GET /guest/hotels/{h}/reviews`, staff `GET /hotels/{h}/reviews` + `POST /reviews/{id}/moderate` | none — build model/migration/state-machine/service/repo/policy/tests | M / D |
| 10 Notifications | `GET /guest/notifications`, `PATCH /guest/notifications/{n}/read`, `POST /guest/notifications/read-all` | `NotificationService` (recipient = guest) | M / D |
| 11 Dashboard gaps | `GET /guests`, `/hotels/{h}/{arrivals\|departures\|in-house}`, `/payments`, `/invoices`, `/settlements`, `/hotels/{h}/reviews`, `/notifications` (staff-wide), `/audit`, `/reports/*`, `/overview` | repositories/services exist; add list endpoints + resources + policies | D |

---

## Enum / state contract (backend authoritative — clients must mirror, never rename)

| Domain | States |
|---|---|
| Reservation | `pending → deposit_held → verified → checked_in → in_stay → checkout_in_progress → (checkout_blocked) → checked_out → invoiced`; `pending/deposit_held/verified → cancelled` |
| Payment | `not_started → hold_requested → hold_active → capture_requested → captured → final_settlement_requested → settled` (+ `hold_failed`, `cancelled`, `expired`) |
| Identity | `not_started → document_uploaded → selfie_captured → matching_in_progress → auto_approved \| pending_manual_review \| retry_allowed` (+ staff `approved`/`rejected`) |
| Digital access | per `DigitalAccessStateMachine` |
| Service order | per `ServiceOrderStateMachine` |
| Checkout | per `CheckoutStateMachine` |
| Review (new) | `pending → approved \| rejected` |
| Notification | per `NotificationDeliveryStateMachine` |

Clients render every state; an unknown state must degrade gracefully, never crash.
