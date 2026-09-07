import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/config/app_config.dart';
import 'package:hotel_guest_app/core/config/app_environment.dart';
import 'package:hotel_guest_app/core/errors/app_exception.dart';
import 'package:hotel_guest_app/core/network/api_client.dart';
import 'package:hotel_guest_app/core/security/in_memory_token_store.dart';
import 'package:hotel_guest_app/features/discovery/data/datasources/api_discovery_data_source.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/hotel_filters.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/hotel_sort.dart';

void main() {
  final ApiDiscoveryDataSource source = ApiDiscoveryDataSource(
    ApiClient(
      config: const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://localhost',
        apiVersion: 'v1',
        useDummyData: false,
      ),
      tokenStore: InMemoryTokenStore(),
    ),
  );

  test('every method is a documented not-implemented stub', () {
    expect(source.fetchCities(), throwsA(isA<NotImplementedInPhaseException>()));
    expect(
      source.fetchFeaturedHotels(),
      throwsA(isA<NotImplementedInPhaseException>()),
    );
    expect(
      source.searchHotels(
        query: '',
        filters: HotelFilters.none,
        sort: HotelSort.recommended,
      ),
      throwsA(isA<NotImplementedInPhaseException>()),
    );
    expect(
      source.fetchHotel('oasis'),
      throwsA(isA<NotImplementedInPhaseException>()),
    );
    expect(
      source.fetchAvailability(
        hotelId: 'oasis',
        checkIn: DateTime(2026, 9, 6),
        checkOut: DateTime(2026, 9, 8),
        adults: 2,
        children: 0,
      ),
      throwsA(isA<NotImplementedInPhaseException>()),
    );
  });
}
