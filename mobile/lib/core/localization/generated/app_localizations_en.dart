// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Hotel System';

  @override
  String get appTagline => 'Book, verify and enter — from your phone.';

  @override
  String get foundationScreenTitle => 'Foundation & Design System';

  @override
  String get foundationScreenSubtitle =>
      'Mobile Phase 0 — architecture, theme, localization and data-layer scaffolding only. Feature screens arrive in later phases.';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get sectionTheme => 'Appearance';

  @override
  String get sectionBackendStatus => 'Backend connectivity';

  @override
  String get sectionComponents => 'Design system components';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String environmentLabel(String name) {
    return 'Environment: $name';
  }

  @override
  String apiBaseUrlLabel(String url) {
    return 'API base URL: $url';
  }

  @override
  String get backendStatusOk => 'Reachable';

  @override
  String get backendStatusDegraded => 'Degraded';

  @override
  String get backendStatusDown => 'Unreachable';

  @override
  String backendStatusCheckedAt(String time) {
    return 'Checked at $time';
  }

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionCheckAgain => 'Check again';

  @override
  String get actionPrimaryExample => 'Primary action';

  @override
  String get actionSecondaryExample => 'Secondary action';

  @override
  String get stateLoadingTitle => 'Loading…';

  @override
  String get stateEmptyTitle => 'Nothing here yet';

  @override
  String get stateEmptySubtitle =>
      'When there is something to show, it will appear here.';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get errorGeneric =>
      'We could not complete that request. Please try again.';

  @override
  String get errorNetwork =>
      'You appear to be offline. Check your connection and try again.';

  @override
  String get errorTimeout => 'The request took too long. Please try again.';

  @override
  String get errorUnauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorServer =>
      'The service is temporarily unavailable. Please try again later.';

  @override
  String get errorNotImplemented => 'This is not available in Phase 0.';

  @override
  String get textFieldExampleLabel => 'Full name';

  @override
  String get textFieldExampleHint => 'Enter your name';
}
