/// Route names and paths.
///
/// Mobile Phase 1 adds the entry + authentication surface. Later feature routes
/// (discovery, availability, reservations, …) are added here as each phase
/// lands, so there is one place to see the navigation surface.
abstract final class AppRoutes {
  /// Startup route: decides splash vs entry vs home from [AuthState].
  static const String splash = '/';
  static const String splashName = 'splash';

  /// `01 · Entry` — first-run welcome screen.
  static const String welcome = '/welcome';
  static const String welcomeName = 'welcome';

  /// `09 · Authentication` — phone-number entry.
  static const String signIn = '/auth/phone';
  static const String signInName = 'signIn';

  /// `09 · Authentication` — one-time-code entry.
  static const String otp = '/auth/otp';
  static const String otpName = 'otp';

  /// `09 · Authentication` — first-time guest name + email.
  static const String completeProfile = '/auth/profile';
  static const String completeProfileName = 'completeProfile';

  /// `09 · Authentication` — expired-session re-entry.
  static const String sessionExpired = '/auth/session-expired';
  static const String sessionExpiredName = 'sessionExpired';

  /// Phase 0/1 foundation preview — architecture, theme and backend-health
  /// diagnostics. Still registered (so the Phase 0 route test and manual
  /// diagnostics keep working) but no longer the authenticated landing: from
  /// Phase 2 that is [discover].
  static const String home = '/home';
  static const String homeName = 'home';

  /// Retained for the Phase 0 error-route test / deep diagnostics.
  static const String foundation = home;
  static const String foundationName = homeName;

  /// `02 · Discover & Book` — the authenticated landing from Phase 2 on.
  static const String discover = '/discover';
  static const String discoverName = 'discover';

  /// `15 · Search, filters & sort` — hotel search + filters + sort.
  static const String hotelSearch = '/discover/search';
  static const String hotelSearchName = 'hotelSearch';

  /// `02 · Discover & Book` (screen 3) — hotel detail. `:hotelId` path param.
  static const String hotelDetail = '/discover/hotel/:hotelId';
  static const String hotelDetailName = 'hotelDetail';

  /// `16 · Stay dates & available rooms` — stay-date selection.
  static const String stayDates = '/discover/hotel/:hotelId/dates';
  static const String stayDatesName = 'stayDates';

  /// `16 · Stay dates & available rooms` — the available-rooms list.
  static const String availableRooms = '/discover/hotel/:hotelId/rooms';
  static const String availableRoomsName = 'availableRooms';

  /// `08 · Room selection & stay actions` (screen 1) — one room type in full,
  /// with the "select this room" action. `:roomTypeId` path param.
  static const String roomDetail = '/discover/hotel/:hotelId/rooms/:roomTypeId';
  static const String roomDetailName = 'roomDetail';

  /// Review the chosen room + stay + party and confirm the reservation
  /// (Mobile Phase 4). Creates a `PENDING` reservation; nothing is charged.
  static const String roomSelectionReview = '/discover/hotel/:hotelId/review';
  static const String roomSelectionReviewName = 'roomSelectionReview';

  /// Reservation confirmation + details, by id (`03 · Pay & Verify`).
  static const String reservationDetail = '/reservation/:reservationId';
  static const String reservationDetailName = 'reservationDetail';

  /// `03 · Pay & Verify` — review the deposit hold (Mobile Phase 5).
  static const String paymentReview = '/reservation/:reservationId/payment';
  static const String paymentReviewName = 'paymentReview';

  /// `03 · Pay & Verify` — the transient processing screen (Mobile Phase 5).
  static const String paymentProcessing =
      '/reservation/:reservationId/payment/processing';
  static const String paymentProcessingName = 'paymentProcessing';

  /// `03 · Pay & Verify` — the authoritative hold outcome (Mobile Phase 5).
  static const String paymentResult =
      '/reservation/:reservationId/payment/result';
  static const String paymentResultName = 'paymentResult';

  /// `10 · Identity verification` — the guest verification flow (Mobile Phase 6).
  static const String identityVerification =
      '/reservation/:reservationId/identity';
  static const String identityVerificationName = 'identityVerification';

