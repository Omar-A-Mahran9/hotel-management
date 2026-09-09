import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Tonal status chip (e.g. "متاحة", "مؤكد", "قيد الانتظار"). Colour is passed in
/// by the caller from theme/semantic tokens. Matches the Figma pills: pill
/// shape, small icon, heavy short label.
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
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.allPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: AppTypography.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
