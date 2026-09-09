import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Secondary action button from the design system.
///
/// The Figma secondary button is **not** a coloured-outline Material button —
/// it is a paper/cream-filled pill with a subtle hairline border and
/// on-surface text (see `تغيير رقم الجوال`, `عرض حجوزاتي`). The fill + border +
/// pill shape come from [ThemeData.outlinedButtonTheme]; this widget only
/// composes the icon + label.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
  }
}
