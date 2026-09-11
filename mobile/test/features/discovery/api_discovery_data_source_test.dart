import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/errors/app_exception.dart';
import 'package:hotel_guest_app/core/network/api_client.dart';
import 'package:hotel_guest_app/core/network/interceptors/error_interceptor.dart';
import 'package:hotel_guest_app/features/discovery/data/datasources/api_discovery_data_source.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/hotel_filters.dart';
import 'package:hotel_guest_app/features/discovery/domain/entities/hotel_sort.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);

  final Map<String, (int, Map<String, dynamic>)> routes;
  final List<RequestOptions> received = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    received.add(options);
    final String key = '${options.method} ${options.path}';
    final (int, Map<String, dynamic>) entry =
        routes[key] ?? (404, <String, dynamic>{'success': false, 'message': 'no route $key'});
    return ResponseBody.fromString(
      jsonEncode(entry.$2),
      entry.$1,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiDiscoveryDataSource _source(_FakeAdapter adapter) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ErrorInterceptor());
  return ApiDiscoveryDataSource(ApiClient.withDio(dio));
}

void main() {
  test('fetchCities maps city + hotel_count', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{
      'GET /guest/hotels/cities': (200, <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'city': 'Riyadh', 'hotel_count': 3},
        ],
      }),
    });

    final cities = await _source(adapter).fetchCities();
    expect(cities.single.id, 'Riyadh');
    expect(cities.single.hotelCount, 3);
  });

  test('searchHotels parses PublicHotelResource rows and reads meta.total', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{
      'GET /guest/hotels': (200, <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'name': 'Oasis',
            'tagline': 'Nice place',
            'city': 'Riyadh',
            'star_rating': 4,
            'price_from': '250.00',
          },
        ],
        'meta': <String, dynamic>{'total': 12},
      }),
    });

    final result = await _source(adapter).searchHotels(
      query: '',
      filters: HotelFilters.none,
      sort: HotelSort.recommended,
    );

    expect(result.hotels.single.id, '1');
    expect(result.hotels.single.cityId, 'Riyadh');
    expect(result.hotels.single.nightlyRateFrom.amount, 250);
    expect(result.totalCount, 12);
  });

  test('searchHotels sends the single selected city as the city query param', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{
      'GET /guest/hotels': (200, <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': <Map<String, dynamic>>[],
      }),
    });

    await _source(adapter).searchHotels(
      query: 'spa',
      filters: const HotelFilters(cityIds: <String>{'Jeddah'}),
      sort: HotelSort.recommended,
    );

    expect(adapter.received.single.queryParameters['city'], 'Jeddah');
    expect(adapter.received.single.queryParameters['q'], 'spa');
  });

  test('fetchAvailability parses RoomAvailabilityResource rows', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{
      'GET /guest/hotels/1/availability': (200, <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': <String, dynamic>{
          'hotel_id': 1,
          'check_in': '2026-09-06',
          'check_out': '2026-09-08',
          'adults': 2,
          'children': 0,
          'rooms': <Map<String, dynamic>>[
            <String, dynamic>{
              'room_type_id': 5,
              'name': 'Deluxe',
              'base_price': '300.00',
              'capacity': 3,
              'rooms_available': 2,
              'is_available': true,
            },
          ],
        },
      }),
    });

    final result = await _source(adapter).fetchAvailability(
      hotelId: '1',
      checkIn: DateTime(2026, 9, 6),
      checkOut: DateTime(2026, 9, 8),
      adults: 2,
      children: 0,
    );

    expect(result.hotelId, '1');
    expect(result.rooms.single.isAvailable, isTrue);
    expect(result.rooms.single.roomType.nightlyRate.amount, 300);
  });

  test('fetchFeaturedHotels maps real PublicHotelResource rows (Hotels of the Group)', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{
      'GET /guest/hotels': (200, <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'name': 'Oasis',
            'tagline': 'Nice place',
            'city': 'Riyadh',
            'star_rating': 4,
            'rating': '4.50',
            'reviews_count': 12,
            'price_from': '250.00',
            'cover_url': 'https://cdn.example.com/oasis.jpg',
          },
        ],
        'meta': <String, dynamic>{'total': 1},
      }),
    });

    final hotels = await _source(adapter).fetchFeaturedHotels();
    expect(hotels.single.id, '1');
    // `rating` comes from the review-average field, never `star_rating`.
    expect(hotels.single.rating, 4.5);
    expect(hotels.single.reviewCount, 12);
    expect(hotels.single.coverUrl, 'https://cdn.example.com/oasis.jpg');
  });

  test('fetchFeaturedHotels requests recommended (most-booked) order', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{
      'GET /guest/hotels': (200, <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{'total': 0},
      }),
    });

    await _source(adapter).fetchFeaturedHotels();
    expect(adapter.received.single.queryParameters['sort'], 'recommended');
  });

  test('fetchUpcomingStay stays a documented gap — discovery has no reservation access', () async {
    final adapter = _FakeAdapter(<String, (int, Map<String, dynamic>)>{});
    final source = _source(adapter);

    expect(source.fetchUpcomingStay(), throwsA(isA<NotImplementedInPhaseException>()));
  });
}
