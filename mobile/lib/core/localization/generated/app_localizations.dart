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

  /// No description provided for @discoverFeaturedSection.
  ///
  /// In en, this message translates to:
  /// **'Group hotels'**
  String get discoverFeaturedSection;

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

  /// No description provided for @reservationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation'**
  String get reservationDetailTitle;

  /// No description provided for @reservationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reservation is confirmed'**
  String get reservationSuccessTitle;

  /// No description provided for @reservationSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ve saved your reservation. Keep your confirmation code handy.'**
  String get reservationSuccessBody;

  /// No description provided for @reservationReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get reservationReferenceLabel;

  /// No description provided for @reservationStatusFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reservationStatusFieldLabel;

  /// No description provided for @reservationBookedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Booked on'**
  String get reservationBookedOnLabel;

  /// No description provided for @reservationPendingNote.
  ///
  /// In en, this message translates to:
  /// **'This reservation is pending and not yet secured.'**
  String get reservationPendingNote;

  /// No description provided for @reservationDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reservationDone;

  /// No description provided for @reservationViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View reservation'**
  String get reservationViewDetails;

  /// No description provided for @reservationNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation not found'**
  String get reservationNotFoundTitle;

  /// No description provided for @reservationNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that reservation.'**
  String get reservationNotFoundBody;

  /// No description provided for @reservationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reservationStatusPending;

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
