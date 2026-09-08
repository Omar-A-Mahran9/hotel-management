import '../../domain/entities/identity_verification_request.dart';
import '../models/identity_verification_models.dart';

/// The identity-verification data contract. Dummy + API implementations,
/// selected by DI (`AppConfig.useDummyData`) exactly like
/// `ReservationDataSource`. Methods return DTO models; the repository maps them
/// to domain entities.
abstract interface class IdentityVerificationDataSource {
  Future<IdentityVerificationSessionModel> fetchStatus(String reservationId);

  Future<IdentityVerificationSessionModel> submitDocument(
    SubmitIdentityDocumentRequest request,
  );

  Future<IdentityVerificationSessionModel> submitSelfie(
    SubmitSelfieRequest request,
  );
}
