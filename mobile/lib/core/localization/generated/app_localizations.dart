import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Product name shown in the app bar and app metadata.
  ///
  /// In en, this message translates to:
  /// **'Hotel System'**
  String get appName;

  /// One-line promise shown on the foundation screen.
  ///
  /// In en, this message translates to:
  /// **'Book, verify and enter — from your phone.'**
  String get appTagline;

  /// Title of the Phase 0 placeholder screen.
  ///
  /// In en, this message translates to:
  /// **'Foundation & Design System'**
  String get foundationScreenTitle;

  /// No description provided for @foundationScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Phase 0 — architecture, theme, localization and data-layer scaffolding only. Feature screens arrive in later phases.'**
  String get foundationScreenSubtitle;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @sectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionTheme;

  /// No description provided for @sectionBackendStatus.
  ///
  /// In en, this message translates to:
  /// **'Backend connectivity'**
  String get sectionBackendStatus;

  /// No description provided for @sectionComponents.
  ///
  /// In en, this message translates to:
  /// **'Design system components'**
  String get sectionComponents;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @environmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Environment: {name}'**
  String environmentLabel(String name);

  /// No description provided for @apiBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'API base URL: {url}'**
  String apiBaseUrlLabel(String url);

  /// No description provided for @backendStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Reachable'**
  String get backendStatusOk;

  /// No description provided for @backendStatusDegraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get backendStatusDegraded;

  /// No description provided for @backendStatusDown.
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get backendStatusDown;

  /// No description provided for @backendStatusCheckedAt.
  ///
  /// In en, this message translates to:
  /// **'Checked at {time}'**
  String backendStatusCheckedAt(String time);

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get actionCheckAgain;

  /// No description provided for @actionPrimaryExample.
  ///
  /// In en, this message translates to:
  /// **'Primary action'**
  String get actionPrimaryExample;

  /// No description provided for @actionSecondaryExample.
  ///
  /// In en, this message translates to:
  /// **'Secondary action'**
  String get actionSecondaryExample;

  /// No description provided for @stateLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get stateLoadingTitle;

  /// No description provided for @stateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmptyTitle;

  /// No description provided for @stateEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When there is something to show, it will appear here.'**
  String get stateEmptySubtitle;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that request. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'You appear to be offline. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'This is not available in Phase 0.'**
  String get errorNotImplemented;

  /// No description provided for @textFieldExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get textFieldExampleLabel;

  /// No description provided for @textFieldExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get textFieldExampleHint;

  /// Small eyebrow line above the entry headline (01 · Entry).
  ///
  /// In en, this message translates to:
  /// **'A stay without paperwork'**
  String get entryTagline;

  /// No description provided for @entryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Book, verify and enter your room — from your phone'**
  String get entryHeadline;

  /// No description provided for @entrySubtext.
  ///
  /// In en, this message translates to:
  /// **'No queues, no front desk'**
  String get entrySubtext;

  /// No description provided for @entryStartAction.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get entryStartAction;

  /// No description provided for @entryLanguageSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get entryLanguageSwitchLabel;

  /// No description provided for @authPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get authPhoneHeading;

  /// No description provided for @authPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'We use it to confirm your booking and send your room entry code. We will not use it for anything else.'**
  String get authPhoneBody;

  /// No description provided for @authPhoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get authPhoneFieldLabel;

  /// No description provided for @authPhoneFieldHint.
  ///
  /// In en, this message translates to:
  /// **'51 234 5678'**
  String get authPhoneFieldHint;

  /// No description provided for @authPhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code to this number'**
  String get authPhoneHelper;

  /// No description provided for @authPhoneTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the Terms and the Privacy Policy.'**
  String get authPhoneTerms;

  /// No description provided for @authPhoneSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get authPhoneSubmit;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get authPhoneInvalid;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authOtpTitle;

  /// No description provided for @authOtpHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent'**
  String get authOtpHeading;

  /// No description provided for @authOtpChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get authOtpChange;

  /// No description provided for @authOtpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String authOtpResendCountdown(String time);

  /// No description provided for @authOtpResendAction.
  ///
  /// In en, this message translates to:
  /// **'Resend the code'**
  String get authOtpResendAction;

  /// No description provided for @authOtpSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authOtpSubmit;

  /// No description provided for @authOtpInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter the {length}-digit code'**
  String authOtpInvalidFormat(int length);

  /// No description provided for @authOtpErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get authOtpErrorTitle;

  /// No description provided for @authOtpErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Attempts remaining: {count}. Use the most recent code — earlier codes stop working as soon as a new one is sent.'**
  String authOtpErrorBody(int count);

  /// No description provided for @authOtpRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get authOtpRetry;

  /// No description provided for @authOtpChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change mobile number'**
  String get authOtpChangeNumber;

  /// No description provided for @authOtpLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get authOtpLockedTitle;

  /// No description provided for @authOtpLockedBody.
  ///
  /// In en, this message translates to:
  /// **'For your security we stopped accepting codes. Request a new code to continue.'**
  String get authOtpLockedBody;

  /// No description provided for @authProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your details'**
  String get authProfileTitle;

  /// No description provided for @authProfileBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your name exactly as it appears on your ID'**
  String get authProfileBannerTitle;

  /// No description provided for @authProfileBannerBody.
  ///
  /// In en, this message translates to:
  /// **'The system matches your name against your ID during verification. Any difference may delay your check-in.'**
  String get authProfileBannerBody;

  /// No description provided for @authProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authProfileNameLabel;

  /// No description provided for @authProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Mahmoud Nabil'**
  String get authProfileNameHint;

  /// No description provided for @authProfileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authProfileEmailLabel;

  /// No description provided for @authProfileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authProfileEmailHint;

  /// No description provided for @authProfileSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get authProfileSubmit;

  /// No description provided for @authProfileNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authProfileNameInvalid;

  /// No description provided for @authProfileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authProfileEmailInvalid;

  /// No description provided for @authSessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get authSessionExpiredTitle;

  /// No description provided for @authSessionExpiredBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended'**
  String get authSessionExpiredBannerTitle;

  /// No description provided for @authSessionExpiredBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Your booking is saved and was not cancelled. Sign in again and we will take you back to where you left off.'**
  String get authSessionExpiredBannerBody;

  /// No description provided for @authSessionExpiredSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSessionExpiredSubmit;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Development build: the verification code is {code}.'**
  String authDemoHint(String code);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
