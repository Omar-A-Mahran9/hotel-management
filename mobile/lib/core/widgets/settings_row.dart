import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// The Figma `List Item` component (design-system.md's deferred "List Item
/// {None/Chevron/Toggle/Value}" — built here for the Account screen): a
/// leading icon in a soft rounded tile, a label, and an optional trailing
/// value — the whole row tappable when [onTap] is set.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColorTokens c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.bgSubtle,
                borderRadius: AppRadius.allMd,
              ),
              child: Icon(icon, size: 20, color: c.textPrimary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            if (value != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
