import 'app_environment.dart';

/// Immutable runtime configuration.
///
/// Values come from `--dart-define`s at build time so no environment detail or
/// secret is baked into source (md/mobile/coding_rules.md §10). Nothing here is
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
    const String baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    );
    // Phase 0 has no approved endpoints wired, so dummy data is the default.
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
  /// (md/mobile/architecture.md §5).
  String get apiRoot => '$apiBaseUrl/api/$apiVersion';

  bool get isProduction => environment == AppEnvironment.production;
}
