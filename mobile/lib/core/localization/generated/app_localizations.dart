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
  /// **'This isn\'t available yet. Please try again later.'**
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

  /// App-bar title of the first-run language selection screen (01 · Entry).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageScreenTitle;

  /// No description provided for @languageScreenHeading.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get languageScreenHeading;

  /// No description provided for @languageScreenBody.
  ///
  /// In en, this message translates to:
  /// **'You can change it later from Account. The interface is designed in Arabic first.'**
  String get languageScreenBody;

  /// Small marker on the language that is pre-selected on first run (Arabic).
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get languageDefaultTag;

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

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get navBookings;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// Snackbar shown when a not-yet-built bottom-nav tab is tapped.
  ///
  /// In en, this message translates to:
  /// **'This section is coming in a later update.'**
  String get navComingSoon;

  /// No description provided for @discoverGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get discoverGreeting;

  /// No description provided for @discoverGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String discoverGreetingNamed(String name);

  /// No description provided for @discoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the group\'s hotels'**
  String get discoverSubtitle;

  /// No description provided for @discoverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a hotel or city'**
  String get discoverSearchHint;

  /// No description provided for @discoverNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get discoverNotificationsTooltip;

  /// App-bar action shown to a guest browsing without an account.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get discoverSignIn;

  /// No description provided for @discoverFeaturedSection.
  ///
  /// In en, this message translates to:
  /// **'Group hotels'**
  String get discoverFeaturedSection;

  /// No description provided for @discoverExploreRooms.
  ///
  /// In en, this message translates to:
  /// **'Explore rooms'**
  String get discoverExploreRooms;

  /// No description provided for @discoverUpcomingStay.
  ///
  /// In en, this message translates to:
  /// **'Your upcoming stay'**
  String get discoverUpcomingStay;

  /// No description provided for @discoverSubtitleHotel.
  ///
  /// In en, this message translates to:
  /// **'Discover {hotel}'**
  String discoverSubtitleHotel(String hotel);

  /// No description provided for @discoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No hotels to show yet'**
  String get discoverEmptyTitle;

  /// No description provided for @discoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'The group\'s hotels will appear here once they are published.'**
  String get discoverEmptyBody;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearTooltip;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No hotels available} =1{1 hotel available} other{{count} hotels available}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No hotels match your search'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different city or clear your filters.'**
  String get searchNoResultsBody;

  /// No description provided for @searchClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get searchClearFilters;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortTopRated;

  /// No description provided for @sortLowestPrice.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get sortLowestPrice;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort results'**
  String get sortTitle;

  /// No description provided for @sortHint.
  ///
  /// In en, this message translates to:
  /// **'The order stays until you change it or search again.'**
  String get sortHint;

  /// No description provided for @sortApply.
  ///
  /// In en, this message translates to:
  /// **'Apply sort'**
  String get sortApply;

  /// No description provided for @sortActiveTag.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get sortActiveTag;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter results'**
  String get filterTitle;

  /// No description provided for @filterMatchCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matching hotels} =1{1 matching hotel} other{{count} matching hotels}}'**
  String filterMatchCount(int count);

  /// No description provided for @filterHint.
  ///
  /// In en, this message translates to:
  /// **'Adjust the criteria to narrow the results.'**
  String get filterHint;

  /// No description provided for @filterCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get filterCityLabel;

  /// No description provided for @filterValueAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterValueAll;

  /// No description provided for @filterSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String filterSelectedCount(int count);

  /// No description provided for @filterPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get filterPriceLabel;

  /// No description provided for @filterFacilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get filterFacilitiesLabel;

  /// No description provided for @filterRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get filterRatingLabel;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get filterApply;

  /// No description provided for @filterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filterClearAll;

  /// No description provided for @filterCityPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get filterCityPickerTitle;

  /// No description provided for @filterCityPickerHint.
  ///
  /// In en, this message translates to:
  /// **'You can choose more than one city. Results update when you apply.'**
  String get filterCityPickerHint;

  /// No description provided for @cityHotelCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hotel} other{{count} hotels}}'**
  String cityHotelCount(int count);

  /// No description provided for @priceRangeValue.
  ///
  /// In en, this message translates to:
  /// **'SAR {min} – SAR {max}'**
  String priceRangeValue(int min, int max);

  /// No description provided for @priceFrom.
  ///
  /// In en, this message translates to:
  /// **'from SAR {amount}'**
  String priceFrom(int amount);

  /// No description provided for @pricePerNight.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount} / night'**
  String pricePerNight(int amount);

  /// No description provided for @priceStayTotal.
  ///
  /// In en, this message translates to:
  /// **'SAR {amount} total'**
  String priceStayTotal(int amount);

  /// No description provided for @priceFromLabel.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get priceFromLabel;

  /// No description provided for @priceNightSuffix.
  ///
  /// In en, this message translates to:
  /// **'/ night'**
  String get priceNightSuffix;

  /// No description provided for @priceTotalSuffix.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get priceTotalSuffix;

  /// No description provided for @hotelRatingValue.
  ///
  /// In en, this message translates to:
  /// **'{rating}'**
  String hotelRatingValue(double rating);

  /// No description provided for @hotelReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String hotelReviewCount(int count);

  /// No description provided for @hotelAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get hotelAvailable;

  /// No description provided for @hotelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available right now'**
  String get hotelUnavailable;

  /// No description provided for @hotelDetailReviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & reviews'**
  String get hotelDetailReviews;

  /// No description provided for @hotelReviewCleanliness.
  ///
  /// In en, this message translates to:
  /// **'Cleanliness'**
  String get hotelReviewCleanliness;

  /// No description provided for @hotelReviewCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get hotelReviewCommunication;

  /// No description provided for @hotelReviewLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get hotelReviewLocation;

  /// No description provided for @hotelDetailAmenities.
  ///
  /// In en, this message translates to:
  /// **'What this hotel offers'**
  String get hotelDetailAmenities;

  /// No description provided for @hotelRoomTypeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 room type} other{{count} room types}}'**
  String hotelRoomTypeCount(int count);

  /// No description provided for @hotelPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{+{count}}}'**
  String hotelPhotoCount(int count);

  /// No description provided for @hotelSelectDates.
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get hotelSelectDates;

  /// No description provided for @hotelBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get hotelBookNow;

  /// No description provided for @hotelGuestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String hotelGuestCount(int count);

  /// No description provided for @roomAreaSqm.
  ///
  /// In en, this message translates to:
  /// **'{area} m²'**
  String roomAreaSqm(int area);

  /// No description provided for @amenityFreeWifi.
  ///
  /// In en, this message translates to:
  /// **'Free Wi-Fi'**
  String get amenityFreeWifi;

  /// No description provided for @amenityBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get amenityBreakfast;

  /// No description provided for @amenityParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get amenityParking;

  /// No description provided for @amenityPool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get amenityPool;

  /// No description provided for @amenityGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get amenityGym;

  /// No description provided for @amenityFamilyRooms.
  ///
  /// In en, this message translates to:
  /// **'Family rooms'**
  String get amenityFamilyRooms;

  /// No description provided for @amenityAirportShuttle.
  ///
  /// In en, this message translates to:
  /// **'Airport shuttle'**
  String get amenityAirportShuttle;

  /// No description provided for @amenityRoomService.
  ///
  /// In en, this message translates to:
  /// **'Room service'**
  String get amenityRoomService;

  /// No description provided for @amenityAirConditioning.
  ///
  /// In en, this message translates to:
  /// **'Air conditioning'**
  String get amenityAirConditioning;

  /// No description provided for @amenityCityView.
  ///
  /// In en, this message translates to:
  /// **'City view'**
  String get amenityCityView;

  /// No description provided for @amenityBalcony.
  ///
  /// In en, this message translates to:
  /// **'Balcony'**
  String get amenityBalcony;

  /// No description provided for @amenityKitchenette.
  ///
  /// In en, this message translates to:
  /// **'Kitchenette'**
  String get amenityKitchenette;

  /// No description provided for @stayDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your stay dates'**
  String get stayDatesTitle;

  /// No description provided for @stayDatesCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get stayDatesCheckIn;

  /// No description provided for @stayDatesCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get stayDatesCheckOut;

  /// No description provided for @stayDatesPick.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get stayDatesPick;

  /// No description provided for @stayDatesClear.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get stayDatesClear;

  /// No description provided for @stayDatesShowRooms.
  ///
  /// In en, this message translates to:
  /// **'Show available rooms'**
  String get stayDatesShowRooms;

  /// No description provided for @stayNights.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 night} other{{count} nights}}'**
  String stayNights(int count);

  /// No description provided for @stayDatesErrorCheckoutBeforeCheckin.
  ///
  /// In en, this message translates to:
  /// **'Check-out must be after check-in'**
  String get stayDatesErrorCheckoutBeforeCheckin;

  /// No description provided for @stayDatesErrorPast.
  ///
  /// In en, this message translates to:
  /// **'Choose a date from today onwards'**
  String get stayDatesErrorPast;

  /// No description provided for @stayDatesEditDates.
  ///
  /// In en, this message translates to:
  /// **'Edit dates'**
  String get stayDatesEditDates;

  /// No description provided for @guestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Number of guests'**
  String get guestsTitle;

  /// No description provided for @guestsAdults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get guestsAdults;

  /// No description provided for @guestsChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get guestsChildren;

  /// No description provided for @guestsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm guests'**
  String get guestsConfirm;

  /// No description provided for @stepperDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get stepperDecrease;

  /// No description provided for @stepperIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get stepperIncrease;

  /// No description provided for @guestsAdultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 adult} other{{count} adults}}'**
  String guestsAdultsCount(int count);

  /// No description provided for @guestsChildrenCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 child} other{{count} children}}'**
  String guestsChildrenCount(int count);

  /// No description provided for @roomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available rooms'**
  String get roomsTitle;

  /// No description provided for @roomsAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None available} =1{1 available} other{{count} available}}'**
  String roomsAvailableCount(int count);

  /// No description provided for @roomsSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get roomsSortLabel;

  /// No description provided for @roomsSortLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get roomsSortLowest;

  /// No description provided for @roomsSortHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest price'**
  String get roomsSortHighest;

  /// No description provided for @roomOccupancy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String roomOccupancy(int count);

  /// No description provided for @roomBreakfastIncluded.
  ///
  /// In en, this message translates to:
  /// **'Breakfast included'**
  String get roomBreakfastIncluded;

  /// No description provided for @roomFreeCancellation.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation'**
  String get roomFreeCancellation;

  /// No description provided for @roomNonRefundable.
  ///
  /// In en, this message translates to:
  /// **'Non-refundable'**
  String get roomNonRefundable;

  /// No description provided for @roomSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Not available for these dates'**
  String get roomSoldOut;

  /// No description provided for @roomsAllSoldOutTitle.
  ///
  /// In en, this message translates to:
  /// **'All rooms are sold out for these dates'**
  String get roomsAllSoldOutTitle;

  /// No description provided for @roomsAllSoldOutBody.
  ///
  /// In en, this message translates to:
  /// **'Try different dates and we will show the rooms that open up.'**
  String get roomsAllSoldOutBody;

  /// No description provided for @roomsNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No rooms for these dates'**
  String get roomsNoResultsTitle;

  /// No description provided for @roomsNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try different dates or adjust the number of guests.'**
  String get roomsNoResultsBody;

  /// No description provided for @roomsChangeDates.
  ///
  /// In en, this message translates to:
  /// **'Change dates'**
  String get roomsChangeDates;

  /// No description provided for @roomsChangeGuests.
  ///
  /// In en, this message translates to:
  /// **'Change guests'**
  String get roomsChangeGuests;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Seven short weekday names, Sunday first, comma-separated.
  ///
  /// In en, this message translates to:
  /// **'Sun,Mon,Tue,Wed,Thu,Fri,Sat'**
  String get calendarWeekdays;

  /// Selected check-in – check-out summary; dates are pre-formatted.
  ///
  /// In en, this message translates to:
  /// **'{checkIn} – {checkOut}'**
  String stayDatesSelectedRange(String checkIn, String checkOut);

  /// No description provided for @stayDatesHintPickCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Choose your check-in date to start'**
  String get stayDatesHintPickCheckIn;

  /// No description provided for @stayDatesHintPickCheckOut.
  ///
  /// In en, this message translates to:
  /// **'{checkIn} · choose your check-out date'**
  String stayDatesHintPickCheckOut(String checkIn);

  /// No description provided for @stayDatesFieldPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get stayDatesFieldPlaceholder;

  /// No description provided for @roomSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get roomSelect;

  /// No description provided for @roomSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get roomSelected;

  /// No description provided for @roomViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get roomViewDetails;

  /// No description provided for @roomDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Room details'**
  String get roomDetailsTitle;

  /// No description provided for @roomBedType.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get roomBedType;

  /// No description provided for @roomCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleeps'**
  String get roomCapacityLabel;

  /// No description provided for @roomPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get roomPolicyLabel;

  /// No description provided for @roomPolicyRefundable.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation'**
  String get roomPolicyRefundable;

  /// No description provided for @roomPolicyNonRefundable.
  ///
  /// In en, this message translates to:
  /// **'Non-refundable'**
  String get roomPolicyNonRefundable;

  /// No description provided for @roomSelectThisRoom.
  ///
  /// In en, this message translates to:
  /// **'Select this room'**
  String get roomSelectThisRoom;

  /// No description provided for @roomRemoveSelection.
  ///
  /// In en, this message translates to:
  /// **'Remove selection'**
  String get roomRemoveSelection;

  /// No description provided for @roomStayTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'for {nights, plural, =1{1 night} other{{nights} nights}}'**
  String roomStayTotalLabel(int nights);

  /// No description provided for @roomDetailAmenitiesHeading.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get roomDetailAmenitiesHeading;

  /// No description provided for @roomDetailCancellationHeading.
  ///
  /// In en, this message translates to:
  /// **'Cancellation policy'**
  String get roomDetailCancellationHeading;

  /// No description provided for @roomDetailStayHeading.
  ///
  /// In en, this message translates to:
  /// **'Your stay'**
  String get roomDetailStayHeading;

  /// No description provided for @roomSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort rooms'**
  String get roomSortTitle;

  /// No description provided for @roomSortApply.
  ///
  /// In en, this message translates to:
  /// **'Apply sort'**
  String get roomSortApply;

  /// No description provided for @roomSortActiveTag.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get roomSortActiveTag;

  /// No description provided for @roomsSortTrigger.
  ///
  /// In en, this message translates to:
  /// **'Sort: {label}'**
  String roomsSortTrigger(String label);

  /// No description provided for @roomsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get roomsContinue;

  /// No description provided for @roomsSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a room to continue'**
  String get roomsSelectPrompt;

  /// No description provided for @roomsSelectionClearedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your room selection was cleared because the stay details changed. Choose a room again.'**
  String get roomsSelectionClearedNotice;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your selection'**
  String get reviewTitle;

  /// No description provided for @reviewNotBookedNotice.
  ///
  /// In en, this message translates to:
  /// **'Nothing is booked yet. You can still change your dates, guests or room before the reservation step.'**
  String get reviewNotBookedNotice;

  /// No description provided for @reviewHotelLabel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get reviewHotelLabel;

  /// No description provided for @reviewRoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get reviewRoomLabel;

  /// No description provided for @reviewStayLabel.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get reviewStayLabel;

  /// No description provided for @reviewGuestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get reviewGuestsLabel;

  /// No description provided for @reviewCheckInLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get reviewCheckInLabel;

  /// No description provided for @reviewCheckOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get reviewCheckOutLabel;

  /// No description provided for @reviewPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get reviewPriceLabel;

  /// No description provided for @reviewTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total for {nights, plural, =1{1 night} other{{nights} nights}}'**
  String reviewTotalLabel(int nights);

  /// No description provided for @reviewChangeSelection.
  ///
  /// In en, this message translates to:
  /// **'Change selection'**
  String get reviewChangeSelection;

  /// No description provided for @reviewNoSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No room selected'**
  String get reviewNoSelectionTitle;

  /// No description provided for @reviewNoSelectionBody.
  ///
  /// In en, this message translates to:
  /// **'Go back and choose a room to see your selection here.'**
  String get reviewNoSelectionBody;

  /// No description provided for @reviewBackToRooms.
  ///
  /// In en, this message translates to:
  /// **'Back to rooms'**
  String get reviewBackToRooms;

  /// Primary CTA on the review screen for a guest who has not signed in yet.
  ///
  /// In en, this message translates to:
  /// **'Sign in to confirm'**
  String get reviewSignInToConfirm;

  /// Helper line under the review summary explaining why sign-in is required at this step.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need an account to confirm this booking. Browsing stays free.'**
  String get reviewSignInHint;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stay dates'**
  String get bookingDatesLabel;

  /// No description provided for @bookingRoomSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Stay subtotal'**
  String get bookingRoomSubtotal;

  /// No description provided for @bookingServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get bookingServiceFee;

  /// Shown under a design-only mock service fee; the real amount comes from the backend.
  ///
  /// In en, this message translates to:
  /// **'Estimate for display — the hotel confirms the final amount.'**
  String get bookingServiceFeeNote;

  /// No description provided for @bookingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bookingTotal;

  /// No description provided for @bookingProceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to payment'**
  String get bookingProceedToPayment;

  /// No description provided for @bookingRoomAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get bookingRoomAvailable;

  /// No description provided for @reservationConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm reservation'**
  String get reservationConfirmCta;

  /// No description provided for @reservationConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming…'**
  String get reservationConfirming;

  /// No description provided for @reservationConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'By confirming, you request this room for the dates above. Nothing is charged yet.'**
  String get reservationConfirmHint;

  /// No description provided for @reservationCreateFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm your reservation'**
  String get reservationCreateFailedTitle;

  /// No description provided for @reservationStatusFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reservationStatusFieldLabel;

  /// No description provided for @reservationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reservationStatusPending;

  /// Guest-facing umbrella label for a secured booking (design-system content/status/confirmed). ReservationStatus itself has no `confirmed` member; used on the confirmation screen and future Bookings-list filter.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get reservationStatusConfirmed;

  /// No description provided for @reservationStatusDepositHeld.
  ///
  /// In en, this message translates to:
  /// **'Deposit held'**
  String get reservationStatusDepositHeld;

  /// No description provided for @reservationStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get reservationStatusVerified;

  /// No description provided for @reservationStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get reservationStatusCheckedIn;

  /// No description provided for @reservationStatusInStay.
  ///
  /// In en, this message translates to:
  /// **'In stay'**
  String get reservationStatusInStay;

  /// No description provided for @reservationStatusCheckoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Checkout in progress'**
  String get reservationStatusCheckoutInProgress;

  /// No description provided for @reservationStatusCheckoutBlocked.
  ///
  /// In en, this message translates to:
  /// **'Checkout on hold'**
  String get reservationStatusCheckoutBlocked;

  /// No description provided for @reservationStatusCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'Checked out'**
  String get reservationStatusCheckedOut;

  /// No description provided for @reservationStatusInvoiced.
  ///
  /// In en, this message translates to:
  /// **'Invoiced'**
  String get reservationStatusInvoiced;

  /// No description provided for @reservationStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reservationStatusCancelled;

  /// A currency amount, e.g. 'SAR 900'.
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount}'**
  String moneyAmount(String currency, int amount);

  /// No description provided for @paymentReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentReviewTitle;

  /// No description provided for @paymentProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing payment'**
  String get paymentProcessingTitle;

  /// No description provided for @paymentResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentResultTitle;

  /// No description provided for @paymentReservationLabel.
  ///
  /// In en, this message translates to:
  /// **'Reservation'**
  String get paymentReservationLabel;

  /// No description provided for @paymentStatusFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get paymentStatusFieldLabel;

  /// No description provided for @paymentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentAmountLabel;

  /// No description provided for @paymentPayNowCta.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get paymentPayNowCta;

  /// No description provided for @paymentHoldExplainer.
  ///
  /// In en, this message translates to:
  /// **'A refundable deposit hold is placed for your stay. Nothing is charged now.'**
  String get paymentHoldExplainer;

  /// No description provided for @paymentProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment…'**
  String get paymentProcessingBody;

  /// No description provided for @paymentDoNotClose.
  ///
  /// In en, this message translates to:
  /// **'Please keep this screen open.'**
  String get paymentDoNotClose;

  /// No description provided for @paymentAlreadyHeldTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit already held'**
  String get paymentAlreadyHeldTitle;

  /// No description provided for @paymentAlreadyHeldBody.
  ///
  /// In en, this message translates to:
  /// **'The deposit hold for this reservation is already in place.'**
  String get paymentAlreadyHeldBody;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit hold confirmed'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your deposit is secured. You can continue with identity verification.'**
  String get paymentSuccessBody;

  /// No description provided for @paymentPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment is processing'**
  String get paymentPendingTitle;

  /// No description provided for @paymentPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your bank hasn\'t confirmed the hold yet. You can check the status again shortly.'**
  String get paymentPendingBody;

  /// No description provided for @paymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment didn\'t go through'**
  String get paymentFailedTitle;

  /// No description provided for @paymentFailedBody.
  ///
  /// In en, this message translates to:
  /// **'No money was taken. You can try again.'**
  String get paymentFailedBody;

  /// No description provided for @paymentCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelledTitle;

  /// No description provided for @paymentExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment hold expired'**
  String get paymentExpiredTitle;

  /// No description provided for @paymentRetryCta.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get paymentRetryCta;

  /// No description provided for @paymentBackToReservation.
  ///
  /// In en, this message translates to:
  /// **'Back to reservation'**
  String get paymentBackToReservation;

  /// No description provided for @paymentUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment is unavailable'**
  String get paymentUnavailableTitle;

  /// No description provided for @paymentStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get paymentStatusNotStarted;

  /// No description provided for @paymentStatusHoldRequested.
  ///
  /// In en, this message translates to:
  /// **'Authorizing'**
  String get paymentStatusHoldRequested;

  /// No description provided for @paymentStatusHoldActive.
  ///
  /// In en, this message translates to:
  /// **'Deposit held'**
  String get paymentStatusHoldActive;

  /// No description provided for @paymentStatusHoldFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentStatusHoldFailed;

  /// No description provided for @paymentStatusCaptureRequested.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get paymentStatusCaptureRequested;

  /// No description provided for @paymentStatusCaptured.
  ///
  /// In en, this message translates to:
  /// **'Charged'**
  String get paymentStatusCaptured;

  /// No description provided for @paymentStatusCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Charge failed'**
  String get paymentStatusCaptureFailed;

  /// No description provided for @paymentStatusFinalSettlementRequested.
  ///
  /// In en, this message translates to:
  /// **'Settling'**
  String get paymentStatusFinalSettlementRequested;

  /// No description provided for @paymentStatusSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get paymentStatusSettled;

  /// No description provided for @paymentStatusSettlementFailed.
  ///
  /// In en, this message translates to:
  /// **'Settlement failed'**
  String get paymentStatusSettlementFailed;

  /// No description provided for @paymentStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get paymentStatusCancelled;

  /// No description provided for @paymentStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get paymentStatusExpired;

  /// No description provided for @paymentStatusRefundRequested.
  ///
  /// In en, this message translates to:
  /// **'Refund pending'**
  String get paymentStatusRefundRequested;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentStatusRefunded;

  /// No description provided for @paymentStatusRefundFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund failed'**
  String get paymentStatusRefundFailed;

  /// No description provided for @identityVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identityVerificationTitle;

  /// No description provided for @identityVerificationResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identityVerificationResultTitle;

  /// No description provided for @identityVerifyCta.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get identityVerifyCta;

  /// No description provided for @identityStepDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get identityStepDocument;

  /// No description provided for @identityStepSelfie.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get identityStepSelfie;

  /// No description provided for @identityStepResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get identityStepResult;

  /// No description provided for @identityDocumentStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your ID document'**
  String get identityDocumentStepTitle;

  /// No description provided for @identityDocumentStepBody.
  ///
  /// In en, this message translates to:
  /// **'Use your passport, national ID or residence permit. Make sure the whole document is visible and readable.'**
  String get identityDocumentStepBody;

  /// No description provided for @identityDocumentTypePassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get identityDocumentTypePassport;

  /// No description provided for @identityDocumentTypeNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get identityDocumentTypeNationalId;

  /// No description provided for @identityDocumentTypeResidencePermit.
  ///
  /// In en, this message translates to:
  /// **'Residence permit'**
  String get identityDocumentTypeResidencePermit;

  /// No description provided for @identityDocumentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get identityDocumentTypeLabel;

  /// No description provided for @identityDocumentCaptureCta.
  ///
  /// In en, this message translates to:
  /// **'Add document photo'**
  String get identityDocumentCaptureCta;

  /// No description provided for @identityDocumentCapturedLabel.
  ///
  /// In en, this message translates to:
  /// **'Document photo added'**
  String get identityDocumentCapturedLabel;

  /// No description provided for @identityDocumentSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Continue to selfie'**
  String get identityDocumentSubmitCta;

  /// No description provided for @identitySelfieStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie'**
  String get identitySelfieStepTitle;

  /// No description provided for @identitySelfieStepBody.
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera in good light. We match your selfie to your ID photo.'**
  String get identitySelfieStepBody;

  /// No description provided for @identitySelfieCaptureCta.
  ///
  /// In en, this message translates to:
  /// **'Add selfie'**
  String get identitySelfieCaptureCta;

  /// No description provided for @identitySelfieCapturedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selfie added'**
  String get identitySelfieCapturedLabel;

  /// No description provided for @identitySelfieSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Submit for verification'**
  String get identitySelfieSubmitCta;

  /// No description provided for @identityProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verifying your identity'**
  String get identityProcessingTitle;

  /// No description provided for @identityProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Matching your selfie to your document…'**
  String get identityProcessingBody;

  /// No description provided for @identityApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get identityApprovedTitle;

  /// No description provided for @identityApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your identity is confirmed. You\'re ready for check-in.'**
  String get identityApprovedBody;

  /// No description provided for @identityManualReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual review in progress'**
  String get identityManualReviewTitle;

  /// No description provided for @identityManualReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Our team is reviewing your documents. This usually takes a short while — we\'ll notify you when it\'s done.'**
  String get identityManualReviewBody;

  /// No description provided for @identityRetryTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s try that again'**
  String get identityRetryTitle;

  /// No description provided for @identityRetryBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your identity from those photos. Please retake them and submit again.'**
  String get identityRetryBody;

  /// No description provided for @identityRetryCta.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get identityRetryCta;

  /// No description provided for @identityRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification not approved'**
  String get identityRejectedTitle;

  /// No description provided for @identityRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Our team could not approve your identity verification. Please contact the front desk for help.'**
  String get identityRejectedBody;

  /// No description provided for @identityRejectedRetryBody.
  ///
  /// In en, this message translates to:
  /// **'Our team could not approve your identity verification. You can submit new photos and try again.'**
  String get identityRejectedRetryBody;

  /// No description provided for @identityAttemptCount.
  ///
  /// In en, this message translates to:
  /// **'Attempt {count}'**
  String identityAttemptCount(int count);

  /// No description provided for @identityBackToReservation.
  ///
  /// In en, this message translates to:
  /// **'Back to reservation'**
  String get identityBackToReservation;

  /// No description provided for @identityViewResultCta.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get identityViewResultCta;

  /// No description provided for @identityUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification is unavailable'**
  String get identityUnavailableTitle;

  /// No description provided for @identityStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get identityStatusNotStarted;

  /// No description provided for @identityStatusDocumentUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document uploaded'**
  String get identityStatusDocumentUploaded;

  /// No description provided for @identityStatusSelfieCaptured.
  ///
  /// In en, this message translates to:
  /// **'Selfie captured'**
  String get identityStatusSelfieCaptured;

  /// No description provided for @identityStatusMatchingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get identityStatusMatchingInProgress;

  /// No description provided for @identityStatusAutoApproved.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get identityStatusAutoApproved;

  /// No description provided for @identityStatusPendingManualReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get identityStatusPendingManualReview;

  /// No description provided for @identityStatusStaffApproved.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get identityStatusStaffApproved;

  /// No description provided for @identityStatusStaffRejected.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get identityStatusStaffRejected;

  /// No description provided for @identityStatusRetryAllowed.
  ///
  /// In en, this message translates to:
  /// **'Retry needed'**
  String get identityStatusRetryAllowed;

  /// No description provided for @reservationCheckInCta.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get reservationCheckInCta;

  /// No description provided for @checkInTitle.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkInTitle;

  /// No description provided for @checkInProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking you in'**
  String get checkInProcessingTitle;

  /// No description provided for @accessTitle.
  ///
  /// In en, this message translates to:
  /// **'Room access'**
  String get accessTitle;

  /// No description provided for @checkInReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to check in'**
  String get checkInReadyTitle;

  /// No description provided for @checkInReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your reservation is verified. Check in to get your room number and entry code.'**
  String get checkInReadyBody;

  /// No description provided for @checkInNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not ready to check in yet'**
  String get checkInNotReadyTitle;

  /// No description provided for @checkInNotReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete payment and identity verification first.'**
  String get checkInNotReadyBody;

  /// No description provided for @checkInUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in isn\'t available'**
  String get checkInUnavailableTitle;

  /// No description provided for @checkInAlreadyDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re already checked in'**
  String get checkInAlreadyDoneTitle;

  /// No description provided for @checkInCta.
  ///
  /// In en, this message translates to:
  /// **'Check in now'**
  String get checkInCta;

  /// No description provided for @checkInProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Issuing your digital room key…'**
  String get checkInProcessingBody;

  /// No description provided for @checkInDoNotClose.
  ///
  /// In en, this message translates to:
  /// **'Please keep this screen open.'**
  String get checkInDoNotClose;

  /// No description provided for @checkInFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in didn\'t complete'**
  String get checkInFailedTitle;

  /// No description provided for @checkInFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Your room key couldn\'t be issued. You can try again.'**
  String get checkInFailedBody;

  /// No description provided for @checkInPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get checkInPendingTitle;

  /// No description provided for @checkInPendingBody.
  ///
  /// In en, this message translates to:
  /// **'The front desk is finishing your check-in. Check again shortly.'**
  String get checkInPendingBody;

  /// No description provided for @checkInRetryCta.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get checkInRetryCta;

  /// No description provided for @accessCheckedInTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re checked in'**
  String get accessCheckedInTitle;

  /// No description provided for @accessRoomNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Room number'**
  String get accessRoomNumberLabel;

  /// No description provided for @accessEntryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry code'**
  String get accessEntryCodeLabel;

  /// No description provided for @accessExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid until your stay ends · {date}'**
  String accessExpiresLabel(String date);

  /// No description provided for @accessHelpBanner.
  ///
  /// In en, this message translates to:
  /// **'Code not working? Contact reception.'**
  String get accessHelpBanner;

  /// No description provided for @accessNotIssuedTitle.
  ///
  /// In en, this message translates to:
  /// **'No room key yet'**
  String get accessNotIssuedTitle;

  /// No description provided for @accessNotIssuedBody.
  ///
  /// In en, this message translates to:
  /// **'Check in to get your digital room key.'**
  String get accessNotIssuedBody;

  /// No description provided for @accessRevokedTitle.
  ///
  /// In en, this message translates to:
  /// **'Room key deactivated'**
  String get accessRevokedTitle;

  /// No description provided for @accessRevokedBody.
  ///
  /// In en, this message translates to:
  /// **'This room key is no longer active. Contact reception if you need help.'**
  String get accessRevokedBody;

  /// No description provided for @accessExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Room key expired'**
  String get accessExpiredTitle;

  /// No description provided for @accessExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Your stay has ended, so this room key no longer works.'**
  String get accessExpiredBody;

  /// No description provided for @accessFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Room key unavailable'**
  String get accessFailedTitle;

  /// No description provided for @accessUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Access is unavailable'**
  String get accessUnavailableTitle;

  /// No description provided for @accessBackToReservation.
  ///
  /// In en, this message translates to:
  /// **'Back to reservation'**
  String get accessBackToReservation;

  /// No description provided for @accessStatusNotIssued.
  ///
  /// In en, this message translates to:
  /// **'Not issued'**
  String get accessStatusNotIssued;

  /// No description provided for @accessStatusIssueRequested.
  ///
  /// In en, this message translates to:
  /// **'Issuing'**
  String get accessStatusIssueRequested;

  /// No description provided for @accessStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get accessStatusActive;

  /// No description provided for @accessStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get accessStatusFailed;

  /// No description provided for @accessStatusRevokeRequested.
  ///
  /// In en, this message translates to:
  /// **'Deactivating'**
  String get accessStatusRevokeRequested;

  /// No description provided for @accessStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get accessStatusRevoked;

  /// No description provided for @accessStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get accessStatusExpired;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Hotel services'**
  String get servicesTitle;

  /// No description provided for @servicesIntroBanner.
  ///
  /// In en, this message translates to:
  /// **'Order what you need from your room. Requests go straight to reception.'**
  String get servicesIntroBanner;

  /// No description provided for @servicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get servicesEmptyTitle;

  /// No description provided for @servicesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'This hotel hasn\'t published any services yet.'**
  String get servicesEmptyBody;

  /// No description provided for @servicesUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Services are unavailable'**
  String get servicesUnavailableTitle;

  /// No description provided for @serviceUncategorised.
  ///
  /// In en, this message translates to:
  /// **'Other services'**
  String get serviceUncategorised;

  /// No description provided for @serviceFreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get serviceFreeLabel;

  /// No description provided for @serviceEstimatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{count} min'**
  String serviceEstimatedMinutes(int count);

  /// No description provided for @serviceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceDetailTitle;

  /// No description provided for @serviceQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get serviceQuantityLabel;

  /// No description provided for @serviceNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get serviceNotesLabel;

  /// No description provided for @serviceNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything the team should know'**
  String get serviceNotesHint;

  /// No description provided for @serviceRequestCta.
  ///
  /// In en, this message translates to:
  /// **'Request this service'**
  String get serviceRequestCta;

  /// No description provided for @serviceRequestingCta.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get serviceRequestingCta;

  /// No description provided for @serviceEstimatedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get serviceEstimatedTotalLabel;

  /// No description provided for @serviceChargeNote.
  ///
  /// In en, this message translates to:
  /// **'Any charge is added to your room account and settled at checkout.'**
  String get serviceChargeNote;

  /// No description provided for @serviceRequestFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your request'**
  String get serviceRequestFailedTitle;

  /// No description provided for @myRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequestsTitle;

  /// No description provided for @myRequestsIntroBanner.
  ///
  /// In en, this message translates to:
  /// **'Track each request. You can cancel one before the team starts it.'**
  String get myRequestsIntroBanner;

  /// No description provided for @myRequestsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get myRequestsEmptyTitle;

  /// No description provided for @myRequestsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Request a service and it will show up here.'**
  String get myRequestsEmptyBody;

  /// No description provided for @newRequestCta.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequestCta;

  /// No description provided for @serviceOrderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get serviceOrderDetailTitle;

  /// No description provided for @serviceOrderRequestedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get serviceOrderRequestedAtLabel;

  /// No description provided for @serviceOrderConfirmedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get serviceOrderConfirmedAtLabel;

  /// No description provided for @serviceCancelCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get serviceCancelCta;

  /// No description provided for @serviceCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this request?'**
  String get serviceCancelConfirmTitle;

  /// No description provided for @serviceCancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The team hasn\'t started this yet, so it can still be cancelled.'**
  String get serviceCancelConfirmBody;

  /// No description provided for @serviceCancelConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get serviceCancelConfirmCta;

  /// No description provided for @serviceCancelKeepCta.
  ///
  /// In en, this message translates to:
  /// **'Keep request'**
  String get serviceCancelKeepCta;

  /// No description provided for @serviceCancelNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This request can no longer be cancelled.'**
  String get serviceCancelNotAllowed;

  /// No description provided for @serviceContactReception.
  ///
  /// In en, this message translates to:
  /// **'Contact reception'**
  String get serviceContactReception;

  /// No description provided for @serviceContactReceptionHint.
  ///
  /// In en, this message translates to:
  /// **'Call reception from your room phone or the front desk for help with this request.'**
  String get serviceContactReceptionHint;

  /// No description provided for @serviceStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get serviceStatusRequested;

  /// No description provided for @serviceStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get serviceStatusConfirmed;

  /// No description provided for @serviceStatusFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get serviceStatusFulfilled;

  /// No description provided for @serviceStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get serviceStatusCancelled;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Completing checkout'**
  String get checkoutProcessingTitle;

  /// No description provided for @checkoutCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Your stay summary'**
  String get checkoutCompleteTitle;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceTitle;

  /// No description provided for @checkoutReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to check out'**
  String get checkoutReadyTitle;

  /// No description provided for @checkoutReadyBody.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks.'**
  String get checkoutReadyBody;

  /// No description provided for @checkoutNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout isn\'t available yet'**
  String get checkoutNotReadyTitle;

  /// No description provided for @checkoutNotReadyBody.
  ///
  /// In en, this message translates to:
  /// **'You can check out once your stay has started.'**
  String get checkoutNotReadyBody;

  /// No description provided for @checkoutUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout is unavailable'**
  String get checkoutUnavailableTitle;

  /// No description provided for @folioSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Charge summary'**
  String get folioSummaryTitle;

  /// No description provided for @folioAccommodationLine.
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get folioAccommodationLine;

  /// No description provided for @folioServiceLine.
  ///
  /// In en, this message translates to:
  /// **'Service charge'**
  String get folioServiceLine;

  /// No description provided for @folioTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get folioTotalLabel;

  /// No description provided for @folioPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Already paid'**
  String get folioPaidLabel;

  /// No description provided for @folioOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount due now'**
  String get folioOutstandingLabel;

  /// No description provided for @checkoutSettleNote.
  ///
  /// In en, this message translates to:
  /// **'The amount due is charged in one payment to your card on file. Your invoice is sent electronically.'**
  String get checkoutSettleNote;

  /// No description provided for @checkoutCompleteCta.
  ///
  /// In en, this message translates to:
  /// **'Complete checkout'**
  String get checkoutCompleteCta;

  /// No description provided for @checkoutProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Settling your account…'**
  String get checkoutProcessingBody;

  /// No description provided for @checkoutDoNotClose.
  ///
  /// In en, this message translates to:
  /// **'Please keep this screen open.'**
  String get checkoutDoNotClose;

  /// No description provided for @checkoutDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your stay'**
  String get checkoutDoneTitle;

  /// No description provided for @checkoutDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is settled and your invoice is ready.'**
  String get checkoutDoneBody;

  /// No description provided for @checkoutPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement is processing'**
  String get checkoutPendingTitle;

  /// No description provided for @checkoutPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your bank hasn\'t confirmed the payment yet. Check the status again shortly.'**
  String get checkoutPendingBody;

  /// No description provided for @checkoutFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement didn\'t complete'**
  String get checkoutFailedTitle;

  /// No description provided for @checkoutFailedBody.
  ///
  /// In en, this message translates to:
  /// **'No money was taken. You can try again.'**
  String get checkoutFailedBody;

  /// No description provided for @checkoutRetryCta.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get checkoutRetryCta;

  /// No description provided for @checkoutViewInvoiceCta.
  ///
  /// In en, this message translates to:
  /// **'View invoice'**
  String get checkoutViewInvoiceCta;

  /// No description provided for @checkoutDoneCta.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get checkoutDoneCta;

  /// No description provided for @checkoutStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get checkoutStatusInProgress;

  /// No description provided for @checkoutStatusAwaitingSettlement.
  ///
  /// In en, this message translates to:
  /// **'Awaiting settlement'**
  String get checkoutStatusAwaitingSettlement;

  /// No description provided for @checkoutStatusSettlementFailed.
  ///
  /// In en, this message translates to:
  /// **'Settlement failed'**
  String get checkoutStatusSettlementFailed;

  /// No description provided for @checkoutStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get checkoutStatusCompleted;

  /// No description provided for @invoiceIssuedBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your e-invoice was issued'**
  String get invoiceIssuedBannerTitle;

  /// No description provided for @invoiceIssuedBannerBody.
  ///
  /// In en, this message translates to:
  /// **'It was sent to your email and is always saved here — no paper invoice.'**
  String get invoiceIssuedBannerBody;

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice number'**
  String get invoiceNumberLabel;

  /// No description provided for @invoiceIssuedLabel.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get invoiceIssuedLabel;

  /// No description provided for @invoiceItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get invoiceItemsTitle;

  /// No description provided for @invoiceSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get invoiceSubtotalLabel;

  /// No description provided for @invoicePaymentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get invoicePaymentsLabel;

  /// No description provided for @invoiceOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get invoiceOutstandingLabel;

  /// No description provided for @invoiceSettledTag.
  ///
  /// In en, this message translates to:
  /// **'Settled in full'**
  String get invoiceSettledTag;

  /// No description provided for @invoiceNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'No invoice yet'**
  String get invoiceNotReadyTitle;

  /// No description provided for @invoiceNotReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your invoice will be here once you check out.'**
  String get invoiceNotReadyBody;

  /// No description provided for @invoiceUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice is unavailable'**
  String get invoiceUnavailableTitle;

  /// No description provided for @reservationLoyaltyCta.
  ///
  /// In en, this message translates to:
  /// **'Loyalty & points'**
  String get reservationLoyaltyCta;

  /// No description provided for @reservationReviewCta.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get reservationReviewCta;

  /// No description provided for @reservationViewReviewCta.
  ///
  /// In en, this message translates to:
  /// **'View your review'**
  String get reservationViewReviewCta;

  /// No description provided for @loyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty is unavailable'**
  String get loyaltyUnavailableTitle;

  /// No description provided for @loyaltyBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Points balance'**
  String get loyaltyBalanceLabel;

  /// No description provided for @loyaltyPointsValue.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{1 pt} other{{points} pts}}'**
  String loyaltyPointsValue(int points);

  /// No description provided for @loyaltyGroupWideNote.
  ///
  /// In en, this message translates to:
  /// **'Your points work across every hotel in the group.'**
  String get loyaltyGroupWideNote;

  /// No description provided for @loyaltyProgramOffTitle.
  ///
  /// In en, this message translates to:
  /// **'The loyalty programme isn\'t active'**
  String get loyaltyProgramOffTitle;

  /// No description provided for @loyaltyProgramOffBody.
  ///
  /// In en, this message translates to:
  /// **'This hotel group hasn\'t switched on points earning yet. There\'s nothing to do here for now.'**
  String get loyaltyProgramOffBody;

  /// No description provided for @loyaltyEarnCta.
  ///
  /// In en, this message translates to:
  /// **'Earn points for this stay'**
  String get loyaltyEarnCta;

  /// No description provided for @loyaltyEarningCta.
  ///
  /// In en, this message translates to:
  /// **'Adding your points…'**
  String get loyaltyEarningCta;

  /// No description provided for @loyaltyEarnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Points added'**
  String get loyaltyEarnedTitle;

  /// No description provided for @loyaltyEarnedBody.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{1 point was added to your balance.} other{{points} points were added to your balance.}}'**
  String loyaltyEarnedBody(int points);

  /// No description provided for @loyaltyAlreadyEarnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Points already added'**
  String get loyaltyAlreadyEarnedTitle;

  /// No description provided for @loyaltyAlreadyEarnedBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already earned points for this stay.'**
  String get loyaltyAlreadyEarnedBody;

  /// No description provided for @loyaltyNotEligibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Not eligible yet'**
  String get loyaltyNotEligibleTitle;

  /// No description provided for @loyaltyNotEligibleBody.
  ///
  /// In en, this message translates to:
  /// **'Points are added once your stay is completed.'**
  String get loyaltyNotEligibleBody;

  /// No description provided for @loyaltyNothingToEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'No points to add'**
  String get loyaltyNothingToEarnTitle;

  /// No description provided for @loyaltyNothingToEarnBody.
  ///
  /// In en, this message translates to:
  /// **'This stay doesn\'t have an amount that earns points.'**
  String get loyaltyNothingToEarnBody;

  /// No description provided for @loyaltyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Points history'**
  String get loyaltyHistoryTitle;

  /// No description provided for @loyaltyHistoryNote.
  ///
  /// In en, this message translates to:
  /// **'Your full points ledger is kept by the hotel group. This is a read-only copy.'**
  String get loyaltyHistoryNote;

  /// No description provided for @loyaltyHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No points activity yet'**
  String get loyaltyHistoryEmptyTitle;

  /// No description provided for @loyaltyHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Points you earn and redeem will show up here.'**
  String get loyaltyHistoryEmptyBody;

  /// No description provided for @loyaltyPointsAdded.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{+1 pt} other{+{points} pts}}'**
  String loyaltyPointsAdded(int points);

  /// No description provided for @loyaltyPointsRemoved.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{-1 pt} other{-{points} pts}}'**
  String loyaltyPointsRemoved(int points);

  /// No description provided for @loyaltyTxThisStay.
  ///
  /// In en, this message translates to:
  /// **'This stay'**
  String get loyaltyTxThisStay;

  /// No description provided for @loyaltyTxEarnLabel.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get loyaltyTxEarnLabel;

  /// No description provided for @loyaltyTxRedeemLabel.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get loyaltyTxRedeemLabel;

  /// No description provided for @loyaltyTxReverseLabel.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get loyaltyTxReverseLabel;

  /// No description provided for @loyaltyTxAdjustLabel.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get loyaltyTxAdjustLabel;

  /// No description provided for @loyaltyTxExpireLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get loyaltyTxExpireLabel;

  /// No description provided for @loyaltyRedeemCta.
  ///
  /// In en, this message translates to:
  /// **'Redeem points'**
  String get loyaltyRedeemCta;

  /// No description provided for @loyaltyRedeemTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem points'**
  String get loyaltyRedeemTitle;

  /// No description provided for @loyaltyRedeemSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get loyaltyRedeemSubmitCta;

  /// No description provided for @loyaltyRedeemingCta.
  ///
  /// In en, this message translates to:
  /// **'Redeeming…'**
  String get loyaltyRedeemingCta;

  /// No description provided for @loyaltyRedeemAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Points to redeem'**
  String get loyaltyRedeemAmountLabel;

  /// No description provided for @loyaltyRedeemNote.
  ///
  /// In en, this message translates to:
  /// **'Points are redeemed against this booking. The hotel group confirms the final value.'**
  String get loyaltyRedeemNote;

  /// No description provided for @loyaltyRedeemMax.
  ///
  /// In en, this message translates to:
  /// **'Use max ({points})'**
  String loyaltyRedeemMax(int points);

  /// No description provided for @loyaltyRedeemedTitle.
  ///
  /// In en, this message translates to:
  /// **'Points redeemed'**
  String get loyaltyRedeemedTitle;

  /// No description provided for @loyaltyRedeemedBody.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{1 point was redeemed against this booking.} other{{points} points were redeemed against this booking.}}'**
  String loyaltyRedeemedBody(int points);

  /// No description provided for @loyaltyRedeemedValueNote.
  ///
  /// In en, this message translates to:
  /// **'That\'s about {value} {currency} off this booking.'**
  String loyaltyRedeemedValueNote(String value, String currency);

  /// No description provided for @loyaltyRedeemNotEligibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t redeem on this booking'**
  String get loyaltyRedeemNotEligibleTitle;

  /// No description provided for @loyaltyRedeemNotEligibleBody.
  ///
  /// In en, this message translates to:
  /// **'Points can only be redeemed against an active booking.'**
  String get loyaltyRedeemNotEligibleBody;

  /// No description provided for @loyaltyAlreadyRedeemedTitle.
  ///
  /// In en, this message translates to:
  /// **'Already redeemed'**
  String get loyaltyAlreadyRedeemedTitle;

  /// No description provided for @loyaltyAlreadyRedeemedBody.
  ///
  /// In en, this message translates to:
  /// **'Points were already redeemed against this booking.'**
  String get loyaltyAlreadyRedeemedBody;

  /// No description provided for @loyaltyAlreadyRedeemedDifferentBody.
  ///
  /// In en, this message translates to:
  /// **'A different number of points was already redeemed against this booking.'**
  String get loyaltyAlreadyRedeemedDifferentBody;

  /// No description provided for @loyaltyInsufficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough points'**
  String get loyaltyInsufficientTitle;

  /// No description provided for @loyaltyInsufficientBody.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough points for that amount.'**
  String get loyaltyInsufficientBody;

  /// No description provided for @loyaltyInvalidAmountBody.
  ///
  /// In en, this message translates to:
  /// **'Choose how many points to redeem.'**
  String get loyaltyInvalidAmountBody;

  /// No description provided for @reviewFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get reviewFormTitle;

  /// No description provided for @reviewFormPrompt.
  ///
  /// In en, this message translates to:
  /// **'How was your stay?'**
  String get reviewFormPrompt;

  /// No description provided for @reviewResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get reviewResultTitle;

  /// No description provided for @reviewProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sending your review'**
  String get reviewProcessingTitle;

  /// No description provided for @reviewProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Sending your review…'**
  String get reviewProcessingBody;

  /// No description provided for @reviewDoNotClose.
  ///
  /// In en, this message translates to:
  /// **'This only takes a moment. Please don\'t close the app.'**
  String get reviewDoNotClose;

  /// No description provided for @reviewRatingRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a rating from 1 to 5 stars.'**
  String get reviewRatingRequired;

  /// No description provided for @reviewStarsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String reviewStarsLabel(int count);

  /// No description provided for @reviewTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Your review (optional)'**
  String get reviewTextLabel;

  /// No description provided for @reviewTextHint.
  ///
  /// In en, this message translates to:
  /// **'Tell other guests about your stay'**
  String get reviewTextHint;

  /// No description provided for @reviewSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get reviewSubmitCta;

  /// No description provided for @reviewSubmittingCta.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get reviewSubmittingCta;

  /// No description provided for @reviewYourRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get reviewYourRatingLabel;

  /// No description provided for @reviewBackToReservation.
  ///
  /// In en, this message translates to:
  /// **'Back to reservation'**
  String get reviewBackToReservation;

  /// No description provided for @reviewUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews are unavailable'**
  String get reviewUnavailableTitle;

  /// No description provided for @reviewNotEligibleTitle.
  ///
  /// In en, this message translates to:
  /// **'You can\'t review this stay'**
  String get reviewNotEligibleTitle;

  /// No description provided for @reviewNotEligibleBody.
  ///
  /// In en, this message translates to:
  /// **'Reviews open once your stay is completed.'**
  String get reviewNotEligibleBody;

  /// No description provided for @reviewSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review'**
  String get reviewSubmittedTitle;

  /// No description provided for @reviewPublishedBody.
  ///
  /// In en, this message translates to:
  /// **'Your review has been posted.'**
  String get reviewPublishedBody;

  /// No description provided for @reviewPendingModerationBody.
  ///
  /// In en, this message translates to:
  /// **'Your review was received and is with our team for a quick check before it\'s published.'**
  String get reviewPendingModerationBody;

  /// No description provided for @reviewAlreadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already reviewed this stay'**
  String get reviewAlreadyTitle;

  /// No description provided for @reviewAlreadyBody.
  ///
  /// In en, this message translates to:
  /// **'Only one review per stay. Your existing review is shown below.'**
  String get reviewAlreadyBody;

  /// No description provided for @reviewRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'This review wasn\'t published'**
  String get reviewRejectedTitle;

  /// No description provided for @reviewRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your review didn\'t pass our check and wasn\'t published.'**
  String get reviewRejectedBody;

  /// No description provided for @reviewInvalidRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating out of range'**
  String get reviewInvalidRatingTitle;

  /// No description provided for @reviewInvalidRatingBody.
  ///
  /// In en, this message translates to:
  /// **'A rating must be between 1 and 5 stars.'**
  String get reviewInvalidRatingBody;

  /// No description provided for @reviewFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your review'**
  String get reviewFailedTitle;

  /// No description provided for @reviewStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get reviewStatusPending;

  /// No description provided for @reviewStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get reviewStatusPublished;

  /// No description provided for @reviewStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Not published'**
  String get reviewStatusRejected;

  /// No description provided for @bookingsPillCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get bookingsPillCurrent;

  /// No description provided for @bookingsPillUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bookingsPillUpcoming;

  /// No description provided for @bookingsPillPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get bookingsPillPast;

  /// No description provided for @bookingsPastTitle.
  ///
  /// In en, this message translates to:
  /// **'Past stays'**
  String get bookingsPastTitle;

  /// No description provided for @bookingsSectionOngoingStay.
  ///
  /// In en, this message translates to:
  /// **'Ongoing stay'**
  String get bookingsSectionOngoingStay;

  /// No description provided for @bookingsSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming bookings'**
  String get bookingsSectionUpcoming;

  /// No description provided for @bookingsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get bookingsEmptyTitle;

  /// No description provided for @bookingsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your bookings will appear here once you make one.'**
  String get bookingsEmptyBody;

  /// No description provided for @bookingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingStatusConfirmed;

  /// No description provided for @bookingStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get bookingStatusCheckedIn;

  /// No description provided for @bookingStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingStatusCompleted;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetailTitle;

  /// No description provided for @bookingPaymentStatusHeading.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get bookingPaymentStatusHeading;

  /// No description provided for @bookingCancellationPolicyHeading.
  ///
  /// In en, this message translates to:
  /// **'Cancellation policy'**
  String get bookingCancellationPolicyHeading;

  /// No description provided for @bookingCancellationPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation up to 24 hours before arrival. After that, the deposit is deducted.'**
  String get bookingCancellationPolicyBody;

  /// No description provided for @bookingPendingRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get bookingPendingRowTitle;

  /// No description provided for @bookingPendingRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get bookingPendingRowSubtitle;

  /// No description provided for @bookingAutoCancelRowTitle.
  ///
  /// In en, this message translates to:
  /// **'The booking auto-cancels in 30 minutes'**
  String get bookingAutoCancelRowTitle;

  /// No description provided for @bookingRoomHeldRowTitle.
  ///
  /// In en, this message translates to:
  /// **'The room is held temporarily'**
  String get bookingRoomHeldRowTitle;

  /// No description provided for @bookingRoomHeldRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get bookingRoomHeldRowSubtitle;

  /// No description provided for @bookingDepositHeldRowTitle.
  ///
  /// In en, this message translates to:
  /// **'The deposit has been held'**
  String get bookingDepositHeldRowTitle;

  /// No description provided for @bookingDepositHeldRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No charge has been made yet'**
  String get bookingDepositHeldRowSubtitle;

  /// No description provided for @bookingDeductedAtCheckinRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Deducted at check-in'**
  String get bookingDeductedAtCheckinRowTitle;

  /// No description provided for @bookingExtrasChargedOnceRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra charges are collected on departure'**
  String get bookingExtrasChargedOnceRowTitle;

  /// No description provided for @bookingExtrasChargedOnceRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'As a single payment'**
  String get bookingExtrasChargedOnceRowSubtitle;

  /// No description provided for @bookingIdentityVerifiedRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified'**
  String get bookingIdentityVerifiedRowTitle;

  /// No description provided for @bookingIdentityVerifiedRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get bookingIdentityVerifiedRowSubtitle;

  /// No description provided for @bookingCheckInAvailableRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in available from'**
  String get bookingCheckInAvailableRowTitle;

  /// No description provided for @bookingDepositAmountHeldRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit amount held'**
  String get bookingDepositAmountHeldRowTitle;

  /// No description provided for @bookingOngoingStayRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Ongoing stay'**
  String get bookingOngoingStayRowTitle;

  /// No description provided for @bookingRoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room {number}'**
  String bookingRoomLabel(String number);

  /// No description provided for @bookingDepartureRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get bookingDepartureRowTitle;

  /// No description provided for @bookingExtraChargesRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra charges'**
  String get bookingExtraChargesRowTitle;

  /// No description provided for @bookingCancelledRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get bookingCancelledRowTitle;

  /// No description provided for @bookingDepositRefundRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit refund'**
  String get bookingDepositRefundRowTitle;

  /// No description provided for @bookingDepositRefundRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Within 3 business days'**
  String get bookingDepositRefundRowSubtitle;

  /// No description provided for @bookingCancellationFeeRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation fee'**
  String get bookingCancellationFeeRowTitle;

  /// No description provided for @bookingCancellationFeeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get bookingCancellationFeeNone;

  /// No description provided for @bookingStayEndedRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay ended'**
  String get bookingStayEndedRowTitle;

  /// No description provided for @bookingTotalPaidRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get bookingTotalPaidRowTitle;

  /// No description provided for @bookingInvoiceReadyRowTitle.
  ///
  /// In en, this message translates to:
  /// **'E-invoice'**
  String get bookingInvoiceReadyRowTitle;

  /// No description provided for @bookingInvoiceReadyRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get bookingInvoiceReadyRowSubtitle;

  /// No description provided for @bookingCtaContinuePayment.
  ///
  /// In en, this message translates to:
  /// **'Continue payment'**
  String get bookingCtaContinuePayment;

  /// No description provided for @bookingCtaCancelReservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get bookingCtaCancelReservation;

  /// No description provided for @bookingCtaVerifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get bookingCtaVerifyIdentity;

  /// No description provided for @bookingCtaDigitalCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Digital check-in'**
  String get bookingCtaDigitalCheckIn;

  /// No description provided for @bookingCtaMyCurrentStay.
  ///
  /// In en, this message translates to:
  /// **'My current stay'**
  String get bookingCtaMyCurrentStay;

  /// No description provided for @bookingCtaShowAccessCode.
  ///
  /// In en, this message translates to:
  /// **'Show access code'**
  String get bookingCtaShowAccessCode;

  /// No description provided for @bookingCtaBookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book again'**
  String get bookingCtaBookAgain;

  /// No description provided for @bookingCtaViewInvoice.
  ///
  /// In en, this message translates to:
  /// **'View invoice'**
  String get bookingCtaViewInvoice;

  /// No description provided for @bookingCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get bookingCancelConfirmTitle;

  /// No description provided for @bookingCancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. Any deposit will be refunded per the cancellation policy.'**
  String get bookingCancelConfirmBody;

  /// No description provided for @bookingCancelKeepCta.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get bookingCancelKeepCta;

  /// No description provided for @bookingCancelConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get bookingCancelConfirmCta;

  /// No description provided for @bookingNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking not found'**
  String get bookingNotFoundTitle;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountLoyaltyProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty program'**
  String get accountLoyaltyProgramTitle;

  /// No description provided for @accountLoyaltyPointsSuffix.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get accountLoyaltyPointsSuffix;

  /// No description provided for @accountLoyaltyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your points build up across every hotel in the group and can be redeemed at any branch.'**
  String get accountLoyaltyDescription;

  /// No description provided for @accountLoyaltyPerNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Per night'**
  String get accountLoyaltyPerNightLabel;

  /// No description provided for @accountTrustedGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted guest'**
  String get accountTrustedGuestTitle;

  /// No description provided for @accountTrustedGuestBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be asked to re-upload your ID at any other hotel in the group.'**
  String get accountTrustedGuestBody;

  /// No description provided for @accountPreviousStaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous stays'**
  String get accountPreviousStaysLabel;

  /// No description provided for @accountPreferencesLabel.
  ///
  /// In en, this message translates to:
  /// **'My preferences'**
  String get accountPreferencesLabel;

  /// No description provided for @accountPreferencesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get accountPreferencesEmpty;

  /// No description provided for @accountPrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get accountPrivacyLabel;

  /// No description provided for @accountHelpSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get accountHelpSupportLabel;

  /// No description provided for @stayHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your current stay'**
  String get stayHomeTitle;

  /// No description provided for @stayHomeRoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Your room'**
  String get stayHomeRoomLabel;

  /// No description provided for @stayHomeServicesHeading.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get stayHomeServicesHeading;

  /// No description provided for @stayHomeRoomService.
  ///
  /// In en, this message translates to:
  /// **'Room service'**
  String get stayHomeRoomService;

  /// No description provided for @stayHomeRoomCleaning.
  ///
  /// In en, this message translates to:
  /// **'Room cleaning'**
  String get stayHomeRoomCleaning;

  /// No description provided for @stayHomeExtendStay.
  ///
  /// In en, this message translates to:
  /// **'Extend stay'**
  String get stayHomeExtendStay;

  /// No description provided for @stayHomeReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get stayHomeReportProblem;

  /// No description provided for @stayHomeExtraCharges.
  ///
  /// In en, this message translates to:
  /// **'Extra charges'**
  String get stayHomeExtraCharges;

  /// No description provided for @stayHomeExtraChargesNote.
  ///
  /// In en, this message translates to:
  /// **'Deducted automatically on departure'**
  String get stayHomeExtraChargesNote;

  /// No description provided for @stayHomeNoActiveStayTitle.
  ///
  /// In en, this message translates to:
  /// **'No active stay'**
  String get stayHomeNoActiveStayTitle;

  /// No description provided for @stayHomeNoActiveStayBody.
  ///
  /// In en, this message translates to:
  /// **'Once you check in, your room, key and services will show up here.'**
  String get stayHomeNoActiveStayBody;

  /// No description provided for @extendStayTitle.
  ///
  /// In en, this message translates to:
  /// **'Extend stay'**
  String get extendStayTitle;

  /// No description provided for @extendStayNewCheckOutLabel.
  ///
  /// In en, this message translates to:
  /// **'New checkout date'**
  String get extendStayNewCheckOutLabel;

  /// No description provided for @extendStayNightsAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Nights added'**
  String get extendStayNightsAddedLabel;

  /// No description provided for @extendStayCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm extension'**
  String get extendStayCta;

  /// No description provided for @extendStaySuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay extended'**
  String get extendStaySuccessTitle;

  /// No description provided for @extendStaySuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your checkout date is now {date}. {amount} has been added to your folio.'**
  String extendStaySuccessBody(String date, String amount);

  /// No description provided for @extendStayNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Extend stay is only available during your current stay.'**
  String get extendStayNotEligible;

  /// No description provided for @reportProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblemTitle;

  /// No description provided for @reportProblemCategoryHeading.
  ///
  /// In en, this message translates to:
  /// **'What\'s the issue?'**
  String get reportProblemCategoryHeading;

  /// No description provided for @reportProblemCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the closest category so your report reaches the right team directly.'**
  String get reportProblemCategoryBody;

  /// No description provided for @reportCategoryAcHeating.
  ///
  /// In en, this message translates to:
  /// **'AC or heating'**
  String get reportCategoryAcHeating;

  /// No description provided for @reportCategoryPlumbingWater.
  ///
  /// In en, this message translates to:
  /// **'Plumbing or water'**
  String get reportCategoryPlumbingWater;

  /// No description provided for @reportCategoryElectricityLighting.
  ///
  /// In en, this message translates to:
  /// **'Electricity and lighting'**
  String get reportCategoryElectricityLighting;

  /// No description provided for @reportCategoryRoomCleanliness.
  ///
  /// In en, this message translates to:
  /// **'Room cleanliness'**
  String get reportCategoryRoomCleanliness;

  /// No description provided for @reportCategoryInternetWifi.
  ///
  /// In en, this message translates to:
  /// **'Internet and Wi-Fi'**
  String get reportCategoryInternetWifi;

  /// No description provided for @reportCategoryNoiseDisturbance.
  ///
  /// In en, this message translates to:
  /// **'Noise or disturbance'**
  String get reportCategoryNoiseDisturbance;

  /// No description provided for @reportProblemContinueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get reportProblemContinueCta;

  /// No description provided for @reportDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem description'**
  String get reportDescriptionTitle;

  /// No description provided for @reportUrgencyHeading.
  ///
  /// In en, this message translates to:
  /// **'How urgent is this?'**
  String get reportUrgencyHeading;

  /// No description provided for @reportUrgencyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get reportUrgencyNormal;

  /// No description provided for @reportUrgencyImportant.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get reportUrgencyImportant;

  /// No description provided for @reportUrgencyUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get reportUrgencyUrgent;

  /// No description provided for @reportNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get reportNotesLabel;

  /// No description provided for @reportNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any details that help our team respond faster'**
  String get reportNotesHint;

  /// No description provided for @reportNoFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'No fees'**
  String get reportNoFeeTitle;

  /// No description provided for @reportNoFeeBody.
  ///
  /// In en, this message translates to:
  /// **'Reporting a problem is free and will never be added to your bill.'**
  String get reportNoFeeBody;

  /// No description provided for @reportSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmitCta;

  /// No description provided for @reportSubmittingCta.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get reportSubmittingCta;

  /// No description provided for @reportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your report'**
  String get reportFailedTitle;

  /// No description provided for @reportSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get reportSubmittedTitle;

  /// No description provided for @reportSubmittedBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your report reached reception'**
  String get reportSubmittedBannerTitle;

  /// No description provided for @reportSubmittedBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Report {reference}. Our reception team will be in touch shortly, and you can track its status anytime.'**
  String reportSubmittedBannerBody(String reference);

  /// No description provided for @reportTrackCta.
  ///
  /// In en, this message translates to:
  /// **'Track report'**
  String get reportTrackCta;

  /// No description provided for @reportDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Report details'**
  String get reportDetailTitle;

  /// No description provided for @reportDetailBody.
  ///
  /// In en, this message translates to:
  /// **'Your report has been received and our team is on it.'**
  String get reportDetailBody;

  /// No description provided for @reportContactReceptionCta.
  ///
  /// In en, this message translates to:
  /// **'Contact reception'**
  String get reportContactReceptionCta;

  /// No description provided for @reportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get reportStatusOpen;

  /// No description provided for @reportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get reportStatusInProgress;

  /// No description provided for @reportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get reportStatusResolved;

  /// No description provided for @reportUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports are unavailable'**
  String get reportUnavailableTitle;

  /// No description provided for @reportNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Report not found'**
  String get reportNotFoundTitle;
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
