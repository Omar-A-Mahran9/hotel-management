import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../reviews/domain/entities/review.dart';
import '../../../reviews/presentation/state/review_providers.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../state/reservation_detail_provider.dart';
import '../widgets/reservation_status_pill.dart';
import '../widgets/reservation_summary_card.dart';

/// Confirmation + details for one reservation (`03 · Pay & Verify` /
/// `08 · Room selection & stay actions` — "تم التحقق وتأكيد حجزك"). This is the
/// screen the guest lands on straight after confirming; it also backs a deep
/// link / a later visit by id.
class ReservationDetailPage extends ConsumerWidget {
  const ReservationDetailPage({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<Reservation> async =
        ref.watch(reservationDetailProvider(reservationId));

    return Scaffold(
      appBar: HotelAppBar(title: l10n.reservationDetailTitle),
      body: SafeArea(
        child: async.when(
          loading: () => Center(child: LoadingView(label: l10n.stateLoadingTitle)),
          error: (Object error, StackTrace _) {
            final failure = ErrorMapper.toFailure(error);
            return MessageView(
              icon: Icons.receipt_long_outlined,
              title: l10n.reservationNotFoundTitle,
              message: failure.localizedMessage(l10n),
              actionLabel: l10n.actionRetry,
              onAction: () =>
                  ref.invalidate(reservationDetailProvider(reservationId)),
            );
          },
          data: (Reservation reservation) => _Body(reservation: reservation),
        ),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (_) => SafeArea(
          minimum: const EdgeInsets.all(AppSpacing.pageGutter),
          child: PrimaryButton(
            label: l10n.reservationDone,
            onPressed: () => context.goNamed(AppRoutes.discoverName),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      children: <Widget>[
        InfoBanner(
          tone: InfoBannerTone.success,
          title: l10n.reservationSuccessTitle,
          message: l10n.reservationSuccessBody,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.reservationReferenceLabel,
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xxs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.allSm,
                ),
                child: Text(
                  reservation.reference,
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.5,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(l10n.reservationStatusFieldLabel,
                        style: theme.textTheme.bodySmall),
                  ),
                  ReservationStatusPill(status: reservation.status),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(l10n.reservationBookedOnLabel,
                        style: theme.textTheme.bodySmall),
                  ),
                  Text(
                    ml.formatMediumDate(reservation.createdAt),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ReservationSummaryCard(reservation: reservation),
        if (reservation.status.isAwaitingPayment) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          InfoBanner(
            tone: InfoBannerTone.info,
            title: l10n.reservationPendingNote,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: l10n.reservationPayCta,
          icon: Icons.payments_outlined,
          onPressed: () => context.pushNamed(
            AppRoutes.paymentReviewName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SecondaryButton(
          label: l10n.reservationVerifyIdentityCta,
          icon: Icons.badge_outlined,
          onPressed: () => context.pushNamed(
            AppRoutes.identityVerificationName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SecondaryButton(
          label: l10n.reservationCheckInCta,
          icon: Icons.meeting_room_outlined,
          onPressed: () => context.pushNamed(
            AppRoutes.checkInName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SecondaryButton(
          label: l10n.reservationServicesCta,
          icon: Icons.room_service_outlined,
          onPressed: () => context.pushNamed(
            AppRoutes.stayServicesName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SecondaryButton(
          label: l10n.reservationCheckoutCta,
          icon: Icons.logout_outlined,
          onPressed: () => context.pushNamed(
            AppRoutes.checkoutName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        _CompletedStayActions(reservation: reservation),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Loyalty + review entry points. Shown only once the stay is completed
/// (`CHECKED_OUT` / `INVOICED`) — the same "completed stay" definition the
/// backend loyalty + review eligibility use. The backend stays authoritative;
/// this is a UX gate. Renders nothing (no extra spacing) for any other status,
/// so the Phase 5–9 CTAs above are untouched.
class _CompletedStayActions extends ConsumerWidget {
  const _CompletedStayActions({required this.reservation});

  final Reservation reservation;

  bool get _isCompletedStay =>
      reservation.status == ReservationStatus.checkedOut ||
      reservation.status == ReservationStatus.invoiced;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_isCompletedStay) return const SizedBox.shrink();
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<Review?> review =
        ref.watch(reservationReviewProvider(reservation.id));
    final bool hasReview = review.valueOrNull != null;

    return Column(
      children: <Widget>[
        const SizedBox(height: AppSpacing.xs),
        SecondaryButton(
          label: l10n.reservationLoyaltyCta,
          icon: Icons.card_giftcard_outlined,
          onPressed: () => context.pushNamed(
            AppRoutes.loyaltyName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SecondaryButton(
          label: hasReview
              ? l10n.reservationViewReviewCta
              : l10n.reservationReviewCta,
          icon: Icons.rate_review_outlined,
          onPressed: () => context.pushNamed(
            AppRoutes.reviewFormName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
      ],
    );
  }
}
