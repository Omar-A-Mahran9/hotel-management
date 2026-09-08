import 'package:flutter/foundation.dart';

import '../../../reservation/domain/entities/reservation.dart';
import '../../../reservation/domain/entities/reservation_status.dart';
import 'loyalty_transaction.dart';

/// The context the guest app can seed a loyalty read/operation with, from the
/// authoritative reservation the guest already holds.
///
/// The backend guest endpoints (once they exist) need **none** of this — the
/// server resolves the account, the guest, the balance, the rate and the
/// reservation eligibility itself. The dummy source uses it to build behaviour
/// consistent with the reservation the guest sees.
@immutable
class LoyaltyContext {
  const LoyaltyContext({
    required this.reservationId,
    required this.reservationStatus,
    required this.reservationAmount,
    required this.currency,
  });

  factory LoyaltyContext.forReservation(Reservation reservation) =>
      LoyaltyContext(
        reservationId: reservation.id,
        reservationStatus: reservation.status,
        reservationAmount: reservation.priceSnapshot.amount,
        currency: reservation.priceSnapshot.currency,
      );

  final String reservationId;
  final ReservationStatus reservationStatus;
  final int reservationAmount;
  final String currency;

  /// A completed/stayed booking — the backend's earn eligibility
  /// (`LoyaltyService::COMPLETED_RESERVATION_STATUSES`). A **UX pre-check
  /// only**; the backend stays authoritative.
  bool get isCompletedStay =>
      reservationStatus == ReservationStatus.checkedOut ||
      reservationStatus == ReservationStatus.invoiced;

  /// An active, not-yet-completed, not-cancelled booking — the backend's
  /// redeem eligibility (`LoyaltyService::REDEEMABLE_RESERVATION_STATUSES`).
  bool get isRedeemableBooking => switch (reservationStatus) {
        ReservationStatus.pending ||
        ReservationStatus.depositHeld ||
        ReservationStatus.verified ||
        ReservationStatus.checkedIn ||
        ReservationStatus.inStay =>
          true,
        _ => false,
      };
}

/// The safe, client-visible outcome of an **earn** attempt. The MVP backend's
/// earn is idempotent (a second call returns the existing entry) and throws a
/// 422 for a business precondition. This models both paths as an outcome — never
/// as a false success and never by mutating the balance locally.
enum LoyaltyEarnOutcome {
  /// A new `earn` entry was created.
  earned,

  /// Points for this reservation were already accrued — the existing entry is
  /// returned (not an error).
  alreadyEarned,

  /// The backend refused: the reservation is not a completed stay.
  notEligible,

  /// The group's loyalty program is off / has no earn rate configured.
  programInactive,

  /// The completed booking had no value to earn from.
  nothingToEarn;

  bool get isSuccess =>
      this == LoyaltyEarnOutcome.earned ||
      this == LoyaltyEarnOutcome.alreadyEarned;

  /// A blocked outcome the guest cannot fix by retrying.
  bool get isBlocked => !isSuccess;
}

@immutable
class EarnPointsResult {
  const EarnPointsResult({required this.outcome, this.transaction});

  final LoyaltyEarnOutcome outcome;

  /// Present for [LoyaltyEarnOutcome.earned] / [alreadyEarned].
  final LoyaltyTransaction? transaction;

  @override
  bool operator ==(Object other) =>
      other is EarnPointsResult &&
      other.outcome == outcome &&
      other.transaction == transaction;

  @override
  int get hashCode => Object.hash(outcome, transaction);
}

/// A request to accrue points for a completed reservation. The approved backend
/// `POST /reservations/{reservation}/loyalty/earn` carries **no body**; the
/// idempotency is the `(account, type, source)` uniqueness. This request only
/// carries the reservation id + a stable local key.
@immutable
class EarnPointsRequest {
  const EarnPointsRequest({required this.reservationId});

  final String reservationId;

  /// Stable key for local duplicate-submit dedupe. No time / randomness.
  String get idempotencyKey => 'loyalty:earn:$reservationId';

  @override
  bool operator ==(Object other) =>
      other is EarnPointsRequest && other.reservationId == reservationId;

  @override
  int get hashCode => reservationId.hashCode;

  @override
  String toString() => 'EarnPointsRequest($idempotencyKey)';
}

/// The safe, client-visible outcome of a **redeem** attempt.
enum LoyaltyRedeemOutcome {
  /// Points were redeemed against the booking.
  redeemed,

  /// A redemption for this booking already exists with the same amount — an
  /// idempotent replay (not an error).
  alreadyRedeemed,

  /// A different redemption already exists for this booking.
  alreadyRedeemedDifferent,

  /// The account does not have enough points.
  insufficientPoints,

  /// The reservation is not an eligible (active, non-completed) booking.
  notEligible,

  /// The group's loyalty program is off / has no redeem rate configured.
  programInactive,

  /// The points amount is not a positive integer.
  invalidAmount;

  bool get isSuccess =>
      this == LoyaltyRedeemOutcome.redeemed ||
      this == LoyaltyRedeemOutcome.alreadyRedeemed;

  bool get isBlocked => !isSuccess;
}

@immutable
class RedeemPointsResult {
  const RedeemPointsResult({required this.outcome, this.transaction});

  final LoyaltyRedeemOutcome outcome;

  /// Present for [LoyaltyRedeemOutcome.redeemed] / [alreadyRedeemed].
  final LoyaltyTransaction? transaction;

  @override
  bool operator ==(Object other) =>
      other is RedeemPointsResult &&
      other.outcome == outcome &&
      other.transaction == transaction;

  @override
  int get hashCode => Object.hash(outcome, transaction);
}

/// A request to redeem [points] against an eligible booking. Mirrors the
/// approved backend `POST /reservations/{reservation}/loyalty/redeem` body
/// (`points` — a positive integer; nothing else). The account, balance, point
/// value and ledger delta are all backend-derived.
@immutable
class RedeemPointsRequest {
  const RedeemPointsRequest({
    required this.reservationId,
    required this.points,
  });

  final String reservationId;
  final int points;

  /// Stable key for local dedupe. The points amount is part of it so a changed
  /// amount is a different operation; no time / randomness.
  String get idempotencyKey => 'loyalty:redeem:$reservationId:$points';

  @override
  bool operator ==(Object other) =>
      other is RedeemPointsRequest &&
      other.reservationId == reservationId &&
      other.points == points;

  @override
  int get hashCode => Object.hash(reservationId, points);

  @override
  String toString() => 'RedeemPointsRequest($idempotencyKey)';
}
