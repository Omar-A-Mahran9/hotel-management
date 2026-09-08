import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../domain/entities/identity_verification_session.dart';
import '../../domain/entities/identity_verification_status.dart';
import '../state/identity_verification_controller.dart';
import '../widgets/identity_document_step.dart';
import '../widgets/identity_selfie_step.dart';
import '../widgets/identity_step_indicator.dart';

/// `10 · Identity verification` — the guest verification flow before check-in.
///
/// Walks the approved state machine: Document → Selfie → Verification processing
/// → Result. The app never claims approval before the repository confirms it,
/// and never transitions the session or the reservation itself. When the
/// session resolves (auto-approved / awaiting manual review) it hands off to
/// the dedicated result screen.
class IdentityVerificationPage extends ConsumerStatefulWidget {
  const IdentityVerificationPage({super.key, required this.reservationId});

  final String reservationId;

  @override
  ConsumerState<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState
    extends ConsumerState<IdentityVerificationPage> {
  bool _handedOff = false;

  void _maybeHandOff(IdentityVerificationState state) {
    if (_handedOff || !mounted) return;
    final IdentityVerificationSession? session = state.session;
    if (session == null || state.isBusy) return;
    if (session.isApproved || session.isManualReview) {
      _handedOff = true;
      context.pushReplacementNamed(
        AppRoutes.identityVerificationResultName,
        pathParameters: <String, String>{
          'reservationId': widget.reservationId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final IdentityVerificationState state =
        ref.watch(identityVerificationControllerProvider(widget.reservationId));

    ref.listen<IdentityVerificationState>(
      identityVerificationControllerProvider(widget.reservationId),
      (_, next) => _maybeHandOff(next),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeHandOff(state));

    return Scaffold(
      appBar: HotelAppBar(title: l10n.identityVerificationTitle),
      body: SafeArea(child: _body(context, ref, state)),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    IdentityVerificationState state,
  ) {
    final AppLocalizations l10n = context.l10n;
    final IdentityVerificationSession? session = state.session;

    if (session == null) {
      if (state.hasFailure) {
        return MessageView(
          icon: Icons.badge_outlined,
          title: l10n.identityUnavailableTitle,
          message: state.failure!.localizedMessage(l10n),
          actionLabel: l10n.actionRetry,
          onAction: () => ref
              .read(identityVerificationControllerProvider(widget.reservationId)
                  .notifier)
              .refresh(),
        );
      }
      return Center(child: LoadingView(label: l10n.stateLoadingTitle));
    }

    final IdentityVerificationController controller = ref.read(
      identityVerificationControllerProvider(widget.reservationId).notifier,
    );

    final IdentityStep step = _stepFor(session.status);

    // Selfie in flight, or the backend is matching — show the processing state.
    if (state.isSubmittingSelfie || session.isProcessing) {
      return _Processing(step: step);
    }

    // Resolved states hand off to the result screen; render a spinner while the
    // post-frame navigation runs.
    if (session.isApproved || session.isManualReview) {
      return _Processing(step: IdentityStep.result);
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.xs,
          ),
          child: IdentityStepIndicator(current: step),
        ),
        if (state.hasFailure)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.xs,
              AppSpacing.pageGutter,
              0,
            ),
            child: InfoBanner(
              tone: InfoBannerTone.error,
              title: l10n.identityUnavailableTitle,
              message: state.failure!.localizedMessage(l10n),
            ),
          ),
        Expanded(
          child: session.needsSelfie
              ? IdentitySelfieStep(
                  submitting: state.isSubmittingSelfie,
                  onSubmit: controller.submitSelfie,
                )
              : IdentityDocumentStep(
                  submitting: state.isSubmittingDocument,
                  retryBanner: _retryBanner(context, session),
                  onSubmit: (type) => controller.submitDocument(type),
                ),
        ),
      ],
    );
  }

  Widget? _retryBanner(
    BuildContext context,
    IdentityVerificationSession session,
  ) {
    final AppLocalizations l10n = context.l10n;
    return switch (session.status) {
      IdentityVerificationStatus.retryAllowed => InfoBanner(
          tone: InfoBannerTone.warning,
          title: l10n.identityRetryTitle,
          message: l10n.identityRetryBody,
        ),
      IdentityVerificationStatus.staffRejected => InfoBanner(
          tone: InfoBannerTone.error,
          title: l10n.identityRejectedTitle,
          message: session.canRetry
              ? l10n.identityRejectedRetryBody
              : l10n.identityRejectedBody,
        ),
      _ => null,
    };
  }

  static IdentityStep _stepFor(IdentityVerificationStatus status) {
    if (status.needsSelfie) return IdentityStep.selfie;
    if (status.isProcessing || status.isApproved || status.isManualReview) {
      return IdentityStep.result;
    }
    return IdentityStep.document;
  }
}

class _Processing extends StatelessWidget {
  const _Processing({required this.step});

  final IdentityStep step;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.xs,
          ),
          child: IdentityStepIndicator(current: step),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  LoadingView(label: l10n.identityProcessingTitle),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.identityProcessingBody,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
