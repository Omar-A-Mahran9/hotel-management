import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/identity_verification_status.dart';
import '../identity_verification_l10n.dart';

/// Tonal chip for an [IdentityVerificationStatus], built on the design-system
/// [StatusPill]. Colour is derived from the status only — Laravel stays
/// authoritative for the status value itself.
class IdentityStatusPill extends StatelessWidget {
  const IdentityStatusPill({super.key, required this.status});

  final IdentityVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (Color fg, Color bg) = switch (status) {
      IdentityVerificationStatus.staffRejected =>
        (theme.colorScheme.error, AppColors.errorContainer),
      IdentityVerificationStatus.retryAllowed ||
      IdentityVerificationStatus.pendingManualReview ||
      IdentityVerificationStatus.notStarted =>
        (semantic.warning, semantic.warningContainer),
      IdentityVerificationStatus.autoApproved ||
      IdentityVerificationStatus.staffApproved =>
        (semantic.success, semantic.successContainer),
      _ => (semantic.info, semantic.infoContainer),
    };

    return StatusPill(
      label: l10n.identityStatusLabel(status),
      foreground: fg,
      background: bg,
      icon: Icons.circle,
    );
  }
}
