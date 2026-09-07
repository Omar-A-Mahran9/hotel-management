import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Tone of an [InfoBanner], mapped to the design system's semantic containers.
enum InfoBannerTone { info, warning, error }

/// Tinted, rounded message block with a leading icon — the pattern used for the
/// "write your name as on your ID", "incorrect code" and "session ended" notices
/// in `09 · Authentication`. Copy is passed in by the caller
/// (architecture.md §9); it lays out correctly in RTL and LTR.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.tone,
    required this.title,
    this.message,
  });

  final InfoBannerTone tone;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (Color fg, Color bg, IconData icon) = switch (tone) {
      InfoBannerTone.info => (
          semantic.info,
          semantic.infoContainer,
          Icons.info_outline,
        ),
      InfoBannerTone.warning => (
          semantic.warning,
          semantic.warningContainer,
          Icons.schedule_outlined,
        ),
      InfoBannerTone.error => (
          theme.colorScheme.error,
          AppColors.errorContainer,
          Icons.error_outline,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.allMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(color: fg),
                ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(message!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
