import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/presentation/ui_state.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/availability_request.dart';
import '../../domain/entities/availability_result.dart';
import '../../domain/entities/available_room.dart';
import '../../domain/entities/guest_party.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/room_selection.dart';
import '../../domain/entities/room_sort.dart';
import '../../domain/entities/stay_range.dart';
import '../discovery_l10n.dart';
import '../state/guest_party_controller.dart';
import '../state/hotel_detail_provider.dart';
import '../state/room_availability_controller.dart';
import '../state/room_selection_controller.dart';
import '../state/stay_dates_controller.dart';
import '../widgets/guest_party_sheet.dart';
import '../widgets/room_sort_sheet.dart';
import '../widgets/room_summary_card.dart';
import '../../../../core/widgets/app_icons.dart';

/// `16 · Stay dates & available rooms` — the available-rooms list.
///
/// Availability is dummy data only — the mobile app never computes authoritative
/// availability (a later phase's Laravel API does). Tapping a room opens its
/// detail screen where it can be selected; nothing is booked here.
class AvailableRoomsPage extends ConsumerStatefulWidget {
  const AvailableRoomsPage({super.key, required this.hotelId});

  final String hotelId;

  @override
  ConsumerState<AvailableRoomsPage> createState() => _AvailableRoomsPageState();
}

class _AvailableRoomsPageState extends ConsumerState<AvailableRoomsPage> {
  bool _selectionClearedNotice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  /// (Re)loads availability for the guest's current dates + party. A no-op when
  /// the dates are incomplete or the controller already holds a fresh result.
  void _sync() {
    final AvailabilityRequest? request = _currentRequest();
    if (request == null) return;
    ref.read(roomAvailabilityControllerProvider.notifier).load(request);
  }

  AvailabilityRequest? _currentRequest() {
    final StayRange? stay = ref
        .read(stayDatesControllerProvider)
        .rangeAgainst(ref.today());
    if (stay == null) return null;
    return AvailabilityRequest(
      hotelId: widget.hotelId,
      stay: stay,
      party: ref.read(guestPartyControllerProvider),
    );
  }

  void _openRoom(String roomTypeId) {
    context.pushNamed(
      AppRoutes.roomDetailName,
      pathParameters: <String, String>{
        'hotelId': widget.hotelId,
        'roomTypeId': roomTypeId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    ref.listen<StayDatesDraft>(stayDatesControllerProvider, (_, _) => _sync());
    ref.listen<GuestParty>(guestPartyControllerProvider, (_, _) => _sync());
    ref.listen<RoomSelection?>(roomSelectionControllerProvider, (
      RoomSelection? prev,
      RoomSelection? next,
    ) {
      if (prev != null && next == null && mounted) {
        setState(() => _selectionClearedNotice = true);
      }
    });

    final AvailabilityRequest? request = _currentRequest();
    final RoomAvailabilityState availability = ref.watch(
      roomAvailabilityControllerProvider,
    );
    if (request != null &&
        !availability.isFreshFor(request) &&
        availability.result is! UiLoading<AvailabilityResult>) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sync();
      });
    }

    final AsyncValue<Hotel> hotelAsync = ref.watch(
      hotelDetailProvider(widget.hotelId),
    );

    return hotelAsync.when(
      loading: () => Scaffold(
        appBar: HotelAppBar(title: l10n.roomsTitle),
        body: Center(child: LoadingView(label: l10n.stateLoadingTitle)),
      ),
      error: (Object error, StackTrace _) => Scaffold(
        appBar: HotelAppBar(title: l10n.roomsTitle),
        body: Center(
          child: ErrorView(
            title: l10n.stateErrorTitle,
            message: ErrorMapper.toFailure(error).localizedMessage(l10n),
            actionLabel: l10n.commonBack,
            onAction: () => context.pop(),
          ),
        ),
      ),
      data: (Hotel hotel) => _Loaded(
        hotel: hotel,
        selectionClearedNotice: _selectionClearedNotice,
        onDismissNotice: () => setState(() => _selectionClearedNotice = false),
        onOpenRoom: _openRoom,
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({
    required this.hotel,
    required this.selectionClearedNotice,
    required this.onDismissNotice,
    required this.onOpenRoom,
  });

  final Hotel hotel;
  final bool selectionClearedNotice;
  final VoidCallback onDismissNotice;
  final ValueChanged<String> onOpenRoom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final DateTime today = ref.today();
    final StayRange? range = ref
        .watch(stayDatesControllerProvider)
        .rangeAgainst(today);
    final GuestParty party = ref.watch(guestPartyControllerProvider);
    final RoomAvailabilityState state = ref.watch(
      roomAvailabilityControllerProvider,
    );
    final RoomSelection? selection = ref.watch(roomSelectionControllerProvider);

    if (range == null) {
      return Scaffold(
        appBar: HotelAppBar(title: l10n.roomsTitle),
        body: MessageView(
          icon: AppIcons.calendar,
          title: l10n.roomsNoResultsTitle,
          message: l10n.roomsNoResultsBody,
          actionLabel: l10n.roomsChangeDates,
          onAction: () => context.pop(),
        ),
      );
    }

    final AvailabilityRequest request = AvailabilityRequest(
      hotelId: hotel.id,
      stay: range,
      party: party,
    );
    final bool selectionMatches =
        selection != null && selection.matches(request);
    final bool canContinue =
        selectionMatches && state.result is UiSuccess<AvailabilityResult>;

    return Scaffold(
      appBar: HotelAppBar(title: l10n.roomsTitle),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.sm,
                AppSpacing.pageGutter,
                AppSpacing.xs,
              ),
              child: _StaySummaryCard(
                hotel: hotel,
                range: range,
                party: party,
                onEditDates: () => context.pop(),
                onEditGuests: () => showGuestPartySheet(context),
              ),
            ),
            _SortRow(
              sort: state.sort,
              onPick: (RoomSort next) => ref
                  .read(roomAvailabilityControllerProvider.notifier)
                  .setSort(next),
            ),
            if (selectionClearedNotice)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  0,
                  AppSpacing.pageGutter,
                  AppSpacing.xs,
                ),
                child: GestureDetector(
                  onTap: onDismissNotice,
                  child: InfoBanner(
                    tone: InfoBannerTone.warning,
                    title: l10n.roomsSelectionClearedNotice,
                  ),
                ),
              ),
            Expanded(
              child: UiStateView<AvailabilityResult>(
                state: state.result,
                onRetry: () => ref
                    .read(roomAvailabilityControllerProvider.notifier)
                    .retry(),
                emptyTitle: l10n.roomsNoResultsTitle,
                emptyMessage: l10n.roomsNoResultsBody,
                onSuccess: (AvailabilityResult result) => _RoomList(
                  result: result,
                  nights: range.nights,
                  selectedRoomTypeId: selectionMatches
                      ? selection.roomTypeId
                      : null,
                  onOpenRoom: onOpenRoom,
                ),
              ),
            ),
            if (state.result is UiEmpty<AvailabilityResult>)
              _NoResultsActions(
                onChangeDates: () => context.pop(),
                onChangeGuests: () => showGuestPartySheet(context),
              ),
          ],
        ),
      ),
      bottomNavigationBar: state.result is UiSuccess<AvailabilityResult>
          ? _ContinueBar(
              enabled: canContinue,
              onContinue: () => context.pushNamed(
                AppRoutes.roomSelectionReviewName,
                pathParameters: <String, String>{'hotelId': hotel.id},
              ),
            )
          : null,
    );
  }
}

