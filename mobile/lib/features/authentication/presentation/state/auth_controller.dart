import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/core_providers.dart';
import '../../data/datasources/api_auth_data_source.dart';
import '../../data/datasources/auth_data_source.dart';
import '../../data/datasources/dummy_auth_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/guest_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Selects the auth data source by configuration — the UI never sees this choice
/// (README — "Development Strategy").
final authDataSourceProvider = Provider<AuthDataSource>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return config.useDummyData
      ? const DummyAuthDataSource()
      : ApiAuthDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(authDataSourceProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

/// Owns [AuthState] and the transitions between its cases. Feature screens call
/// these methods; the router redirects on the resulting state.
class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    // Kick off session restore; until it resolves the router shows a splash.
    Future<void>(() async {
      try {
        final AuthSession? restored = await _repository.restoreSession();
        state = restored == null
            ? const AuthState.unauthenticated()
            : _fromSession(restored);
      } catch (_) {
        state = const AuthState.unauthenticated();
      }
    });
    return const AuthState.unknown();
  }

  /// Called by the login flow once a code is accepted.
  void onOtpVerified(AuthSession session) => state = _fromSession(session);

  /// Called after the first-time guest saves their name + email.
  void onProfileCompleted(AuthSession session) =>
      state = AuthState.authenticated(session);

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState.unauthenticated();
  }

  /// Invoked by the API/error layer when the backend rejects the stored token.
  Future<void> expireSession() async {
    await _repository.signOut();
    state = const AuthState.sessionExpired();
  }

  /// Leaves the `انتهت الجلسة` screen back to a clean sign-in.
  void acknowledgeExpiry() => state = const AuthState.unauthenticated();

  AuthState _fromSession(AuthSession session) => session.isProfileComplete
      ? AuthState.authenticated(session)
      : AuthState.awaitingProfile(session);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
