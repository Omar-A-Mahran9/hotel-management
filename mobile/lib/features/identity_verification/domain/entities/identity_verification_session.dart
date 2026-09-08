import 'package:flutter/foundation.dart';

import 'identity_verification_status.dart';

/// A safe, coarse classification of the automated match result, mirroring the
/// backend `latest_outcome` string on `IdentityVerificationResource` without
/// assuming its exact vocabulary. Never carries a score breakdown or any
/// provider detail.
enum IdentityMatchOutcome {
  match,
  noMatch,
  inconclusive,
  unknown;

  static IdentityMatchOutcome fromWire(String? value) => switch (value) {
        'match' || 'approved' || 'pass' => IdentityMatchOutcome.match,
        'no_match' || 'mismatch' || 'fail' => IdentityMatchOutcome.noMatch,
        'inconclusive' || 'manual' || 'review' => IdentityMatchOutcome.inconclusive,
        _ => IdentityMatchOutcome.unknown,
      };
}

/// An identity-verification session as the guest app knows it.
///
/// Mirrors the safe fields of the Laravel `IdentityVerificationResource`
/// (`reservation_id`, `status`, `attempts`, `latest_outcome`, `decided_at`).
/// Document/selfie storage paths, provider references, raw scores, attempt
/// metadata and PII are deliberately absent there and here
/// (md/mobile/architecture.md §8).
///
/// Laravel stays authoritative for [status]; the app never transitions a
/// session itself.
@immutable
class IdentityVerificationSession {
  const IdentityVerificationSession({
    required this.reservationId,
    required this.status,
    this.attempts = 0,
    this.latestOutcome = IdentityMatchOutcome.unknown,
    this.decidedAt,
  });

  /// A "nothing submitted yet" session for a reservation.
  factory IdentityVerificationSession.notStarted(String reservationId) =>
      IdentityVerificationSession(
        reservationId: reservationId,
        status: IdentityVerificationStatus.notStarted,
      );

  final String reservationId;
  final IdentityVerificationStatus status;
  final int attempts;
  final IdentityMatchOutcome latestOutcome;
  final DateTime? decidedAt;

  bool get isApproved => status.isApproved;
  bool get isManualReview => status.isManualReview;
  bool get isProcessing => status.isProcessing;
  bool get needsDocument => status.needsDocument;
  bool get needsSelfie => status.needsSelfie;

  /// Retry eligibility, as far as the app can tell — the state machine allows
  /// it and the backend has not said otherwise.
  bool get canRetry => status.allowsRetry;

  /// A resolved session that will not change without a new guest action
  /// (approved, or awaiting a staff decision).
  bool get isResolved => status.isApproved || status.isManualReview;

  IdentityVerificationSession copyWith({
    IdentityVerificationStatus? status,
    int? attempts,
    IdentityMatchOutcome? latestOutcome,
    DateTime? decidedAt,
  }) {
    return IdentityVerificationSession(
      reservationId: reservationId,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      latestOutcome: latestOutcome ?? this.latestOutcome,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is IdentityVerificationSession &&
      other.reservationId == reservationId &&
      other.status == status &&
      other.attempts == attempts &&
      other.latestOutcome == latestOutcome &&
      other.decidedAt == decidedAt;

  @override
  int get hashCode =>
      Object.hash(reservationId, status, attempts, latestOutcome, decidedAt);

  @override
  String toString() =>
      'IdentityVerificationSession($reservationId, ${status.wireValue}, '
      'attempts: $attempts)';
}
