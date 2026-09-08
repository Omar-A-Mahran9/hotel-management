import '../../../../core/data/data_source.dart';
import '../../domain/entities/loyalty_account.dart';
import '../../domain/entities/loyalty_operations.dart';
import '../../domain/entities/loyalty_transaction.dart';
import '../../domain/entities/loyalty_transaction_type.dart';
import 'loyalty_data_source.dart';

/// A deterministic earn scenario, chosen purely from the reservation id.
enum DummyEarnScenario { earnsFresh, alreadyEarned }

/// A deterministic redeem scenario, chosen purely from the reservation id.
enum DummyRedeemScenario { redeemsOk, alreadyRedeemed }

/// Deterministic, offline loyalty source used while no guest-facing loyalty
/// contract is approved. One instance holds one guest's account + ledger for
/// the whole session.
///
/// Guarantees required by the phase brief:
/// * no network, no timers, no randomness, no `DateTime.now()` branching (a
///   `clock` is injected for entry timestamps only);
/// * the earn/redeem *scenario* is a pure function of the reservation id
///   ([earnScenarioFor] / [redeemScenarioFor] / [programActiveFor]);
/// * `earn` is idempotent — a second call for the same reservation returns the
///   existing entry ([LoyaltyEarnOutcome.alreadyEarned]) and never
///   double-accrues; `redeem` is idempotent for the same amount;
/// * the balance is the account cache — it is only ever changed **here**,
///   alongside a ledger append; the presentation layer re-reads it and never
///   computes a new balance itself;
/// * the earn / redeem **rates** below are documented dummy samples, not a
///   production rule (there is no seeded backend rate — §13).
///
/// [failWith] is a test seam. [seedLedger] controls whether the account starts
/// with a couple of historical entries (for the "empty history" scenario).
class DummyLoyaltyDataSource implements LoyaltyDataSource, DummyDataSource {
  DummyLoyaltyDataSource({DateTime Function()? clock, bool seedLedger = true})
      : _clock = clock ?? DateTime.now {
    _balance = seedLedger ? 1240 : 0;
    if (seedLedger) {
      final DateTime t = _clock();
      _ledger.addAll(<LoyaltyTransaction>[
        LoyaltyTransaction(
          id: 'seed-earn-1',
          type: LoyaltyTransactionType.earn,
          points: 450,
          description: 'Points earned for a completed stay',
          sourceType: 'reservation',
          sourceId: 'past-oasis',
          createdAt: t.subtract(const Duration(days: 40)),
          earnBaseAmount: '900.00',
        ),
        LoyaltyTransaction(
          id: 'seed-earn-2',
          type: LoyaltyTransactionType.earn,
          points: 1080,
          description: 'Points earned for a completed stay',
          sourceType: 'reservation',
          sourceId: 'past-palm',
          createdAt: t.subtract(const Duration(days: 20)),
          earnBaseAmount: '2160.00',
        ),
        LoyaltyTransaction(
          id: 'seed-redeem-1',
          type: LoyaltyTransactionType.redeem,
          points: -290,
          description: 'Points redeemed against a booking',
          sourceType: 'reservation',
          sourceId: 'past-palm',
          createdAt: t.subtract(const Duration(days: 18)),
          notionalValue: '14.50',
        ),
      ]);
    }
  }

  /// Dummy sample: 1 point per 2 currency units earned (backend uses a
  /// Group-Owner-configured `earn_points_per_currency`).
  static const int _earnCurrencyPerPoint = 2;

  /// Dummy sample: each point is worth 0.05 currency notionally (backend uses
  /// a configured `redeem_currency_per_point`).
  static const int _redeemMilliCurrencyPerPoint = 50; // 0.050

  final DateTime Function() _clock;
  final List<LoyaltyTransaction> _ledger = <LoyaltyTransaction>[];
  final Set<String> _earnedReservations = <String>{};
  final Map<String, int> _redeemedReservations = <String, int>{};
  late int _balance;
  int _seq = 0;

  /// When non-null, the next call throws this instead.
  Object? failWith;

  // ── deterministic scenario selection ──────────────────────────────

  static DummyEarnScenario earnScenarioFor(String reservationId) =>
      _fnv1a('earn:$reservationId') % 2 == 0
          ? DummyEarnScenario.earnsFresh
          : DummyEarnScenario.alreadyEarned;

  static DummyRedeemScenario redeemScenarioFor(String reservationId) =>
      _fnv1a('redeem:$reservationId') % 2 == 0
          ? DummyRedeemScenario.redeemsOk
          : DummyRedeemScenario.alreadyRedeemed;

  /// The group loyalty program is off for one deterministic slice of
  /// reservations (mirrors "loyalty is OFF until a valid rule is configured").
  static bool programActiveFor(String reservationId) =>
      _fnv1a('program:$reservationId') % 5 != 0;

  // ── reads ────────────────────────────────────────────────────────

  @override
  Future<LoyaltyAccount> fetchAccount(LoyaltyContext context) async {
    if (failWith != null) throw failWith!;
    return LoyaltyAccount(
      id: 'dummy-account',
      pointsBalance: _balance,
      isActive: programActiveFor(context.reservationId),
    );
  }

