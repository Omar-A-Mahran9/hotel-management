import 'package:flutter/foundation.dart';

/// An inclusive nightly-rate window. The bounds shown in the filter sheet come
/// from the spread of the dataset (min/max nightly rate), not an invented range.
@immutable
class PriceRange {
  const PriceRange({required this.min, required this.max});

  final int min;
  final int max;

  bool contains(int amount) => amount >= min && amount <= max;

  @override
  bool operator ==(Object other) =>
      other is PriceRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'PriceRange($min–$max)';
}

/// Typed, composable filter state for hotel search (`15 · Search, filters &
/// sort`, screen "تصفية النتائج"). Only the filters the design actually exposes:
/// destination city and price range. Rating / room-type / amenity filters are
/// shown locked in the reference and belong to a later phase.
@immutable
class HotelFilters {
  const HotelFilters({
    this.cityIds = const <String>{},
    this.priceRange,
  });

  /// Empty means "all cities".
  final Set<String> cityIds;

  /// `null` means "any price".
  final PriceRange? priceRange;

  static const HotelFilters none = HotelFilters();

  bool get isActive => cityIds.isNotEmpty || priceRange != null;

  int get activeCount => (cityIds.isNotEmpty ? 1 : 0) + (priceRange != null ? 1 : 0);

  HotelFilters copyWith({
    Set<String>? cityIds,
    PriceRange? priceRange,
    bool clearPriceRange = false,
  }) {
    return HotelFilters(
      cityIds: cityIds ?? this.cityIds,
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
    );
  }

  HotelFilters toggleCity(String cityId) {
    final Set<String> next = Set<String>.of(cityIds);
    if (!next.remove(cityId)) next.add(cityId);
    return copyWith(cityIds: next);
  }

  @override
  bool operator ==(Object other) =>
      other is HotelFilters &&
      setEquals(other.cityIds, cityIds) &&
      other.priceRange == priceRange;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(cityIds), priceRange);
}
