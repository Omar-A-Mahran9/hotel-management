import 'package:flutter/foundation.dart';

/// The kind of government ID the guest is submitting. A short, non-PII label —
/// never a document number — matching the backend `document_type` field
/// (`SubmitIdentityDocumentRequest`: `max:40`, `/^[A-Za-z0-9 _-]+$/`).
enum IdentityDocumentType {
  passport('passport'),
  nationalId('national_id'),
  residencePermit('residence_permit');

  const IdentityDocumentType(this.wireValue);

  final String wireValue;

  static IdentityDocumentType fromWire(String value) {
    for (final IdentityDocumentType t in IdentityDocumentType.values) {
      if (t.wireValue == value) return t;
    }
    return IdentityDocumentType.passport;
  }
}

/// A locally captured image, referenced only by non-sensitive metadata.
///
/// The app never keeps the image bytes in domain/state objects and never logs
/// them (mobile/docs/architecture.md §8, phase brief "Security"). A real capture
/// flow (camera / file picker) would hand the bytes straight to the upload data
/// source; this value object carries just enough to show "a photo was added"
/// and to describe the payload shape. In dummy mode it is a fixed placeholder.
@immutable
class CapturedImage {
  const CapturedImage({
    required this.label,
    required this.sizeBytes,
    this.mimeType = 'image/jpeg',
  });

  /// A deterministic placeholder capture for dummy mode — no real bytes exist.
  static const CapturedImage dummy = CapturedImage(
    label: 'captured-image',
    sizeBytes: 128 * 1024,
  );

  /// A short, non-sensitive label for display / logs (e.g. a file name).
  final String label;

  /// Size in bytes — used only to validate against the upload limit.
  final int sizeBytes;

  final String mimeType;

  @override
  bool operator ==(Object other) =>
      other is CapturedImage &&
      other.label == label &&
      other.sizeBytes == sizeBytes &&
      other.mimeType == mimeType;

  @override
  int get hashCode => Object.hash(label, sizeBytes, mimeType);

  @override
  String toString() => 'CapturedImage($label, $sizeBytes bytes)';
}
