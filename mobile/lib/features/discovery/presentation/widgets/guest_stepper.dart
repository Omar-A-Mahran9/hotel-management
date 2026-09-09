import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icons.dart';

/// A labelled −/+ stepper row (`16 · Stay dates & available rooms`, the "عدد
/// الضيوف" sheet).
///
/// Figma style: circular tinted −/+ buttons flanking the value in a boxed
/// field. Buttons disable at [min] / [max]. Increment/decrement behaviour is
/// unchanged from the previous implementation.
class GuestStepper extends StatelessWidget {
  const GuestStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
        _RoundButton(
          icon: AppIcons.remove,
          tooltip: '${l10n.stepperDecrease} — $label',
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          width: 52,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.allSm,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Text('$value', style: theme.textTheme.titleMedium),
        ),
        _RoundButton(
          icon: AppIcons.add,
          tooltip: '${l10n.stepperIncrease} — $label',
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool enabled = onPressed != null;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        backgroundColor: enabled
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.35),
        shape: const CircleBorder(),
      ),
    );
  }
}
