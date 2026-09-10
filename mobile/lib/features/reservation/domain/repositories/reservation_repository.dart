import '../entities/create_reservation_request.dart';
import '../entities/reservation.dart';

/// The reservation contract the presentation layer depends on
/// (mobile/docs/architecture.md §4). Which data source fulfils it (dummy vs the
/// future guest reservation API) is a DI decision, exactly as in
/// `DiscoveryRepository` / `AuthRepository`.
///
/// Every method throws a `Failure` on error (mapped by the implementation) so
/// callers only handle the user-safe type.
abstract interface class ReservationRepository {
  /// Creates a reservation. The backend places a new reservation in
  /// `PENDING`; nothing here transitions it further.
  Future<Reservation> create(CreateReservationRequest request);

  /// Fetches a previously created reservation by its id.
  Future<Reservation> getById(String id);
}
