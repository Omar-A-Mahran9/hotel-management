// Data-transfer models for the discovery feature.
//
// Each model parses a JSON-shaped map and maps to a domain entity. The dummy
// data source builds these from `discovery_fixtures.dart`; a future
// `ApiDiscoveryDataSource` would build them from `ApiClient` responses. The
// exact Laravel field names are not an approved contract yet — these keys are
// the dummy layer's own and will be reconciled when the contract lands.

import '../../domain/entities/availability_result.dart';
import '../../domain/entities/available_room.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/guest_party.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_summary.dart';
import '../../domain/entities/localized_text.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/room_type_summary.dart';
import '../../domain/entities/stay_range.dart';

typedef Json = Map<String, Object?>;

LocalizedText _text(Object? value) {
  final Json map = (value as Json?) ?? const <String, Object?>{};
  return LocalizedText(
    ar: (map['ar'] as String?) ?? '',
    en: (map['en'] as String?) ?? '',
  );
}

Json _textJson(LocalizedText text) => <String, Object?>{'ar': text.ar, 'en': text.en};

Money _money(Object? value) {
  final Json map = (value as Json?) ?? const <String, Object?>{};
  return Money(
    amount: (map['amount'] as num?)?.toInt() ?? 0,
    currency: (map['currency'] as String?) ?? 'SAR',
  );
}

Json _moneyJson(Money money) =>
    <String, Object?>{'amount': money.amount, 'currency': money.currency};

class CityModel {
  const CityModel({
    required this.id,
    required this.name,
    required this.hotelCount,
  });

  factory CityModel.fromJson(Json json) => CityModel(
        id: json['id'] as String,
        name: _text(json['name']),
        hotelCount: (json['hotel_count'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final LocalizedText name;
  final int hotelCount;

  City toEntity() => City(id: id, name: name, hotelCount: hotelCount);
}

class HotelSummaryModel {
  const HotelSummaryModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.cityName,
    required this.tagline,
    required this.rating,
    required this.reviewCount,
    required this.nightlyRateFrom,
    required this.isAvailable,
  });

  factory HotelSummaryModel.fromJson(Json json) => HotelSummaryModel(
        id: json['id'] as String,
        name: _text(json['name']),
        cityId: json['city_id'] as String,
        cityName: _text(json['city_name']),
        tagline: _text(json['tagline']),
        rating: (json['rating'] as num?)?.toDouble(),
        reviewCount: (json['review_count'] as num?)?.toInt(),
        nightlyRateFrom: _money(json['nightly_rate_from']),
        isAvailable: (json['is_available'] as bool?) ?? true,
      );

  final String id;
  final LocalizedText name;
  final String cityId;
  final LocalizedText cityName;
  final LocalizedText tagline;
  final double? rating;
  final int? reviewCount;
  final Money nightlyRateFrom;
  final bool isAvailable;

  HotelSummary toEntity() => HotelSummary(
        id: id,
        name: name,
        cityId: cityId,
        cityName: cityName,
        tagline: tagline,
        rating: rating,
        reviewCount: reviewCount,
        nightlyRateFrom: nightlyRateFrom,
        isAvailable: isAvailable,
      );
}

class HotelModel {
  const HotelModel({
    required this.summary,
    required this.description,
    required this.amenities,
    required this.reviewScores,
    required this.roomTypeCount,
    required this.photoCount,
  });

  factory HotelModel.fromJson(Json json) => HotelModel(
        summary: HotelSummaryModel.fromJson(json),
        description: _text(json['description']),
        amenities: <HotelAmenity>[
          for (final Object? raw in (json['amenities'] as List<Object?>? ?? const <Object?>[]))
            if (_amenityByName[raw as String?] != null) _amenityByName[raw]!,
        ],
        reviewScores: json['review_scores'] == null
            ? null
            : _reviewScores(json['review_scores'] as Json),
        roomTypeCount: (json['room_type_count'] as num?)?.toInt() ?? 0,
        photoCount: (json['photo_count'] as num?)?.toInt() ?? 0,
      );

  final HotelSummaryModel summary;
  final LocalizedText description;
  final List<HotelAmenity> amenities;
  final ReviewScores? reviewScores;
  final int roomTypeCount;
  final int photoCount;

  Hotel toEntity() => Hotel(
        summary: summary.toEntity(),
        description: description,
        amenities: amenities,
        reviewScores: reviewScores,
        roomTypeCount: roomTypeCount,
        photoCount: photoCount,
      );

  static const Map<String?, HotelAmenity> _amenityByName = <String?, HotelAmenity>{
    'free_wifi': HotelAmenity.freeWifi,
    'breakfast': HotelAmenity.breakfast,
    'parking': HotelAmenity.parking,
    'pool': HotelAmenity.pool,
    'gym': HotelAmenity.gym,
    'family_rooms': HotelAmenity.familyRooms,
    'airport_shuttle': HotelAmenity.airportShuttle,
    'room_service': HotelAmenity.roomService,
  };

