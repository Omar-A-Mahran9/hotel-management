import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/hotel_filters.dart';
import '../../domain/entities/hotel_sort.dart';
import '../models/discovery_models.dart';
import 'discovery_data_source.dart';

/// API-backed discovery source.
///
/// Phase 2 keeps this a documented stub: the Laravel catalogue / availability
/// endpoints are not part of an approved contract yet, so each method raises
/// [NotImplementedInPhaseException] rather than guessing a route, query string
/// or response schema (README — "Backend-First Rule"). The [ApiClient]
/// dependency and the wiring are already in place; completing a method is a
/// localized change once the contract lands. The commented calls only sketch the
/// intended shape — none of these paths are confirmed.
class ApiDiscoveryDataSource implements DiscoveryDataSource, RemoteDataSource {
  ApiDiscoveryDataSource(this._client);

  // Retained so wiring the approved endpoints stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'Hotel discovery / availability endpoints are not part of an approved contract yet';

  @override
  Future<List<CityModel>> fetchCities() async {
    // final json = await _client.getJson('/cities');
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<List<HotelSummaryModel>> fetchFeaturedHotels() async {
    // final json = await _client.getJson('/hotels', query: {'featured': true});
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<HotelSearchResultModel> searchHotels({
    required String query,
    required HotelFilters filters,
    required HotelSort sort,
  }) async {
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<HotelModel> fetchHotel(String hotelId) async {
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<AvailabilityResultModel> fetchAvailability({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
  }) async {
    throw const NotImplementedInPhaseException(_reason);
  }
}
