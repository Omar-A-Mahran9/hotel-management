import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Tonal status chip (e.g. "متاحة", "مؤكد", "قيد الانتظار"; Figma `Status Pill`).
/// Colour is passed in by the caller from theme/semantic tokens. Pill shape,
/// small leading icon, heavy short label.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.allPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: AppIconSizes.pill, color: foreground),
            const SizedBox(width: AppSpacing.space1),
          ],
          Text(label, style: AppTypography.labelStrong(foreground)),
        ],
      ),
    );
  }
}
