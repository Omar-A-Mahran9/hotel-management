import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/config/app_config.dart';
import 'package:hotel_guest_app/core/config/app_environment.dart';
import 'package:hotel_guest_app/core/errors/app_exception.dart';
import 'package:hotel_guest_app/core/network/api_client.dart';
import 'package:hotel_guest_app/core/security/in_memory_token_store.dart';
import 'package:hotel_guest_app/features/reservation/data/datasources/api_reservation_data_source.dart';
import 'package:hotel_guest_app/features/reservation/data/datasources/dummy_reservation_data_source.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation_status.dart';

import 'reservation_test_support.dart';

void main() {
  final DateTime fixedNow = DateTime(2026, 9, 8, 9, 41);

  group('DummyReservationDataSource', () {
    DummyReservationDataSource source() =>
        DummyReservationDataSource(clock: () => fixedNow);

    test('creates a deterministic PENDING reservation from the request',
        () async {
      final a = await source().create(fakeRequest());
      final b = await source().create(fakeRequest());

      expect(a.status, ReservationStatus.pending);
      expect(a.id, b.id);
      expect(a.reference, b.reference);
      expect(a.reference, startsWith('RSV-'));
      expect(a.priceSnapshot.amount, 900);
      expect(a.createdAt, fixedNow);
    });

    test('create is idempotent — a repeat returns the same reservation',
        () async {
      final s = source();
      final a = await s.create(fakeRequest());
      final b = await s.create(fakeRequest());
      expect(identical(a, b), isTrue);
    });

    test('a different request produces a different reservation', () async {
      final s = source();
      final a = await s.create(fakeRequest());
      final b = await s.create(fakeRequest(guestReference: '+966500000000'));
      expect(a.id, isNot(b.id));
    });

    test('fetchById returns a created reservation, else NotFound', () async {
      final s = source();
      final created = await s.create(fakeRequest());
      final fetched = await s.fetchById(created.id);
      expect(fetched.reference, created.reference);

      expect(
        () => s.fetchById('does-not-exist'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('failWith seam surfaces an error from create and fetch', () async {
      final s = source()..failWith = const NetworkException();
      await expectLater(
        s.create(fakeRequest()),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        s.fetchById('x'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('ApiReservationDataSource', () {
    final ApiReservationDataSource source = ApiReservationDataSource(
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

    test('both methods are documented not-implemented stubs', () {
      expect(
        source.create(fakeRequest()),
        throwsA(isA<NotImplementedInPhaseException>()),
      );
      expect(
        source.fetchById('1'),
        throwsA(isA<NotImplementedInPhaseException>()),
      );
    });
  });
}
