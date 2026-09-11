import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// A screen section title with an optional trailing "عرض الكل" action
/// (`HOME_Default`). Figma "Section Header".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                context.l10n.commonSeeAll,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
