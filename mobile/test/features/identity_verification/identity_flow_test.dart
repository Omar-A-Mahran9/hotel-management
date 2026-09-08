import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/app/router/app_router.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/features/identity_verification/data/datasources/dummy_identity_verification_data_source.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/create_reservation_request.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation.dart';
import 'package:hotel_guest_app/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:hotel_guest_app/features/reservation/presentation/state/reservation_providers.dart';

import '../../support/auth_test_support.dart';
import '../../support/pump_app.dart';
import '../payment/payment_test_support.dart' show fakeReservation;
import 'identity_test_support.dart';

class _StubReservationRepository implements ReservationRepository {
  @override
  Future<Reservation> create(CreateReservationRequest request) async =>
      fakeReservation();
  @override
  Future<Reservation> getById(String id) async => fakeReservation(id: id);
}

Future<AppLocalizations> _l10n(String code) =>
    AppLocalizations.delegate.load(Locale(code));

Future<void> _open(WidgetTester tester, String id, {Locale? locale}) async {
  final c = await pumpApp(
    tester,
    bootSession: completeSession(),
    locale: locale,
    extraOverrides: <Override>[
      reservationRepositoryProvider
          .overrideWithValue(_StubReservationRepository()),
    ],
  );
  c.read(appRouterProvider).go('/reservation/$id/identity');
  await tester.pumpAndSettle();
}

Future<void> _submitDocumentAndSelfie(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await tester
      .tap(find.widgetWithText(TextButton, l10n.identityDocumentCaptureCta));
  await tester.pumpAndSettle();
  await tester
      .tap(find.widgetWithText(FilledButton, l10n.identityDocumentSubmitCta));
  await tester.pumpAndSettle();

  await tester
      .tap(find.widgetWithText(TextButton, l10n.identitySelfieCaptureCta));
  await tester.pumpAndSettle();
  await tester
      .tap(find.widgetWithText(FilledButton, l10n.identitySelfieSubmitCta));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('document → selfie → processing → verified → reservation (EN)',
      (WidgetTester tester) async {
    final en = await _l10n('en');
    final id = reservationIdForScenario(DummyVerificationScenario.autoApprove);
    await _open(tester, id);

    expect(find.text(en.identityDocumentStepTitle), findsOneWidget);
    await _submitDocumentAndSelfie(tester, en);

    expect(find.text(en.identityApprovedTitle), findsOneWidget);
    await tester
        .tap(find.widgetWithText(FilledButton, en.identityBackToReservation));
    await tester.pumpAndSettle();
    expect(find.text(en.reservationDetailTitle), findsWidgets);
  });

  testWidgets('manual-review scenario shows the safe waiting state',
      (tester) async {
    final en = await _l10n('en');
    final id = reservationIdForScenario(DummyVerificationScenario.manualReview);
    await _open(tester, id);
    await _submitDocumentAndSelfie(tester, en);
    expect(find.text(en.identityManualReviewTitle), findsOneWidget);
  });

  testWidgets('retry scenario shows a retry CTA and recovers', (tester) async {
    final en = await _l10n('en');
    final id =
        reservationIdForScenario(DummyVerificationScenario.retryThenApprove);
    await _open(tester, id);
    await _submitDocumentAndSelfie(tester, en);

    // Back on the document step with a retry banner.
    expect(find.text(en.identityRetryTitle), findsWidgets);
    expect(find.text(en.identityDocumentStepTitle), findsOneWidget);

    await _submitDocumentAndSelfie(tester, en);
    expect(find.text(en.identityApprovedTitle), findsOneWidget);
  });

  testWidgets('rejected scenario shows a safe rejection with retry',
      (tester) async {
    final en = await _l10n('en');
    final id =
        reservationIdForScenario(DummyVerificationScenario.rejectThenReview);
    await _open(tester, id);
    await _submitDocumentAndSelfie(tester, en);
    expect(find.text(en.identityRejectedTitle), findsWidgets);
    // No provider/internal detail leaked.
    expect(find.textContaining('score'), findsNothing);
  });

  testWidgets('the flow renders right-to-left in Arabic', (tester) async {
    final ar = await _l10n('ar');
    final id = reservationIdForScenario(DummyVerificationScenario.autoApprove);
    await _open(tester, id, locale: arabic);

    expect(
      Directionality.of(
          tester.element(find.text(ar.identityDocumentStepTitle))),
      TextDirection.rtl,
    );
    await _submitDocumentAndSelfie(tester, ar);
    expect(find.text(ar.identityApprovedTitle), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(ar.identityApprovedTitle))),
      TextDirection.rtl,
    );
  });
}
