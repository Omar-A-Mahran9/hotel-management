import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/core/theme/theme_controller.dart';
import 'package:hotel_guest_app/core/time/clock.dart';
import 'package:hotel_guest_app/features/discovery/presentation/widgets/stay_range_calendar.dart';
import 'package:hotel_guest_app/features/reservation/presentation/pages/reservation_detail_page.dart';

import '../../support/auth_test_support.dart';
import '../../support/pump_app.dart';

Finder _calDay(String d) => find.descendant(
      of: find.byType(StayRangeCalendar),
      matching: find.text(d),
    );

void main() {
  testWidgets('the confirm + confirmation screens render in dark mode',
      (WidgetTester tester) async {
    final ProviderContainer container = await pumpApp(
      tester,
      bootSession: completeSession(),
      extraOverrides: <Override>[
        clockProvider.overrideWithValue(() => DateTime(2026, 9, 1)),
      ],
    );
    container.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
    await tester.pumpAndSettle();

    final AppLocalizations en =
        await AppLocalizations.delegate.load(const Locale('en'));

    await tester.tap(find.text('The Oasis Hotel').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.hotelSelectDates));
    await tester.pumpAndSettle();
    await tester.tap(_calDay('6').first);
    await tester.pumpAndSettle();
    await tester.tap(_calDay('8').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, en.stayDatesShowRooms));
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(OutlinedButton, en.roomViewDetails).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, en.roomSelectThisRoom));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, en.roomsContinue));
    await tester.pumpAndSettle();

    expect(find.text(en.reservationConfirmCta), findsOneWidget);

    await tester
        .tap(find.widgetWithText(FilledButton, en.reservationConfirmCta));
    await tester.pumpAndSettle();

    expect(find.byType(ReservationDetailPage), findsOneWidget);
    expect(find.text(en.reservationSuccessTitle), findsOneWidget);
    // Dark theme is actually applied.
    final ThemeData theme = Theme.of(
      tester.element(find.text(en.reservationSuccessTitle)),
    );
    expect(theme.brightness, Brightness.dark);

    expect(tester.takeException(), isNull);
  });
}
