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
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../authentication/presentation/state/auth_controller.dart';
import '../../../authentication/presentation/state/auth_state.dart';
import '../../../authentication/presentation/state/login_flow_controller.dart';
import '../../../authentication/presentation/state/post_auth_redirect_controller.dart';
import '../../../reservation/domain/entities/create_reservation_request.dart';
import '../../../reservation/presentation/state/create_reservation_controller.dart';
import '../../domain/entities/guest_party.dart';
import '../../domain/entities/room_selection.dart';
import '../state/booking_price.dart';
import '../state/guest_party_controller.dart';
import '../state/room_selection_controller.dart';
import '../widgets/guest_stepper.dart';
import '../widgets/hotel_thumbnail.dart';
import '../widgets/price_breakdown_card.dart';

/// `BOOKING_Summary` — the "تفاصيل الحجز" screen: the chosen room, editable stay
/// dates + guest party, and the price breakdown. Confirming (signed in) creates
/// a `PENDING` reservation and moves straight to payment; a guest is sent to
/// sign-in first and returned here (deferred auth,
/// `docs/mobile-deferred-auth.md`).
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

  void _signInToConfirm(BuildContext context, WidgetRef ref) {
    ref
        .read(postAuthRedirectProvider.notifier)
        .remember(GoRouterState.of(context).uri.toString());
    ref.read(loginFlowControllerProvider.notifier).reset();
    context.goNamed(AppRoutes.signInName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final RoomSelection? selection = ref.watch(roomSelectionControllerProvider);
    final String? guestReference = _guestReference(
      ref.watch(authControllerProvider),
    );

    if (selection == null || selection.hotelId != hotelId) {
      return Scaffold(
        appBar: HotelAppBar(title: l10n.bookingDetailsTitle),
        body: MessageView(
          icon: AppIcons.room,
          title: l10n.reviewNoSelectionTitle,
          message: l10n.reviewNoSelectionBody,
          actionLabel: l10n.reviewBackToRooms,
          onAction: () => context.pop(),
        ),
      );
    }

    final GuestParty party = ref.watch(guestPartyControllerProvider);
    final BookingPriceBreakdown breakdown = BookingPriceBreakdown.of(
      selection,
      serviceFee: ref.watch(bookingServiceFeeProvider),
    );
    final bool signedIn = guestReference != null;

    final CreateReservationRequest? request = signedIn
        ? CreateReservationRequest.fromSelection(
            selection,
            guestReference: guestReference,
          )
        : null;
    final CreateReservationState reservationState =
        ref.watch(createReservationControllerProvider);

    // Once this exact request succeeds, go straight to payment.
    ref.listen<CreateReservationState>(createReservationControllerProvider, (
      CreateReservationState? _,
      CreateReservationState next,
    ) {
      if (next is CreateReservationDone && next.request == request) {
        context.pushReplacementNamed(
          AppRoutes.paymentReviewName,
          pathParameters: <String, String>{
            'reservationId': next.reservation.id,
          },
        );
      }
    });

    final bool submitting = reservationState is CreateReservationSubmitting &&
        reservationState.request == request;
    final Failure? failure = reservationState is CreateReservationFailed &&
            reservationState.request == request
        ? reservationState.failure
        : null;

    return Scaffold(
      appBar: HotelAppBar(title: l10n.bookingDetailsTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          children: <Widget>[
            _RoomCard(selection: selection),
            const SizedBox(height: AppSpacing.md),
            _DatesCard(
              selection: selection,
              onEdit: () => context.pushNamed(
                AppRoutes.stayDatesName,
                pathParameters: <String, String>{'hotelId': hotelId},
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PartyCard(
              party: party,
              onAdults: (int v) => ref
                  .read(guestPartyControllerProvider.notifier)
                  .setAdults(v),
              onChildren: (int v) => ref
                  .read(guestPartyControllerProvider.notifier)
                  .setChildren(v),
            ),
            const SizedBox(height: AppSpacing.md),
            PriceBreakdownCard(breakdown: breakdown),
            if (failure != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                tone: InfoBannerTone.error,
                title: l10n.reservationCreateFailedTitle,
                message: failure.localizedMessage(l10n),
              ),
            ],
            if (!signedIn) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.reviewSignInHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
        child: signedIn
            ? PrimaryButton(
                label: submitting
                    ? l10n.reservationConfirming
                    : l10n.bookingProceedToPayment,
                isLoading: submitting,
                onPressed: submitting
                    ? null
                    : () => ref
                        .read(createReservationControllerProvider.notifier)
                        .submit(request!),
              )
            : PrimaryButton(
                label: l10n.reviewSignInToConfirm,
                onPressed: () => _signInToConfirm(context, ref),
              ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.selection});

  final RoomSelection selection;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final AppColorTokens c = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  selection.roomType.name.resolve(locale),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(AppIcons.location, size: 13, color: c.textSecondary),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        selection.hotelName.resolve(locale),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    MoneyText(
                      selection.nightlyRate.amount,
                      suffix: l10n.priceNightSuffix,
                      markSize: 13,
                    ),
                    const Spacer(),
                    StatusPill(
                      label: l10n.bookingRoomAvailable,
                      foreground: c.successFg,
                      background: c.successBg,
                      icon: AppIcons.shieldCheck,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const HotelThumbnail(
            imageUrl: null,
            width: 76,
            height: 76,
            icon: AppIcons.bed,
          ),
        ],
      ),
    );
  }
}

class _DatesCard extends StatelessWidget {
  const _DatesCard({required this.selection, required this.onEdit});

  final RoomSelection selection;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.bookingDatesLabel,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: context.colors.textSecondary),
                ),
              ),
              InkWell(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    l10n.commonEdit,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n.stayDatesSelectedRange(ml.formatMediumDate(selection.stay.checkIn), ml.formatMediumDate(selection.stay.checkOut))} · ${l10n.stayNights(selection.nights)}',
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.party,
    required this.onAdults,
    required this.onChildren,
  });

  final GuestParty party;
  final ValueChanged<int> onAdults;
  final ValueChanged<int> onChildren;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return AppCard(
      child: Column(
        children: <Widget>[
          GuestStepper(
            label: l10n.guestsAdults,
            value: party.adults,
            min: GuestParty.minAdults,
            max: GuestParty.maxAdults,
            onChanged: onAdults,
          ),
          const SizedBox(height: AppSpacing.sm),
          GuestStepper(
            label: l10n.guestsChildren,
            value: party.children,
            min: GuestParty.minChildren,
            max: GuestParty.maxChildren,
            onChanged: onChildren,
          ),
        ],
      ),
    );
  }
}
