import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/result_view.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/access_grant.dart';
import '../../domain/entities/access_status.dart';
import '../../domain/entities/check_in.dart';
import '../state/check_in_controller.dart';
import '../state/digital_access_providers.dart';
import '../widgets/access_credential_card.dart';
import '../widgets/access_status_pill.dart';
import '../../../../core/widgets/app_icons.dart';

/// `04 · Check in & Stay` — the digital room-key screen.
///
/// Renders exactly what the repository resolved for the grant: an active
/// credential, a still-pending issuance, a safe failure with retry, or a
/// revoked / expired notice. It never claims a working key before the
/// repository confirms it, and never renders provider internals.
class DigitalAccessPage extends ConsumerWidget {
  const DigitalAccessPage({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<AccessGrant> grantAsync = ref.watch(
      accessGrantProvider(reservationId),
    );
    final CheckInActionState action = ref.watch(checkInControllerProvider);

    // A just-completed check-in action can carry a fresher grant than a cached
    // fetch — prefer it when it targets this reservation.
    final AccessGrant? fromAction =
        action is CheckInDone && action.request.reservationId == reservationId
        ? action.result.grant
        : null;

    return Scaffold(
      appBar: HotelAppBar(title: l10n.accessTitle),
      body: SafeArea(
        child: grantAsync.when(
          loading: () => fromAction != null
              ? _Body(grant: fromAction, reservationId: reservationId)
              : Center(child: LoadingView(label: l10n.stateLoadingTitle)),
          error: (Object error, StackTrace _) {
            final failure = ErrorMapper.toFailure(error);
            return MessageView(
              icon: AppIcons.key,
              title: l10n.accessUnavailableTitle,
              message: failure.localizedMessage(l10n),
              actionLabel: l10n.actionRetry,
              onAction: () =>
                  ref.invalidate(accessGrantProvider(reservationId)),
            );
          },
          data: (AccessGrant grant) {
            final AccessGrant shown = (fromAction != null && !grant.isActive)
                ? fromAction
                : grant;
            return _Body(grant: shown, reservationId: reservationId);
          },
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.grant, required this.reservationId});

  final AccessGrant grant;
  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    void backToReservation() => context.goNamed(
      AppRoutes.reservationDetailName,
      pathParameters: <String, String>{'reservationId': reservationId},
    );

    void toCheckIn() => context.pushReplacementNamed(
      AppRoutes.checkInName,
      pathParameters: <String, String>{'reservationId': reservationId},
    );

    void retryCheckIn() {
      ref
          .read(checkInControllerProvider.notifier)
          .submit(CheckInRequest(reservationId: reservationId));
      context.pushReplacementNamed(
        AppRoutes.checkInProcessingName,
        pathParameters: <String, String>{'reservationId': reservationId},
      );
    }

    if (grant.isActive) {
      return Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pageGutter),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.accessCheckedInTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    AccessStatusPill(status: grant.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AccessCredentialCard(grant: grant),
                const SizedBox(height: AppSpacing.md),
                InfoBanner(
                  tone: InfoBannerTone.info,
                  title: l10n.accessHelpBanner,
                ),
              ],
            ),
          ),
          _BottomAction(
            label: l10n.accessBackToReservation,
            onPressed: backToReservation,
          ),
        ],
      );
    }

    // Non-active states → a tinted result banner + the right recovery action.
    final (
      InfoBannerTone tone,
      String title,
      String body,
      Widget action,
    ) = switch (grant.status) {
      AccessStatus.failed => (
        InfoBannerTone.error,
        l10n.checkInFailedTitle,
        l10n.checkInFailedBody,
        _TwoActions(
          primaryLabel: l10n.checkInRetryCta,
          onPrimary: retryCheckIn,
          secondaryLabel: l10n.accessBackToReservation,
          onSecondary: backToReservation,
        ),
      ),
      AccessStatus.issueRequested || AccessStatus.revokeRequested => (
        InfoBannerTone.warning,
        l10n.checkInPendingTitle,
        l10n.checkInPendingBody,
        _TwoActions(
          primaryLabel: l10n.actionCheckAgain,
          onPrimary: () => ref.invalidate(accessGrantProvider(reservationId)),
          secondaryLabel: l10n.accessBackToReservation,
          onSecondary: backToReservation,
        ),
      ),
      AccessStatus.revoked => (
        InfoBannerTone.error,
        l10n.accessRevokedTitle,
        l10n.accessRevokedBody,
        _BottomAction(
          label: l10n.accessBackToReservation,
          onPressed: backToReservation,
        ),
      ),
      AccessStatus.expired => (
        InfoBannerTone.info,
        l10n.accessExpiredTitle,
        l10n.accessExpiredBody,
        _BottomAction(
          label: l10n.accessBackToReservation,
          onPressed: backToReservation,
        ),
      ),
      _ => (
        InfoBannerTone.info,
        l10n.accessNotIssuedTitle,
        l10n.accessNotIssuedBody,
        _BottomAction(label: l10n.reservationCheckInCta, onPressed: toCheckIn),
      ),
    };

    return Column(
      children: <Widget>[
        Expanded(
          child: ResultView(
            tone: tone,
            title: title,
            message: body,
            detail: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.reservationStatusFieldLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                AccessStatusPill(status: grant.status),
              ],
            ),
          ),
        ),
        action,
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.xs,
        AppSpacing.pageGutter,
        AppSpacing.md,
      ),
      child: PrimaryButton(label: label, onPressed: onPressed),
    );
  }
}

class _TwoActions extends StatelessWidget {
  const _TwoActions({
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
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
          PrimaryButton(label: primaryLabel, onPressed: onPrimary),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(label: secondaryLabel, onPressed: onSecondary),
        ],
      ),
    );
  }
}
