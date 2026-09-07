/// Route names and paths.
///
/// Mobile Phase 1 adds the entry + authentication surface. Later feature routes
/// (discovery, availability, reservations, …) are added here as each phase
/// lands, so there is one place to see the navigation surface.
abstract final class AppRoutes {
  /// Startup route: decides splash vs entry vs home from [AuthState].
  static const String splash = '/';
  static const String splashName = 'splash';

  /// `01 · Entry` — first-run welcome screen.
  static const String welcome = '/welcome';
  static const String welcomeName = 'welcome';

  /// `09 · Authentication` — phone-number entry.
  static const String signIn = '/auth/phone';
  static const String signInName = 'signIn';

  /// `09 · Authentication` — one-time-code entry.
  static const String otp = '/auth/otp';
  static const String otpName = 'otp';

  /// `09 · Authentication` — first-time guest name + email.
  static const String completeProfile = '/auth/profile';
  static const String completeProfileName = 'completeProfile';

  /// `09 · Authentication` — expired-session re-entry.
  static const String sessionExpired = '/auth/session-expired';
  static const String sessionExpiredName = 'sessionExpired';

  /// Authenticated landing. Phase 1 shows the Phase 0 foundation preview here;
  /// the real home screen arrives in a later phase.
  static const String home = '/home';
  static const String homeName = 'home';

  /// Retained for the Phase 0 error-route test / deep diagnostics.
  static const String foundation = home;
  static const String foundationName = homeName;

  /// Routes that make up the unauthenticated entry + auth surface.
  static const Set<String> authSurface = <String>{
    welcome,
    signIn,
    otp,
    sessionExpired,
  };
}
