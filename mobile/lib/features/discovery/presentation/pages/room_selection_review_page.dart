import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../authentication/presentation/state/auth_controller.dart';
import '../../../authentication/presentation/state/auth_state.dart';
import '../../../reservation/domain/entities/create_reservation_request.dart';
import '../../../reservation/presentation/state/create_reservation_controller.dart';
import '../../domain/entities/room_selection.dart';
import '../state/room_selection_controller.dart';
import '../widgets/guest_party_sheet.dart';

/// Review the chosen room + stay + party, then **confirm the reservation**
/// (Mobile Phase 4). Confirming creates a `PENDING` reservation and moves to the
/// confirmation screen. Nothing is charged here.
///
/// The [RoomSelection] lives in [roomSelectionControllerProvider], not the
/// route; it is auto-invalidated when the guest changes dates or party (Phase 3)
/// so a stale selection can never be confirmed.
class RoomSelectionReviewPage extends ConsumerWidget {
  const RoomSelectionReviewPage({super.key, required this.hotelId});

  final String hotelId;

  String? _guestReference(AuthState auth) => auth.map(
        unknown: () => null,
        unauthenticated: () => null,
        awaitingProfile: (session) => session.profile.phone.e164,
        authenticated: (session) => session.profile.phone.e164,
        sessionExpired: () => null,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final RoomSelection? selection = ref.watch(roomSelectionControllerProvider);
    final String? guestReference =
        _guestReference(ref.watch(authControllerProvider));

    if (selection == null || selection.hotelId != hotelId || guestReference == null) {
      return Scaffold(
        appBar: HotelAppBar(title: l10n.reviewTitle),
        body: MessageView(
          icon: Icons.bookmark_border,
          title: l10n.reviewNoSelectionTitle,
          message: l10n.reviewNoSelectionBody,
          actionLabel: l10n.reviewBackToRooms,
          onAction: () => context.pop(),
        ),
      );
    }

    final CreateReservationRequest request =
        CreateReservationRequest.fromSelection(
      selection,
      guestReference: guestReference,
    );
    final CreateReservationState reservationState =
        ref.watch(createReservationControllerProvider);

    // Navigate to the confirmation screen once this exact request succeeds.
    ref.listen<CreateReservationState>(createReservationControllerProvider, (
      CreateReservationState? _,
      CreateReservationState next,
    ) {
      if (next is CreateReservationDone && next.request == request) {
        context.pushReplacementNamed(
          AppRoutes.reservationDetailName,
          pathParameters: <String, String>{
            'reservationId': next.reservation.id,
          },
        );
      }
    });

    final bool submitting = reservationState is CreateReservationSubmitting &&
        reservationState.request == request;
    final bool alreadyCreated = reservationState is CreateReservationDone &&
        reservationState.request == request;
    final Failure? failure = reservationState is CreateReservationFailed &&
            reservationState.request == request
        ? reservationState.failure
        : null;

    return Scaffold(
      appBar: HotelAppBar(title: l10n.reviewTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          children: <Widget>[
            InfoBanner(
              tone: InfoBannerTone.info,
              title: l10n.reviewNotBookedNotice,
            ),
            const SizedBox(height: AppSpacing.md),
            _SummaryCard(selection: selection),
            if (failure != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                tone: InfoBannerTone.error,
                title: l10n.reservationCreateFailedTitle,
                message: failure.localizedMessage(l10n),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.reservationConfirmHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.xs,
          AppSpacing.pageGutter,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (alreadyCreated)
              PrimaryButton(
                label: l10n.reservationViewDetails,
                onPressed: () => context.pushReplacementNamed(
                  AppRoutes.reservationDetailName,
                  pathParameters: <String, String>{
                    'reservationId': reservationState.reservation.id,
                  },
                ),
              )
            else
              PrimaryButton(
                label: submitting
                    ? l10n.reservationConfirming
                    : l10n.reservationConfirmCta,
                isLoading: submitting,
                onPressed: submitting
                    ? null
                    : () => ref
                        .read(createReservationControllerProvider.notifier)
                        .submit(request),
              ),
            const SizedBox(height: AppSpacing.xs),
            SecondaryButton(
              label: l10n.reviewChangeSelection,
              icon: Icons.edit_outlined,
              onPressed: submitting ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.selection});

  final RoomSelection selection;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final Locale locale = Localizations.localeOf(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Row(
            label: l10n.reviewHotelLabel,
            value: selection.hotelName.resolve(locale),
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: l10n.reviewRoomLabel,
            value: selection.roomType.name.resolve(locale),
            secondary: selection.roomType.bedType.resolve(locale),
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: l10n.reviewCheckInLabel,
            value: ml.formatFullDate(selection.stay.checkIn),
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: l10n.reviewCheckOutLabel,
            value: ml.formatFullDate(selection.stay.checkOut),
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: l10n.reviewStayLabel,
            value: l10n.stayNights(selection.nights),
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: l10n.reviewGuestsLabel,
            value: guestPartySummaryText(l10n, selection.party),
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: l10n.reviewPriceLabel,
            value: l10n.pricePerNight(selection.nightlyRate.amount),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.reviewTotalLabel(selection.nights),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                l10n.priceStayTotal(selection.stayTotal.amount),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.extension<AppSemanticColors>()?.accent ??
                      AppColors.bronze500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.secondary});

  final String label;
  final String value;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 110,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(value, style: theme.textTheme.bodyLarge),
              if (secondary != null)
                Text(secondary!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
