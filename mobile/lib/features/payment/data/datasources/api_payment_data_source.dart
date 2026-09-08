import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment_request.dart';
import '../models/payment_models.dart';
import 'payment_data_source.dart';

/// API-backed payment source.
///
/// Kept a documented stub for Mobile Phase 5 (same pattern as
/// `ApiReservationDataSource` / `ApiDiscoveryDataSource`). A payment *endpoint*
/// exists — `POST /api/v1/reservations/{reservation}/payment/hold`
/// (`StorePaymentHoldRequest`: `amount`, optional `currency`; `Idempotency-Key`
/// header; response is `PaymentResource`) — but it is **staff/dashboard-scoped**:
/// `PaymentController::hold` resolves the reservation through
/// `ReservationService::findAccessibleBy($request->user(), …)` and authorises
/// with `PaymentPolicy` against the acting user's hotel access. There is:
///
/// * **no guest-facing payment contract** — the whole `/v1` surface sits behind
///   `auth:sanctum` staff tokens, and the mobile guest auth layer issues its
///   own session that those policies would reject;
/// * **no `GET` for a reservation's current payment** — the only payment route
///   is the `hold` POST, so there is nothing to poll for status;
/// * **no approved way for a guest to submit card / provider data** — a real
///   integration would run through the provider SDK, not our API body.
///
/// Wiring is sketched in comments so adopting an approved guest contract stays a
/// small change; until then each method raises [NotImplementedInPhaseException]
/// rather than guessing.
class ApiPaymentDataSource implements PaymentDataSource, RemoteDataSource {
  ApiPaymentDataSource(this._client);

  // Retained so wiring an approved endpoint stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'A guest-facing payment contract (guest identity + a status endpoint) is '
      'not approved yet';

  @override
  Future<PaymentModel?> fetchForReservation(String reservationId) async {
    // final json = await _client.getJson('/reservations/$reservationId/payment');
    // return PaymentModel.fromJson(json['data'] as Map<String, Object?>);
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<PaymentModel> requestHold(PaymentHoldRequest request) async {
    // final payload = PaymentHoldPayload.fromRequest(request).toJson();
    // final json = await _client.postJson(
    //   '/reservations/${request.reservationId}/payment/hold',
    //   body: payload,
    //   // headers: {'Idempotency-Key': request.idempotencyKey},
    // );
    // return PaymentModel.fromJson(json['data'] as Map<String, Object?>);
    throw const NotImplementedInPhaseException(_reason);
  }
}
