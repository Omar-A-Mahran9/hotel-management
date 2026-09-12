import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icons.dart';

/// The compact `4.96 🏅` badge under a hotel image in the Home grid
/// (`HOME_Default`'s "Stacked" listing-card layout — `design-system-tokens.md`
/// §9 `Listing Card` `Layout` axis). Sits on the card's own surface, so it uses
/// the light `accentWarm` pair rather than a photo-scrim.
///
/// Distinct from `RatingPill`, which is the inline, review-count variant used on
/// the detail screens.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final AppColorTokens c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: c.accentWarmBg,
        borderRadius: AppRadius.allPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.l10n.hotelRatingValue(rating),
            style: AppTypography.labelStrong(c.accentWarmFg),
          ),
          const SizedBox(width: AppSpacing.space1),
          Icon(AppIcons.rating, size: 13, color: c.accentWarm),
        ],
      ),
    );
  }
}
