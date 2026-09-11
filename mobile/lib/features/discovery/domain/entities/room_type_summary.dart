import 'package:flutter/foundation.dart';

import 'localized_text.dart';
import 'money.dart';

/// A room-level amenity shown as an icon/label on the available-room card
/// (`16 · Stay dates & available rooms`). Only the values the design shows.
enum RoomAmenity { freeWifi, airConditioning, cityView, balcony, kitchenette }

/// The compact view of a room type in the available-rooms list.
///
/// [maxOccupancy], [breakfastIncluded] and [refundable] are attributes the
/// design's room chips display ("2 أشخاص", "إفطار مجاني", "إلغاء مجاني"); they
/// are not booking rules the mobile app enforces.
@immutable
class RoomTypeSummary {
  const RoomTypeSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.bedType,
    required this.maxOccupancy,
    required this.amenities,
    required this.nightlyRate,
    required this.breakfastIncluded,
    required this.refundable,
    this.areaSqm,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText bedType;
  final int maxOccupancy;
  final List<RoomAmenity> amenities;
  final Money nightlyRate;
  final bool breakfastIncluded;
  final bool refundable;

  /// Room floor area in square metres, shown as a spec chip on the room / hotel
  /// detail screens (`32 م²`). `null` when the source does not provide it.
  final int? areaSqm;

  @override
  bool operator ==(Object other) =>
      other is RoomTypeSummary &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.bedType == bedType &&
      other.maxOccupancy == maxOccupancy &&
      listEquals(other.amenities, amenities) &&
      other.nightlyRate == nightlyRate &&
      other.breakfastIncluded == breakfastIncluded &&
      other.refundable == refundable &&
      other.areaSqm == areaSqm;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        bedType,
        maxOccupancy,
        Object.hashAll(amenities),
        nightlyRate,
        breakfastIncluded,
        refundable,
        areaSqm,
      );
}