  static ReviewScores _reviewScores(Json json) => ReviewScores(
        overall: (json['overall'] as num).toDouble(),
        count: (json['count'] as num).toInt(),
        cleanliness: (json['cleanliness'] as num).toDouble(),
        communication: (json['communication'] as num).toDouble(),
      );
}

class HotelSearchResultModel {
  const HotelSearchResultModel({required this.hotels, required this.totalCount});

  factory HotelSearchResultModel.fromJson(Json json) => HotelSearchResultModel(
        hotels: <HotelSummaryModel>[
          for (final Object? raw in (json['data'] as List<Object?>? ?? const <Object?>[]))
            HotelSummaryModel.fromJson(raw as Json),
        ],
        totalCount: (json['total'] as num?)?.toInt() ?? 0,
      );

  final List<HotelSummaryModel> hotels;
  final int totalCount;

  HotelSearchResult toEntity() => HotelSearchResult(
        hotels: hotels.map((HotelSummaryModel m) => m.toEntity()).toList(growable: false),
        totalCount: totalCount,
      );
}

class RoomTypeSummaryModel {
  const RoomTypeSummaryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.bedType,
    required this.maxOccupancy,
    required this.amenities,
    required this.nightlyRate,
    required this.breakfastIncluded,
    required this.refundable,
  });

  factory RoomTypeSummaryModel.fromJson(Json json) => RoomTypeSummaryModel(
        id: json['id'] as String,
        name: _text(json['name']),
        description: _text(json['description']),
        bedType: _text(json['bed_type']),
        maxOccupancy: (json['max_occupancy'] as num?)?.toInt() ?? 1,
        amenities: <RoomAmenity>[
          for (final Object? raw in (json['amenities'] as List<Object?>? ?? const <Object?>[]))
            if (_amenityByName[raw as String?] != null) _amenityByName[raw]!,
        ],
        nightlyRate: _money(json['nightly_rate']),
        breakfastIncluded: (json['breakfast_included'] as bool?) ?? false,
        refundable: (json['refundable'] as bool?) ?? false,
      );

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText bedType;
  final int maxOccupancy;
  final List<RoomAmenity> amenities;
  final Money nightlyRate;
  final bool breakfastIncluded;
  final bool refundable;

  RoomTypeSummary toEntity() => RoomTypeSummary(
        id: id,
        name: name,
        description: description,
        bedType: bedType,
        maxOccupancy: maxOccupancy,
        amenities: amenities,
        nightlyRate: nightlyRate,
        breakfastIncluded: breakfastIncluded,
        refundable: refundable,
      );

  static const Map<String?, RoomAmenity> _amenityByName = <String?, RoomAmenity>{
    'free_wifi': RoomAmenity.freeWifi,
    'air_conditioning': RoomAmenity.airConditioning,
    'city_view': RoomAmenity.cityView,
    'balcony': RoomAmenity.balcony,
    'kitchenette': RoomAmenity.kitchenette,
  };
}

class AvailableRoomModel {
  const AvailableRoomModel({required this.roomType, required this.isAvailable});

  factory AvailableRoomModel.fromJson(Json json) => AvailableRoomModel(
        roomType: RoomTypeSummaryModel.fromJson(json['room_type'] as Json),
        isAvailable: (json['is_available'] as bool?) ?? true,
      );

  final RoomTypeSummaryModel roomType;
  final bool isAvailable;

  AvailableRoom toEntity() => AvailableRoom(
        roomType: roomType.toEntity(),
        isAvailable: isAvailable,
      );
}

class AvailabilityResultModel {
  const AvailabilityResultModel({
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.rooms,
  });

  factory AvailabilityResultModel.fromJson(Json json) => AvailabilityResultModel(
        hotelId: json['hotel_id'] as String,
        checkIn: DateTime.parse(json['check_in'] as String),
        checkOut: DateTime.parse(json['check_out'] as String),
        adults: (json['adults'] as num).toInt(),
        children: (json['children'] as num).toInt(),
        rooms: <AvailableRoomModel>[
          for (final Object? raw in (json['rooms'] as List<Object?>? ?? const <Object?>[]))
            AvailableRoomModel.fromJson(raw as Json),
        ],
      );

  final String hotelId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final List<AvailableRoomModel> rooms;

  AvailabilityResult toEntity() => AvailabilityResult(
        hotelId: hotelId,
        stay: StayRange(checkIn: checkIn, checkOut: checkOut),
        party: GuestParty(adults: adults, children: children),
        rooms: rooms.map((AvailableRoomModel m) => m.toEntity()).toList(growable: false),
      );
}

// Kept for symmetry / a future API data source that serialises requests.
Json localizedTextToJson(LocalizedText text) => _textJson(text);
Json moneyToJson(Money money) => _moneyJson(money);
