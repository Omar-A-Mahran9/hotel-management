import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/service_order_status.dart';
import '../stay_services_l10n.dart';

/// Tonal chip for a [ServiceOrderStatus], built on the design-system
/// [StatusPill]. Colour is derived from the status only.
class ServiceOrderStatusPill extends StatelessWidget {
  const ServiceOrderStatusPill({super.key, required this.status});

  final ServiceOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (Color fg, Color bg) = switch (status) {
      ServiceOrderStatus.cancelled =>
        (theme.colorScheme.error, AppColors.errorContainer),
      ServiceOrderStatus.requested =>
        (semantic.warning, semantic.warningContainer),
      ServiceOrderStatus.confirmed => (semantic.info, semantic.infoContainer),
      ServiceOrderStatus.fulfilled =>
        (semantic.success, semantic.successContainer),
    };

    return StatusPill(
      label: l10n.serviceOrderStatusLabel(status),
      foreground: fg,
      background: bg,
      icon: Icons.circle,
    );
  }
}
