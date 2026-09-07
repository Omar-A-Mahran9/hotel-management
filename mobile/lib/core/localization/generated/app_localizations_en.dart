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

  @override
  String get entryTagline => 'A stay without paperwork';

  @override
  String get entryHeadline =>
      'Book, verify and enter your room — from your phone';

  @override
  String get entrySubtext => 'No queues, no front desk';

  @override
  String get entryStartAction => 'Start now';

  @override
  String get entryLanguageSwitchLabel => 'Language';

  @override
  String get authPhoneTitle => 'Sign in';

  @override
  String get authPhoneHeading => 'Enter your mobile number';

  @override
  String get authPhoneBody =>
      'We use it to confirm your booking and send your room entry code. We will not use it for anything else.';

  @override
  String get authPhoneFieldLabel => 'Mobile number';

  @override
  String get authPhoneFieldHint => '51 234 5678';

  @override
  String get authPhoneHelper =>
      'We will send a verification code to this number';

  @override
  String get authPhoneTerms =>
      'By continuing you agree to the Terms and the Privacy Policy.';

  @override
  String get authPhoneSubmit => 'Send verification code';

  @override
  String get authPhoneInvalid => 'Enter a valid mobile number';

  @override
  String get authOtpTitle => 'Verification code';

  @override
  String get authOtpHeading => 'Enter the code we sent';

  @override
  String get authOtpChange => 'Change';

  @override
  String authOtpResendCountdown(String time) {
    return 'Resend in $time';
  }

  @override
  String get authOtpResendAction => 'Resend the code';

  @override
  String get authOtpSubmit => 'Confirm';

  @override
  String authOtpInvalidFormat(int length) {
    return 'Enter the $length-digit code';
  }

  @override
  String get authOtpErrorTitle => 'Incorrect code';

  @override
  String authOtpErrorBody(int count) {
    return 'Attempts remaining: $count. Use the most recent code — earlier codes stop working as soon as a new one is sent.';
  }

  @override
  String get authOtpRetry => 'Try again';

  @override
  String get authOtpChangeNumber => 'Change mobile number';

  @override
  String get authOtpLockedTitle => 'Too many attempts';

  @override
  String get authOtpLockedBody =>
      'For your security we stopped accepting codes. Request a new code to continue.';

  @override
  String get authProfileTitle => 'Complete your details';

  @override
  String get authProfileBannerTitle =>
      'Write your name exactly as it appears on your ID';

  @override
  String get authProfileBannerBody =>
      'The system matches your name against your ID during verification. Any difference may delay your check-in.';

  @override
  String get authProfileNameLabel => 'Full name';

  @override
  String get authProfileNameHint => 'Mahmoud Nabil';

  @override
  String get authProfileEmailLabel => 'Email';

  @override
  String get authProfileEmailHint => 'name@example.com';

  @override
  String get authProfileSubmit => 'Save and continue';

  @override
  String get authProfileNameInvalid => 'Enter your full name';

  @override
  String get authProfileEmailInvalid => 'Enter a valid email address';

  @override
  String get authSessionExpiredTitle => 'Session ended';

  @override
  String get authSessionExpiredBannerTitle => 'Your session has ended';

  @override
  String get authSessionExpiredBannerBody =>
      'Your booking is saved and was not cancelled. Sign in again and we will take you back to where you left off.';

  @override
  String get authSessionExpiredSubmit => 'Sign in';

  @override
  String get authSignOut => 'Sign out';

  @override
  String authDemoHint(String code) {
    return 'Development build: the verification code is $code.';
  }
}
