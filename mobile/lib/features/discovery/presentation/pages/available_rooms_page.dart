import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/presentation/ui_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/availability_result.dart';
import '../../domain/entities/guest_party.dart';
import '../../domain/entities/room_sort.dart';
import '../../domain/entities/stay_range.dart';
import '../discovery_l10n.dart';
import '../state/guest_party_controller.dart';
import '../state/room_availability_controller.dart';
import '../state/stay_dates_controller.dart';
import '../widgets/guest_party_sheet.dart';
import '../widgets/room_summary_card.dart';

/// `16 · Stay dates & available rooms` — the available-rooms list. Dummy
/// availability only: the mobile app never computes authoritative availability
/// (a later phase's Laravel API does). The flow ends here — there is no booking
/// CTA in this phase.
class AvailableRoomsPage extends ConsumerStatefulWidget {
  const AvailableRoomsPage({super.key, required this.hotelId});

  final String hotelId;

  @override
  ConsumerState<AvailableRoomsPage> createState() => _AvailableRoomsPageState();
}

class _AvailableRoomsPageState extends ConsumerState<AvailableRoomsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final StayRange? range =
        ref.read(stayDatesControllerProvider).rangeAgainst(ref.today());
    if (range == null) return;
    ref.read(roomAvailabilityControllerProvider.notifier).load(
          hotelId: widget.hotelId,
          stay: range,
          party: ref.read(guestPartyControllerProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DateTime today = ref.today();
    final StayRange? range =
        ref.watch(stayDatesControllerProvider).rangeAgainst(today);
    final GuestParty party = ref.watch(guestPartyControllerProvider);
    final RoomAvailabilityState state =
        ref.watch(roomAvailabilityControllerProvider);

    // Reload whenever the party changes from this screen's "change guests".
    ref.listen<GuestParty>(guestPartyControllerProvider, (_, _) => _load());

    if (range == null) {
      return Scaffold(
        appBar: HotelAppBar(title: l10n.roomsTitle),
        body: MessageView(
          icon: Icons.event_busy_outlined,
          title: l10n.roomsNoResultsTitle,
          message: l10n.roomsNoResultsBody,
          actionLabel: l10n.roomsChangeDates,
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: HotelAppBar(
        title: l10n.roomsTitle,
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.stayDatesEditDates),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _StayHeader(range: range, party: party),
            const Divider(height: 1),
            _Toolbar(
              sort: state.sort,
              onSort: ref
                  .read(roomAvailabilityControllerProvider.notifier)
                  .setSort,
              onChangeGuests: () => showGuestPartySheet(context),
            ),
            Expanded(
              child: UiStateView<AvailabilityResult>(
                state: state.result,
                onRetry: _load,
                emptyTitle: l10n.roomsNoResultsTitle,
                emptyMessage: l10n.roomsNoResultsBody,
                onSuccess: (AvailabilityResult result) => _RoomList(
                  result: result,
                  nights: range.nights,
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
    );
  }
}

class _StayHeader extends StatelessWidget {
  const _StayHeader({required this.range, required this.party});

  final StayRange range;
  final GuestParty party;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${ml.formatMediumDate(range.checkIn)} → ${ml.formatMediumDate(range.checkOut)}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${l10n.stayNights(range.nights)} · ${guestPartySummaryText(l10n, party)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.sort,
    required this.onSort,
    required this.onChangeGuests,
  });

  final RoomSort sort;
  final ValueChanged<RoomSort> onSort;
  final VoidCallback onChangeGuests;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Text('${l10n.roomsSortLabel}: ', style: Theme.of(context).textTheme.bodySmall),
          DropdownButton<RoomSort>(
            value: sort,
            underline: const SizedBox.shrink(),
            onChanged: (RoomSort? value) {
              if (value != null) onSort(value);
            },
            items: <DropdownMenuItem<RoomSort>>[
              for (final RoomSort option in RoomSort.values)
                DropdownMenuItem<RoomSort>(
                  value: option,
                  child: Text(l10n.roomSortLabel(option)),
                ),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onChangeGuests,
            icon: const Icon(Icons.person_outline, size: 16),
            label: Text(l10n.roomsChangeGuests),
          ),
        ],
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  const _RoomList({required this.result, required this.nights});

  final AvailabilityResult result;
  final int nights;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
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
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            l10n.roomsAvailableCount(result.bookableCount),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        for (final room in result.rooms) ...<Widget>[
          RoomSummaryCard(room: room, nights: nights),
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
          SecondaryButton(
            label: l10n.roomsChangeDates,
            onPressed: onChangeDates,
          ),
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
