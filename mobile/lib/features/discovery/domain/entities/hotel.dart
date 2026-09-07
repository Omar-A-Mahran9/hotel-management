import 'package:flutter/foundation.dart';

import 'hotel_summary.dart';
import 'localized_text.dart';

/// A guest-facing hotel amenity shown as a chip on the detail screen
/// (`02 · Discover & Book`, screen 3). Only the values the design represents.
enum HotelAmenity {
  freeWifi,
  breakfast,
  parking,
  pool,
  gym,
  familyRooms,
  airportShuttle,
  roomService,
}

/// The rating breakdown shown under "التقييم والمراجعات" — a small set of named
/// sub-scores plus the overall average and review count.
@immutable
class ReviewScores {
  const ReviewScores({
    required this.overall,
    required this.count,
    required this.cleanliness,
    required this.communication,
  });

  final double overall;
  final int count;
  final double cleanliness;
  final double communication;

  @override
  bool operator ==(Object other) =>
      other is ReviewScores &&
      other.overall == overall &&
      other.count == count &&
      other.cleanliness == cleanliness &&
      other.communication == communication;

  @override
  int get hashCode => Object.hash(overall, count, cleanliness, communication);
}

/// The full hotel, backing the detail screen. Composes [summary] so lists and
/// the detail screen share exactly one source of the shared fields.
@immutable
class Hotel {
  const Hotel({
    required this.summary,
    required this.description,
    required this.amenities,
    required this.reviewScores,
    required this.roomTypeCount,
    required this.photoCount,
  });

  final HotelSummary summary;
  final LocalizedText description;
  final List<HotelAmenity> amenities;
  final ReviewScores? reviewScores;

  /// Number of room types the hotel offers — the detail screen shows it and the
  /// photo strip uses [photoCount] for its "+N" overflow tile.
  final int roomTypeCount;
  final int photoCount;

  String get id => summary.id;
  LocalizedText get name => summary.name;

  @override
  bool operator ==(Object other) =>
      other is Hotel &&
      other.summary == summary &&
      other.description == description &&
      listEquals(other.amenities, amenities) &&
      other.reviewScores == reviewScores &&
      other.roomTypeCount == roomTypeCount &&
      other.photoCount == photoCount;

  @override
  int get hashCode => Object.hash(
        summary,
        description,
        Object.hashAll(amenities),
        reviewScores,
        roomTypeCount,
        photoCount,
      );
}
