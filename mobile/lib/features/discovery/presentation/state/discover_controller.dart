import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/presentation/ui_state.dart';
import '../../../authentication/presentation/state/auth_controller.dart';
import '../../../authentication/presentation/state/auth_state.dart';
import '../../domain/entities/hotel_summary.dart';
import 'discovery_providers.dart';

/// Everything the discover screen (`02 · Discover & Book`) needs in one value:
/// the guest's first name for the greeting and the curated hotel list.
@immutable
class DiscoverView {
  const DiscoverView({required this.greetingName, required this.featuredHotels});

  /// First name of the signed-in guest, or `null` for a returning guest whose
  /// profile has no name yet — the screen then shows the generic greeting.
  final String? greetingName;
  final List<HotelSummary> featuredHotels;

  @override
  bool operator ==(Object other) =>
      other is DiscoverView &&
      other.greetingName == greetingName &&
      listEquals(other.featuredHotels, featuredHotels);

  @override
  int get hashCode => Object.hash(greetingName, Object.hashAll(featuredHotels));
}

/// Loads the discover screen. Read as a `UiState` via [discoverUiState].
class DiscoverController extends AutoDisposeAsyncNotifier<DiscoverView> {
  @override
  Future<DiscoverView> build() async {
    // Watch auth so the greeting fills in once session restore resolves.
    final String? greeting = _greetingName(ref.watch(authControllerProvider));
    final List<HotelSummary> hotels =
        await ref.watch(discoveryRepositoryProvider).featuredHotels();
    return DiscoverView(greetingName: greeting, featuredHotels: hotels);
  }

  Future<void> refresh() async {
    state = const AsyncValue<DiscoverView>.loading();
    state = await AsyncValue.guard(() async {
      final List<HotelSummary> hotels =
          await ref.read(discoveryRepositoryProvider).featuredHotels();
      return DiscoverView(
        greetingName: _greetingName(ref.read(authControllerProvider)),
        featuredHotels: hotels,
      );
    });
  }

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

/// Adapts the Riverpod [AsyncValue] to the app's [UiState] vocabulary, matching
/// `backendHealthUiState`.
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
