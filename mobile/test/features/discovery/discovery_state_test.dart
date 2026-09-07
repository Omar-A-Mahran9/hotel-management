import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/di/core_providers.dart';
import 'package:hotel_guest_app/core/presentation/ui_state.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/availability_result.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/guest_party.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/room_sort.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/stay_range.dart';
import 'package:hotel_guest_app/features/discovery/domain/validators/stay_dates_validator.dart';
import 'package:hotel_guest_app/features/discovery/presentation/state/guest_party_controller.dart';
import 'package:hotel_guest_app/features/discovery/presentation/state/room_availability_controller.dart';
import 'package:hotel_guest_app/features/discovery/presentation/state/stay_dates_controller.dart';

import '../../support/test_config.dart';

ProviderContainer _container() {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[appConfigProvider.overrideWithValue(testConfig)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final DateTime today = DateTime(2026, 9, 1);

  group('StayDatesController', () {
    test('first tap sets check-in, second sets check-out', () {
      final ProviderContainer c = _container();
      final controller = c.read(stayDatesControllerProvider.notifier);

      controller.selectDay(DateTime(2026, 9, 6));
      expect(c.read(stayDatesControllerProvider).checkIn, DateTime(2026, 9, 6));
      expect(c.read(stayDatesControllerProvider).checkOut, isNull);

      controller.selectDay(DateTime(2026, 9, 8));
      final draft = c.read(stayDatesControllerProvider);
      expect(draft.checkOut, DateTime(2026, 9, 8));
      expect(draft.rangeAgainst(today)!.nights, 2);
    });

    test('a second tap before check-in restarts the selection', () {
      final ProviderContainer c = _container();
      final controller = c.read(stayDatesControllerProvider.notifier);
      controller.selectDay(DateTime(2026, 9, 8));
      controller.selectDay(DateTime(2026, 9, 6));
      expect(c.read(stayDatesControllerProvider).checkIn, DateTime(2026, 9, 6));
      expect(c.read(stayDatesControllerProvider).checkOut, isNull);
    });

    test('a third tap starts a new range', () {
      final ProviderContainer c = _container();
      final controller = c.read(stayDatesControllerProvider.notifier);
      controller.selectDay(DateTime(2026, 9, 6));
      controller.selectDay(DateTime(2026, 9, 8));
      controller.selectDay(DateTime(2026, 9, 20));
      final draft = c.read(stayDatesControllerProvider);
      expect(draft.checkIn, DateTime(2026, 9, 20));
      expect(draft.checkOut, isNull);
    });

    test('clear empties the draft', () {
      final ProviderContainer c = _container();
      final controller = c.read(stayDatesControllerProvider.notifier);
      controller.selectDay(DateTime(2026, 9, 6));
      controller.clear();
      expect(c.read(stayDatesControllerProvider).isEmpty, isTrue);
    });

    test('an incomplete draft reports the incomplete error', () {
      final ProviderContainer c = _container();
      c.read(stayDatesControllerProvider.notifier).selectDay(DateTime(2026, 9, 6));
      expect(
        c.read(stayDatesControllerProvider).errorAgainst(today),
        StayDatesError.incomplete,
      );
      expect(c.read(stayDatesControllerProvider).rangeAgainst(today), isNull);
    });
  });

  group('GuestPartyController', () {
    test('increments and decrements within bounds', () {
      final ProviderContainer c = _container();
      final controller = c.read(guestPartyControllerProvider.notifier);

      controller.incrementAdults();
      expect(c.read(guestPartyControllerProvider).adults, 3);

      for (int i = 0; i < 10; i++) {
        controller.decrementAdults();
      }
      expect(c.read(guestPartyControllerProvider).adults, GuestParty.minAdults);

      controller.incrementChildren();
      expect(c.read(guestPartyControllerProvider).children, 1);

      controller.reset();
      expect(c.read(guestPartyControllerProvider), GuestParty.initial);
    });
  });

  group('RoomAvailabilityController', () {
    StayRange range() =>
        StayRange(checkIn: DateTime(2026, 9, 6), checkOut: DateTime(2026, 9, 8));

    test('loads a success result sorted cheapest-first by default', () async {
      final ProviderContainer c = _container();
      final controller = c.read(roomAvailabilityControllerProvider.notifier);

      await controller.load(
        hotelId: 'oasis',
        stay: range(),
        party: GuestParty.initial,
      );

      final state = c.read(roomAvailabilityControllerProvider);
      expect(state.result, isA<UiSuccess<AvailabilityResult>>());
      final rooms =
          (state.result as UiSuccess<AvailabilityResult>).data.rooms;
      // bookable rooms first, then ascending price.
      final bookable = rooms.where((r) => r.isAvailable).toList();
      for (int i = 1; i < bookable.length; i++) {
        expect(
          bookable[i].nightlyRate.amount >= bookable[i - 1].nightlyRate.amount,
          isTrue,
        );
      }
    });

    test('a party too large for any room yields an empty state', () async {
      final ProviderContainer c = _container();
      await c.read(roomAvailabilityControllerProvider.notifier).load(
            hotelId: 'oasis',
            stay: range(),
            party: const GuestParty(adults: 6, children: 2),
          );
      expect(
        c.read(roomAvailabilityControllerProvider).result,
        isA<UiEmpty<AvailabilityResult>>(),
      );
    });

    test('setSort flips the order without refetching', () async {
      final ProviderContainer c = _container();
      final controller = c.read(roomAvailabilityControllerProvider.notifier);
      await controller.load(
          hotelId: 'oasis', stay: range(), party: GuestParty.initial);

      controller.setSort(RoomSort.priceDesc);
      final rooms = (c.read(roomAvailabilityControllerProvider).result
              as UiSuccess<AvailabilityResult>)
          .data
          .rooms;
      final bookable = rooms.where((r) => r.isAvailable).toList();
      for (int i = 1; i < bookable.length; i++) {
        expect(
          bookable[i].nightlyRate.amount <= bookable[i - 1].nightlyRate.amount,
          isTrue,
        );
      }
      expect(c.read(roomAvailabilityControllerProvider).sort, RoomSort.priceDesc);
    });

    test('reset returns to the initial state', () async {
      final ProviderContainer c = _container();
      final controller = c.read(roomAvailabilityControllerProvider.notifier);
      await controller.load(
          hotelId: 'oasis', stay: range(), party: GuestParty.initial);
      controller.reset();
      expect(
        c.read(roomAvailabilityControllerProvider).result,
        isA<UiInitial<AvailabilityResult>>(),
      );
    });
  });
}
