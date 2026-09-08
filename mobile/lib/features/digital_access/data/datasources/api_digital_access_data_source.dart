import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/check_in.dart';
import '../models/digital_access_models.dart';
import 'digital_access_data_source.dart';

/// API-backed digital-access source.
///
/// Kept a documented stub for Mobile Phase 7 (same pattern as
/// `ApiPaymentDataSource`). Endpoints exist —
/// `POST /api/v1/check-in/{reservation}` (`CheckInRequest`, `Idempotency-Key`
/// header → `AccessGrantResource`), `GET /api/v1/access/{reservation}`,
/// `POST /api/v1/access/{reservation}/revoke` — but they are
/// **staff/dashboard-scoped**: `CheckInController` / `DigitalAccessController`
/// resolve the reservation through
/// `ReservationService::findAccessibleBy($request->user(), …)` and authorise
/// with `AccessGrantPolicy` against the acting user's hotel access. The whole
/// `/v1` surface is behind `auth:sanctum` staff tokens.
///
/// There is **no guest-facing digital-access contract**, and the
/// `AccessGrantResource` does **not** carry a friendly room number (documented
/// gap). Wiring is sketched in comments; until an approved contract lands each
/// method raises [NotImplementedInPhaseException].
class ApiDigitalAccessDataSource
    implements DigitalAccessDataSource, RemoteDataSource {
  ApiDigitalAccessDataSource(this._client);

  // Retained so wiring an approved endpoint stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'A guest-facing digital-access contract (guest identity + a room number '
      'field) is not approved yet';

  @override
  Future<AccessGrantModel?> fetchGrant(String reservationId) async {
    // final json = await _client.getJson('/access/$reservationId');
    // return AccessGrantModel.fromJson(json['data'] as Map<String, Object?>);
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<AccessGrantModel> checkIn(CheckInRequest request) async {
    // final json = await _client.postJson(
    //   '/check-in/${request.reservationId}',
    //   // headers: {'Idempotency-Key': request.idempotencyKey},
    // );
    // return AccessGrantModel.fromJson(json['data'] as Map<String, Object?>);
    throw const NotImplementedInPhaseException(_reason);
  }
}
