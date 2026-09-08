# Mobile Phase 6 — Identity Verification

Guest-app identity verification flow required before check-in. It walks the
approved backend identity state machine (Document → Selfie → Matching → Result)
and represents every business state — it never invents states and never claims
approval before the repository confirms it.

## Scope

* Upload an ID document, capture a selfie, submit for the automated match.
* Represent the full Laravel `IdentityVerificationSession` status vocabulary and
  the safe subset of `IdentityVerificationResource` fields.
* Deterministic dummy behaviour while no guest-facing identity API exists.
* A logging-safe, bytes-free abstraction for document/selfie capture.

Out of scope (staff only): `POST .../review` (the manual approve/reject
decision).

## Identity state machine

`lib/features/identity_verification/domain/entities/identity_verification_status.dart`
mirrors `App\Domain\IdentityVerification\Models\IdentityVerificationSession` and
`IdentityVerificationStateMachine` **exactly**:

```
NOT_STARTED → DOCUMENT_UPLOADED → SELFIE_CAPTURED → MATCHING_IN_PROGRESS
MATCHING_IN_PROGRESS → AUTO_APPROVED | PENDING_MANUAL_REVIEW | RETRY_ALLOWED
RETRY_ALLOWED        → DOCUMENT_UPLOADED (new attempt)
PENDING_MANUAL_REVIEW→ STAFF_APPROVED | STAFF_REJECTED
STAFF_REJECTED       → DOCUMENT_UPLOADED (new attempt)
```

`AUTO_APPROVED` / `STAFF_APPROVED` are terminal. `STAFF_REJECTED` is **not**
terminal — it has a retry edge. Derived predicates on the enum:
`isApproved` (positive list: auto + staff), `isTerminal`, `needsDocument`,
`needsSelfie`, `isProcessing`, `isManualReview`, `allowsRetry`.

A **retry is not a separate call**: from `RETRY_ALLOWED` / `STAFF_REJECTED` the
guest re-enters `submitDocument` (the approved `… → DOCUMENT_UPLOADED` edges),
then `submitSelfie` again.

## UI flow

```
Reservation Detail
      │  "Verify your identity"
      ▼
Identity Verification (IdentityVerificationPage)
      │  Document step  → Selfie step  → Verification processing
      ▼
   resolves:
     AUTO_APPROVED / STAFF_APPROVED  → hand off to Result screen (verified)
     PENDING_MANUAL_REVIEW           → hand off to Result screen (waiting)
     RETRY_ALLOWED                   → stay: document step + retry banner
     STAFF_REJECTED                  → stay: document step + rejection banner
                                        (+ "contact front desk" copy)
      ▼
Verification Result (IdentityVerificationResultPage)
      │  "Back to reservation" / retry / check again
      ▼
Reservation Detail
```

Routes (auth-guarded): `/reservation/:reservationId/identity`,
`/reservation/:reservationId/identity/result`.

Widgets: `IdentityStepIndicator` (Document → Selfie → Result),
`IdentityDocumentStep`, `IdentitySelfieStep`, `VerificationResultView`,
`IdentityStatusPill`.

## State management

* `identityVerificationControllerProvider` — a **`NotifierProvider.family`
  keyed by reservation id**, so a session for reservation A can never be
  overwritten by a late result addressed to reservation B (structural
  isolation).
* State (`IdentityVerificationState`): `phase` ∈
  `loading / ready / submittingDocument / submittingSelfie / failed`, plus the
  authoritative `IdentityVerificationSession` and an optional `Failure`.
* Within one reservation: a monotonic `_token` drops stale results from a
  superseded action; `state.isBusy` blocks duplicate submits.
* `refresh()` re-reads status (used while awaiting a manual review, or to
  recover a load failure).
* The controller never transitions the session — it only reflects what the
  repository returns.

### Idempotency

`SubmitSelfieRequest.idempotencyKey` = `idv-selfie:<reservationId>` (stable,
no time/random) — the `Idempotency-Key` header for the future API. The dummy
source relies on the **state-machine guard** (a selfie only resolves from
`DOCUMENT_UPLOADED` / `SELFIE_CAPTURED`) plus the controller's `isBusy` guard,
so a repeat submit from a resolved state is a no-op and never runs a second
match or bumps the attempt count.

## Data layer

```
IdentityVerificationRepository
 └── IdentityVerificationDataSource
       ├── DummyIdentityVerificationDataSource   (DummyDataSource)
       └── ApiIdentityVerificationDataSource     (RemoteDataSource — stubbed)
```

* `IdentityVerificationSessionModel.fromJson` mirrors
  `IdentityVerificationResource` — **only** `reservation_id`, `status`,
  `attempts`, `latest_outcome` (coarsened to `IdentityMatchOutcome`),
  `decided_at`. `latest_score`, `provider`, storage paths, attempt metadata and
  the `latest_decision` internals are **not** mapped onto the entity.
