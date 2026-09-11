import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/identity_document.dart';
import '../../domain/entities/identity_verification_request.dart';
import '../models/identity_verification_models.dart';
import 'identity_verification_data_source.dart';

/// API-backed identity-verification source.
///
/// Real, authenticated guest contract, reusing the shared
/// `IdentityVerificationResource`:
/// `POST /guest/reservations/{reservation}/identity/documents`,
/// `POST .../identity/selfie`, `GET .../identity`. There is no guest
/// equivalent of the staff `review` (manual approve/reject) action.
///
/// KNOWN GAP: [CapturedImage] carries an optional [CapturedImage.filePath]
/// that a real camera/file-picker capture flow would populate — no such flow
/// is wired into the identity-verification UI yet (no image_picker/camera
/// plugin dependency exists in this app). Until a capture screen produces a
/// real file, [submitDocument]/[submitSelfie] throw
/// [NotImplementedInPhaseException] rather than upload zero bytes or fabricate
/// a fake success; [fetchStatus] is fully real.
class ApiIdentityVerificationDataSource
    implements IdentityVerificationDataSource, RemoteDataSource {
  ApiIdentityVerificationDataSource(this._client);

  final ApiClient _client;

  static const String _noCaptureReason =
      'No real camera/file-picker capture is wired yet — CapturedImage has no '
      'file to upload';

  @override
  Future<IdentityVerificationSessionModel> fetchStatus(
    String reservationId,
  ) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/guest/reservations/$reservationId/identity',
    );
    final Map<String, Object?> data =
        (json['data'] as Map<String, Object?>?) ?? const <String, Object?>{};
    return IdentityVerificationSessionModel.fromJson(data);
  }

  @override
  Future<IdentityVerificationSessionModel> submitDocument(
    SubmitIdentityDocumentRequest request,
  ) async {
    final String? path = request.image.filePath;
    if (path == null) throw const NotImplementedInPhaseException(_noCaptureReason);

    final Map<String, dynamic> json = await _client.postMultipart(
      '/guest/reservations/${request.reservationId}/identity/documents',
      files: <String, MultipartFile>{
        'document': await MultipartFile.fromFile(
          path,
          filename: request.image.label,
          contentType: MediaType.parse(request.image.mimeType),
        ),
      },
      fields: <String, dynamic>{'document_type': request.type.wireValue},
    );
    final Map<String, Object?> data =
        (json['data'] as Map<String, Object?>?) ?? const <String, Object?>{};
    return IdentityVerificationSessionModel.fromJson(data);
  }

  @override
  Future<IdentityVerificationSessionModel> submitSelfie(
    SubmitSelfieRequest request,
  ) async {
    final String? path = request.image.filePath;
    if (path == null) throw const NotImplementedInPhaseException(_noCaptureReason);

    final Map<String, dynamic> json = await _client.postMultipart(
      '/guest/reservations/${request.reservationId}/identity/selfie',
      files: <String, MultipartFile>{
        'selfie': await MultipartFile.fromFile(
          path,
          filename: request.image.label,
          contentType: MediaType.parse(request.image.mimeType),
        ),
      },
      headers: <String, String>{'Idempotency-Key': request.idempotencyKey},
    );
    final Map<String, Object?> data =
        (json['data'] as Map<String, Object?>?) ?? const <String, Object?>{};
    return IdentityVerificationSessionModel.fromJson(data);
  }
}
