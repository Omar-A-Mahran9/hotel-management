// Data-transfer models for the reviews feature.
//
// There is NO backend review domain in the MVP. This model mirrors the shape a
// future guest review endpoint is expected to return (see the phase doc):
// `id`, `reservation_id`, `rating`, `text`, `status`, `created_at`.

import '../../domain/entities/review.dart';

typedef Json = Map<String, Object?>;

class ReviewModel {
  const ReviewModel(this._json);
  final Json _json;

  Review toEntity() {
    final Object? rawText = _json['text'];
    final String? text = rawText is String && rawText.trim().isNotEmpty
        ? rawText.trim()
        : null;
    final Object? rawDate = _json['created_at'];
    return Review(
      id: '${_json['id']}',
      reservationId: '${_json['reservation_id']}',
      rating: (_json['rating'] as num?)?.toInt() ?? 0,
      text: text,
      status: ReviewStatus.fromWire(_json['status'] as String?),
      createdAt: rawDate is String && rawDate.isNotEmpty
          ? DateTime.tryParse(rawDate)
          : null,
    );
  }
}

/// The submit request body, as far as the expected contract goes.
class SubmitReviewPayload {
  const SubmitReviewPayload({required this.rating, this.text});

  final int rating;
  final String? text;

  Json toJson() => <String, Object?>{
        'rating': rating,
        if (text != null) 'text': text,
      };
}
