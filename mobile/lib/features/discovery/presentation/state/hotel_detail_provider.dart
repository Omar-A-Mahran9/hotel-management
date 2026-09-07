import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/hotel.dart';
import 'discovery_providers.dart';

/// The full hotel for the detail screen (`02 · Discover & Book`, screen 3),
/// keyed by hotel id. `autoDispose` so leaving the screen drops the fetch.
final hotelDetailProvider = FutureProvider.autoDispose.family<Hotel, String>(
  (Ref ref, String hotelId) =>
      ref.watch(discoveryRepositoryProvider).hotel(hotelId),
);
