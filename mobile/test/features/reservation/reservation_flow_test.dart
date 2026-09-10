import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_guest_app/app/router/app_router.dart';
import 'package:hotel_guest_app/core/errors/app_exception.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/core/time/clock.dart';
import 'package:hotel_guest_app/features/reservation/data/datasources/dummy_reservation_data_source.dart';
import 'package:hotel_guest_app/features/reservation/data/repositories/reservation_repository_impl.dart';
import 'package:hotel_guest_app/features/reservation/presentation/state/reservation_providers.dart';
import 'package:hotel_guest_app/features/reservation/presentation/widgets/reservation_summary_card.dart';

import '../../support/auth_test_support.dart';
import '../../support/calendar_test_support.dart';
import '../../support/pump_app.dart';

final DateTime _now = DateTime(2026, 9, 1);
final List<Override> _fixedClock = <Override>[
  clockProvider.overrideWithValue(() => _now),
];


Future<AppLocalizations> _toReview(
  WidgetTester tester, {
  List<Override> extra = const <Override>[],
}) async {
  await pumpApp(
    tester,
    bootSession: completeSession(),
    extraOverrides: <Override>[..._fixedClock, ...extra],
  );
  final AppLocalizations en =
      await AppLocalizations.delegate.load(const Locale('en'));

  await tester.tap(find.text('The Oasis Hotel').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(en.hotelSelectDates));
  await tester.pumpAndSettle();
  await tapCalendarDay(tester, '6');
  await tapCalendarDay(tester, '8');
  await tester.tap(find.widgetWithText(FilledButton, en.stayDatesShowRooms));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, en.roomViewDetails).first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, en.roomSelectThisRoom));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, en.roomsContinue));
  await tester.pumpAndSettle();

  expect(find.text(en.reviewTitle), findsOneWidget);
  return en;
}

void main() {
  testWidgets('review → confirm → reservation confirmation screen',
      (WidgetTester tester) async {
    final AppLocalizations en = await _toReview(tester);

    final Finder confirm =
        find.widgetWithText(FilledButton, en.reservationConfirmCta);
    expect(confirm, findsOneWidget);

    await tester.tap(confirm);
    await tester.pumpAndSettle();

    // Landed on the confirmation / details screen.
    expect(find.text(en.reservationSuccessTitle), findsOneWidget);
    expect(find.text(en.reservationReferenceLabel), findsOneWidget);
    expect(find.textContaining('RSV-'), findsOneWidget);
    expect(find.text(en.reservationStatusPending), findsWidgets);
    expect(find.byType(ReservationSummaryCard), findsOneWidget);
    // Pending note is shown for a freshly created reservation.
    await tester.scrollUntilVisible(
      find.text(en.reservationPendingNote),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(en.reservationPendingNote), findsOneWidget);

    // "Done" returns to discover.
    await tester.tap(find.widgetWithText(FilledButton, en.reservationDone));
    await tester.pumpAndSettle();
    expect(find.text(en.discoverSubtitle), findsWidgets);
  });

  testWidgets('a failed create shows an error banner and allows retry',
      (WidgetTester tester) async {
    final DummyReservationDataSource ds = DummyReservationDataSource()
      ..failWith = const NetworkException();

    final AppLocalizations en = await _toReview(tester, extra: <Override>[
      reservationRepositoryProvider
          .overrideWithValue(ReservationRepositoryImpl(ds)),
    ]);

    await tester
        .tap(find.widgetWithText(FilledButton, en.reservationConfirmCta));
    await tester.pumpAndSettle();

    // Still on the review screen, now showing the failure.
    expect(find.text(en.reviewTitle), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(en.reservationCreateFailedTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(en.reservationCreateFailedTitle), findsOneWidget);

    // Recover and retry.
    ds.failWith = null;
    await tester
        .tap(find.widgetWithText(FilledButton, en.reservationConfirmCta));
    await tester.pumpAndSettle();
    expect(find.text(en.reservationSuccessTitle), findsOneWidget);
  });

  testWidgets('the confirm button is not offered without a selection',
      (WidgetTester tester) async {
    final container = await pumpApp(
      tester,
      bootSession: completeSession(),
      extraOverrides: _fixedClock,
    );
    final AppLocalizations en =
        await AppLocalizations.delegate.load(const Locale('en'));

    final GoRouter router = container.read(appRouterProvider);
    router.go('/discover/hotel/oasis/review');
    await tester.pumpAndSettle();

    expect(find.text(en.reviewNoSelectionTitle), findsOneWidget);
    expect(find.widgetWithText(FilledButton, en.reservationConfirmCta),
        findsNothing);
  });
}
