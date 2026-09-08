import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/review_draft.dart';
import '../../domain/entities/submit_review.dart';
import 'review_data_source.dart';

/// API-backed reviews source.
///
/// Kept a documented stub for Mobile Phase 10. Unlike loyalty (where the
/// endpoints exist but are staff-scoped), **there is no backend review domain
/// at all** — no `Review` model, migration, controller, resource or route in
/// the Laravel app. The whole guest review surface is unbuilt.
///
/// Expected future guest contract (see
/// `mobile/docs/mobile-phase-10-loyalty-reviews.md`):
///
/// * `GET  /api/v1/reservations/{reservation}/review`        → 200 ReviewResource | 404 (none yet)
/// * `POST /api/v1/reservations/{reservation}/review`        (`{ rating: 1..5, text?: string }`)
///        → 201 ReviewResource (status `pending` while moderation is on)
///        → 409 / 422 when a review already exists (return the existing one)
///        → 422 `reservation_not_completed:*` when not an eligible stay
///
/// One review per eligible reservation; eligibility + ownership + duplicate +
/// moderation are all resolved server-side. The `status` field
/// (`pending` / `published` / `rejected`) drives the client message — the app
/// never claims a review is live unless `published`.
///
/// Until an approved contract lands each method raises
/// [NotImplementedInPhaseException].
class ApiReviewDataSource implements ReviewDataSource, RemoteDataSource {
  ApiReviewDataSource(this._client);

  // Retained so wiring an approved endpoint stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'There is no guest (or any) review contract in the backend yet';

  @override
  Future<Review?> fetchReview(ReviewContext context) async {
    // final json = await _client.getJson(
    //   '/reservations/${context.reservationId}/review');
    // return ReviewModel(json['data'] as Map<String, Object?>).toEntity();
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<SubmitReviewResult> submit(
    SubmitReviewRequest request,
    ReviewContext context,
  ) async {
    // final body = SubmitReviewPayload(
    //   rating: request.rating, text: request.text).toJson();
    // final json = await _client.postJson(
    //   '/reservations/${request.reservationId}/review', body: body);
    // return SubmitReviewResult(
    //   outcome: ReviewSubmitOutcome.submitted,
    //   review: ReviewModel(json['data'] as Map<String, Object?>).toEntity(),
    // );
    throw const NotImplementedInPhaseException(_reason);
  }
}
