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
    this.singleHotelGroup = false,
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
    // Real integration: --dart-define=USE_DUMMY_DATA=false. As of the final
    // mobile↔backend integration pass, every feature's `Api*DataSource` is a
    // real implementation against the guest API (auth, discovery,
    // reservations, payment reads, identity status, check-in/access, service
    // catalogue/orders, folio/checkout/invoice, loyalty reads/redeem,
    // reviews). Documented, narrower gaps remain and throw
    // `NotImplementedInPhaseException` rather than guessing: payment `hold`
    // is backend-blocked pending an approved deposit-amount rule; identity
    // document/selfie upload needs a real camera/file-picker capture flow
    // (`CapturedImage.filePath`); loyalty has no guest-triggerable `earn`;
    // stay-services has no guest cancel; discovery has no "featured hotels"
    // or "upcoming stay" concept server-side (see
    // md/integration-contract-matrix.md).
    const bool useDummy = bool.fromEnvironment('USE_DUMMY_DATA', defaultValue: true);
    // Demo/QA flag: render the single-hotel Home variant (`اكتشف {hotel}` +
    // `استكشف الغرف`). The real group size comes from the backend catalogue;
    // this just lets the variant be walked with dummy data.
    const bool singleHotel =
        bool.fromEnvironment('SINGLE_HOTEL', defaultValue: false);

    return AppConfig(
      environment: AppEnvironment.fromName(env),
      apiBaseUrl: baseUrl,
      apiVersion: 'v1',
      useDummyData: useDummy,
      singleHotelGroup: singleHotel,
    );
  }

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String apiVersion;
  final bool useDummyData;

  /// When `true` the group operates one hotel — the Home screen shows the
  /// single-hotel layout (`docs/mobile-discover-book.md`).
  final bool singleHotelGroup;

  /// Fully-qualified API root, e.g. `https://api.example.com/api/v1`
  /// (mobile/docs/architecture.md §5).
  String get apiRoot => '$apiBaseUrl/api/$apiVersion';

  bool get isProduction => environment == AppEnvironment.production;
}
