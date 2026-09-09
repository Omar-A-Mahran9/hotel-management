import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Surface container from the design system: white/surface, rounded, with a soft
/// warm shadow. Matches the Figma cards, which are **borderless** — the hairline
/// [border] is opt-in for the few list-container cards that show one.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.border = true,
    this.shadow = true,
    this.color,
    this.radius = AppRadius.allCard,
  });

  /// A card with no inner padding — for list containers that draw their own row
  /// insets and dividers.
  const AppCard.list({
    super.key,
    required this.child,
    this.onTap,
    this.border = true,
    this.shadow = true,
    this.color,
    this.radius = AppRadius.allCard,
  }) : padding = EdgeInsets.zero;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool border;
  final bool shadow;
  final Color? color;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLight = theme.brightness == Brightness.light;

    final Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: radius,
        border: border ? Border.all(color: theme.colorScheme.outline) : null,
        boxShadow: (shadow && isLight) ? AppShadows.card : AppShadows.none,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;

    return Material(
      color: AppColors.white.withValues(alpha: 0),
      borderRadius: radius,
      child: InkWell(borderRadius: radius, onTap: onTap, child: content),
    );
  }
}
