import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/checkout.dart';
import '../state/checkout_controller.dart';

/// `05 · Depart & Invoice` screen 3 — the authoritative checkout outcome:
/// "thank you for your stay" on success, a safe retry on settlement failure, a
/// waiting state while pending. Never claims completion before the repository
/// confirms it.
class CheckoutCompletionPage extends ConsumerWidget {
  const CheckoutCompletionPage({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final CheckoutActionState action = ref.watch(checkoutControllerProvider);

    if (action is CheckoutIdle || action is CheckoutSubmitting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pushReplacementNamed(
            AppRoutes.checkoutName,
            pathParameters: <String, String>{'reservationId': reservationId},
          );
        }
      });
      return Scaffold(
        appBar: HotelAppBar(title: l10n.checkoutCompleteTitle),
        body: Center(child: LoadingView(label: l10n.stateLoadingTitle)),
      );
    }

    return Scaffold(
      appBar: HotelAppBar(title: l10n.checkoutCompleteTitle),
      body: SafeArea(child: _Body(reservationId: reservationId, action: action)),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.reservationId, required this.action});

  final String reservationId;
  final CheckoutActionState action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final CheckoutResult? result = action.resultOrNull;
    final bool isFailure = action is CheckoutFailed ||
        (result?.outcome == CheckoutOutcome.settlementFailed);
    final bool isPending =
        result?.outcome == CheckoutOutcome.settlementPending;
    final bool isSuccess = result?.outcome.isSuccess ?? false;

    final (IconData icon, Color color, String title, String body) = isSuccess
        ? (
            Icons.check_rounded,
            semantic.success,
            l10n.checkoutDoneTitle,
            l10n.checkoutDoneBody,
          )
        : isPending
            ? (
                Icons.hourglass_bottom_rounded,
                semantic.warning,
                l10n.checkoutPendingTitle,
                l10n.checkoutPendingBody,
              )
            : (
                Icons.error_outline_rounded,
                theme.colorScheme.error,
                l10n.checkoutFailedTitle,
                action is CheckoutFailed
                    ? (action as CheckoutFailed).failure.localizedMessage(l10n)
                    : l10n.checkoutFailedBody,
              );

    void done() => context.goNamed(
          AppRoutes.reservationDetailName,
          pathParameters: <String, String>{'reservationId': reservationId},
        );

    void retry() {
      ref.read(checkoutControllerProvider.notifier).submit(reservationId);
      context.pushReplacementNamed(
        AppRoutes.checkoutProcessingName,
        pathParameters: <String, String>{'reservationId': reservationId},
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            children: <Widget>[
              Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(body,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (result != null && result.checkout.chargesTotal.amount > 0)
                AppCard(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(l10n.invoiceTitle,
                            style: theme.textTheme.titleSmall),
                      ),
                      Text(
                        l10n.moneyAmount(result.checkout.currency,
                            result.checkout.chargesTotal.amount),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: semantic.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isFailure) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                InfoBanner(
                  tone: InfoBannerTone.error,
                  title: l10n.checkoutFailedTitle,
                  message: l10n.checkoutFailedBody,
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.xs,
            AppSpacing.pageGutter,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isFailure) ...<Widget>[
                PrimaryButton(label: l10n.checkoutRetryCta, onPressed: retry),
                const SizedBox(height: AppSpacing.xs),
              ],
              if (isSuccess) ...<Widget>[
                PrimaryButton(
                  label: l10n.checkoutViewInvoiceCta,
                  onPressed: () => context.pushNamed(
                    AppRoutes.invoiceName,
                    pathParameters: <String, String>{
                      'reservationId': reservationId,
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              (isSuccess)
                  ? SecondaryButton(label: l10n.checkoutDoneCta, onPressed: done)
                  : PrimaryButton(
                      label: l10n.checkoutDoneCta, onPressed: done),
            ],
          ),
        ),
      ],
    );
  }
}
