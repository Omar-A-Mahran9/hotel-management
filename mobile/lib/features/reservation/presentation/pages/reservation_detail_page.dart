import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/reservation.dart';
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
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      children: <Widget>[
        Column(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: semantic.successContainer,
              child: Icon(Icons.check_rounded, color: semantic.success, size: 30),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.reservationSuccessTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.reservationSuccessBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
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
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
