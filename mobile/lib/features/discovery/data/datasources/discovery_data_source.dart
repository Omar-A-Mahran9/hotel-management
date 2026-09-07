import '../../domain/entities/hotel_filters.dart';
import '../../domain/entities/hotel_sort.dart';
import '../models/discovery_models.dart';

/// The discovery data contract. Dummy + API implementations, selected by DI
/// (`AppConfig.useDummyData`) exactly like `AuthDataSource` / `HealthDataSource`.
///
/// Retrieval, filtering and sorting live here, not in widgets or controllers
/// (phase brief §4). Methods return DTO models; the repository maps them to
/// domain entities.
abstract interface class DiscoveryDataSource {
  Future<List<CityModel>> fetchCities();

  Future<List<HotelSummaryModel>> fetchFeaturedHotels();

  Future<HotelSearchResultModel> searchHotels({
    required String query,
    required HotelFilters filters,
    required HotelSort sort,
  });

  Future<HotelModel> fetchHotel(String hotelId);

  Future<AvailabilityResultModel> fetchAvailability({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
  });
}
