import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_guest_app/app/router/app_router.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/core/time/clock.dart';

import '../../support/auth_test_support.dart';
import '../../support/calendar_test_support.dart';
import '../../support/pump_app.dart';

final List<Override> _fixedClock = <Override>[
  clockProvider.overrideWithValue(() => DateTime(2026, 9, 1)),
];

Future<AppLocalizations> _en() =>
    AppLocalizations.delegate.load(const Locale('en'));

/// Drives the flow to the available-rooms page for The Oasis Hotel,
/// 6–8 September, default party.
Future<AppLocalizations> _openRooms(WidgetTester tester) async {
  await pumpApp(
    tester,
    bootSession: completeSession(),
    extraOverrides: _fixedClock,
  );
  final AppLocalizations en = await _en();

  await tester.tap(find.text('The Oasis Hotel').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(en.hotelBookNow));
  await tester.pumpAndSettle();
  await tapCalendarDay(tester, '6');
  await tapCalendarDay(tester, '8');
  await tester.tap(find.widgetWithText(FilledButton, en.stayDatesShowRooms));
  await tester.pumpAndSettle();
  return en;
}

/// Opens the first room's detail page and taps "Select this room".
Future<void> _selectFirstRoom(WidgetTester tester, AppLocalizations en) async {
  await tester.tap(find.widgetWithText(OutlinedButton, en.roomViewDetails).first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, en.roomSelectThisRoom));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('selecting a room enables Continue; the review page shows it',
      (WidgetTester tester) async {
    final AppLocalizations en = await _openRooms(tester);

    final Finder continueBtn =
        find.widgetWithText(FilledButton, en.roomsContinue);
    expect(tester.widget<FilledButton>(continueBtn).onPressed, isNull);
    expect(find.text(en.roomsSelectPrompt), findsOneWidget);

    await _selectFirstRoom(tester, en);

    // Back on the list: the room is marked selected and Continue is enabled.
    expect(find.text(en.roomSelected), findsWidgets);
    expect(tester.widget<FilledButton>(continueBtn).onPressed, isNotNull);

    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text(en.bookingDetailsTitle), findsOneWidget);
    expect(find.text('The Oasis Hotel'), findsWidgets);
    expect(find.text('Standard Room'), findsWidgets);
    // 320 / night × 2 nights = 640 subtotal.
    expect(find.text(en.bookingRoomSubtotal), findsOneWidget);
    expect(find.text(en.bookingTotal), findsOneWidget);
  });

  testWidgets('changing the guest party clears a room selection with a notice',
      (WidgetTester tester) async {
    final AppLocalizations en = await _openRooms(tester);
    await _selectFirstRoom(tester, en);
    expect(find.text(en.roomSelected), findsWidgets);

    // Add an adult via the guests sheet ("Edit" in the summary card).
    await tester.tap(find.text(en.commonEdit).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithIcon(IconButton, Icons.add).first);
    await tester.pump();
    await tester.tap(find.text(en.guestsConfirm));
    await tester.pumpAndSettle();

    expect(find.text(en.roomsSelectionClearedNotice), findsOneWidget);
    expect(find.text(en.roomSelected), findsNothing);
    expect(
      tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, en.roomsContinue),
      ).onPressed,
      isNull,
    );
  });

  testWidgets('changing dates after selecting clears the selection',
      (WidgetTester tester) async {
    final AppLocalizations en = await _openRooms(tester);
    await _selectFirstRoom(tester, en);
    expect(find.text(en.roomSelected), findsWidgets);

    // "Edit dates" in the summary card → back to the calendar.
    await tester.tap(find.text(en.stayDatesEditDates).first);
    await tester.pumpAndSettle();
    expect(find.text(en.stayDatesTitle), findsOneWidget);

    // A new check-in day restarts the range and invalidates the selection.
    await tapCalendarDay(tester, '3');
    await tapCalendarDay(tester, '5');
    await tester.tap(find.widgetWithText(FilledButton, en.stayDatesShowRooms));
    await tester.pumpAndSettle();

    expect(find.text(en.roomSelected), findsNothing);
    expect(
      tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, en.roomsContinue),
      ).onPressed,
      isNull,
    );
  });

  testWidgets('the room detail page can remove an existing selection',
      (WidgetTester tester) async {
    final AppLocalizations en = await _openRooms(tester);
    await _selectFirstRoom(tester, en);
    expect(find.text(en.roomSelected), findsWidgets);

    // Re-open the same room's detail and remove the selection.
    await tester.tap(find.widgetWithText(OutlinedButton, en.roomViewDetails).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, en.roomRemoveSelection));
    await tester.pumpAndSettle();

    expect(find.text(en.roomSelected), findsNothing);
  });

  testWidgets('the review route shows an empty state when nothing is selected',
      (WidgetTester tester) async {
    final ProviderContainer container = await pumpApp(
      tester,
      bootSession: completeSession(),
      extraOverrides: _fixedClock,
    );
    final AppLocalizations en = await _en();

    final GoRouter router = container.read(appRouterProvider);
    router.go('/discover/hotel/oasis/review');
    await tester.pumpAndSettle();

    expect(find.text(en.reviewNoSelectionTitle), findsOneWidget);
    expect(find.text(en.reviewBackToRooms), findsOneWidget);
  });
}
