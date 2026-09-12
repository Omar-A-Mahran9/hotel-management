import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_filters.dart';
import '../../domain/entities/hotel_sort.dart';
import '../../domain/entities/localized_text.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/room_type_summary.dart';
import '../models/discovery_models.dart';
import 'discovery_data_source.dart';

typedef Json = Map<String, Object?>;

/// API-backed discovery source.
///
/// Real, unauthenticated guest contract (`GuestDiscoveryController`):
/// `GET /guest/hotels`, `/guest/hotels/cities`, `/guest/hotels/{hotel}`,
/// `/guest/hotels/{hotel}/availability` — active hotels / active room types
/// only, no caller identity, so no hotel scope.
///
/// The backend resources (`PublicHotelResource`, `PublicRoomTypeResource`,
/// `RoomAvailabilityResource`) do not carry every field the dummy-fixture
/// shaped domain models expect (no bed type / breakfast / refundable / area
/// flags on a room type, no per-room media) — those are left `null`/`false`
/// rather than fabricated; the UI already renders them as optional.
///
/// `GET /guest/hotels` accepts `city`, `q`, `per_page`, `sort`
/// (`recommended` | `highest_rated` | `cheapest`), `min_price`, `max_price`
/// and `facilities` (comma-separated keys, AND semantics) — all applied
/// server-side over the full catalogue via real DB aggregates/ordering.
/// [HotelSort] and [HotelFilters] map onto these 1:1; nothing is re-sorted or
/// re-filtered client-side over a single fetched page. `city` is a single
/// value server-side — [HotelFilters.cityIds] with more than one entry
/// narrows the (already server-filtered-by-first-city) page client-side as a
/// display convenience, not a claim of full-dataset multi-city search (the
/// backend has no such parameter; a genuine multi-city filter is a backend
/// gap, not invented here).
class ApiDiscoveryDataSource implements DiscoveryDataSource, RemoteDataSource {
  ApiDiscoveryDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<CityModel>> fetchCities() async {
    final Map<String, dynamic> json = await _client.getJson('/guest/hotels/cities');
    final List<Object?> data = (json['data'] as List<Object?>?) ?? const <Object?>[];
    return data.whereType<Json>().map((Json row) {
      final String city = (row['city'] as String?) ?? '';
      return CityModel(
        id: city,
        name: LocalizedText(ar: city, en: city),
        hotelCount: (row['hotel_count'] as num?)?.toInt() ?? 0,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<HotelSummaryModel>> fetchFeaturedHotels() async {
    // "Hotels of the Group" (`HOME_Default`) — this deployment has exactly
    // one hotel group, so the full active-hotel list *is* the group's
    // hotels; no separate group-scoped endpoint exists or is needed. Default
    // (`recommended`) ordering matches the Home screen's unselected "الكل"
    // chip state.
    final Map<String, dynamic> json = await _client.getJson(
      '/guest/hotels',
      query: const <String, dynamic>{'sort': 'recommended', 'per_page': 20},
    );
    final List<Object?> rows = (json['data'] as List<Object?>?) ?? const <Object?>[];
    return rows.whereType<Json>().map(_hotelSummaryFromPublicHotel).toList(growable: false);
  }

  @override
  Future<HotelSearchResultModel> searchHotels({
    required String query,
    required HotelFilters filters,
    required HotelSort sort,
  }) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/guest/hotels',
      query: <String, dynamic>{
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (filters.cityIds.isNotEmpty) 'city': filters.cityIds.first,
        if (filters.priceRange != null) 'min_price': filters.priceRange!.min,
        if (filters.priceRange != null) 'max_price': filters.priceRange!.max,
        if (filters.facilities.isNotEmpty)
          'facilities': filters.facilities.map(_facilityKey).join(','),
        'sort': _sortParam(sort),
        'per_page': 50,
      },
    );
    final List<Object?> rows = (json['data'] as List<Object?>?) ?? const <Object?>[];
    List<HotelSummaryModel> hotels = rows
        .whereType<Json>()
        .map(_hotelSummaryFromPublicHotel)
        .toList(growable: false);

    // `city` is a single server-side value; a second/third selected city
    // narrows the already-fetched (first-city) page as a display convenience
    // only — the backend has no multi-city parameter (see class doc).
    if (filters.cityIds.length > 1) {
      hotels = hotels
          .where((HotelSummaryModel h) => filters.cityIds.contains(h.cityId))
          .toList(growable: false);
    }

    final Json meta = (json['meta'] as Json?) ?? const <String, Object?>{};
    return HotelSearchResultModel(
      hotels: hotels,
      totalCount: (meta['total'] as num?)?.toInt() ?? hotels.length,
    );
  }

  @override
  Future<HotelModel> fetchHotel(String hotelId) async {
    final Map<String, dynamic> json = await _client.getJson('/guest/hotels/$hotelId');
    final Json data = (json['data'] as Json?) ?? const <String, Object?>{};
    return _hotelFromPublicHotel(data);
  }

  @override
  Future<AvailabilityResultModel> fetchAvailability({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
  }) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/guest/hotels/$hotelId/availability',
      query: <String, dynamic>{
        'check_in': _isoDate(checkIn),
        'check_out': _isoDate(checkOut),
        'adults': adults,
        'children': children,
      },
    );
    final Json data = (json['data'] as Json?) ?? const <String, Object?>{};
    final List<Object?> rooms = (data['rooms'] as List<Object?>?) ?? const <Object?>[];
    return AvailabilityResultModel(
      hotelId: '${data['hotel_id']}',
      checkIn: DateTime.parse(data['check_in'] as String),
      checkOut: DateTime.parse(data['check_out'] as String),
      adults: (data['adults'] as num?)?.toInt() ?? adults,
      children: (data['children'] as num?)?.toInt() ?? children,
      rooms: rooms
          .whereType<Json>()
          .map((Json r) => AvailableRoomModel(
                roomType: _roomTypeSummaryFromAvailability(r),
                isAvailable: (r['is_available'] as bool?) ?? false,
              ))
          .toList(growable: false),
    );
  }