* `IdentityDocumentPayload.toFields` mirrors the `document_type` field of
  `SubmitIdentityDocumentRequest` (`max:40`, `/^[A-Za-z0-9 _-]+$/`).
* `IdentityVerificationRepositoryImpl` maps every data-layer error to `Failure`.

### Document / selfie capture abstraction

`CapturedImage` (`identity_document.dart`) carries **only** a non-sensitive
`label`, `sizeBytes` and `mimeType` — never image bytes. Domain/state objects
never hold the picture. In dummy mode the UI's "Add photo" / "Add selfie"
buttons attach `CapturedImage.dummy` (a fixed placeholder). A live build would
swap those buttons for the platform camera / provider SDK and hand the bytes
**straight to the upload data source** (multipart, private disk) without them
passing through domain state or logs.

### API contract status — **not integrated (stubbed)**

`ApiIdentityVerificationDataSource` raises `NotImplementedInPhaseException` from
every method. Reasons:

* All four endpoints
  (`POST .../documents`, `POST .../selfie`, `GET .../status`, `POST .../review`)
  are **staff/dashboard-scoped**: `IdentityVerificationController` resolves the
  reservation via `ReservationService::findAccessibleBy($request->user(), …)`
  and every action is authorised by `IdentityVerificationPolicy` against the
  acting user's hotel access. The `/v1` surface is behind `auth:sanctum` staff
  tokens.
* `.../review` is explicitly a staff decision endpoint.
* Uploads go multipart to a **private** disk and are never served back — the
  mobile app must only ever receive the safe `IdentityVerificationResource`.

**Backend integration still required:**

1. A guest-authenticated identity surface (guest token accepted; hotel scope +
   guest identity resolved server-side from the reservation).
2. `POST /reservations/{id}/identity-verification/documents` (multipart
   `document` + `document_type`) and `.../selfie` (multipart `selfie`,
   `Idempotency-Key` header) accepting a guest caller, returning
   `IdentityVerificationResource`.
3. `GET /reservations/{id}/identity-verification` returning the current
   `IdentityVerificationResource` (or `NOT_STARTED`).
4. Confirmation that `latest_outcome` values map cleanly onto
   `IdentityMatchOutcome` (`match` / `no_match` / `inconclusive`).

Once those land, un-stub the three methods in
`ApiIdentityVerificationDataSource` (wiring is in comments).

## Dummy datasource behaviour

Deterministic scenario chosen from the reservation id
(`DummyIdentityVerificationDataSource.scenarioFor`):

| `scenarioFor(id) % 4` | scenario           | attempt 1 selfie        | attempt 2 selfie          |
|-----------------------|--------------------|-------------------------|---------------------------|
| 0                     | `autoApprove`      | `AUTO_APPROVED`         | —                         |
| 1                     | `manualReview`     | `PENDING_MANUAL_REVIEW` | `PENDING_MANUAL_REVIEW`   |
| 2                     | `retryThenApprove` | `RETRY_ALLOWED`         | `AUTO_APPROVED`           |
| 3                     | `rejectThenReview` | `STAFF_REJECTED`        | `PENDING_MANUAL_REVIEW`   |

The session walks the full state machine
(`NOT_STARTED → DOCUMENT_UPLOADED → SELFIE_CAPTURED → …`). No `Random`, no
`DateTime.now()` for branching (`clock` injected for `decided_at` only).
`failWith` is a test seam for infrastructure errors.

## Security

* No image bytes in domain/state/logs — `CapturedImage` is metadata only.
* No `latest_score`, provider name, storage path or attempt metadata on the
  entity (`identity_models_test.dart` asserts they don't appear in
  `toString()`).
* `NotImplementedInPhaseException` messages carry no sensitive data.
* Guest-facing errors go through `Failure.localizedMessage` — no provider or
  backend detail rendered. Rejection copy points the guest to the front desk,
  never to a reason string.

## Tests

`test/features/identity_verification/` — domain (status mapping, session
getters, request invariants, `CapturedImage` safety), models, dummy + API
datasources (all four scenarios, state-machine walk, no-op on repeat,
`failWith`), repository mapping, controller (load, document, selfie, approved,
manual review, retry, rejected, duplicate action, cross-reservation isolation,
failure + recovery), routing (registration + auth guard), and a widget flow
(document → selfie → processing → verified → reservation; manual review;
retry + recovery; rejection; Arabic RTL).

## Known limitations

* No real camera / file picker and no provider — deterministic dummy only.
* Manual-review resolution (`STAFF_APPROVED` / `STAFF_REJECTED` from
  `PENDING_MANUAL_REVIEW`) is staff-driven; the app only re-polls via
  "Check again".
* The reservation stays `PENDING` in dummy mode; the backend owns the
  `DEPOSIT_HELD → VERIFIED` transition. The app reflects verification status
  independently and never changes the reservation status.
