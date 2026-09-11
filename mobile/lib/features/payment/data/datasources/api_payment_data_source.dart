import '../../../../core/data/data_source.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment_request.dart';
import '../models/payment_models.dart';
import 'payment_data_source.dart';

/// API-backed payment source.
///
/// Real, authenticated guest contract:
/// `GET /guest/reservations/{reservation}/payment` → `GuestPaymentResource`
/// or `{data: null}` when no payment exists yet, and
/// `POST /guest/reservations/{reservation}/payment/hold`.
///
/// The hold endpoint is deliberately blocked server-side: there is no
/// approved guest deposit-amount rule
/// (`config('guest_booking.deposit.rule')` is null), so the guest supplies no
/// amount and the backend refuses every call with a 422
/// (`api.guest_booking.deposit_rule_undefined`, `errors.reason ==
/// 'deposit_amount_rule_undefined'`). This is a real, current business-rule
/// gap (see md/integration-contract-matrix.md), not a bug — the call
/// propagates as a normal [ValidationException] `Failure`; a bespoke
/// "deposit unavailable" outcome would need `PaymentDataSource.requestHold`
/// to return a result wrapper (like `RedeemPointsResult`), which ripples into
/// the payment repository/notifier/UI and is out of scope for wiring this
/// data source to the real contract.
class ApiPaymentDataSource implements PaymentDataSource, RemoteDataSource {
  ApiPaymentDataSource(this._client);

  final ApiClient _client;

  @override
  Future<PaymentModel?> fetchForReservation(String reservationId) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/guest/reservations/$reservationId/payment',
    );
    final Object? data = json['data'];
    if (data is! Map<String, Object?>) return null;
    return PaymentModel.fromJson(data);
  }

  @override
  Future<PaymentModel> requestHold(PaymentHoldRequest request) async {
    final Map<String, dynamic> json = await _client.postJson(
      '/guest/reservations/${request.reservationId}/payment/hold',
      headers: <String, String>{'Idempotency-Key': request.idempotencyKey},
    );
    final Map<String, Object?> data =
        (json['data'] as Map<String, Object?>?) ?? const <String, Object?>{};
    return PaymentModel.fromJson(data);
  }
}