  @override
  Future<List<LoyaltyTransaction>> fetchTransactions(
    LoyaltyContext context,
  ) async {
    if (failWith != null) throw failWith!;
    final List<LoyaltyTransaction> out = List<LoyaltyTransaction>.of(_ledger)
      ..sort((LoyaltyTransaction a, LoyaltyTransaction b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return out;
  }

  // ── earn ─────────────────────────────────────────────────────────

  @override
  Future<EarnPointsResult> earn(
    EarnPointsRequest request,
    LoyaltyContext context,
  ) async {
    if (failWith != null) throw failWith!;

    if (!programActiveFor(request.reservationId)) {
      return const EarnPointsResult(outcome: LoyaltyEarnOutcome.programInactive);
    }
    if (!context.isCompletedStay) {
      return const EarnPointsResult(outcome: LoyaltyEarnOutcome.notEligible);
    }

    final int points = context.reservationAmount ~/ _earnCurrencyPerPoint;
    if (points <= 0) {
      return const EarnPointsResult(outcome: LoyaltyEarnOutcome.nothingToEarn);
    }

    // `alreadyEarned` scenario: pre-seed the earn so the first call already
    // returns the existing entry (as the backend's idempotent earn does).
    if (earnScenarioFor(request.reservationId) ==
            DummyEarnScenario.alreadyEarned &&
        !_earnedReservations.contains(request.reservationId)) {
      _recordEarn(request.reservationId, points, context, backdatedDays: 3);
    }

    final LoyaltyTransaction? existing = _findBySource(
      LoyaltyTransactionType.earn,
      request.reservationId,
    );
    if (existing != null) {
      return EarnPointsResult(
        outcome: LoyaltyEarnOutcome.alreadyEarned,
        transaction: existing,
      );
    }

    final LoyaltyTransaction tx =
        _recordEarn(request.reservationId, points, context);
    return EarnPointsResult(
      outcome: LoyaltyEarnOutcome.earned,
      transaction: tx,
    );
  }

  LoyaltyTransaction _recordEarn(
    String reservationId,
    int points,
    LoyaltyContext context, {
    int backdatedDays = 0,
  }) {
    final LoyaltyTransaction tx = LoyaltyTransaction(
      id: 'earn-${++_seq}',
      type: LoyaltyTransactionType.earn,
      points: points,
      description: 'Points earned for a completed stay',
      sourceType: 'reservation',
      sourceId: reservationId,
      createdAt: _clock().subtract(Duration(days: backdatedDays)),
      earnBaseAmount: context.reservationAmount.toStringAsFixed(2),
    );
    _ledger.add(tx);
    _balance += points;
    _earnedReservations.add(reservationId);
    return tx;
  }

  // ── redeem ───────────────────────────────────────────────────────

  @override
  Future<RedeemPointsResult> redeem(
    RedeemPointsRequest request,
    LoyaltyContext context,
  ) async {
    if (failWith != null) throw failWith!;

    if (request.points < 1) {
      return const RedeemPointsResult(
          outcome: LoyaltyRedeemOutcome.invalidAmount);
    }
    if (!programActiveFor(request.reservationId)) {
      return const RedeemPointsResult(
          outcome: LoyaltyRedeemOutcome.programInactive);
    }
    if (!context.isRedeemableBooking) {
      return const RedeemPointsResult(
          outcome: LoyaltyRedeemOutcome.notEligible);
    }

    // `alreadyRedeemed` scenario: pre-seed a redemption for this booking.
    if (redeemScenarioFor(request.reservationId) ==
            DummyRedeemScenario.alreadyRedeemed &&
        !_redeemedReservations.containsKey(request.reservationId) &&
        _balance >= request.points) {
      _recordRedeem(request.reservationId, request.points, backdatedDays: 2);
    }

    final int? priorPoints = _redeemedReservations[request.reservationId];
    if (priorPoints != null) {
      if (priorPoints == request.points) {
        return RedeemPointsResult(
          outcome: LoyaltyRedeemOutcome.alreadyRedeemed,
          transaction:
              _findBySource(LoyaltyTransactionType.redeem, request.reservationId),
        );
      }
      return const RedeemPointsResult(
          outcome: LoyaltyRedeemOutcome.alreadyRedeemedDifferent);
    }

    if (_balance < request.points) {
      return const RedeemPointsResult(
          outcome: LoyaltyRedeemOutcome.insufficientPoints);
    }

    final LoyaltyTransaction tx =
        _recordRedeem(request.reservationId, request.points);
    return RedeemPointsResult(
      outcome: LoyaltyRedeemOutcome.redeemed,
      transaction: tx,
    );
  }

  LoyaltyTransaction _recordRedeem(
    String reservationId,
    int points, {
    int backdatedDays = 0,
  }) {
    final int notionalMilli = points * _redeemMilliCurrencyPerPoint;
    final String notionalWhole = (notionalMilli ~/ 1000).toString();
    final String notionalFraction =
        ((notionalMilli % 1000) ~/ 10).toString().padLeft(2, '0');
    final String notional = '$notionalWhole.$notionalFraction';
    final LoyaltyTransaction tx = LoyaltyTransaction(
      id: 'redeem-${++_seq}',
      type: LoyaltyTransactionType.redeem,
      points: -points,
      description: 'Points redeemed against a booking',
      sourceType: 'reservation',
      sourceId: reservationId,
      createdAt: _clock().subtract(Duration(days: backdatedDays)),
      notionalValue: notional,
    );
    _ledger.add(tx);
    _balance -= points;
    _redeemedReservations[reservationId] = points;
    return tx;
  }

  LoyaltyTransaction? _findBySource(
    LoyaltyTransactionType type,
    String reservationId,
  ) {
    for (final LoyaltyTransaction t in _ledger) {
      if (t.type == type && t.isForReservation(reservationId)) return t;
    }
    return null;
  }

  static int _fnv1a(String value) {
    int hash = 0x811c9dc5;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