  @override
  Future<int> fetchGroupHotelCount() async {
    final Map<String, dynamic> json = await _client.getJson(
      '/guest/hotels',
      query: const <String, dynamic>{'per_page': 1},
    );
    final Json meta = (json['meta'] as Json?) ?? const <String, Object?>{};
    return (meta['total'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<List<AvailableRoomModel>> fetchHotelRooms(String hotelId) async {
    // No date-scoped availability requested — these are the hotel's offered
    // room types (real data), each marked available since no stay window was
    // checked; a genuine live availability read is `fetchAvailability`.
    final Map<String, dynamic> json = await _client.getJson('/guest/hotels/$hotelId');
    final Json data = (json['data'] as Json?) ?? const <String, Object?>{};
    final List<Object?> roomTypes = (data['room_types'] as List<Object?>?) ?? const <Object?>[];
    return roomTypes
        .whereType<Json>()
        .map((Json rt) => AvailableRoomModel(
              roomType: _roomTypeSummaryFromPublicRoomType(rt),
              isAvailable: true,
            ))
        .toList(growable: false);
  }

  @override
  Future<UpcomingStayModel?> fetchUpcomingStay() async {
    // Not a discovery concern — the guest's own upcoming stay comes from the
    // authenticated reservation list, which this unauthenticated data source
    // has no access to. Composing it needs a cross-feature (reservation)
    // read at the repository layer, not a discovery endpoint.
    throw const NotImplementedInPhaseException(
      'Upcoming-stay needs the authenticated guest reservation list, not a '
      'discovery endpoint',
    );
  }

  // ── mapping helpers ──────────────────────────────────────────────────

  HotelSummaryModel _hotelSummaryFromPublicHotel(Json h) => HotelSummaryModel(
        id: '${h['id']}',
        name: _text(h['name']),
        cityId: (h['city'] as String?) ?? '',
        cityName: _text(h['city']),
        tagline: _text(h['tagline']),
        // `rating` is the real average of published guest reviews
        // (`PublicHotelResource`); `star_rating` is the hotel's own
        // classification (1-5 stars set by the operator) and is a different
        // concept — never substituted here.
        rating: _parseRating(h['rating']),
        reviewCount: (h['reviews_count'] as num?)?.toInt(),
        nightlyRateFrom: _money(h['price_from']),
        isAvailable: true,
        coverUrl: h['cover_url'] as String?,
      );

  HotelModel _hotelFromPublicHotel(Json h) {
    final List<Object?> roomTypes = (h['room_types'] as List<Object?>?) ?? const <Object?>[];
    final List<Object?> amenities = (h['amenities'] as List<Object?>?) ?? const <Object?>[];
    final List<Object?> gallery = (h['gallery'] as List<Object?>?) ?? const <Object?>[];
    return HotelModel(
      summary: _hotelSummaryFromPublicHotel(h),
      description: _text(h['description']),
      amenities: <HotelAmenity>[
        for (final Object? raw in amenities)
          if (_hotelAmenityByKey[raw as String?] != null) _hotelAmenityByKey[raw]!,
      ],
      reviewScores: null,
      roomTypeCount: (h['room_types_count'] as num?)?.toInt() ?? roomTypes.length,
      photoCount: gallery.length,
      entryRoom: roomTypes.isEmpty
          ? null
          : _roomTypeSummaryFromPublicRoomType(roomTypes.first as Json),
      galleryUrls: <String>[
        for (final Object? raw in gallery)
          if (raw is Json && raw['url'] is String) raw['url']! as String,
      ],
    );
  }

  /// `rating` arrives as a decimal-formatted string (e.g. `"4.50"`, matching
  /// `price_from`'s convention) or is absent/null when the hotel has zero
  /// published reviews.
  static double? _parseRating(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  static String _sortParam(HotelSort sort) => switch (sort) {
        HotelSort.recommended => 'recommended',
        HotelSort.ratingDesc => 'highest_rated',
        HotelSort.priceAsc => 'cheapest',
      };

  static const Map<HotelAmenity, String> _facilityKeyByAmenity = <HotelAmenity, String>{
    HotelAmenity.freeWifi: 'free_wifi',
    HotelAmenity.breakfast: 'breakfast',
    HotelAmenity.parking: 'parking',
    HotelAmenity.pool: 'pool',
    HotelAmenity.gym: 'gym',
    HotelAmenity.familyRooms: 'family_rooms',
    HotelAmenity.airportShuttle: 'airport_shuttle',
    HotelAmenity.roomService: 'room_service',
  };

  static String _facilityKey(HotelAmenity amenity) =>
      _facilityKeyByAmenity[amenity] ?? '';

  RoomTypeSummaryModel _roomTypeSummaryFromPublicRoomType(Json rt) {
    final List<Object?> amenities = (rt['amenities'] as List<Object?>?) ?? const <Object?>[];
    return RoomTypeSummaryModel(
      id: '${rt['id']}',
      name: _text(rt['name']),
      description: _text(rt['description']),
      bedType: const LocalizedText(ar: '', en: ''),
      maxOccupancy: (rt['capacity'] as num?)?.toInt() ?? 1,
      amenities: <RoomAmenity>[
        for (final Object? raw in amenities)
          if (_roomAmenityByKey[raw as String?] != null) _roomAmenityByKey[raw]!,
      ],
      nightlyRate: _money(rt['base_price']),
      breakfastIncluded: false,
      refundable: false,
      areaSqm: null,
    );
  }

  RoomTypeSummaryModel _roomTypeSummaryFromAvailability(Json r) {
    final List<Object?> amenities = (r['amenities'] as List<Object?>?) ?? const <Object?>[];
    return RoomTypeSummaryModel(
      id: '${r['room_type_id']}',
      name: _text(r['name']),
      description: _text(r['description']),
      bedType: const LocalizedText(ar: '', en: ''),
      maxOccupancy: (r['capacity'] as num?)?.toInt() ?? 1,
      amenities: <RoomAmenity>[
        for (final Object? raw in amenities)
          if (_roomAmenityByKey[raw as String?] != null) _roomAmenityByKey[raw]!,
      ],
      nightlyRate: _money(r['base_price']),
      breakfastIncluded: false,
      refundable: false,
      areaSqm: null,
    );
  }

  static LocalizedText _text(Object? raw) {
    if (raw is String) return LocalizedText(ar: raw, en: raw);
    return const LocalizedText(ar: '', en: '');
  }

  static Money _money(Object? raw) {
    int amount = 0;
    if (raw is num) amount = raw.round();
    if (raw is String) amount = (double.tryParse(raw) ?? 0).round();
    return Money(amount: amount, currency: Money.fallbackCurrency);
  }

  static String _isoDate(DateTime date) {
    final DateTime d = DateTime(date.year, date.month, date.day);
    final String y = d.year.toString().padLeft(4, '0');
    final String m = d.month.toString().padLeft(2, '0');
    final String dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }

  static const Map<String?, HotelAmenity> _hotelAmenityByKey = <String?, HotelAmenity>{
    'free_wifi': HotelAmenity.freeWifi,
    'breakfast': HotelAmenity.breakfast,
    'parking': HotelAmenity.parking,
    'pool': HotelAmenity.pool,
    'gym': HotelAmenity.gym,
    'family_rooms': HotelAmenity.familyRooms,
    'airport_shuttle': HotelAmenity.airportShuttle,
    'room_service': HotelAmenity.roomService,
  };

  static const Map<String?, RoomAmenity> _roomAmenityByKey = <String?, RoomAmenity>{
    'free_wifi': RoomAmenity.freeWifi,
    'air_conditioning': RoomAmenity.airConditioning,
    'city_view': RoomAmenity.cityView,
    'balcony': RoomAmenity.balcony,
    'kitchenette': RoomAmenity.kitchenette,
  };
}
