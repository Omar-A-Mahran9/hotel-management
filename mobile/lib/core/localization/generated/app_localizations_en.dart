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

  @override
  String get commonApply => 'Apply';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonBack => 'Back';

  @override
  String get discoverGreeting => 'Welcome';

  @override
  String discoverGreetingNamed(String name) {
    return 'Welcome, $name';
  }

  @override
  String get discoverSubtitle => 'Discover the group\'s hotels';

  @override
  String get discoverSearchHint => 'Search for a hotel or city';

  @override
  String get discoverNotificationsTooltip => 'Notifications';

  @override
  String get discoverFeaturedSection => 'Group hotels';

  @override
  String get discoverEmptyTitle => 'No hotels to show yet';

  @override
  String get discoverEmptyBody =>
      'The group\'s hotels will appear here once they are published.';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchClearTooltip => 'Clear search';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hotels available',
      one: '1 hotel available',
      zero: 'No hotels available',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResultsTitle => 'No hotels match your search';

  @override
  String get searchNoResultsBody =>
      'Try a different city or clear your filters.';

  @override
  String get searchClearFilters => 'Clear filters';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortTopRated => 'Top rated';

  @override
  String get sortLowestPrice => 'Best value';

  @override
  String get sortTitle => 'Sort results';

  @override
  String get sortHint => 'The order stays until you change it or search again.';

  @override
  String get sortApply => 'Apply sort';

  @override
  String get sortActiveTag => 'on';

  @override
  String get filterTitle => 'Filter results';

  @override
  String filterMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matching hotels',
      one: '1 matching hotel',
      zero: 'No matching hotels',
    );
    return '$_temp0';
  }

  @override
  String get filterHint => 'Adjust the criteria to narrow the results.';

  @override
  String get filterCityLabel => 'City';

  @override
  String get filterValueAll => 'All';

  @override
  String filterSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get filterPriceLabel => 'Price range';

  @override
  String get filterApply => 'Apply filter';

  @override
  String get filterClearAll => 'Clear all';

  @override
  String get filterCityPickerTitle => 'City';

  @override
  String get filterCityPickerHint =>
      'You can choose more than one city. Results update when you apply.';

  @override
  String cityHotelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hotels',
      one: '1 hotel',
    );
    return '$_temp0';
  }

  @override
  String priceRangeValue(int min, int max) {
    return 'SAR $min – SAR $max';
  }

  @override
  String priceFrom(int amount) {
    return 'from SAR $amount';
  }

  @override
  String pricePerNight(int amount) {
    return 'SAR $amount / night';
  }

  @override
  String priceStayTotal(int amount) {
    return 'SAR $amount total';
  }

  @override
  String hotelRatingValue(double rating) {
    final intl.NumberFormat ratingNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String ratingString = ratingNumberFormat.format(rating);

    return '$ratingString';
  }

  @override
  String hotelReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get hotelAvailable => 'Available';

  @override
  String get hotelUnavailable => 'Not available right now';

  @override
  String get hotelDetailReviews => 'Ratings & reviews';

  @override
  String get hotelReviewCleanliness => 'Cleanliness';

  @override
  String get hotelReviewCommunication => 'Communication';

  @override
  String get hotelDetailAmenities => 'What this hotel offers';

  @override
  String hotelRoomTypeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count room types',
      one: '1 room type',
    );
    return '$_temp0';
  }

  @override
  String hotelPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count',
    );
    return '$_temp0';
  }

  @override
  String get hotelSelectDates => 'Select dates';

  @override
  String get amenityFreeWifi => 'Free Wi-Fi';

  @override
  String get amenityBreakfast => 'Breakfast';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityPool => 'Pool';

  @override
  String get amenityGym => 'Gym';

  @override
  String get amenityFamilyRooms => 'Family rooms';

  @override
  String get amenityAirportShuttle => 'Airport shuttle';

  @override
  String get amenityRoomService => 'Room service';

  @override
  String get amenityAirConditioning => 'Air conditioning';

  @override
  String get amenityCityView => 'City view';

  @override
  String get amenityBalcony => 'Balcony';

  @override
  String get amenityKitchenette => 'Kitchenette';

  @override
  String get stayDatesTitle => 'Choose your stay dates';

  @override
  String get stayDatesCheckIn => 'Check-in';

  @override
  String get stayDatesCheckOut => 'Check-out';

  @override
  String get stayDatesPick => 'Choose date';

  @override
  String get stayDatesClear => 'Clear dates';

  @override
  String get stayDatesShowRooms => 'Show available rooms';

  @override
  String stayNights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nights',
      one: '1 night',
    );
    return '$_temp0';
  }

  @override
  String get stayDatesErrorCheckoutBeforeCheckin =>
      'Check-out must be after check-in';

  @override
  String get stayDatesErrorPast => 'Choose a date from today onwards';

  @override
  String get stayDatesEditDates => 'Edit dates';

  @override
  String get guestsTitle => 'Number of guests';

  @override
  String get guestsAdults => 'Adults';

  @override
  String get guestsChildren => 'Children';

  @override
  String get guestsConfirm => 'Confirm guests';

  @override
  String get stepperDecrease => 'Decrease';

  @override
  String get stepperIncrease => 'Increase';

  @override
  String guestsAdultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adults',
      one: '1 adult',
    );
    return '$_temp0';
  }

  @override
  String guestsChildrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children',
      one: '1 child',
    );
    return '$_temp0';
  }

  @override
  String get roomsTitle => 'Available rooms';

  @override
  String roomsAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count available',
      one: '1 available',
      zero: 'None available',
    );
    return '$_temp0';
  }

  @override
  String get roomsSortLabel => 'Sort';

  @override
  String get roomsSortLowest => 'Lowest price';

  @override
  String get roomsSortHighest => 'Highest price';

  @override
  String roomOccupancy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String get roomBreakfastIncluded => 'Breakfast included';

  @override
  String get roomFreeCancellation => 'Free cancellation';

  @override
  String get roomNonRefundable => 'Non-refundable';

  @override
  String get roomSoldOut => 'Not available for these dates';

  @override
  String get roomsAllSoldOutTitle => 'All rooms are sold out for these dates';

  @override
  String get roomsAllSoldOutBody =>
      'Try different dates and we will show the rooms that open up.';

  @override
  String get roomsNoResultsTitle => 'No rooms for these dates';

  @override
  String get roomsNoResultsBody =>
      'Try different dates or adjust the number of guests.';

  @override
  String get roomsChangeDates => 'Change dates';

  @override
  String get roomsChangeGuests => 'Change guests';
}
