import '../../domain/entities/create_reservation_request.dart';
import '../models/reservation_models.dart';

/// The reservation data contract. Dummy + API implementations, selected by DI
/// (`AppConfig.useDummyData`) exactly like `DiscoveryDataSource` /
/// `AuthDataSource`. Methods return DTO models; the repository maps them to
/// domain entities.
abstract interface class ReservationDataSource {
  Future<ReservationModel> create(CreateReservationRequest request);

  Future<ReservationModel> fetchById(String id);
}
