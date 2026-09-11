import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bookings/domain/bookings_filter.dart';
import '../../../bookings/presentation/state/bookings_providers.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../../stay_services/domain/entities/hotel_service.dart';

/// The guest's current, in-progress stay (`checked_in` / `in_stay`), for the
/// "الخدمات" tab's `STAY_Home` hub — `null` when there is none right now.
/// Reuses [bookingsListProvider]; no separate fetch.
final currentStayProvider = FutureProvider.autoDispose<Reservation?>((Ref ref) async {
  final List<Reservation> reservations = await ref.watch(bookingsListProvider.future);
  for (final Reservation r in reservations) {
    if (r.isOngoingStay) return r;
  }
  return null;
});

/// Finds a catalogue service by an English-name keyword (case-insensitive
/// substring) — used to resolve the STAY_Home quick-action tiles ("تنظيف
/// الغرفة", "الإبلاغ عن مشكلة") against the hotel's **real** service
/// catalogue rather than a hardcoded id, so the tile still works if the
/// catalogue changes.
HotelService? findServiceByKeyword(ServiceCatalogue catalogue, String keyword) {
  final String needle = keyword.toLowerCase();
  for (final HotelService service in catalogue.services) {
    if (service.name.en.toLowerCase().contains(needle)) return service;
  }
  return null;
}
