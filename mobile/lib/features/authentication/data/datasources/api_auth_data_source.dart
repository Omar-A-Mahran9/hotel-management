import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_models.dart';
import 'auth_data_source.dart';

/// API-backed authentication source.
///
/// Phase 1 keeps this a documented stub: the Laravel guest-auth endpoints
/// (`/api/v1/auth/otp`, `/auth/otp/verify`, …) are not part of an approved
/// contract yet, so each method raises [NotImplementedInPhaseException] rather
/// than guessing a route or payload (README — "Backend-First Rule"). The
/// [ApiClient] dependency and the wiring are in place; completing a method is a
/// localized change once the contract lands. The commented calls show the
/// intended shape.
class ApiAuthDataSource implements AuthDataSource, RemoteDataSource {
  ApiAuthDataSource(this._client);

  // Retained so wiring approved endpoints stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'Guest authentication endpoints are not part of an approved contract yet';

  @override
  Future<OtpChallengeModel> requestOtp(String phoneE164) async {
    // final json = await _client.postJson('/auth/otp', body: {'phone': phoneE164});
    // return OtpChallengeModel.fromJson(json['data'] as Map<String, dynamic>);
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<OtpChallengeModel> resendOtp({
    required String challengeId,
    required String phoneE164,
  }) async {
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<OtpVerifyResult> verifyOtp({
    required String challengeId,
    required String phoneE164,
    required int attemptsRemaining,
    required String code,
  }) async {
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<AuthSessionModel> completeProfile({
    required String accessToken,
    required String phoneE164,
    required String fullName,
    required String email,
  }) async {
    throw const NotImplementedInPhaseException(_reason);
  }
}
