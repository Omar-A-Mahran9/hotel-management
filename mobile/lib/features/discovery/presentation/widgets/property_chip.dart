import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// An outlined icon + label pill describing one room/hotel fact — area, guest
/// count, bed type (`HOTEL_Detail`, `08 · تفاصيل الغرفة`). Figma "Property Chip".
class PropertyChip extends StatelessWidget {
  const PropertyChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColorTokens c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.bgSubtle,
        borderRadius: AppRadius.allPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: c.textLabel),
          const SizedBox(width: AppSpacing.space1 + 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textLabel),
          ),
        ],
      ),
    );
  }
}
