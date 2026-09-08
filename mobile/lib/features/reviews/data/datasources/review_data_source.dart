import '../../domain/entities/review.dart';
import '../../domain/entities/review_draft.dart';
import '../../domain/entities/submit_review.dart';

/// The reviews data contract. Dummy + API implementations selected by DI
/// (`AppConfig.useDummyData`), exactly like the other features.
abstract interface class ReviewDataSource {
  Future<Review?> fetchReview(ReviewContext context);

  Future<SubmitReviewResult> submit(
    SubmitReviewRequest request,
    ReviewContext context,
  );
}
