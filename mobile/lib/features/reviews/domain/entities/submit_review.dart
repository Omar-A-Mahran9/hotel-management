import 'package:flutter/foundation.dart';

import 'review.dart';
import 'review_draft.dart';

/// A request to submit a review for a reservation. Mirrors the review MVP
/// concept: numeric `rating` (1–5) + optional `text`, tied to one reservation.
/// No sub-ratings. The backend resolves reservation ownership + eligibility.
@immutable
class SubmitReviewRequest {
  const SubmitReviewRequest({
    required this.reservationId,
    required this.rating,
    this.text,
  });

  factory SubmitReviewRequest.fromDraft(
    String reservationId,
    ReviewDraft draft,
  ) =>
      SubmitReviewRequest(
        reservationId: reservationId,
        rating: draft.rating,
        text: draft.normalizedText,
      );

  final String reservationId;
  final int rating;
  final String? text;

  /// Rebuild the editable draft this request came from — used to re-seed the
  /// form / a retry without re-reading any widget state.
  ReviewDraft toDraft() => ReviewDraft(rating: rating, text: text ?? '');

  /// Stable key for local duplicate-submit dedupe. The rating + text are part
  /// of it so an edited submission is a distinct operation; no time / random.
  String get idempotencyKey =>
      'review:$reservationId:$rating:${text ?? '-'}';

  @override
  bool operator ==(Object other) =>
      other is SubmitReviewRequest &&
      other.reservationId == reservationId &&
      other.rating == rating &&
      other.text == text;

  @override
  int get hashCode => Object.hash(reservationId, rating, text);

  @override
  String toString() => 'SubmitReviewRequest($reservationId, r$rating)';
}

/// The safe, client-visible outcome of a submit attempt.
enum ReviewSubmitOutcome {
  /// The review was accepted. Its [Review.status] says whether it is pending
  /// moderation or already published — the UI must not claim it is live unless
  /// the status says so.
  submitted,

  /// A review for this reservation already exists — the existing one is
  /// returned (not an error).
  alreadyReviewed,

  /// The backend refused: the reservation is not a completed/stayed booking.
  notEligible,

  /// The rating was outside 1–5.
  invalidRating;

  bool get isSuccess =>
      this == ReviewSubmitOutcome.submitted ||
      this == ReviewSubmitOutcome.alreadyReviewed;
}

@immutable
class SubmitReviewResult {
  const SubmitReviewResult({required this.outcome, this.review});

  final ReviewSubmitOutcome outcome;

  /// Present for [ReviewSubmitOutcome.submitted] / [alreadyReviewed].
  final Review? review;

  @override
  bool operator ==(Object other) =>
      other is SubmitReviewResult &&
      other.outcome == outcome &&
      other.review == review;

  @override
  int get hashCode => Object.hash(outcome, review);
}
