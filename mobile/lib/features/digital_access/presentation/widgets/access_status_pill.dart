import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/access_status.dart';
import '../digital_access_l10n.dart';

/// Tonal chip for an [AccessStatus], built on the design-system [StatusPill].
/// Colour is derived from the status only — Laravel stays authoritative.
class AccessStatusPill extends StatelessWidget {
  const AccessStatusPill({super.key, required this.status});

  final AccessStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (Color fg, Color bg) = switch (status) {
      AccessStatus.failed || AccessStatus.revoked =>
        (theme.colorScheme.error, AppColors.errorContainer),
      AccessStatus.notIssued ||
      AccessStatus.issueRequested ||
      AccessStatus.revokeRequested =>
        (semantic.warning, semantic.warningContainer),
      AccessStatus.expired => (semantic.info, semantic.infoContainer),
      AccessStatus.active => (semantic.success, semantic.successContainer),
    };

    return StatusPill(
      label: l10n.accessStatusLabel(status),
      foreground: fg,
      background: bg,
      icon: Icons.circle,
    );
  }
}
