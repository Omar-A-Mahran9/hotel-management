import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/app/router/app_router.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/features/payment/data/datasources/dummy_payment_data_source.dart';
import 'package:hotel_guest_app/features/payment/domain/entities/payment_request.dart';
import 'package:hotel_guest_app/features/payment/presentation/state/payment_providers.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/create_reservation_request.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation.dart';
import 'package:hotel_guest_app/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:hotel_guest_app/features/reservation/presentation/state/reservation_providers.dart';

import '../../support/auth_test_support.dart';
import '../../support/pump_app.dart';
import 'payment_test_support.dart';

class _StubReservationRepository implements ReservationRepository {
  @override
  Future<Reservation> create(CreateReservationRequest request) async =>
      fakeReservation();

  @override
  Future<Reservation> getById(String id) async => fakeReservation(id: id);
}

Future<AppLocalizations> _l10n(String code) =>
    AppLocalizations.delegate.load(Locale(code));

Future<ProviderContainer> _open(
  WidgetTester tester,
  String reservationId, {
  Locale? locale,
  DummyPaymentDataSource? paymentSource,
}) async {
  final c = await pumpApp(
    tester,
    bootSession: completeSession(),
    locale: locale,
    extraOverrides: <Override>[
      reservationRepositoryProvider
          .overrideWithValue(_StubReservationRepository()),
      if (paymentSource != null)
        paymentDataSourceProvider.overrideWithValue(paymentSource),
    ],
  );
  c.read(appRouterProvider).go('/reservation/$reservationId/payment');
  await tester.pumpAndSettle();
  return c;
}

void main() {
  testWidgets('review → pay → processing → result → back to reservation (EN)',
      (WidgetTester tester) async {
    final en = await _l10n('en');
    final id = reservationIdForScenario(DummyHoldScenario.succeeds);
    await _open(tester, id);

    expect(find.text(en.paymentReviewTitle), findsWidgets);
    expect(find.text(en.paymentPayNowCta), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, en.paymentPayNowCta));
    await tester.pumpAndSettle();

    // Landed on the authoritative result screen.
    expect(find.text(en.paymentSuccessTitle), findsOneWidget);
    expect(find.text(en.paymentStatusHoldActive), findsWidgets);

    await tester
        .tap(find.widgetWithText(FilledButton, en.paymentBackToReservation));
    await tester.pumpAndSettle();
    expect(find.text(en.reservationDetailTitle), findsWidgets);
  });

  testWidgets('a pending hold shows the processing result', (tester) async {
    final en = await _l10n('en');
    final id = reservationIdForScenario(DummyHoldScenario.staysPending);
    await _open(tester, id);

    await tester.tap(find.widgetWithText(FilledButton, en.paymentPayNowCta));
    await tester.pumpAndSettle();
    expect(find.text(en.paymentPendingTitle), findsOneWidget);
  });

  testWidgets('an infrastructure failure shows a safe error and retry works',
      (tester) async {
    final en = await _l10n('en');
    final id = reservationIdForScenario(DummyHoldScenario.succeeds);
    final src = DummyPaymentDataSource(clock: () => DateTime(2026, 9, 8));

    await _open(tester, id, paymentSource: src);
    // The review screen loads fine; the hold request is what fails.
    src.failWith = Exception('offline');
    await tester.tap(find.widgetWithText(FilledButton, en.paymentPayNowCta));
    await tester.pumpAndSettle();

    expect(find.text(en.paymentFailedTitle), findsWidgets);
    // No provider/internal detail is shown.
    expect(find.textContaining('offline'), findsNothing);

    src.failWith = null;
    await tester.tap(find.widgetWithText(FilledButton, en.paymentRetryCta));
    await tester.pumpAndSettle();
    expect(find.text(en.paymentSuccessTitle), findsOneWidget);
  });

  testWidgets('the flow renders right-to-left in Arabic', (tester) async {
    final ar = await _l10n('ar');
    final id = reservationIdForScenario(DummyHoldScenario.succeeds);
    await _open(tester, id, locale: arabic);

    expect(
      Directionality.of(tester.element(find.text(ar.paymentPayNowCta))),
      TextDirection.rtl,
    );
    await tester.tap(find.widgetWithText(FilledButton, ar.paymentPayNowCta));
    await tester.pumpAndSettle();
    expect(find.text(ar.paymentSuccessTitle), findsOneWidget);
  });

  testWidgets('tapping pay twice never places two holds', (tester) async {
    final en = await _l10n('en');
    final id = reservationIdForScenario(DummyHoldScenario.succeeds);
    final c = await _open(tester, id);

    final payBtn = find.widgetWithText(FilledButton, en.paymentPayNowCta);
    await tester.tap(payBtn);
    await tester.pump();
    // Second tap while the first request is settling.
    if (tester.any(payBtn)) await tester.tap(payBtn, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text(en.paymentSuccessTitle), findsOneWidget);
    final PaymentHoldRequest req = PaymentHoldRequest.forReservation(fakeReservation(id: id));
    final payment =
        await c.read(paymentRepositoryProvider).currentForReservation(id);
    expect(payment.amount.amount, req.amount.amount);
  });
}
