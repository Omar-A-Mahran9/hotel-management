import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Filled, pill-shaped primary action button from the design system.
///
/// Full-width by default, ~54 tall, heavy label (see [ThemeData.filledButtonTheme]).
/// Shows a spinner and blocks taps while [isLoading]. Label text is supplied by
/// the caller — reusable widgets never hard-code copy.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
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
