import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_icons.dart';

/// Tone of an [InfoBanner], mapped to the design system's semantic containers.
enum InfoBannerTone { info, success, warning, error }

/// Tinted, rounded message block with a leading icon badge — the canonical
/// Figma pattern for **success / error / warning / info** notices and for the
/// header block on result screens (`تم التحقق وتأكيد حجزك`, `الرمز غير صحيح`,
/// `تعذر رفع الصور`, …).
///
/// Copy is passed in by the caller; the block lays out correctly in RTL and
/// LTR. For a result screen, pass [child] (details) and/or use
/// `BottomActionBar` for the actions beneath it.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.tone,
    required this.title,
    this.message,
    this.child,
    this.dense = false,
  });

  final InfoBannerTone tone;
  final String title;
  final String? message;

  /// Optional extra content rendered below the message (e.g. a reference code,
  /// a small summary row) — used by result screens.
  final Widget? child;

  /// Tighter padding for inline use inside lists.
  final bool dense;

  static ({Color fg, IconData icon}) _spec(
    InfoBannerTone tone,
    AppSemanticColors semantic,
    ColorScheme scheme,
  ) {
    return switch (tone) {
      InfoBannerTone.info => (fg: semantic.info, icon: AppIcons.info),
      InfoBannerTone.success => (fg: semantic.success, icon: AppIcons.success),
      InfoBannerTone.warning => (fg: semantic.warning, icon: AppIcons.warning),
      InfoBannerTone.error => (fg: scheme.error, icon: AppIcons.error),
    };
  }

  Color _bg(AppSemanticColors semantic) => switch (tone) {
    InfoBannerTone.info => semantic.infoContainer,
    InfoBannerTone.success => semantic.successContainer,
    InfoBannerTone.warning => semantic.warningContainer,
    InfoBannerTone.error => AppColors.errorContainer,
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;
    final spec = _spec(tone, semantic, theme.colorScheme);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: _bg(semantic),
        borderRadius: AppRadius.allLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _IconBadge(color: spec.fg, icon: spec.icon, dense: dense),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(color: spec.fg),
                ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
                if (child != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  child!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.color,
    required this.icon,
    required this.dense,
  });

  final Color color;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final double size = dense ? 22 : 28;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: dense ? 14 : 18, color: color),
    );
  }
}
