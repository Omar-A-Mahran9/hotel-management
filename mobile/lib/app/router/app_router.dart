import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n.dart';
import '../../core/widgets/hotel_app_bar.dart';
import '../../core/widgets/message_view.dart';
import '../../features/authentication/presentation/pages/auth_splash_page.dart';
import '../../features/authentication/presentation/pages/complete_profile_page.dart';
import '../../features/authentication/presentation/pages/entry_welcome_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/authentication/presentation/pages/phone_login_page.dart';
import '../../features/authentication/presentation/pages/session_expired_page.dart';
import '../../features/authentication/presentation/state/auth_controller.dart';
import '../../features/authentication/presentation/state/auth_state.dart';
import '../../features/discovery/presentation/pages/available_rooms_page.dart';
import '../../features/discovery/presentation/pages/discover_page.dart';
import '../../features/discovery/presentation/pages/hotel_detail_page.dart';
import '../../features/discovery/presentation/pages/hotel_search_page.dart';
import '../../features/discovery/presentation/pages/room_detail_page.dart';
import '../../features/discovery/presentation/pages/room_selection_review_page.dart';
import '../../features/discovery/presentation/pages/stay_dates_page.dart';
import '../../features/reservation/presentation/pages/reservation_detail_page.dart';
import '../foundation_home_page.dart';
import 'app_routes.dart';

/// Bridges [authControllerProvider] to a [Listenable] so `GoRouter` re-runs its
/// redirect whenever the authentication state changes.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(this._ref) {
    _sub = _ref.listen<AuthState>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final _authRouterRefreshProvider = Provider<_AuthRouterRefresh>((Ref ref) {
  final _AuthRouterRefresh refresh = _AuthRouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return refresh;
});

/// The app's [GoRouter]. Kept behind a provider so feature modules can
/// contribute routes and tests can build a router with overridden deps.
final appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: ref.watch(_authRouterRefreshProvider),
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
      final String loc = state.matchedLocation;
      final bool onAuthSurface = AppRoutes.authSurface.contains(loc);
      final bool onProfile = loc == AppRoutes.completeProfile;
      final bool onSplash = loc == AppRoutes.splash;

      return auth.map(
        unknown: () => onSplash ? null : AppRoutes.splash,
        unauthenticated: () {
          if (onSplash) return AppRoutes.welcome;
          if (loc == AppRoutes.sessionExpired) return AppRoutes.welcome;
          if (onAuthSurface) return null;
          return AppRoutes.welcome;
        },
        awaitingProfile: (_) => onProfile ? null : AppRoutes.completeProfile,
        authenticated: (_) => (onSplash || onAuthSurface || onProfile)
            ? AppRoutes.authenticatedHome
            : null,
        sessionExpired: () =>
            loc == AppRoutes.sessionExpired ? null : AppRoutes.sessionExpired,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (_, _) => const AuthSplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        builder: (_, _) => const EntryWelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signInName,
        builder: (_, _) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: AppRoutes.otpName,
        builder: (_, _) => const OtpVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        name: AppRoutes.completeProfileName,
        builder: (_, _) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.sessionExpired,
        name: AppRoutes.sessionExpiredName,
        builder: (_, _) => const SessionExpiredPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (_, _) => const FoundationHomePage(),
      ),
      GoRoute(
        path: AppRoutes.discover,
        name: AppRoutes.discoverName,
        builder: (_, _) => const DiscoverPage(),
      ),
      GoRoute(
        path: AppRoutes.hotelSearch,
        name: AppRoutes.hotelSearchName,
        builder: (_, _) => const HotelSearchPage(),
      ),
      GoRoute(
        path: AppRoutes.hotelDetail,
        name: AppRoutes.hotelDetailName,
        builder: (BuildContext context, GoRouterState state) =>
            HotelDetailPage(hotelId: state.pathParameters['hotelId']!),
      ),
      GoRoute(
        path: AppRoutes.stayDates,
        name: AppRoutes.stayDatesName,
        builder: (BuildContext context, GoRouterState state) =>
            StayDatesPage(hotelId: state.pathParameters['hotelId']!),
      ),
      GoRoute(
        path: AppRoutes.availableRooms,
        name: AppRoutes.availableRoomsName,
        builder: (BuildContext context, GoRouterState state) =>
            AvailableRoomsPage(hotelId: state.pathParameters['hotelId']!),
      ),
      GoRoute(
        path: AppRoutes.roomDetail,
        name: AppRoutes.roomDetailName,
        builder: (BuildContext context, GoRouterState state) => RoomDetailPage(
          hotelId: state.pathParameters['hotelId']!,
          roomTypeId: state.pathParameters['roomTypeId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.roomSelectionReview,
        name: AppRoutes.roomSelectionReviewName,
        builder: (BuildContext context, GoRouterState state) =>
            RoomSelectionReviewPage(hotelId: state.pathParameters['hotelId']!),
      ),
      GoRoute(
        path: AppRoutes.reservationDetail,
        name: AppRoutes.reservationDetailName,
        builder: (BuildContext context, GoRouterState state) =>
            ReservationDetailPage(
          reservationId: state.pathParameters['reservationId']!,
        ),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: HotelAppBar(title: context.l10n.appName),
      body: ErrorView(
        title: context.l10n.stateErrorTitle,
        message: context.l10n.errorGeneric,
      ),
    ),
  );
});
