import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/guest_party.dart';
import '../../domain/entities/stay_range.dart';
import '../discovery_l10n.dart';
import '../state/guest_party_controller.dart';
import '../state/stay_dates_controller.dart';
import '../widgets/guest_party_sheet.dart';
import '../widgets/stay_range_calendar.dart';

/// `16 · Stay dates & available rooms` — the check-in / check-out picker.
///
/// It only produces state (a [StayRange] plus the [GuestParty]); it does not
/// call an availability API or create a reservation. The CTA is disabled until
/// both dates are chosen and check-out is after check-in.
class StayDatesPage extends ConsumerWidget {
  const StayDatesPage({super.key, required this.hotelId});

  final String hotelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);

    final DateTime today = ref.today();
    final StayDatesDraft draft = ref.watch(stayDatesControllerProvider);
    final GuestParty party = ref.watch(guestPartyControllerProvider);
    final StayDatesController dates =
        ref.read(stayDatesControllerProvider.notifier);

    final StayRange? range = draft.rangeAgainst(today);
    final String? errorText = l10n.stayDatesErrorLabel(draft.errorAgainst(today));

    return Scaffold(
      appBar: HotelAppBar(
        title: l10n.stayDatesTitle,
        actions: <Widget>[
          if (!draft.isEmpty)
            TextButton(
              onPressed: dates.clear,
              child: Text(l10n.stayDatesClear),
            ),
        ],
      ),
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
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _DateField(
                      label: l10n.stayDatesCheckIn,
                      value: draft.checkIn == null
                          ? l10n.stayDatesPick
                          : ml.formatMediumDate(draft.checkIn!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _DateField(
                      label: l10n.stayDatesCheckOut,
                      value: draft.checkOut == null
                          ? l10n.stayDatesPick
                          : ml.formatMediumDate(draft.checkOut!),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => showGuestPartySheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        guestPartySummaryText(l10n, party),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const Icon(Icons.edit_outlined, size: 16),
                  ],
                ),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    errorText,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ),
            const Divider(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.xs,
                  AppSpacing.pageGutter,
                  AppSpacing.xl,
                ),
                children: <Widget>[
                  StayRangeCalendar(
                    firstDay: today,
                    checkIn: draft.checkIn,
                    checkOut: draft.checkOut,
                    onSelectDay: dates.selectDay,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.pageGutter),
        child: PrimaryButton(
          label: range == null
              ? l10n.stayDatesShowRooms
              : '${l10n.stayDatesShowRooms} · ${l10n.stayNights(range.nights)}',
          onPressed: range == null
              ? null
              : () => context.pushNamed(
                    AppRoutes.availableRoomsName,
                    pathParameters: <String, String>{'hotelId': hotelId},
                  ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
