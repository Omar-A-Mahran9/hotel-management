import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import 'app_icons.dart';

/// Tone of an [InfoBanner], mapped to the design system's `color/state/*` set.
enum InfoBannerTone { info, success, warning, error }

/// Tinted, rounded message block with a leading icon badge — the canonical
/// Figma pattern for **success / error / warning / info** notices and for the
/// header block on result screens (`تم التحقق وتأكيد حجزك`, `الرمز غير صحيح`,
/// `تعذر رفع الصور`, …). Also covers the `Toast` component's tones.
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

  ({Color fg, Color bg, Color border, IconData icon}) _spec(
    AppColorTokens c,
  ) {
    return switch (tone) {
      InfoBannerTone.info => (
        fg: c.infoFg,
        bg: c.infoBg,
        border: c.infoBorder,
        icon: AppIcons.info,
      ),
      InfoBannerTone.success => (
        fg: c.successFg,
        bg: c.successBg,
        border: c.successBorder,
        icon: AppIcons.success,
      ),
      InfoBannerTone.warning => (
        fg: c.warningFg,
        bg: c.warningBg,
        border: c.warningBorder,
        icon: AppIcons.warning,
      ),
      InfoBannerTone.error => (
        fg: c.errorFg,
        bg: c.errorBg,
        border: c.errorBorder,
        icon: AppIcons.error,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColorTokens c = context.colors;
    final spec = _spec(c);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        dense ? AppSpacing.space3 : AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: AppRadius.allLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _IconBadge(
            fill: spec.border,
            iconColor: spec.fg,
            icon: spec.icon,
            dense: dense,
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(color: spec.fg),
                ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                ],
                if (child != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.space3),
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
    required this.fill,
    required this.iconColor,
    required this.icon,
    required this.dense,
  });

  final Color fill;
  final Color iconColor;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final double size = dense
        ? AppIconSizes.badgeDense
        : AppIconSizes.badge;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: Icon(
        icon,
        size: dense ? AppIconSizes.iconSm : AppIconSizes.icon,
        color: iconColor,
      ),
    );
  }
}
