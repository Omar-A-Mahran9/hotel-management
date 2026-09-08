# Mobile Phase 5 — Payment

Guest-app payment flow that follows reservation creation (Mobile Phase 4). It
requests a **refundable deposit hold** on a reservation and reflects the
authoritative backend payment lifecycle — it never collapses payment to a
boolean "paid".

## Scope

* Request a deposit hold for a `PENDING` reservation and show its outcome.
* Represent the full Laravel `Payment` status vocabulary and the safe subset of
  `PaymentResource` fields.
* Deterministic dummy behaviour while no guest-facing payment API exists.

Out of scope (backend / staff / webhook driven, not a guest action): capture,
final settlement, refunds, provider selection, card data entry.

## Payment lifecycle

`lib/features/payment/domain/entities/payment_status.dart` mirrors
`App\Domain\Payment\Models\Payment` **exactly**:

```
NOT_STARTED → HOLD_REQUESTED → HOLD_ACTIVE → CAPTURE_REQUESTED → CAPTURED
            → FINAL_SETTLEMENT_REQUESTED → SETTLED
also: HOLD_FAILED, CAPTURE_FAILED, SETTLEMENT_FAILED, CANCELLED, EXPIRED,
      REFUND_REQUESTED, REFUNDED, REFUND_FAILED
```

The app only ever drives `NOT_STARTED → HOLD_REQUESTED → HOLD_ACTIVE`
(`POST /reservations/{id}/payment/hold`). `PaymentStatus` also carries the
derived predicates the UI needs: `isSecured`, `isTerminal`, `canRequestHold`,
`isPending`, `isFailed`. Laravel stays authoritative for the status and the
amount; the app never transitions a payment or the reservation.

`PaymentOutcome` (`payment_result.dart`) is the safe classification the result
screen renders: `held / pending / failed / cancelled / expired / other`,
mirroring the branches of `PaymentController::hold`.

## UI flow

```
Reservation Detail
      │  "Continue to payment"
      ▼
Payment Review   (PaymentReviewPage)   — reference, hotel, dates, amount,
      │  "Pay now"                       current payment status, hold explainer
      ▼
Payment Processing (PaymentProcessingPage) — clear processing state, no cancel,
      │                                       never claims success
      ▼
Payment Result   (PaymentResultPage)   — authoritative outcome + status pill;
      │  "Back to reservation" / retry   safe error + retry on failure
      ▼
Reservation Detail
```

Routes (`AppRoutes`, all auth-guarded, all under `/reservation/:reservationId`):
`payment`, `payment/processing`, `payment/result`.

Reusable widgets: `PaymentSummaryCard`, `PaymentStatusPill`.

## State management

* `paymentControllerProvider` — a `Notifier<PaymentActionState>` (app-scoped so
  the review → processing → result pages share one action state). Sealed states:
  `PaymentActionIdle / Submitting(request) / Done(request, result) / Failed(request, failure)`.
* Guarantees: duplicate-submit is a no-op while submitting or after a
  *successful* `Done`; retry is allowed from `Failed` and from a `Done` with a
  retryable outcome; an async result is dropped if a newer `PaymentHoldRequest`
  superseded it (`_superseded`), so an old result never overwrites a newer
  payment's state.
* `currentPaymentProvider(reservationId)` — `FutureProvider.autoDispose.family`;
  returns the current `Payment`, filling a synthetic `Payment.none` with the
  authoritative reservation amount when no hold exists yet.

### Idempotency

`PaymentHoldRequest.idempotencyKey` = `pay:<reservationId>:<amount>:<currency>` —
stable across rebuilds, no time/random component. Used as the `Idempotency-Key`
header (future API) and for local dedupe. The dummy source caches only
non-failed results by key, so a genuine retry after `HOLD_FAILED` re-attempts
while a duplicate submit of a successful hold returns the same record.

## Data layer

```
PaymentRepository
 └── PaymentDataSource
       ├── DummyPaymentDataSource   (DummyDataSource)
       └── ApiPaymentDataSource     (RemoteDataSource — stubbed)
```

* `PaymentModel.fromJson` mirrors `PaymentResource` (`id`, `reservation_id`,
  `hotel_id`, `status`, `amount` decimal-string, `currency`, `hold_expires_at`,
  timestamps). `PaymentHoldPayload.toJson` mirrors `StorePaymentHoldRequest`
  (`amount`, `currency` — never the idempotency key).
* `PaymentRepositoryImpl` maps every data-layer error to `Failure` via
  `ErrorMapper`.

### API contract status — **not integrated (stubbed)**

`ApiPaymentDataSource` raises `NotImplementedInPhaseException` from every
method. Reasons:

* `POST /api/v1/reservations/{reservation}/payment/hold` is
  **staff/dashboard-scoped**: `PaymentController::hold` resolves the reservation
  via `ReservationService::findAccessibleBy($request->user(), …)` and authorises
  with `PaymentPolicy` against the acting user's hotel access. The whole `/v1`
  surface is behind `auth:sanctum` staff tokens.
* There is **no `GET` endpoint** for a reservation's current payment — nothing
  to poll for status.
* There is **no approved guest mechanism** to submit card/provider data.

**Backend integration still required:**

1. A guest-authenticated payment surface (guest token accepted; hotel scope +
   guest identity resolved server-side from the reservation, as Phase 8–10
   already do for other reservation-scoped guest features).
2. `POST /reservations/{id}/payment/hold` accepting a guest caller, body
   `{ amount, currency? }`, `Idempotency-Key` header, returning `PaymentResource`.
3. `GET /reservations/{id}/payment` returning the current `PaymentResource`
   (or 404 / `NOT_STARTED` when none).
4. A provider-side capture mechanism (SDK/redirect) if real card capture is
   introduced — never an API body field.

Once those land, un-stub the two methods in `ApiPaymentDataSource` (wiring is in
comments) — no UI/state changes needed.

## Dummy datasource behaviour

Deterministic scenario chosen from the reservation id
(`DummyPaymentDataSource.scenarioFor`):

| `scenarioFor(id) % 3` | scenario            | first hold      | retry           |
|-----------------------|---------------------|-----------------|-----------------|
| 0                     | `failsThenSucceeds` | `HOLD_FAILED`   | `HOLD_ACTIVE`   |
| 1                     | `staysPending`      | `HOLD_REQUESTED`| `HOLD_REQUESTED`|
| 2                     | `succeeds`          | `HOLD_ACTIVE`   | —               |

No `Random`, no `DateTime.now()` for branching (a `clock` is injected for
`created_at` only). `failWith` is a test seam for infrastructure errors.

## Security

* `PaymentHoldRequest` / `Payment` carry **only** reservation id, amount,
  currency, status, timestamps. No card number, CVV, PIN, provider secret or
  raw credential exists anywhere in the feature.
* `NotImplementedInPhaseException` messages contain no sensitive data.
* Failures shown to the guest go through `Failure.localizedMessage` — no
  provider or backend implementation detail is ever rendered.

## Tests

`test/features/payment/` — domain, models, dummy + API datasources, repository
mapping, controller (idle/loading/success/failure/retry/duplicate/stable
key/stale/supersession), routing (registration + auth guard), and a widget flow
(review → pay → processing → result → reservation; pending; failure + retry;
Arabic RTL; double-tap safety).

## Known limitations

* No real payment provider / card capture — deterministic dummy only.
* No status polling UI beyond the review screen's retry (no `GET` endpoint).
* The reservation stays `PENDING` in dummy mode (the backend owns the
  `PENDING → DEPOSIT_HELD` transition); the app reflects payment status
  independently and never changes reservation status.
