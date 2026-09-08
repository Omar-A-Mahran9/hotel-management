import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/config/app_config.dart';
import 'package:hotel_guest_app/core/config/app_environment.dart';
import 'package:hotel_guest_app/core/errors/app_exception.dart';
import 'package:hotel_guest_app/core/network/api_client.dart';
import 'package:hotel_guest_app/core/security/in_memory_token_store.dart';
import 'package:hotel_guest_app/features/loyalty/data/datasources/api_loyalty_data_source.dart';
import 'package:hotel_guest_app/features/loyalty/data/datasources/dummy_loyalty_data_source.dart';
import 'package:hotel_guest_app/features/loyalty/domain/entities/loyalty_operations.dart';
import 'package:hotel_guest_app/features/loyalty/domain/entities/loyalty_transaction_type.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation_status.dart';

import 'loyalty_test_support.dart';

void main() {
  final DateTime now = DateTime(2026, 9, 8, 11);
  DummyLoyaltyDataSource source({bool seedLedger = true}) =>
      DummyLoyaltyDataSource(clock: () => now, seedLedger: seedLedger);

  group('DummyLoyaltyDataSource — reads', () {
    test('a seeded account has a cached balance and the program flag', () async {
      final String id = earnFreshActiveId();
      final account =
          await source().fetchAccount(fakeLoyaltyContext(reservationId: id));
      expect(account.pointsBalance, 1240);
      expect(account.isActive, isTrue);
    });

    test('an unseeded account is empty', () async {
      final account = await source(seedLedger: false)
          .fetchAccount(fakeLoyaltyContext(reservationId: earnFreshActiveId()));
      expect(account.pointsBalance, 0);
    });

    test('transactions come back newest-first', () async {
      final ledger =
          await source().fetchTransactions(fakeLoyaltyContext());
      expect(ledger, hasLength(3));
      for (int i = 0; i < ledger.length - 1; i++) {
        expect(
          ledger[i].createdAt!.isAfter(ledger[i + 1].createdAt!) ||
              ledger[i].createdAt!.isAtSameMomentAs(ledger[i + 1].createdAt!),
          isTrue,
        );
      }
    });

    test('the program is off for one deterministic slice', () async {
      final account = await source().fetchAccount(
          fakeLoyaltyContext(reservationId: programInactiveId()));
      expect(account.isActive, isFalse);
    });
  });

  group('DummyLoyaltyDataSource — earn', () {
    test('a fresh completed stay earns points and appends one ledger entry',
        () async {
      final String id = earnFreshActiveId();
      final s = source();
      final before = (await s.fetchAccount(fakeLoyaltyContext(reservationId: id)))
          .pointsBalance;

      final result = await s.earn(
        EarnPointsRequest(reservationId: id),
        fakeLoyaltyContext(reservationId: id, amount: 900),
      );
      expect(result.outcome, LoyaltyEarnOutcome.earned);
      expect(result.transaction!.type, LoyaltyTransactionType.earn);
      expect(result.transaction!.points, 450); // 900 / 2 (dummy sample rate)

      final after = await s.fetchAccount(fakeLoyaltyContext(reservationId: id));
      expect(after.pointsBalance, before + 450);
      expect(await s.fetchTransactions(fakeLoyaltyContext()), hasLength(4));
    });

    test('earn is idempotent — a second call returns the existing entry, '
        'no double accrual', () async {
      final String id = earnFreshActiveId();
      final s = source();
      final first = await s.earn(EarnPointsRequest(reservationId: id),
          fakeLoyaltyContext(reservationId: id));
      final balAfterFirst =
          (await s.fetchAccount(fakeLoyaltyContext(reservationId: id)))
              .pointsBalance;

      final second = await s.earn(EarnPointsRequest(reservationId: id),
          fakeLoyaltyContext(reservationId: id));
      expect(first.outcome, LoyaltyEarnOutcome.earned);
      expect(second.outcome, LoyaltyEarnOutcome.alreadyEarned);
      expect(second.transaction!.id, first.transaction!.id);
      expect(
        (await s.fetchAccount(fakeLoyaltyContext(reservationId: id)))
            .pointsBalance,
        balAfterFirst,
      );
    });

    test('the "already earned" scenario returns alreadyEarned on the first call',
        () async {
      final String id = earnAlreadyActiveId();
      final result = await source().earn(EarnPointsRequest(reservationId: id),
          fakeLoyaltyContext(reservationId: id));
      expect(result.outcome, LoyaltyEarnOutcome.alreadyEarned);
      expect(result.transaction, isNotNull);
    });

    test('a not-yet-completed stay is not eligible', () async {
      final String id = earnFreshActiveId();
      final result = await source().earn(
        EarnPointsRequest(reservationId: id),
        fakeLoyaltyContext(
            reservationId: id, status: ReservationStatus.checkedIn),
      );
      expect(result.outcome, LoyaltyEarnOutcome.notEligible);
    });

    test('an inactive program blocks earning', () async {
      final String id = programInactiveId();
      final result = await source().earn(EarnPointsRequest(reservationId: id),
          fakeLoyaltyContext(reservationId: id));
      expect(result.outcome, LoyaltyEarnOutcome.programInactive);
    });

    test('a completed stay with no earnable value yields nothingToEarn',
        () async {
      final String id = earnFreshActiveId();
      final result = await source().earn(
        EarnPointsRequest(reservationId: id),
        fakeLoyaltyContext(reservationId: id, amount: 1),
      );
      expect(result.outcome, LoyaltyEarnOutcome.nothingToEarn);
    });
  });

  group('DummyLoyaltyDataSource — redeem', () {
    LoyaltyContext redeemCtx(String id) => fakeLoyaltyContext(
        reservationId: id, status: ReservationStatus.checkedIn);

    test('redeeming against an eligible booking debits the balance', () async {
      final String id = redeemOkActiveId();
      final s = source();
      final result = await s.redeem(
        RedeemPointsRequest(reservationId: id, points: 100),
        redeemCtx(id),
      );
      expect(result.outcome, LoyaltyRedeemOutcome.redeemed);
      expect(result.transaction!.points, -100);
      expect(
        (await s.fetchAccount(redeemCtx(id))).pointsBalance,
        1240 - 100,
      );
    });

    test('redeeming the same amount again is an idempotent replay', () async {
      final String id = redeemAlreadyActiveId();
      final s = source();
      final first = await s.redeem(
          RedeemPointsRequest(reservationId: id, points: 100), redeemCtx(id));
      final second = await s.redeem(
          RedeemPointsRequest(reservationId: id, points: 100), redeemCtx(id));
      expect(first.outcome, LoyaltyRedeemOutcome.alreadyRedeemed);
      expect(second.outcome, LoyaltyRedeemOutcome.alreadyRedeemed);
    });

    test('a different amount against an already-redeemed booking is blocked',
        () async {
      final String id = redeemAlreadyActiveId();
      final s = source();
      await s.redeem(
          RedeemPointsRequest(reservationId: id, points: 100), redeemCtx(id));
      final other = await s.redeem(
          RedeemPointsRequest(reservationId: id, points: 150), redeemCtx(id));
      expect(other.outcome, LoyaltyRedeemOutcome.alreadyRedeemedDifferent);
    });

    test('redeeming more than the balance is insufficientPoints', () async {
      final String id = redeemOkActiveId();
      final result = await source(seedLedger: false).redeem(
        RedeemPointsRequest(reservationId: id, points: 50),
        redeemCtx(id),
      );
      expect(result.outcome, LoyaltyRedeemOutcome.insufficientPoints);
    });

    test('a non-positive amount is invalidAmount', () async {
      final String id = redeemOkActiveId();
      final result = await source().redeem(
        RedeemPointsRequest(reservationId: id, points: 0),
        redeemCtx(id),
      );
      expect(result.outcome, LoyaltyRedeemOutcome.invalidAmount);
    });

    test('redeeming against a completed (non-active) booking is not eligible',
        () async {
      final String id = redeemOkActiveId();
      final result = await source().redeem(
        RedeemPointsRequest(reservationId: id, points: 100),
        fakeLoyaltyContext(
            reservationId: id, status: ReservationStatus.checkedOut),
      );
      expect(result.outcome, LoyaltyRedeemOutcome.notEligible);
    });
  });

  group('DummyLoyaltyDataSource — failWith seam', () {
    test('surfaces the error from every method', () async {
      final s = source()..failWith = const NetworkException();
      await expectLater(
          s.fetchAccount(fakeLoyaltyContext()), throwsA(isA<NetworkException>()));
      await expectLater(s.fetchTransactions(fakeLoyaltyContext()),
          throwsA(isA<NetworkException>()));
      await expectLater(
        s.earn(const EarnPointsRequest(reservationId: 'x'), fakeLoyaltyContext()),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        s.redeem(const RedeemPointsRequest(reservationId: 'x', points: 1),
            fakeLoyaltyContext()),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('ApiLoyaltyDataSource', () {
    final source = ApiLoyaltyDataSource(
      ApiClient(
        config: const AppConfig(
          environment: AppEnvironment.development,
          apiBaseUrl: 'http://localhost',
          apiVersion: 'v1',
          useDummyData: false,
        ),
        tokenStore: InMemoryTokenStore(),
      ),
    );

    test('every method is a documented not-implemented stub', () {
      expect(source.fetchAccount(fakeLoyaltyContext()),
          throwsA(isA<NotImplementedInPhaseException>()));
      expect(source.fetchTransactions(fakeLoyaltyContext()),
          throwsA(isA<NotImplementedInPhaseException>()));
      expect(
        source.earn(
            const EarnPointsRequest(reservationId: '1'), fakeLoyaltyContext()),
        throwsA(isA<NotImplementedInPhaseException>()),
      );
      expect(
        source.redeem(const RedeemPointsRequest(reservationId: '1', points: 1),
            fakeLoyaltyContext()),
        throwsA(isA<NotImplementedInPhaseException>()),
      );
    });
  });
}