/// The stay summary card (`16 · Stay dates & available rooms`, row 2 header):
/// hotel + edit-dates, labelled check-in / check-out, nights + guests + edit.
class _StaySummaryCard extends StatelessWidget {
  const _StaySummaryCard({
    required this.hotel,
    required this.range,
    required this.party,
    required this.onEditDates,
    required this.onEditGuests,
  });

  final Hotel hotel;
  final StayRange range;
  final GuestParty party;
  final VoidCallback onEditDates;
  final VoidCallback onEditGuests;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  hotel.summary.name.resolve(locale),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              _LinkButton(label: l10n.stayDatesEditDates, onTap: onEditDates),
            ],
          ),
          const Divider(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _DateColumn(
                  label: l10n.stayDatesCheckIn,
                  value: ml.formatMediumDate(range.checkIn),
                ),
              ),
              Expanded(
                child: _DateColumn(
                  label: l10n.stayDatesCheckOut,
                  value: ml.formatMediumDate(range.checkOut),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${l10n.stayNights(range.nights)} · ${guestPartySummaryText(l10n, party)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              _LinkButton(label: l10n.commonEdit, onTap: onEditGuests),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({required this.sort, required this.onPick});

  final RoomSort sort;
  final ValueChanged<RoomSort> onPick;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.xxs,
        AppSpacing.pageGutter,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            onPressed: () async {
              final RoomSort? picked = await showRoomSortSheet(
                context,
                current: sort,
              );
              if (picked != null) onPick(picked);
            },
            icon: const Icon(AppIcons.sort, size: 16),
            label: Text(l10n.roomsSortTrigger(l10n.roomSortLabel(sort))),
          ),
        ],
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  const _RoomList({
    required this.result,
    required this.nights,
    required this.selectedRoomTypeId,
    required this.onOpenRoom,
  });

  final AvailabilityResult result;
  final int nights;
  final String? selectedRoomTypeId;
  final ValueChanged<String> onOpenRoom;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.xs,
        AppSpacing.pageGutter,
        AppSpacing.xl,
      ),
      children: <Widget>[
        if (result.isSoldOut)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InfoBanner(
              tone: InfoBannerTone.warning,
              title: l10n.roomsAllSoldOutTitle,
              message: l10n.roomsAllSoldOutBody,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.roomsTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                l10n.roomsAvailableCount(result.bookableCount),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        for (final AvailableRoom room in result.rooms) ...<Widget>[
          RoomSummaryCard(
            room: room,
            nights: nights,
            selected: room.roomType.id == selectedRoomTypeId,
            onViewDetails: () => onOpenRoom(room.roomType.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _NoResultsActions extends StatelessWidget {
  const _NoResultsActions({
    required this.onChangeDates,
    required this.onChangeGuests,
  });

  final VoidCallback onChangeDates;
  final VoidCallback onChangeGuests;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.all(AppSpacing.pageGutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PrimaryButton(label: l10n.roomsChangeDates, onPressed: onChangeDates),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(
            label: l10n.roomsChangeGuests,
            onPressed: onChangeGuests,
          ),
        ],
      ),
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.enabled, required this.onContinue});

  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.xs,
        AppSpacing.pageGutter,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!enabled)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                l10n.roomsSelectPrompt,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          PrimaryButton(
            label: l10n.roomsContinue,
            onPressed: enabled ? onContinue : null,
          ),
        ],
      ),
    );
  }
}
