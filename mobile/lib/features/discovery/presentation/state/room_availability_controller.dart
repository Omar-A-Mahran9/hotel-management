import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/presentation/ui_state.dart';
import '../../domain/entities/availability_result.dart';
import '../../domain/entities/available_room.dart';
import '../../domain/entities/guest_party.dart';
import '../../domain/entities/room_sort.dart';
import '../../domain/entities/stay_range.dart';
import 'discovery_providers.dart';

/// State for the available-rooms list (`16 · Stay dates & available rooms`).
///
/// [result] is `empty` when no room type can host the party (the no-results
/// screen), `success` otherwise — even if every room is sold out, so the list
/// can still render them greyed.
@immutable
class RoomAvailabilityState {
  const RoomAvailabilityState({
    this.sort = RoomSort.priceAsc,
    this.result = const UiInitial<AvailabilityResult>(),
  });

  final RoomSort sort;
  final UiState<AvailabilityResult> result;

  RoomAvailabilityState copyWith({
    RoomSort? sort,
    UiState<AvailabilityResult>? result,
  }) {
    return RoomAvailabilityState(
      sort: sort ?? this.sort,
      result: result ?? this.result,
    );
  }
}

class RoomAvailabilityController extends Notifier<RoomAvailabilityState> {
  int _requestId = 0;

  @override
  RoomAvailabilityState build() => const RoomAvailabilityState();

  Future<void> load({
    required String hotelId,
    required StayRange stay,
    required GuestParty party,
  }) async {
    final int requestId = ++_requestId;
    state = state.copyWith(result: const UiLoading<AvailabilityResult>());

    try {
      final AvailabilityResult result =
          await ref.read(discoveryRepositoryProvider).availability(
                hotelId: hotelId,
                stay: stay,
                party: party,
              );
      if (requestId != _requestId) return;
      state = state.copyWith(result: _present(result, state.sort));
    } catch (error) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        result:
            UiState<AvailabilityResult>.failure(ErrorMapper.toFailure(error)),
      );
    }
  }

  void setSort(RoomSort sort) {
    if (sort == state.sort) return;
    final UiState<AvailabilityResult> current = state.result;
    if (current is UiSuccess<AvailabilityResult>) {
      state = RoomAvailabilityState(
        sort: sort,
        result: _present(current.data, sort),
      );
    } else {
      state = state.copyWith(sort: sort);
    }
  }

  void reset() => state = const RoomAvailabilityState();

  UiState<AvailabilityResult> _present(AvailabilityResult result, RoomSort sort) {
    if (result.rooms.isEmpty) return const UiEmpty<AvailabilityResult>();
    return UiState<AvailabilityResult>.success(
      AvailabilityResult(
        hotelId: result.hotelId,
        stay: result.stay,
        party: result.party,
        rooms: _sorted(result.rooms, sort),
      ),
    );
  }

  static List<AvailableRoom> _sorted(List<AvailableRoom> rooms, RoomSort sort) {
    final List<AvailableRoom> copy = List<AvailableRoom>.of(rooms);
    copy.sort((AvailableRoom a, AvailableRoom b) {
      // Bookable rooms first, then by price in the chosen direction.
      if (a.isAvailable != b.isAvailable) return a.isAvailable ? -1 : 1;
      final int byPrice =
          a.nightlyRate.amount.compareTo(b.nightlyRate.amount);
      return sort == RoomSort.priceAsc ? byPrice : -byPrice;
    });
    return copy;
  }
}

final roomAvailabilityControllerProvider =
    NotifierProvider<RoomAvailabilityController, RoomAvailabilityState>(
  RoomAvailabilityController.new,
);
