import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/errors/app_exception.dart';
import 'package:hotel_guest_app/features/loyalty/data/datasources/dummy_loyalty_data_source.dart';
import 'package:hotel_guest_app/features/loyalty/data/repositories/loyalty_repository_impl.dart';
import 'package:hotel_guest_app/features/loyalty/domain/entities/loyalty_operations.dart';
import 'package:hotel_guest_app/features/loyalty/presentation/state/loyalty_earn_controller.dart';
import 'package:hotel_guest_app/features/loyalty/presentation/state/loyalty_providers.dart';
import 'package:hotel_guest_app/features/loyalty/presentation/state/loyalty_redeem_controller.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/create_reservation_request.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/extend_stay.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation_status.dart';
import 'package:hotel_guest_app/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:hotel_guest_app/features/reservation/presentation/state/reservation_providers.dart';

import 'loyalty_test_support.dart';

final DateTime _now = DateTime(2026, 9, 8, 11);

class _ReservationRepo implements ReservationRepository {
  _ReservationRepo(this.status, {this.amount = 900});
  final ReservationStatus status;
  final int amount;
  @override
  Future<Reservation> create(CreateReservationRequest request) async =>
      fakeReservation(status: status, amount: amount);
  @override
  Future<Reservation> getById(String id) async =>
      fakeReservation(id: id, status: status, amount: amount);
  @override
  Future<List<Reservation>> list() async => <Reservation>[];

  @override
  Future<Reservation> cancel(String id) async => fakeReservation(id: id);

  @override
  Future<ExtendStayResult> extend(ExtendStayRequest request) async {
    throw UnimplementedError('extend not used in this test');
  }
}

ProviderContainer _container({
  required ReservationStatus status,
  DummyLoyaltyDataSource? source,
  int amount = 900,
}) {
  final ds = source ?? DummyLoyaltyDataSource(clock: () => _now);
  final c = ProviderContainer(overrides: <Override>[
    loyaltyDataSourceProvider.overrideWithValue(ds),
    loyaltyRepositoryProvider.overrideWithValue(LoyaltyRepositoryImpl(ds)),
    reservationRepositoryProvider
        .overrideWithValue(_ReservationRepo(status, amount: amount)),
  ]);
  addTearDown(c.dispose);
  c.listen(loyaltyEarnControllerProvider, (_, _) {});
  c.listen(loyaltyRedeemControllerProvider, (_, _) {});
  return c;
}

void main() {
  group('LoyaltyEarnController', () {
    test('idle → submitting → done with an earned outcome', () async {
      final id = earnFreshActiveId();
      final c = _container(status: ReservationStatus.checkedOut);
      expect(c.read(loyaltyEarnControllerProvider), isA<EarnIdle>());

      await c.read(loyaltyEarnControllerProvider.notifier).submit(id);

      final state = c.read(loyaltyEarnControllerProvider);
      expect(state, isA<EarnDone>());
      expect(state.resultOrNull!.outcome, LoyaltyEarnOutcome.earned);
    });

    test('a second submit after a successful earn is ignored', () async {
      final id = earnFreshActiveId();
      final c = _container(status: ReservationStatus.checkedOut);
      final n = c.read(loyaltyEarnControllerProvider.notifier);
      await n.submit(id);
      final first = c.read(loyaltyEarnControllerProvider).resultOrNull;
      await n.submit(id);
      final second = c.read(loyaltyEarnControllerProvider).resultOrNull;
      expect(identical(first, second), isTrue);
    });

    test('the balance is never mutated locally — the account provider re-reads',
        () async {
      final id = earnFreshActiveId();
      final c = _container(status: ReservationStatus.checkedOut);
      final before = await c.read(loyaltyAccountProvider(id).future);
      await c.read(loyaltyEarnControllerProvider.notifier).submit(id);
      final after = await c.read(loyaltyAccountProvider(id).future);
      expect(after.pointsBalance, before.pointsBalance + 450);
    });

    test('a not-eligible stay is a blocked done, not a Failure', () async {
      final id = earnFreshActiveId();
      final c = _container(status: ReservationStatus.checkedIn);
      await c.read(loyaltyEarnControllerProvider.notifier).submit(id);
      final state = c.read(loyaltyEarnControllerProvider);
      expect(state, isA<EarnDone>());
      expect(state.resultOrNull!.outcome, LoyaltyEarnOutcome.notEligible);
    });

    test('an infrastructure failure surfaces and a retry recovers', () async {
      final id = earnFreshActiveId();
      final ds = DummyLoyaltyDataSource(clock: () => _now)
        ..failWith = const NetworkException();
      final c = _container(status: ReservationStatus.checkedOut, source: ds);
      final n = c.read(loyaltyEarnControllerProvider.notifier);

      await n.submit(id);
      expect(c.read(loyaltyEarnControllerProvider), isA<EarnFailed>());

      ds.failWith = null;
      await n.submit(id);
      expect(c.read(loyaltyEarnControllerProvider), isA<EarnDone>());
    });

    test('reset returns to idle', () async {
      final id = earnFreshActiveId();
      final c = _container(status: ReservationStatus.checkedOut);
      final n = c.read(loyaltyEarnControllerProvider.notifier);
      await n.submit(id);
      n.reset();
      expect(c.read(loyaltyEarnControllerProvider), isA<EarnIdle>());
    });
  });

  group('LoyaltyRedeemController', () {
    test('redeems against an eligible booking', () async {
      final id = redeemOkActiveId();
      final c = _container(status: ReservationStatus.checkedIn);
      await c.read(loyaltyRedeemControllerProvider.notifier).submit(id, 100);
      final state = c.read(loyaltyRedeemControllerProvider);
      expect(state, isA<RedeemDone>());
      expect(state.resultOrNull!.outcome, LoyaltyRedeemOutcome.redeemed);
    });

    test('an invalid amount is a blocked done', () async {
      final id = redeemOkActiveId();
      final c = _container(status: ReservationStatus.checkedIn);
      await c.read(loyaltyRedeemControllerProvider.notifier).submit(id, 0);
      expect(c.read(loyaltyRedeemControllerProvider).resultOrNull!.outcome,
          LoyaltyRedeemOutcome.invalidAmount);
    });

    test('a changed amount is a distinct request and is allowed through',
        () async {
      final id = redeemAlreadyActiveId();
      final c = _container(status: ReservationStatus.checkedIn);
      final n = c.read(loyaltyRedeemControllerProvider.notifier);
      await n.submit(id, 100);
      expect(c.read(loyaltyRedeemControllerProvider).resultOrNull!.outcome,
          LoyaltyRedeemOutcome.alreadyRedeemed);
      await n.submit(id, 150);
      expect(c.read(loyaltyRedeemControllerProvider).resultOrNull!.outcome,
          LoyaltyRedeemOutcome.alreadyRedeemedDifferent);
    });
  });
}
