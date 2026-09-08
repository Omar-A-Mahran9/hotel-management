import 'package:flutter/foundation.dart';

import '../../../reservation/domain/entities/reservation.dart';
import '../../../reservation/domain/entities/reservation_status.dart';

/// The guest's in-progress review — a rating and optional text, before it is
/// submitted. Validation lives here so the form widget stays dumb.
@immutable
class ReviewDraft {
  const ReviewDraft({this.rating = 0, this.text = ''});

  /// 0 means "not chosen yet". A valid submission needs [minRating]–[maxRating].
  final int rating;

  /// Raw text as typed. [normalizedText] is what actually gets submitted.
  final String text;

  static const int minRating = 1;
  static const int maxRating = 5;

  bool get isRatingChosen => rating >= minRating && rating <= maxRating;

  /// Trimmed text, or `null` when it is empty / whitespace-only — a
  /// whitespace-only body is never submitted.
  String? get normalizedText {
    final String t = text.trim();
    return t.isEmpty ? null : t;
  }

  bool get canSubmit => isRatingChosen;

  ReviewDraft copyWith({int? rating, String? text}) =>
      ReviewDraft(rating: rating ?? this.rating, text: text ?? this.text);

  @override
  bool operator ==(Object other) =>
      other is ReviewDraft && other.rating == rating && other.text == text;

  @override
  int get hashCode => Object.hash(rating, text);
}

/// Whether the guest can review this reservation, judged from the reservation
/// status the app already holds. The backend stays authoritative; this is a UX
/// pre-check.
///
/// A review belongs to a completed/stayed reservation — the same definition the
/// backend `LoyaltyService::COMPLETED_RESERVATION_STATUSES` uses for the
/// "completed stay" concept (Phase 0 §14).
enum ReviewEligibility {
  eligible,
  notCompleted,
  cancelled;

  static ReviewEligibility fromReservation(ReservationStatus status) {
    return switch (status) {
      ReservationStatus.checkedOut ||
      ReservationStatus.invoiced =>
        ReviewEligibility.eligible,
      ReservationStatus.cancelled => ReviewEligibility.cancelled,
      _ => ReviewEligibility.notCompleted,
    };
  }

  bool get canReview => this == ReviewEligibility.eligible;
}

/// The context the guest app can seed a review read/submission with. The future
/// backend guest endpoint resolves reservation ownership + eligibility itself.
@immutable
class ReviewContext {
  const ReviewContext({
    required this.reservationId,
    required this.reservationStatus,
  });

  factory ReviewContext.forReservation(Reservation reservation) => ReviewContext(
        reservationId: reservation.id,
        reservationStatus: reservation.status,
      );

  final String reservationId;
  final ReservationStatus reservationStatus;

  ReviewEligibility get eligibility =>
      ReviewEligibility.fromReservation(reservationStatus);
}
