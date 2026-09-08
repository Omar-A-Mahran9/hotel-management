import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/identity_verification_session.dart';
import '../../domain/entities/identity_verification_status.dart';
import 'identity_status_pill.dart';

/// The safe outcome view for a resolved (or awaiting-review) session. Shown on
/// the verification page while navigating and on the dedicated result page.
/// Never renders provider detail, scores or document data.
class VerificationResultView extends StatelessWidget {
  const VerificationResultView({super.key, required this.session});

  final IdentityVerificationSession session;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (IconData icon, Color color, String title, String body) =
        switch (session.status) {
      IdentityVerificationStatus.autoApproved ||
      IdentityVerificationStatus.staffApproved =>
        (
          Icons.verified_user_outlined,
          semantic.success,
          l10n.identityApprovedTitle,
          l10n.identityApprovedBody,
        ),
      IdentityVerificationStatus.pendingManualReview => (
          Icons.hourglass_bottom_rounded,
          semantic.warning,
          l10n.identityManualReviewTitle,
          l10n.identityManualReviewBody,
        ),
      IdentityVerificationStatus.retryAllowed => (
          Icons.refresh_rounded,
          semantic.warning,
          l10n.identityRetryTitle,
          l10n.identityRetryBody,
        ),
      IdentityVerificationStatus.staffRejected => (
          Icons.gpp_bad_outlined,
          theme.colorScheme.error,
          l10n.identityRejectedTitle,
          session.canRetry
              ? l10n.identityRejectedRetryBody
              : l10n.identityRejectedBody,
        ),
      _ => (
          Icons.badge_outlined,
          semantic.info,
          l10n.identityVerificationTitle,
          '',
        ),
    };

    return ListView(
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
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (body.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                body,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.reservationStatusFieldLabel,
                style: theme.textTheme.bodySmall,
              ),
            ),
            IdentityStatusPill(status: session.status),
          ],
        ),
        if (session.attempts > 0) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.identityAttemptCount(session.attempts),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
