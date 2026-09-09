import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icons.dart';

/// The three-step progress header for the verification flow: Document → Selfie →
/// Result. Direction-agnostic (lays out correctly in RTL and LTR).
enum IdentityStep { document, selfie, result }

class IdentityStepIndicator extends StatelessWidget {
  const IdentityStepIndicator({super.key, required this.current});

  final IdentityStep current;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final List<(IdentityStep, String)> steps = <(IdentityStep, String)>[
      (IdentityStep.document, l10n.identityStepDocument),
      (IdentityStep.selfie, l10n.identityStepSelfie),
      (IdentityStep.result, l10n.identityStepResult),
    ];

    return Row(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++) ...<Widget>[
          _Dot(
            index: i + 1,
            label: steps[i].$2,
            done: steps[i].$1.index < current.index,
            active: steps[i].$1 == current,
            accent: semantic.accent,
            muted: theme.colorScheme.outlineVariant,
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                color: steps[i].$1.index < current.index
                    ? semantic.accent
                    : theme.colorScheme.outlineVariant,
              ),
            ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.index,
    required this.label,
    required this.done,
    required this.active,
    required this.accent,
    required this.muted,
  });

  final int index;
  final String label;
  final bool done;
  final bool active;
  final Color accent;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fill = done || active ? accent : Colors.transparent;
    final Color border = done || active ? accent : muted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(AppIcons.check, size: 15, color: AppColors.white)
              : Text(
                  '$index',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: active ? AppColors.white : muted,
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
