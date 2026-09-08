import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/core/time/clock.dart';
import 'package:hotel_guest_app/features/discovery/presentation/widgets/hotel_summary_card.dart';
import 'package:hotel_guest_app/features/discovery/presentation/widgets/room_summary_card.dart';
import 'package:hotel_guest_app/features/discovery/presentation/widgets/stay_range_calendar.dart';

import '../../support/auth_test_support.dart';
import '../../support/pump_app.dart';

final List<Override> _fixedClock = <Override>[
  clockProvider.overrideWithValue(() => DateTime(2026, 9, 1)),
];

Future<AppLocalizations> _en() =>
    AppLocalizations.delegate.load(const Locale('en'));

void main() {
  testWidgets('discover renders the greeting and featured hotel cards',
      (WidgetTester tester) async {
    await pumpApp(tester, bootSession: completeSession());
    final AppLocalizations en = await _en();

    expect(find.text(en.discoverSubtitle), findsOneWidget);
    expect(find.text(en.discoverFeaturedSection), findsOneWidget);
    expect(find.byType(HotelSummaryCard), findsWidgets);
    expect(find.text('The Oasis Hotel'), findsWidgets);
  });

  testWidgets('tapping the search field opens the search screen',
      (WidgetTester tester) async {
    await pumpApp(tester, bootSession: completeSession());
    final AppLocalizations en = await _en();

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.text(en.searchTitle), findsOneWidget);
    // The initial load shows every hotel.
    expect(find.textContaining('hotels available'), findsOneWidget);
  });

  testWidgets('a query with no matches shows the no-results state, then clears',
      (WidgetTester tester) async {
    await pumpApp(tester, bootSession: completeSession());
    final AppLocalizations en = await _en();

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'zzzzz');
    await tester.pumpAndSettle();
    expect(find.text(en.searchNoResultsTitle), findsOneWidget);

    await tester.tap(find.byTooltip(en.searchClearTooltip));
    await tester.pumpAndSettle();
    expect(find.text(en.searchNoResultsTitle), findsNothing);
    expect(find.byType(HotelSummaryCard), findsWidgets);
  });

  testWidgets('the filter sheet applies a city filter', (WidgetTester tester) async {
    await pumpApp(tester, bootSession: completeSession());
    final AppLocalizations en = await _en();

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(en.filterTitle));
    await tester.pumpAndSettle();
    expect(find.text(en.filterTitle), findsOneWidget);

    final Finder jeddahChip =
        find.widgetWithText(FilterChip, 'Jeddah · ${en.cityHotelCount(2)}');
    await tester.ensureVisible(jeddahChip);
    await tester.tap(jeddahChip);
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.filterApply));
    await tester.pumpAndSettle();

    // Only Jeddah hotels remain.
    expect(find.text('The Marina Hotel'), findsWidgets);
    expect(find.text('The Palm Hotel'), findsNothing);
  });

  testWidgets('the sort sheet changes the order', (WidgetTester tester) async {
    await pumpApp(tester, bootSession: completeSession());
    final AppLocalizations en = await _en();

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(en.sortTitle));
    await tester.pumpAndSettle();
    expect(find.text(en.sortTitle), findsOneWidget);
    await tester.tap(find.text(en.sortLowestPrice).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.sortApply));
    await tester.pumpAndSettle();

    expect(find.byType(HotelSummaryCard), findsWidgets);
  });

  testWidgets('discover → hotel detail → stay dates → available rooms',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      bootSession: completeSession(),
      extraOverrides: _fixedClock,
    );
    final AppLocalizations en = await _en();

    await tester.tap(find.text('The Oasis Hotel').first);
    await tester.pumpAndSettle();
    expect(find.text(en.hotelSelectDates), findsOneWidget);

    await tester.tap(find.text(en.hotelSelectDates));
    await tester.pumpAndSettle();
    expect(find.text(en.stayDatesTitle), findsOneWidget);
    expect(find.byType(StayRangeCalendar), findsOneWidget);
    // Guidance line, empty state.
    expect(find.text(en.stayDatesHintPickCheckIn), findsOneWidget);

    // CTA disabled until both dates chosen.
    final Finder cta = find.widgetWithText(FilledButton, en.stayDatesShowRooms);
    expect(tester.widget<FilledButton>(cta).onPressed, isNull);

    await tester.tap(find.descendant(
      of: find.byType(StayRangeCalendar),
      matching: find.text('6'),
    ).first);
    await tester.pumpAndSettle();
    // After the first tap the guidance moves past the initial hint.
    expect(find.text(en.stayDatesHintPickCheckIn), findsNothing);

    await tester.tap(find.descendant(
      of: find.byType(StayRangeCalendar),
      matching: find.text('8'),
    ).first);
    await tester.pumpAndSettle();
    // Both chosen → range + nights guidance and an enabled CTA.
    expect(find.textContaining(en.stayNights(2)), findsWidgets);

    final Finder cta2 = find.widgetWithText(FilledButton, en.stayDatesShowRooms);
    expect(tester.widget<FilledButton>(cta2).onPressed, isNotNull);

    await tester.tap(cta2);
    await tester.pumpAndSettle();

    expect(find.text(en.roomsTitle), findsWidgets);
    expect(find.byType(RoomSummaryCard), findsWidgets);
    // The stay summary card shows the hotel and labelled dates.
    expect(find.text('The Oasis Hotel'), findsWidgets);
    expect(find.text(en.stayDatesCheckIn), findsWidgets);

    // Open a room's detail page.
    await tester.tap(find.widgetWithText(OutlinedButton, en.roomViewDetails).first);
    await tester.pumpAndSettle();
    expect(find.text(en.roomSelectThisRoom), findsOneWidget);
    expect(find.text(en.roomDetailAmenitiesHeading), findsOneWidget);
    expect(find.text(en.roomDetailCancellationHeading), findsOneWidget);
  });

  testWidgets('too many guests shows the no-rooms state with recovery actions',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      bootSession: completeSession(),
      extraOverrides: _fixedClock,
    );
    final AppLocalizations en = await _en();

    await tester.tap(find.text('The Oasis Hotel').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.hotelSelectDates));
    await tester.pumpAndSettle();
    await tester.tap(find.text('6').first);
    await tester.pump();
    await tester.tap(find.text('8').first);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, en.stayDatesShowRooms));
    await tester.pumpAndSettle();

    // Bump the party past every room's occupancy via the guests sheet
    // ("Edit" link in the stay summary card).
    await tester.tap(find.text(en.commonEdit).first);
    await tester.pumpAndSettle();
    for (int i = 0; i < 6; i++) {
      await tester.tap(find.widgetWithIcon(IconButton, Icons.add).first);
      await tester.pump();
    }
    await tester.tap(find.text(en.guestsConfirm));
    await tester.pumpAndSettle();

    expect(find.text(en.roomsNoResultsTitle), findsWidgets);
    expect(find.text(en.roomsChangeDates), findsWidgets);
  });
}
