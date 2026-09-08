import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/core/time/clock.dart';
import 'package:hotel_guest_app/features/discovery/presentation/widgets/stay_range_calendar.dart';

import '../../support/auth_test_support.dart';
import '../../support/pump_app.dart';

Finder _calDay(String d) => find.descendant(
      of: find.byType(StayRangeCalendar),
      matching: find.text(d),
    );

void main() {
  testWidgets('confirm + confirmation screens render right-to-left in Arabic',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      bootSession: completeSession(),
      locale: arabic,
      extraOverrides: <Override>[
        clockProvider.overrideWithValue(() => DateTime(2026, 9, 1)),
      ],
    );
    final AppLocalizations ar =
        await AppLocalizations.delegate.load(const Locale('ar'));

    await tester.tap(find.text('فندق الواحة').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.hotelSelectDates));
    await tester.pumpAndSettle();
    await tester.tap(_calDay('٦').first);
    await tester.pumpAndSettle();
    await tester.tap(_calDay('٨').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, ar.stayDatesShowRooms));
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(OutlinedButton, ar.roomViewDetails).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, ar.roomSelectThisRoom));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, ar.roomsContinue));
    await tester.pumpAndSettle();

    // Review screen with the Arabic confirm CTA.
    expect(find.text(ar.reservationConfirmCta), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(ar.reviewTitle))),
      TextDirection.rtl,
    );

    await tester
        .tap(find.widgetWithText(FilledButton, ar.reservationConfirmCta));
    await tester.pumpAndSettle();

    expect(find.text(ar.reservationSuccessTitle), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(ar.reservationSuccessTitle))),
      TextDirection.rtl,
    );
    expect(find.text('فندق الواحة'), findsWidgets);
  });
}
