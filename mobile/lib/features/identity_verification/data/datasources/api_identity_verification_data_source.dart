import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/identity_verification_request.dart';
import '../models/identity_verification_models.dart';
import 'identity_verification_data_source.dart';

/// API-backed identity-verification source.
///
/// Kept a documented stub for Mobile Phase 6 (same pattern as
/// `ApiReservationDataSource` / `ApiPaymentDataSource`). Endpoints exist —
/// `POST /api/v1/identity-verification/{reservation}/documents`,
/// `.../selfie`, `GET .../status`, `POST .../review` — but they are
/// **staff/dashboard-scoped**:
///
/// * `IdentityVerificationController` resolves the reservation through
///   `ReservationService::findAccessibleBy($request->user(), …)` and every
///   action is authorised by `IdentityVerificationPolicy` against the acting
///   user's hotel access;
/// * the whole `/v1` surface sits behind `auth:sanctum` staff tokens — the
///   mobile guest auth layer issues its own session those policies reject;
/// * `.../review` is an explicitly staff-only decision endpoint;
/// * uploads are multipart to a **private** disk and are never served back —
///   the mobile app must only ever hold the safe `IdentityVerificationResource`
///   status fields.
///
/// No guest-facing identity contract is approved. Wiring is sketched in
/// comments so adopting one stays a small change; until then each method raises
/// [NotImplementedInPhaseException] rather than guessing.
class ApiIdentityVerificationDataSource
    implements IdentityVerificationDataSource, RemoteDataSource {
  ApiIdentityVerificationDataSource(this._client);

  // Retained so wiring an approved endpoint stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'A guest-facing identity-verification contract (guest identity + a guest '
      'upload endpoint) is not approved yet';

  @override
  Future<IdentityVerificationSessionModel> fetchStatus(
    String reservationId,
  ) async {
    // final json = await _client.getJson(
    //   '/identity-verification/$reservationId/status');
    // return IdentityVerificationSessionModel.fromJson(
    //   json['data'] as Map<String, Object?>);
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<IdentityVerificationSessionModel> submitDocument(
    SubmitIdentityDocumentRequest request,
  ) async {
    // final fields = IdentityDocumentPayload.fromRequest(request).toFields();
    // final form = FormData.fromMap({
    //   ...fields,
    //   'document': /* MultipartFile from the real capture bytes */,
    // });
    // final json = await _client.postJson(
    //   '/identity-verification/${request.reservationId}/documents', body: form);
    // return IdentityVerificationSessionModel.fromJson(
    //   json['data'] as Map<String, Object?>);
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<IdentityVerificationSessionModel> submitSelfie(
    SubmitSelfieRequest request,
  ) async {
    // final form = FormData.fromMap({
    //   'selfie': /* MultipartFile from the real capture bytes */,
    // });
    // final json = await _client.postJson(
    //   '/identity-verification/${request.reservationId}/selfie',
    //   body: form,
    //   // headers: {'Idempotency-Key': request.idempotencyKey},
    // );
    // return IdentityVerificationSessionModel.fromJson(
    //   json['data'] as Map<String, Object?>);
    //
    // NOTE: there is no dedicated "retry" endpoint — a retry is simply a new
    // `documents` submission from a RETRY_ALLOWED / STAFF_REJECTED session.
    throw const NotImplementedInPhaseException(_reason);
  }
}
