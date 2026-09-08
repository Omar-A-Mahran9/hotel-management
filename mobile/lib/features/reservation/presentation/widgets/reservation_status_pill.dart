import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/reservation_status.dart';
import '../reservation_l10n.dart';

/// Tonal chip for a [ReservationStatus], built on the design-system
/// [StatusPill]. Colour is derived from the status only — Laravel stays
/// authoritative for the status value itself.
class ReservationStatusPill extends StatelessWidget {
  const ReservationStatusPill({super.key, required this.status});

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (Color fg, Color bg) = switch (status) {
      ReservationStatus.cancelled ||
      ReservationStatus.checkoutBlocked =>
        (theme.colorScheme.error, AppColors.errorContainer),
      ReservationStatus.pending ||
      ReservationStatus.checkoutInProgress =>
        (semantic.warning, semantic.warningContainer),
      ReservationStatus.checkedOut ||
      ReservationStatus.invoiced =>
        (semantic.info, semantic.infoContainer),
      _ => (semantic.success, semantic.successContainer),
    };

    return StatusPill(
      label: l10n.reservationStatusLabel(status),
      foreground: fg,
      background: bg,
      icon: Icons.circle,
    );
  }
}
