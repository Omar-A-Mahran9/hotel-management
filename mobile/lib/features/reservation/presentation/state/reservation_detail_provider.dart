import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reservation.dart';
import 'create_reservation_controller.dart';
import 'reservation_providers.dart';

/// A reservation by id, for the confirmation / details screen.
///
/// Prefers the reservation just created in this session (no round-trip) and
/// falls back to `ReservationRepository.getById` for a deep link or a later
/// visit. `autoDispose` so leaving the screen drops the fetch.
final reservationDetailProvider =
    FutureProvider.autoDispose.family<Reservation, String>((Ref ref, String id) async {
  final Reservation? justCreated =
      ref.watch(createReservationControllerProvider).reservationOrNull;
  if (justCreated != null && justCreated.id == id) return justCreated;

  return ref.watch(reservationRepositoryProvider).getById(id);
});
