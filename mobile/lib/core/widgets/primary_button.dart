import 'package:flutter/material.dart';

import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import 'button_spinner.dart';

/// Filled, pill-shaped primary action button from the design system
/// (Figma `Button`, `Variant=Primary`).
///
/// Full-width by default with the theme's standing height; pass [size] for the
/// component's Small / Medium / Large axis. Shows a [ButtonSpinner] and blocks
/// taps while [isLoading]. Label text is supplied by the caller — reusable
/// widgets never hard-code copy.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonSize? size;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: size == null
          ? null
          : FilledButton.styleFrom(minimumSize: Size.fromHeight(size!.height)),
      child: isLoading
          ? ButtonSpinner(color: Theme.of(context).colorScheme.onPrimary)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: AppIconSizes.button),
                  const SizedBox(width: AppSpacing.space2),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
  }
}
