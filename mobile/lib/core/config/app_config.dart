import 'app_environment.dart';

/// Immutable runtime configuration.
///
/// Values come from `--dart-define`s at build time so no environment detail or
/// secret is baked into source (mobile/docs/coding_rules.md §10). Nothing here is
/// secret: only the API host and feature flags. Tokens/credentials live in the
/// storage layer at runtime, never in config.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.apiVersion,
    required this.useDummyData,
  });

  /// Reads configuration from compile-time defines, with development defaults:
  ///
  /// ```
  /// flutter run \
  ///   --dart-define=APP_ENV=staging \
  ///   --dart-define=API_BASE_URL=https://staging.example.com \
  ///   --dart-define=USE_DUMMY_DATA=false
  /// ```
  factory AppConfig.fromEnvironment() {
    const String env = String.fromEnvironment('APP_ENV', defaultValue: 'development');
    // Default targets the Android emulator loopback. For a real integration
    // run point it at the Laravel host:
    //   iOS Simulator .......... --dart-define=API_BASE_URL=http://127.0.0.1:8000
    //   Physical iPhone ........ --dart-define=API_BASE_URL=http://<your-Mac-LAN-IP>:8000
    // The value is combined with `/api/v1` by [apiRoot]; never hard-code a host.
    const String baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    );
    // Real integration: --dart-define=USE_DUMMY_DATA=false. As of the
    // integration pass only the authentication feature has its API data
    // source wired end-to-end; the remaining features still fall back to
    // their dummy source until their slice lands (see
    // md/integration-contract-matrix.md).
    const bool useDummy = bool.fromEnvironment('USE_DUMMY_DATA', defaultValue: true);

    return AppConfig(
      environment: AppEnvironment.fromName(env),
      apiBaseUrl: baseUrl,
      apiVersion: 'v1',
      useDummyData: useDummy,
    );
  }

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String apiVersion;
  final bool useDummyData;

  /// Fully-qualified API root, e.g. `https://api.example.com/api/v1`
  /// (mobile/docs/architecture.md §5).
  String get apiRoot => '$apiBaseUrl/api/$apiVersion';

  bool get isProduction => environment == AppEnvironment.production;
}
