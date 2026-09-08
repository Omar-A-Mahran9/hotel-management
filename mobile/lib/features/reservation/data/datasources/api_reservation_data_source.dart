import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/create_reservation_request.dart';
import '../models/reservation_models.dart';
import 'reservation_data_source.dart';

/// API-backed reservation source.
///
/// Kept a documented stub for Mobile Phase 4 (same pattern as
/// `ApiDiscoveryDataSource` / `ApiAuthDataSource`). A reservation *endpoint*
/// exists — `POST /api/v1/reservations` (`StoreReservationRequest`:
/// `room_type_id`, `room_id?`, `guest_id`, `check_in`, `check_out`; response is
/// `ReservationResource`) — but it is **staff/dashboard-scoped**: it authorises
/// against the caller's hotel access and stamps `created_by_staff_id`. No
/// guest-facing reservation contract is approved, and the mobile auth layer does
/// not yet expose the numeric `guest_id` that `StoreReservationRequest`
/// requires. Wiring is in place; each method raises
/// [NotImplementedInPhaseException] rather than guessing that contract.
class ApiReservationDataSource
    implements ReservationDataSource, RemoteDataSource {
  ApiReservationDataSource(this._client);

  // Retained so wiring the approved endpoint stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'A guest-facing reservation contract (guest identity + catalogue ids) is '
      'not approved yet';

  @override
  Future<ReservationModel> create(CreateReservationRequest request) async {
    // final payload = ReservationCreatePayload.fromRequest(request).toJson();
    // final json = await _client.postJson('/reservations', body: payload);
    // return ReservationModel.fromJson(
    //   json['data'] as Map<String, Object?>,
    //   hotelName: request.hotelName,
    //   roomName: request.roomName,
    //   party: request.party,
    // );
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<ReservationModel> fetchById(String id) async {
    // final json = await _client.getJson('/reservations/$id');
    throw const NotImplementedInPhaseException(_reason);
  }
}
