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
  String get errorNotImplemented =>
      'This isn\'t available yet. Please try again later.';

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
  String get languageScreenTitle => 'Language';

  @override
  String get languageScreenHeading => 'Choose the app language';

  @override
  String get languageScreenBody =>
      'You can change it later from Account. The interface is designed in Arabic first.';

  @override
  String get languageDefaultTag => 'Default';

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
  String get navHome => 'Home';

  @override
  String get navBookings => 'My bookings';

  @override
  String get navServices => 'Services';

  @override
  String get navAccount => 'Account';

  @override
  String get navComingSoon => 'This section is coming in a later update.';

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
  String get discoverSignIn => 'Sign in';

  @override
  String get discoverFeaturedSection => 'Group hotels';

  @override
  String get discoverExploreRooms => 'Explore rooms';

  @override
  String get discoverUpcomingStay => 'Your upcoming stay';

  @override
  String discoverSubtitleHotel(String hotel) {
    return 'Discover $hotel';
  }

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
  String get filterFacilitiesLabel => 'Facilities';

  @override
  String get filterRatingLabel => 'Rating';

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
  String get priceFromLabel => 'from';

  @override
  String get priceNightSuffix => '/ night';

  @override
  String get priceTotalSuffix => 'total';

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
  String get hotelReviewLocation => 'Location';

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
  String get hotelBookNow => 'Book now';

  @override
  String hotelGuestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String roomAreaSqm(int area) {
    return '$area m²';
  }

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

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonClose => 'Close';

  @override
  String get commonEdit => 'Edit';

  @override
  String get calendarWeekdays => 'Sun,Mon,Tue,Wed,Thu,Fri,Sat';

  @override
  String stayDatesSelectedRange(String checkIn, String checkOut) {
    return '$checkIn – $checkOut';
  }

  @override
  String get stayDatesHintPickCheckIn => 'Choose your check-in date to start';

  @override
  String stayDatesHintPickCheckOut(String checkIn) {
    return '$checkIn · choose your check-out date';
  }

  @override
  String get stayDatesFieldPlaceholder => 'Choose date';

  @override
  String get roomSelect => 'Select';

  @override
  String get roomSelected => 'Selected';

  @override
  String get roomViewDetails => 'View details';

  @override
  String get roomDetailsTitle => 'Room details';

  @override
  String get roomBedType => 'Bed';

  @override
  String get roomCapacityLabel => 'Sleeps';

  @override
  String get roomPolicyLabel => 'Cancellation';

  @override
  String get roomPolicyRefundable => 'Free cancellation';

  @override
  String get roomPolicyNonRefundable => 'Non-refundable';

  @override
  String get roomSelectThisRoom => 'Select this room';

  @override
  String get roomRemoveSelection => 'Remove selection';

  @override
  String roomStayTotalLabel(int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights nights',
      one: '1 night',
    );
    return 'for $_temp0';
  }

  @override
  String get roomDetailAmenitiesHeading => 'Amenities';

  @override
  String get roomDetailCancellationHeading => 'Cancellation policy';

  @override
  String get roomDetailStayHeading => 'Your stay';

  @override
  String get roomSortTitle => 'Sort rooms';

  @override
  String get roomSortApply => 'Apply sort';

  @override
  String get roomSortActiveTag => 'on';

  @override
  String roomsSortTrigger(String label) {
    return 'Sort: $label';
  }

  @override
  String get roomsContinue => 'Continue';

  @override
  String get roomsSelectPrompt => 'Select a room to continue';

  @override
  String get roomsSelectionClearedNotice =>
      'Your room selection was cleared because the stay details changed. Choose a room again.';

  @override
  String get reviewTitle => 'Review your selection';

  @override
  String get reviewNotBookedNotice =>
      'Nothing is booked yet. You can still change your dates, guests or room before the reservation step.';

  @override
  String get reviewHotelLabel => 'Hotel';

  @override
  String get reviewRoomLabel => 'Room';

  @override
  String get reviewStayLabel => 'Stay';

  @override
  String get reviewGuestsLabel => 'Guests';

  @override
  String get reviewCheckInLabel => 'Check-in';

  @override
  String get reviewCheckOutLabel => 'Check-out';

  @override
  String get reviewPriceLabel => 'Price';

  @override
  String reviewTotalLabel(int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights nights',
      one: '1 night',
    );
    return 'Total for $_temp0';
  }

  @override
  String get reviewChangeSelection => 'Change selection';

  @override
  String get reviewNoSelectionTitle => 'No room selected';

  @override
  String get reviewNoSelectionBody =>
      'Go back and choose a room to see your selection here.';

  @override
  String get reviewBackToRooms => 'Back to rooms';

  @override
  String get reviewSignInToConfirm => 'Sign in to confirm';

  @override
  String get reviewSignInHint =>
      'You\'ll need an account to confirm this booking. Browsing stays free.';

  @override
  String get bookingDetailsTitle => 'Booking details';

  @override
  String get bookingDatesLabel => 'Stay dates';

  @override
  String get bookingRoomSubtotal => 'Stay subtotal';

  @override
  String get bookingServiceFee => 'Service fee';

  @override
  String get bookingServiceFeeNote =>
      'Estimate for display — the hotel confirms the final amount.';

  @override
  String get bookingTotal => 'Total';

  @override
  String get bookingProceedToPayment => 'Proceed to payment';

  @override
  String get bookingRoomAvailable => 'Available';

  @override
  String get reservationConfirmCta => 'Confirm reservation';

  @override
  String get reservationConfirming => 'Confirming…';

  @override
  String get reservationConfirmHint =>
      'By confirming, you request this room for the dates above. Nothing is charged yet.';

  @override
  String get reservationCreateFailedTitle =>
      'We couldn\'t confirm your reservation';

  @override
  String get reservationStatusFieldLabel => 'Status';

  @override
  String get reservationStatusPending => 'Pending';

  @override
  String get reservationStatusConfirmed => 'Confirmed';

  @override
  String get reservationStatusDepositHeld => 'Deposit held';

  @override
  String get reservationStatusVerified => 'Verified';

  @override
  String get reservationStatusCheckedIn => 'Checked in';

  @override
  String get reservationStatusInStay => 'In stay';

  @override
  String get reservationStatusCheckoutInProgress => 'Checkout in progress';

  @override
  String get reservationStatusCheckoutBlocked => 'Checkout on hold';

  @override
  String get reservationStatusCheckedOut => 'Checked out';

  @override
  String get reservationStatusInvoiced => 'Invoiced';

  @override
  String get reservationStatusCancelled => 'Cancelled';

  @override
  String moneyAmount(String currency, int amount) {
    return '$currency $amount';
  }

  @override
  String get paymentReviewTitle => 'Payment';

  @override
  String get paymentProcessingTitle => 'Processing payment';

  @override
  String get paymentResultTitle => 'Payment';

  @override
  String get paymentReservationLabel => 'Reservation';

  @override
  String get paymentStatusFieldLabel => 'Payment status';

  @override
  String get paymentAmountLabel => 'Amount';

  @override
  String get paymentPayNowCta => 'Pay now';

  @override
  String get paymentHoldExplainer =>
      'A refundable deposit hold is placed for your stay. Nothing is charged now.';

  @override
  String get paymentProcessingBody => 'Confirming your payment…';

  @override
  String get paymentDoNotClose => 'Please keep this screen open.';

  @override
  String get paymentAlreadyHeldTitle => 'Deposit already held';

  @override
  String get paymentAlreadyHeldBody =>
      'The deposit hold for this reservation is already in place.';

  @override
  String get paymentSuccessTitle => 'Deposit hold confirmed';

  @override
  String get paymentSuccessBody =>
      'Your deposit is secured. You can continue with identity verification.';

  @override
  String get paymentPendingTitle => 'Payment is processing';

  @override
  String get paymentPendingBody =>
      'Your bank hasn\'t confirmed the hold yet. You can check the status again shortly.';

  @override
  String get paymentFailedTitle => 'Payment didn\'t go through';

  @override
  String get paymentFailedBody => 'No money was taken. You can try again.';

  @override
  String get paymentCancelledTitle => 'Payment cancelled';

  @override
  String get paymentExpiredTitle => 'Payment hold expired';

  @override
  String get paymentRetryCta => 'Try again';

  @override
  String get paymentBackToReservation => 'Back to reservation';

  @override
  String get paymentUnavailableTitle => 'Payment is unavailable';

  @override
  String get paymentStatusNotStarted => 'Not started';

  @override
  String get paymentStatusHoldRequested => 'Authorizing';

  @override
  String get paymentStatusHoldActive => 'Deposit held';

  @override
  String get paymentStatusHoldFailed => 'Failed';

  @override
  String get paymentStatusCaptureRequested => 'Charging';

  @override
  String get paymentStatusCaptured => 'Charged';

  @override
  String get paymentStatusCaptureFailed => 'Charge failed';

  @override
  String get paymentStatusFinalSettlementRequested => 'Settling';

  @override
  String get paymentStatusSettled => 'Settled';

  @override
  String get paymentStatusSettlementFailed => 'Settlement failed';

  @override
  String get paymentStatusCancelled => 'Cancelled';

  @override
  String get paymentStatusExpired => 'Expired';

  @override
  String get paymentStatusRefundRequested => 'Refund pending';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get paymentStatusRefundFailed => 'Refund failed';

  @override
  String get identityVerificationTitle => 'Identity verification';

  @override
  String get identityVerificationResultTitle => 'Identity verification';

  @override
  String get identityVerifyCta => 'Verify identity';

  @override
  String get identityStepDocument => 'Document';

  @override
  String get identityStepSelfie => 'Selfie';

  @override
  String get identityStepResult => 'Result';

  @override
  String get identityDocumentStepTitle => 'Upload your ID document';

  @override
  String get identityDocumentStepBody =>
      'Use your passport, national ID or residence permit. Make sure the whole document is visible and readable.';

  @override
  String get identityDocumentTypePassport => 'Passport';

  @override
  String get identityDocumentTypeNationalId => 'National ID';

  @override
  String get identityDocumentTypeResidencePermit => 'Residence permit';

  @override
  String get identityDocumentTypeLabel => 'Document type';

  @override
  String get identityDocumentCaptureCta => 'Add document photo';

  @override
  String get identityDocumentCapturedLabel => 'Document photo added';

  @override
  String get identityDocumentSubmitCta => 'Continue to selfie';

  @override
  String get identitySelfieStepTitle => 'Take a selfie';

  @override
  String get identitySelfieStepBody =>
      'Look straight at the camera in good light. We match your selfie to your ID photo.';

  @override
  String get identitySelfieCaptureCta => 'Add selfie';

  @override
  String get identitySelfieCapturedLabel => 'Selfie added';

  @override
  String get identitySelfieSubmitCta => 'Submit for verification';

  @override
  String get identityProcessingTitle => 'Verifying your identity';

  @override
  String get identityProcessingBody => 'Matching your selfie to your document…';

  @override
  String get identityApprovedTitle => 'Identity verified';

  @override
  String get identityApprovedBody =>
      'Your identity is confirmed. You\'re ready for check-in.';

  @override
  String get identityManualReviewTitle => 'Manual review in progress';

  @override
  String get identityManualReviewBody =>
      'Our team is reviewing your documents. This usually takes a short while — we\'ll notify you when it\'s done.';

  @override
  String get identityRetryTitle => 'Let\'s try that again';

  @override
  String get identityRetryBody =>
      'We couldn\'t verify your identity from those photos. Please retake them and submit again.';

  @override
  String get identityRetryCta => 'Try again';

  @override
  String get identityRejectedTitle => 'Verification not approved';

  @override
  String get identityRejectedBody =>
      'Our team could not approve your identity verification. Please contact the front desk for help.';

  @override
  String get identityRejectedRetryBody =>
      'Our team could not approve your identity verification. You can submit new photos and try again.';

  @override
  String identityAttemptCount(int count) {
    return 'Attempt $count';
  }

  @override
  String get identityBackToReservation => 'Back to reservation';

  @override
  String get identityViewResultCta => 'View result';

  @override
  String get identityUnavailableTitle => 'Verification is unavailable';

  @override
  String get identityStatusNotStarted => 'Not started';

  @override
  String get identityStatusDocumentUploaded => 'Document uploaded';

  @override
  String get identityStatusSelfieCaptured => 'Selfie captured';

  @override
  String get identityStatusMatchingInProgress => 'Matching';

  @override
  String get identityStatusAutoApproved => 'Verified';

  @override
  String get identityStatusPendingManualReview => 'In review';

  @override
  String get identityStatusStaffApproved => 'Verified';

  @override
  String get identityStatusStaffRejected => 'Not approved';

  @override
  String get identityStatusRetryAllowed => 'Retry needed';

  @override
  String get reservationCheckInCta => 'Check in';

  @override
  String get checkInTitle => 'Check in';

  @override
  String get checkInProcessingTitle => 'Checking you in';

  @override
  String get accessTitle => 'Room access';

  @override
  String get checkInReadyTitle => 'Ready to check in';

  @override
  String get checkInReadyBody =>
      'Your reservation is verified. Check in to get your room number and entry code.';

  @override
  String get checkInNotReadyTitle => 'Not ready to check in yet';

  @override
  String get checkInNotReadyBody =>
      'Complete payment and identity verification first.';

  @override
  String get checkInUnavailableTitle => 'Check-in isn\'t available';

  @override
  String get checkInAlreadyDoneTitle => 'You\'re already checked in';

  @override
  String get checkInCta => 'Check in now';

  @override
  String get checkInProcessingBody => 'Issuing your digital room key…';

  @override
  String get checkInDoNotClose => 'Please keep this screen open.';

  @override
  String get checkInFailedTitle => 'Check-in didn\'t complete';

  @override
  String get checkInFailedBody =>
      'Your room key couldn\'t be issued. You can try again.';

  @override
  String get checkInPendingTitle => 'Almost there';

  @override
  String get checkInPendingBody =>
      'The front desk is finishing your check-in. Check again shortly.';

  @override
  String get checkInRetryCta => 'Try again';

  @override
  String get accessCheckedInTitle => 'You\'re checked in';

  @override
  String get accessRoomNumberLabel => 'Room number';

  @override
  String get accessEntryCodeLabel => 'Entry code';

  @override
  String accessExpiresLabel(String date) {
    return 'Valid until your stay ends · $date';
  }

  @override
  String get accessHelpBanner => 'Code not working? Contact reception.';

  @override
  String get accessNotIssuedTitle => 'No room key yet';

  @override
  String get accessNotIssuedBody => 'Check in to get your digital room key.';

  @override
  String get accessRevokedTitle => 'Room key deactivated';

  @override
  String get accessRevokedBody =>
      'This room key is no longer active. Contact reception if you need help.';

  @override
  String get accessExpiredTitle => 'Room key expired';

  @override
  String get accessExpiredBody =>
      'Your stay has ended, so this room key no longer works.';

  @override
  String get accessFailedTitle => 'Room key unavailable';

  @override
  String get accessUnavailableTitle => 'Access is unavailable';

  @override
  String get accessBackToReservation => 'Back to reservation';

  @override
  String get accessStatusNotIssued => 'Not issued';

  @override
  String get accessStatusIssueRequested => 'Issuing';

  @override
  String get accessStatusActive => 'Active';

  @override
  String get accessStatusFailed => 'Failed';

  @override
  String get accessStatusRevokeRequested => 'Deactivating';

  @override
  String get accessStatusRevoked => 'Deactivated';

  @override
  String get accessStatusExpired => 'Expired';

  @override
  String get servicesTitle => 'Hotel services';

  @override
  String get servicesIntroBanner =>
      'Order what you need from your room. Requests go straight to reception.';

  @override
  String get servicesEmptyTitle => 'No services available';

  @override
  String get servicesEmptyBody =>
      'This hotel hasn\'t published any services yet.';

  @override
  String get servicesUnavailableTitle => 'Services are unavailable';

  @override
  String get serviceUncategorised => 'Other services';

  @override
  String get serviceFreeLabel => 'Included';

  @override
  String serviceEstimatedMinutes(int count) {
    return '~$count min';
  }

  @override
  String get serviceDetailTitle => 'Service';

  @override
  String get serviceQuantityLabel => 'Quantity';

  @override
  String get serviceNotesLabel => 'Notes (optional)';

  @override
  String get serviceNotesHint => 'Anything the team should know';

  @override
  String get serviceRequestCta => 'Request this service';

  @override
  String get serviceRequestingCta => 'Sending…';

  @override
  String get serviceEstimatedTotalLabel => 'Estimated total';

  @override
  String get serviceChargeNote =>
      'Any charge is added to your room account and settled at checkout.';

  @override
  String get serviceRequestFailedTitle => 'We couldn\'t send your request';

  @override
  String get myRequestsTitle => 'My requests';

  @override
  String get myRequestsIntroBanner =>
      'Track each request. You can cancel one before the team starts it.';

  @override
  String get myRequestsEmptyTitle => 'No requests yet';

  @override
  String get myRequestsEmptyBody =>
      'Request a service and it will show up here.';

  @override
  String get newRequestCta => 'New request';

  @override
  String get serviceOrderDetailTitle => 'Request details';

  @override
  String get serviceOrderRequestedAtLabel => 'Requested';

  @override
  String get serviceOrderConfirmedAtLabel => 'Accepted';

  @override
  String get serviceCancelCta => 'Cancel request';

  @override
  String get serviceCancelConfirmTitle => 'Cancel this request?';

  @override
  String get serviceCancelConfirmBody =>
      'The team hasn\'t started this yet, so it can still be cancelled.';

  @override
  String get serviceCancelConfirmCta => 'Yes, cancel';

  @override
  String get serviceCancelKeepCta => 'Keep request';

  @override
  String get serviceCancelNotAllowed =>
      'This request can no longer be cancelled.';

  @override
  String get serviceContactReception => 'Contact reception';

  @override
  String get serviceContactReceptionHint =>
      'Call reception from your room phone or the front desk for help with this request.';

  @override
  String get serviceStatusRequested => 'Pending';

  @override
  String get serviceStatusConfirmed => 'Accepted';

  @override
  String get serviceStatusFulfilled => 'Completed';

  @override
  String get serviceStatusCancelled => 'Cancelled';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutProcessingTitle => 'Completing checkout';

  @override
  String get checkoutCompleteTitle => 'Your stay summary';

  @override
  String get invoiceTitle => 'Invoice';

  @override
  String get checkoutReadyTitle => 'Ready to check out';

  @override
  String get checkoutReadyBody => 'No pending tasks.';

  @override
  String get checkoutNotReadyTitle => 'Checkout isn\'t available yet';

  @override
  String get checkoutNotReadyBody =>
      'You can check out once your stay has started.';

  @override
  String get checkoutUnavailableTitle => 'Checkout is unavailable';

  @override
  String get folioSummaryTitle => 'Charge summary';

  @override
  String get folioAccommodationLine => 'Accommodation';

  @override
  String get folioServiceLine => 'Service charge';

  @override
  String get folioTotalLabel => 'Total';

  @override
  String get folioPaidLabel => 'Already paid';

  @override
  String get folioOutstandingLabel => 'Amount due now';

  @override
  String get checkoutSettleNote =>
      'The amount due is charged in one payment to your card on file. Your invoice is sent electronically.';

  @override
  String get checkoutCompleteCta => 'Complete checkout';

  @override
  String get checkoutProcessingBody => 'Settling your account…';

  @override
  String get checkoutDoNotClose => 'Please keep this screen open.';

  @override
  String get checkoutDoneTitle => 'Thank you for your stay';

  @override
  String get checkoutDoneBody =>
      'Your account is settled and your invoice is ready.';

  @override
  String get checkoutPendingTitle => 'Settlement is processing';

  @override
  String get checkoutPendingBody =>
      'Your bank hasn\'t confirmed the payment yet. Check the status again shortly.';

  @override
  String get checkoutFailedTitle => 'Settlement didn\'t complete';

  @override
  String get checkoutFailedBody => 'No money was taken. You can try again.';

  @override
  String get checkoutRetryCta => 'Try again';

  @override
  String get checkoutViewInvoiceCta => 'View invoice';

  @override
  String get checkoutDoneCta => 'Done';

  @override
  String get checkoutStatusInProgress => 'In progress';

  @override
  String get checkoutStatusAwaitingSettlement => 'Awaiting settlement';

  @override
  String get checkoutStatusSettlementFailed => 'Settlement failed';

  @override
  String get checkoutStatusCompleted => 'Completed';

  @override
  String get invoiceIssuedBannerTitle => 'Your e-invoice was issued';

  @override
  String get invoiceIssuedBannerBody =>
      'It was sent to your email and is always saved here — no paper invoice.';

  @override
  String get invoiceNumberLabel => 'Invoice number';

  @override
  String get invoiceIssuedLabel => 'Issued';

  @override
  String get invoiceItemsTitle => 'Items';

  @override
  String get invoiceSubtotalLabel => 'Subtotal';

  @override
  String get invoicePaymentsLabel => 'Payments';

  @override
  String get invoiceOutstandingLabel => 'Outstanding';

  @override
  String get invoiceSettledTag => 'Settled in full';

  @override
  String get invoiceNotReadyTitle => 'No invoice yet';

  @override
  String get invoiceNotReadyBody =>
      'Your invoice will be here once you check out.';

  @override
  String get invoiceUnavailableTitle => 'Invoice is unavailable';

  @override
  String get reservationLoyaltyCta => 'Loyalty & points';

  @override
  String get reservationReviewCta => 'Leave a review';

  @override
  String get reservationViewReviewCta => 'View your review';

  @override
  String get loyaltyTitle => 'Loyalty';

  @override
  String get loyaltyUnavailableTitle => 'Loyalty is unavailable';

  @override
  String get loyaltyBalanceLabel => 'Points balance';

  @override
  String loyaltyPointsValue(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points pts',
      one: '1 pt',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyGroupWideNote =>
      'Your points work across every hotel in the group.';

  @override
  String get loyaltyProgramOffTitle => 'The loyalty programme isn\'t active';

  @override
  String get loyaltyProgramOffBody =>
      'This hotel group hasn\'t switched on points earning yet. There\'s nothing to do here for now.';

  @override
  String get loyaltyEarnCta => 'Earn points for this stay';

  @override
  String get loyaltyEarningCta => 'Adding your points…';

  @override
  String get loyaltyEarnedTitle => 'Points added';

  @override
  String loyaltyEarnedBody(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points were added to your balance.',
      one: '1 point was added to your balance.',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyAlreadyEarnedTitle => 'Points already added';

  @override
  String get loyaltyAlreadyEarnedBody =>
      'You\'ve already earned points for this stay.';

  @override
  String get loyaltyNotEligibleTitle => 'Not eligible yet';

  @override
  String get loyaltyNotEligibleBody =>
      'Points are added once your stay is completed.';

  @override
  String get loyaltyNothingToEarnTitle => 'No points to add';

  @override
  String get loyaltyNothingToEarnBody =>
      'This stay doesn\'t have an amount that earns points.';

  @override
  String get loyaltyHistoryTitle => 'Points history';

  @override
  String get loyaltyHistoryNote =>
      'Your full points ledger is kept by the hotel group. This is a read-only copy.';

  @override
  String get loyaltyHistoryEmptyTitle => 'No points activity yet';

  @override
  String get loyaltyHistoryEmptyBody =>
      'Points you earn and redeem will show up here.';

  @override
  String loyaltyPointsAdded(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '+$points pts',
      one: '+1 pt',
    );
    return '$_temp0';
  }

  @override
  String loyaltyPointsRemoved(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '-$points pts',
      one: '-1 pt',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyTxThisStay => 'This stay';

  @override
  String get loyaltyTxEarnLabel => 'Earned';

  @override
  String get loyaltyTxRedeemLabel => 'Redeemed';

  @override
  String get loyaltyTxReverseLabel => 'Reversed';

  @override
  String get loyaltyTxAdjustLabel => 'Adjustment';

  @override
  String get loyaltyTxExpireLabel => 'Expired';

  @override
  String get loyaltyRedeemCta => 'Redeem points';

  @override
  String get loyaltyRedeemTitle => 'Redeem points';

  @override
  String get loyaltyRedeemSubmitCta => 'Redeem';

  @override
  String get loyaltyRedeemingCta => 'Redeeming…';

  @override
  String get loyaltyRedeemAmountLabel => 'Points to redeem';

  @override
  String get loyaltyRedeemNote =>
      'Points are redeemed against this booking. The hotel group confirms the final value.';

  @override
  String loyaltyRedeemMax(int points) {
    return 'Use max ($points)';
  }

  @override
  String get loyaltyRedeemedTitle => 'Points redeemed';

  @override
  String loyaltyRedeemedBody(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points were redeemed against this booking.',
      one: '1 point was redeemed against this booking.',
    );
    return '$_temp0';
  }

  @override
  String loyaltyRedeemedValueNote(String value, String currency) {
    return 'That\'s about $value $currency off this booking.';
  }

  @override
  String get loyaltyRedeemNotEligibleTitle => 'Can\'t redeem on this booking';

  @override
  String get loyaltyRedeemNotEligibleBody =>
      'Points can only be redeemed against an active booking.';

  @override
  String get loyaltyAlreadyRedeemedTitle => 'Already redeemed';

  @override
  String get loyaltyAlreadyRedeemedBody =>
      'Points were already redeemed against this booking.';

  @override
  String get loyaltyAlreadyRedeemedDifferentBody =>
      'A different number of points was already redeemed against this booking.';

  @override
  String get loyaltyInsufficientTitle => 'Not enough points';

  @override
  String get loyaltyInsufficientBody =>
      'You don\'t have enough points for that amount.';

  @override
  String get loyaltyInvalidAmountBody => 'Choose how many points to redeem.';

  @override
  String get reviewFormTitle => 'Leave a review';

  @override
  String get reviewFormPrompt => 'How was your stay?';

  @override
  String get reviewResultTitle => 'Your review';

  @override
  String get reviewProcessingTitle => 'Sending your review';

  @override
  String get reviewProcessingBody => 'Sending your review…';

  @override
  String get reviewDoNotClose =>
      'This only takes a moment. Please don\'t close the app.';

  @override
  String get reviewRatingRequired => 'Choose a rating from 1 to 5 stars.';

  @override
  String reviewStarsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get reviewTextLabel => 'Your review (optional)';

  @override
  String get reviewTextHint => 'Tell other guests about your stay';

  @override
  String get reviewSubmitCta => 'Submit review';

  @override
  String get reviewSubmittingCta => 'Submitting…';

  @override
  String get reviewYourRatingLabel => 'Your rating';

  @override
  String get reviewBackToReservation => 'Back to reservation';

  @override
  String get reviewUnavailableTitle => 'Reviews are unavailable';

  @override
  String get reviewNotEligibleTitle => 'You can\'t review this stay';

  @override
  String get reviewNotEligibleBody =>
      'Reviews open once your stay is completed.';

  @override
  String get reviewSubmittedTitle => 'Thanks for your review';

  @override
  String get reviewPublishedBody => 'Your review has been posted.';

  @override
  String get reviewPendingModerationBody =>
      'Your review was received and is with our team for a quick check before it\'s published.';

  @override
  String get reviewAlreadyTitle => 'You\'ve already reviewed this stay';

  @override
  String get reviewAlreadyBody =>
      'Only one review per stay. Your existing review is shown below.';

  @override
  String get reviewRejectedTitle => 'This review wasn\'t published';

  @override
  String get reviewRejectedBody =>
      'Your review didn\'t pass our check and wasn\'t published.';

  @override
  String get reviewInvalidRatingTitle => 'Rating out of range';

  @override
  String get reviewInvalidRatingBody =>
      'A rating must be between 1 and 5 stars.';

  @override
  String get reviewFailedTitle => 'We couldn\'t send your review';

  @override
  String get reviewStatusPending => 'Pending review';

  @override
  String get reviewStatusPublished => 'Published';

  @override
  String get reviewStatusRejected => 'Not published';

  @override
  String get bookingsPillCurrent => 'Current';

  @override
  String get bookingsPillUpcoming => 'Upcoming';

  @override
  String get bookingsPillPast => 'Past';

  @override
  String get bookingsPastTitle => 'Past stays';

  @override
  String get bookingsSectionOngoingStay => 'Ongoing stay';

  @override
  String get bookingsSectionUpcoming => 'Upcoming bookings';

  @override
  String get bookingsEmptyTitle => 'No bookings yet';

  @override
  String get bookingsEmptyBody =>
      'Your bookings will appear here once you make one.';

  @override
  String get bookingStatusPending => 'Awaiting payment';

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusCheckedIn => 'Checked in';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get bookingDetailTitle => 'Booking details';

  @override
  String get bookingPaymentStatusHeading => 'Payment status';

  @override
  String get bookingCancellationPolicyHeading => 'Cancellation policy';

  @override
  String get bookingCancellationPolicyBody =>
      'Free cancellation up to 24 hours before arrival. After that, the deposit is deducted.';

  @override
  String get bookingPendingRowTitle => 'Awaiting payment';

  @override
  String get bookingPendingRowSubtitle => 'Not completed';

  @override
  String get bookingAutoCancelRowTitle =>
      'The booking auto-cancels in 30 minutes';

  @override
  String get bookingRoomHeldRowTitle => 'The room is held temporarily';

  @override
  String get bookingRoomHeldRowSubtitle => 'Not confirmed';

  @override
  String get bookingDepositHeldRowTitle => 'The deposit has been held';

  @override
  String get bookingDepositHeldRowSubtitle => 'No charge has been made yet';

  @override
  String get bookingDeductedAtCheckinRowTitle => 'Deducted at check-in';

  @override
  String get bookingExtrasChargedOnceRowTitle =>
      'Extra charges are collected on departure';

  @override
  String get bookingExtrasChargedOnceRowSubtitle => 'As a single payment';

  @override
  String get bookingIdentityVerifiedRowTitle =>
      'Your identity has been verified';

  @override
  String get bookingIdentityVerifiedRowSubtitle => 'Complete';

  @override
  String get bookingCheckInAvailableRowTitle => 'Check-in available from';

  @override
  String get bookingDepositAmountHeldRowTitle => 'Deposit amount held';

  @override
  String get bookingOngoingStayRowTitle => 'Ongoing stay';

  @override
  String bookingRoomLabel(String number) {
    return 'Room $number';
  }

  @override
  String get bookingDepartureRowTitle => 'Departure';

  @override
  String get bookingExtraChargesRowTitle => 'Extra charges';

  @override
  String get bookingCancelledRowTitle => 'Booking cancelled';

  @override
  String get bookingDepositRefundRowTitle => 'Deposit refund';

  @override
  String get bookingDepositRefundRowSubtitle => 'Within 3 business days';

  @override
  String get bookingCancellationFeeRowTitle => 'Cancellation fee';

  @override
  String get bookingCancellationFeeNone => 'None';

  @override
  String get bookingStayEndedRowTitle => 'Stay ended';

  @override
  String get bookingTotalPaidRowTitle => 'Total paid';

  @override
  String get bookingInvoiceReadyRowTitle => 'E-invoice';

  @override
  String get bookingInvoiceReadyRowSubtitle => 'Ready';

  @override
  String get bookingCtaContinuePayment => 'Continue payment';

  @override
  String get bookingCtaCancelReservation => 'Cancel booking';

  @override
  String get bookingCtaVerifyIdentity => 'Verify identity';

  @override
  String get bookingCtaDigitalCheckIn => 'Digital check-in';

  @override
  String get bookingCtaMyCurrentStay => 'My current stay';

  @override
  String get bookingCtaShowAccessCode => 'Show access code';

  @override
  String get bookingCtaBookAgain => 'Book again';

  @override
  String get bookingCtaViewInvoice => 'View invoice';

  @override
  String get bookingCancelConfirmTitle => 'Cancel this booking?';

  @override
  String get bookingCancelConfirmBody =>
      'This can\'t be undone. Any deposit will be refunded per the cancellation policy.';

  @override
  String get bookingCancelKeepCta => 'Keep booking';

  @override
  String get bookingCancelConfirmCta => 'Cancel booking';

  @override
  String get bookingNotFoundTitle => 'Booking not found';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountLoyaltyProgramTitle => 'Loyalty program';

  @override
  String get accountLoyaltyPointsSuffix => 'points';

  @override
  String get accountLoyaltyDescription =>
      'Your points build up across every hotel in the group and can be redeemed at any branch.';

  @override
  String get accountLoyaltyPerNightLabel => 'Per night';

  @override
  String get accountTrustedGuestTitle => 'Trusted guest';

  @override
  String get accountTrustedGuestBody =>
      'You won\'t be asked to re-upload your ID at any other hotel in the group.';

  @override
  String get accountPreviousStaysLabel => 'Previous stays';

  @override
  String get accountPreferencesLabel => 'My preferences';

  @override
  String get accountPreferencesEmpty => 'Not set yet';

  @override
  String get accountPrivacyLabel => 'Privacy & data';

  @override
  String get accountHelpSupportLabel => 'Help & support';

  @override
  String get stayHomeTitle => 'Your current stay';

  @override
  String get stayHomeRoomLabel => 'Your room';

  @override
  String get stayHomeServicesHeading => 'Services';

  @override
  String get stayHomeRoomService => 'Room service';

  @override
  String get stayHomeRoomCleaning => 'Room cleaning';

  @override
  String get stayHomeExtendStay => 'Extend stay';

  @override
  String get stayHomeReportProblem => 'Report a problem';

  @override
  String get stayHomeExtraCharges => 'Extra charges';

  @override
  String get stayHomeExtraChargesNote => 'Deducted automatically on departure';

  @override
  String get stayHomeNoActiveStayTitle => 'No active stay';

  @override
  String get stayHomeNoActiveStayBody =>
      'Once you check in, your room, key and services will show up here.';

  @override
  String get extendStayTitle => 'Extend stay';

  @override
  String get extendStayNewCheckOutLabel => 'New checkout date';

  @override
  String get extendStayNightsAddedLabel => 'Nights added';

  @override
  String get extendStayCta => 'Confirm extension';

  @override
  String get extendStaySuccessTitle => 'Stay extended';

  @override
  String extendStaySuccessBody(String date, String amount) {
    return 'Your checkout date is now $date. $amount has been added to your folio.';
  }

  @override
  String get extendStayNotEligible =>
      'Extend stay is only available during your current stay.';
}
