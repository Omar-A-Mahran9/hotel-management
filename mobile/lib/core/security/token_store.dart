/// Storage for the guest's API access token (Laravel Sanctum bearer token).
///
/// The interface is defined now so the API auth layer can depend on it. Phase 0
/// ships only [InMemoryTokenStore]; a platform-backed secure implementation
/// (Keychain / Keystore) is added in a later phase once Android SDK / Xcode /
/// CocoaPods are available. Tokens are never written to source or logs
/// (md/mobile/architecture.md §8, md/mobile/coding_rules.md §10).
abstract interface class TokenStore {
  Future<String?> readAccessToken();

  Future<void> writeAccessToken(String token);

  Future<void> clear();
}
