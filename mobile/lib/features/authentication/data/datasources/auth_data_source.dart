import '../models/auth_models.dart';

/// Data-source contract for guest authentication. Concrete implementations are
/// [DummyAuthDataSource] (Phase 1) and [ApiAuthDataSource] (later, once the
/// backend contract is approved). Both honour the same behaviour, including
/// error behaviour (coding_rules.md §7).
abstract interface class AuthDataSource {
  Future<OtpChallengeModel> requestOtp(String phoneE164);

  Future<OtpChallengeModel> resendOtp({
    required String challengeId,
    required String phoneE164,
  });

  Future<OtpVerifyResult> verifyOtp({
    required String challengeId,
    required String phoneE164,
    required int attemptsRemaining,
    required String code,
  });

  Future<AuthSessionModel> completeProfile({
    required String accessToken,
    required String phoneE164,
    required String fullName,
    required String email,
  });
}
