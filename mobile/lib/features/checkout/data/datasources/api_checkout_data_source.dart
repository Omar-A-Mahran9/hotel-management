import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/checkout.dart';
import '../../domain/entities/folio.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/checkout_repository.dart';
import 'checkout_data_source.dart';

/// API-backed checkout + invoice source.
///
/// Kept a documented stub for Mobile Phase 9 (same pattern as
/// `ApiPaymentDataSource`). Endpoints exist —
/// `GET /api/v1/reservations/{reservation}/folio`,
/// `POST /api/v1/reservations/{reservation}/checkout`
/// (`PerformCheckoutRequest`: no body, `Idempotency-Key` header →
/// `CheckoutResource`),
/// `GET /api/v1/reservations/{reservation}/invoice` (→ `InvoiceResource`) —
/// but all are **staff/dashboard-scoped**:
///
/// * every route resolves the reservation through
///   `ReservationService::findAccessibleBy($request->user(), …)` and authorises
///   with `CheckoutPolicy` / `InvoicePolicy` / `FolioPolicy` against the acting
///   user's hotel access;
/// * the whole `/v1` surface is behind `auth:sanctum` staff tokens.
///
/// No guest-facing checkout/invoice contract is approved. The settlement amount
/// is computed server-side from the authoritative folio — the client never
/// sends one. Wiring is sketched in comments; until then each method raises
/// [NotImplementedInPhaseException].
class ApiCheckoutDataSource
    implements CheckoutDataSource, InvoiceDataSource, RemoteDataSource {
  ApiCheckoutDataSource(this._client);

  // Retained so wiring approved endpoints stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'A guest-facing checkout/invoice contract (guest identity, resolved '
      'server-side) is not approved yet';

  @override
  Future<Folio> fetchFolio(FolioContext context) async {
    // final json = await _client.getJson(
    //   '/reservations/${context.reservationId}/folio');
    // return FolioModel(json['data'] as Map<String, Object?>).toEntity();
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<CheckoutResult> performCheckout(
    CheckoutRequest request,
    FolioContext context,
  ) async {
    // final json = await _client.postJson(
    //   '/reservations/${request.reservationId}/checkout',
    //   // headers: {'Idempotency-Key': request.idempotencyKey},
    // );
    // return CheckoutResultModel(json['data'] as Map<String, Object?>).toEntity();
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<Invoice> fetchInvoice(String reservationId) async {
    // final json = await _client.getJson(
    //   '/reservations/$reservationId/invoice');
    // return InvoiceModel(json['data'] as Map<String, Object?>).toEntity();
    throw const NotImplementedInPhaseException(_reason);
  }
}
