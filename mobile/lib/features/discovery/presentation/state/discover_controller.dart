import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/presentation/ui_state.dart';
import '../../../authentication/presentation/state/auth_controller.dart';
import '../../../authentication/presentation/state/auth_state.dart';
import '../../domain/entities/available_room.dart';
import '../../domain/entities/hotel_summary.dart';
import '../../domain/entities/upcoming_stay.dart';
import 'discovery_providers.dart';

/// Everything the Home screen (`HOME_Default` / `HOME_if One hotel`) needs in one
/// value: the greeting name, the guest's upcoming stay, and either the group
/// hotel grid or — when the group runs a single hotel — that hotel's rooms.
@immutable
class DiscoverView {
  const DiscoverView({
    required this.greetingName,
    required this.featuredHotels,
    required this.upcomingStay,
    required this.isSingleHotel,
    required this.soleHotelRooms,
  });

  /// First name of the signed-in guest, or `null` (generic greeting).
  final String? greetingName;
  final List<HotelSummary> featuredHotels;

  /// The signed-in guest's next confirmed stay — `null` for a guest or when
  /// there is none.
  final UpcomingStay? upcomingStay;

  /// `true` when the group operates one hotel: Home shows `استكشف الغرف` instead
  /// of the hotel grid.
  final bool isSingleHotel;
  final List<AvailableRoom> soleHotelRooms;

  HotelSummary? get soleHotel =>
      isSingleHotel && featuredHotels.isNotEmpty ? featuredHotels.first : null;

  @override
  bool operator ==(Object other) =>
      other is DiscoverView &&
      other.greetingName == greetingName &&
      listEquals(other.featuredHotels, featuredHotels) &&
      other.upcomingStay == upcomingStay &&
      other.isSingleHotel == isSingleHotel &&
      listEquals(other.soleHotelRooms, soleHotelRooms);

  @override
  int get hashCode => Object.hash(
        greetingName,
        Object.hashAll(featuredHotels),
        upcomingStay,
        isSingleHotel,
        Object.hashAll(soleHotelRooms),
      );
}

/// Loads the Home screen. Read as a `UiState` via [discoverUiState].
class DiscoverController extends AutoDisposeAsyncNotifier<DiscoverView> {
  @override
  Future<DiscoverView> build() async {
    // Watch auth so the greeting + upcoming stay fill in once restore resolves.
    final AuthState auth = ref.watch(authControllerProvider);
    final repo = ref.watch(discoveryRepositoryProvider);

    final List<HotelSummary> hotels = await repo.featuredHotels();
    final int groupCount = await repo.groupHotelCount();
    final bool single = groupCount <= 1 && hotels.isNotEmpty;

    return DiscoverView(
      greetingName: _greetingName(auth),
      featuredHotels: hotels,
      isSingleHotel: single,
      soleHotelRooms:
          single ? await repo.hotelRooms(hotels.first.id) : const <AvailableRoom>[],
      upcomingStay: _isSignedIn(auth) ? await repo.upcomingStay() : null,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue<DiscoverView>.loading();
    state = await AsyncValue.guard(build);
  }

  bool _isSignedIn(AuthState auth) => auth.map(
        unknown: () => false,
        unauthenticated: () => false,
        awaitingProfile: (_) => true,
        authenticated: (_) => true,
        sessionExpired: () => false,
      );

  String? _greetingName(AuthState auth) {
    final String? fullName = auth.map(
      unknown: () => null,
      unauthenticated: () => null,
      awaitingProfile: (session) => session.profile.fullName,
      authenticated: (session) => session.profile.fullName,
      sessionExpired: () => null,
    );
    final String? trimmed = fullName?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

final discoverControllerProvider =
    AutoDisposeAsyncNotifierProvider<DiscoverController, DiscoverView>(
  DiscoverController.new,
);

/// Adapts the Riverpod [AsyncValue] to the app's [UiState] vocabulary.
UiState<DiscoverView> discoverUiState(AsyncValue<DiscoverView> value) {
  return value.map(
    data: (AsyncData<DiscoverView> d) => d.value.featuredHotels.isEmpty
        ? const UiEmpty<DiscoverView>()
        : UiState<DiscoverView>.success(d.value),
    loading: (_) => const UiLoading<DiscoverView>(),
    error: (AsyncError<DiscoverView> e) =>
        UiState<DiscoverView>.failure(ErrorMapper.toFailure(e.error)),
  );
}