  /// `10 · Identity verification` — the authoritative verification outcome
  /// (Mobile Phase 6).
  static const String identityVerificationResult =
      '/reservation/:reservationId/identity/result';
  static const String identityVerificationResultName = 'identityVerificationResult';

  /// `04 · Check in & Stay` — check-in review / eligibility (Mobile Phase 7).
  static const String checkIn = '/reservation/:reservationId/check-in';
  static const String checkInName = 'checkIn';

  /// `04 · Check in & Stay` — the transient check-in processing screen.
  static const String checkInProcessing =
      '/reservation/:reservationId/check-in/processing';
  static const String checkInProcessingName = 'checkInProcessing';

  /// `04 · Check in & Stay` — the digital room-key screen (Mobile Phase 7).
  static const String digitalAccess = '/reservation/:reservationId/access';
  static const String digitalAccessName = 'digitalAccess';

  /// `11 · Services & requests` — the hotel service catalogue (Mobile Phase 8).
  static const String stayServices = '/reservation/:reservationId/services';
  static const String stayServicesName = 'stayServices';

  /// `11 · Services & requests` — one service + request action.
  static const String serviceDetail =
      '/reservation/:reservationId/services/:serviceId';
  static const String serviceDetailName = 'serviceDetail';

  /// `11 · Services & requests` — the guest's service requests.
  static const String serviceOrders =
      '/reservation/:reservationId/service-orders';
  static const String serviceOrdersName = 'serviceOrders';

  /// `11 · Services & requests` — one service request + status / cancel.
  static const String serviceOrderDetail =
      '/reservation/:reservationId/service-orders/:orderId';
  static const String serviceOrderDetailName = 'serviceOrderDetail';

  /// `05 · Depart & Invoice` — review the outstanding amount (Mobile Phase 9).
  static const String checkout = '/reservation/:reservationId/checkout';
  static const String checkoutName = 'checkout';

  /// `05 · Depart & Invoice` — the transient settlement processing screen.
  static const String checkoutProcessing =
      '/reservation/:reservationId/checkout/processing';
  static const String checkoutProcessingName = 'checkoutProcessing';

  /// `05 · Depart & Invoice` — the authoritative checkout outcome.
  static const String checkoutComplete =
      '/reservation/:reservationId/checkout/complete';
  static const String checkoutCompleteName = 'checkoutComplete';

  /// `05 · Depart & Invoice` — the issued e-invoice (Mobile Phase 9).
  static const String invoice = '/reservation/:reservationId/invoice';
  static const String invoiceName = 'invoice';

  /// `14 · Entry, loyalty & completion` — the reservation's loyalty summary:
  /// balance, transaction history, earn + redeem entry points (Mobile Phase 10).
  static const String loyalty = '/reservation/:reservationId/loyalty';
  static const String loyaltyName = 'loyalty';

  /// `14 · Entry, loyalty & completion` — the redeem-points amount picker
  /// (Mobile Phase 10).
  static const String loyaltyRedeem =
      '/reservation/:reservationId/loyalty/redeem';
  static const String loyaltyRedeemName = 'loyaltyRedeem';

  /// `05 · Depart & Invoice` — the guest review form / existing review (Mobile
  /// Phase 10).
  static const String reviewForm = '/reservation/:reservationId/review';
  static const String reviewFormName = 'reviewForm';

  /// `05 · Depart & Invoice` — the transient review-submission screen.
  static const String reviewProcessing =
      '/reservation/:reservationId/review/processing';
  static const String reviewProcessingName = 'reviewProcessing';

  /// `05 · Depart & Invoice` — the authoritative review-submission outcome.
  static const String reviewResult =
      '/reservation/:reservationId/review/result';
  static const String reviewResultName = 'reviewResult';

  /// The authenticated landing route.
  static const String authenticatedHome = discover;

  /// Routes that make up the unauthenticated entry + auth surface.
  static const Set<String> authSurface = <String>{
    welcome,
    signIn,
    otp,
    sessionExpired,
  };
}
