import 'package:flutter/foundation.dart';

import 'identity_document.dart';

/// Submit-an-ID-document request.
///
/// The approved backend `POST
/// /api/v1/identity-verification/{reservation}/documents`
/// (`SubmitIdentityDocumentRequest`) takes a `document` file (jpg/png/pdf) and
/// an optional short `document_type` label. That endpoint is
/// **staff/dashboard-scoped** (it authorises with `IdentityVerificationPolicy`
/// against the acting user's hotel access) and there is no guest-facing
/// contract, so this request only carries what the guest app has: the
/// reservation, the chosen [type] and a locally captured [image] referenced by
/// non-sensitive metadata only.
@immutable
class SubmitIdentityDocumentRequest {
  const SubmitIdentityDocumentRequest({
    required this.reservationId,
    required this.type,
    required this.image,
  });

  final String reservationId;
  final IdentityDocumentType type;
  final CapturedImage image;

  /// A stable key for local duplicate-submit dedupe. No time / randomness.
  String get idempotencyKey =>
      'idv-doc:$reservationId:${type.wireValue}';

  @override
  bool operator ==(Object other) =>
      other is SubmitIdentityDocumentRequest &&
      other.reservationId == reservationId &&
      other.type == type &&
      other.image == image;

  @override
  int get hashCode => Object.hash(reservationId, type, image);
}

/// Submit-a-selfie request.
///
/// The approved backend `POST
/// /api/v1/identity-verification/{reservation}/selfie`
/// (`SubmitIdentitySelfieRequest`) takes a `selfie` image and an
/// `Idempotency-Key` HTTP header. Same scoping caveat as
/// [SubmitIdentityDocumentRequest].
@immutable
class SubmitSelfieRequest {
  const SubmitSelfieRequest({
    required this.reservationId,
    required this.image,
  });

  final String reservationId;
  final CapturedImage image;

  /// Used as the `Idempotency-Key` header and for local dedupe of the *current*
  /// attempt. Stable across widget rebuilds; a genuine retry re-runs because
  /// the data source only caches non-retryable outcomes.
  String get idempotencyKey => 'idv-selfie:$reservationId';

  @override
  bool operator ==(Object other) =>
      other is SubmitSelfieRequest &&
      other.reservationId == reservationId &&
      other.image == image;

  @override
  int get hashCode => Object.hash(reservationId, image);
}
