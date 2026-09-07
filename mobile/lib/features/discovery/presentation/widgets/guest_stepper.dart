import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';

/// A labelled +/- stepper row (`16 · Stay dates & available rooms`, the "عدد
/// الضيوف" sheet). Buttons disable at the supplied bounds.
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
        IconButton.outlined(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
          tooltip: '${l10n.stepperDecrease} — $label',
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton.outlined(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
          tooltip: '${l10n.stepperIncrease} — $label',
        ),
      ],
    );
  }
}
