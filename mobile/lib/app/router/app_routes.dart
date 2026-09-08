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
