# Mobile — Report a problem (`13 · Report a problem`)

Builds the dedicated in-stay problem-report flow that Phase 11 deferred (see
`mobile-phase-11-bookings-account.md`'s "Not built" note): the "الإبلاغ عن
مشكلة" quick action on the `STAY_Home` hub previously just opened the
"Maintenance" service category. It now launches this flow, and the shortcut
is retired.

## Figma board

`Design/13 · Report a problem.png` — 4 screens, Arabic/RTL:

1. **الإبلاغ عن مشكلة** — category picker (6 cards: AC/heating,
   plumbing/water, electricity/lighting, room cleanliness, internet/Wi-Fi,
   noise/disturbance).
2. **وصف المشكلة** — urgency (عادي / مهم / عاجل) + optional notes.
3. **تم الإرسال** — confirmation banner with the report reference.
4. **تفاصيل البلاغ** — status + "تواصل مع الاستقبال" (contact reception).

The board's screen-2 prompt/info-banner copy reads like a reused "schedule
room cleaning" mockup (it references cleaning specifically, and an SLA the
backend doesn't provide) — the shipped copy is a category-agnostic
equivalent that never claims a response time the backend doesn't promise
(`mobile/docs/coding_rules.md` §9).

## Backend contract

Real, already-implemented (`App\Domain\Support`), reservation-scoped,
`auth:guest`:

- `GET  /guest/reservations/{id}/problems` — the guest's own reports,
  paginated (same envelope shape as every other list endpoint; the app reads
  `data` only, like `ReservationRepository.list()` / `serviceOrdersProvider`).
- `POST /guest/reservations/{id}/problems` — `{category, urgency, notes?}`.
  201 on success; 422 on an invalid category/urgency. Rate-limited
  (`throttle:guest.booking.write`) — no special handling beyond the existing
  `ErrorMapper`/429 machinery.
- `GET  /guest/reservations/{id}/problems/{problemId}` — one report; 404 for
  not-found/not-owned (no existence leak).

Enums mirror `App\Domain\Support\Models\ProblemReport` exactly:
`category` ∈ `ac_heating | plumbing_water | electricity_lighting |
room_cleanliness | internet_wifi | noise_disturbance`; `urgency` ∈
`normal | important | urgent`; `status` ∈ `open | in_progress | resolved`
(server-derived; a guest submission always starts `open`).

## Mobile (`lib/features/problem_reports/`)

Structured like `lib/features/reviews/` (submit flow) and
`lib/features/stay_services/` (list+show+create):

- `domain/entities/`: `ProblemCategory` / `ProblemUrgency` /
  `ProblemReportStatus` enums (`fromWire` falls back to a safe default, never
  `null` — mirrors `ReviewStatus.fromWire` / `ServiceOrderStatus.fromWire`),
  `ProblemReport`, `SubmitProblemReportRequest`.
- `data/`: `ProblemReportModel` (JSON ↔ entity), `ProblemReportDataSource`
  with `DummyProblemReportDataSource` (deterministic seeded history + an
  idempotent, incrementing-id `submit` that always echoes `open`) and
  `ApiProblemReportDataSource` (real Dio calls), `ProblemReportRepositoryImpl`.
- `presentation/state/`: `problemReportDataSourceProvider` (dummy/API switch,
  mirrors `reviewDataSourceProvider`), `problemReportsProvider` /
  `problemReportProvider` (list/show), `ProblemReportSubmissionController`
  (idle/submitting/done/failed, duplicate-submit guard — mirrors
  `ReviewSubmissionController` / `ServiceRequestController`).
- `presentation/pages/`: `ReportProblemCategoryPage`,
  `ReportProblemDescriptionPage`, `ReportProblemSubmittedPage`,
  `ProblemReportDetailPage` — one per Figma screen.
- `problem_reports_l10n.dart`: enum → localized-label mapping, mirrors
  `ReviewsL10n` / `StayServicesL10n`.

### Routing

Added to `AppRoutes`/`appRouterProvider`:

```
/reservation/:reservationId/report                      → category picker
/reservation/:reservationId/report/:category/describe    → description + urgency
/reservation/:reservationId/report/:reportId/submitted    → confirmation
/reservation/:reservationId/report/:reportId              → track/detail
```

`StayHomePage`'s "الإبلاغ عن مشكلة" tile now always pushes the category picker
(no longer gated on a "Maintenance" catalogue match).

### Not built

- No dedicated "all my reports" list screen — the Figma board only supplies
  the single-report tracking screen, reached right after a submission via its
  "تتبّع البلاغ" button. `problemReportsProvider` (list) exists for parity/
  tests but has no screen yet; add one if a future board supplies it.
- "تواصل مع الاستقبال" has no destination screen in any supplied design —
  wired to the existing `navComingSoon` snackbar, same convention as
  Account's privacy/help rows.

## Related cleanup: `Money.fallbackCurrency`

Bundled into this pass: the repeated `?? 'SAR'` fallback (Money's default
constructor + several `*_models.dart` files across
payment/reservation/checkout/stay_services/discovery) is now
`Money.fallbackCurrency` — one named constant instead of the literal
repeated everywhere. The fallback behaviour itself is unchanged (still a
documented, deliberate gap: the backend has no configured currency yet).
`LoyaltyRedeemPage`'s result banner also stopped hardcoding `'SAR'` and now
reads the reservation's real currency off `LoyaltyContext.currency`.
