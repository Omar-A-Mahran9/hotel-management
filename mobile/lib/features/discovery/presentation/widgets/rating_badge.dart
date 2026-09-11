import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icons.dart';

/// The compact `4.96 🏅` badge overlaid on the top-start corner of a hotel image
/// in the Home grid (`HOME_Default`). A darker scrim so it reads on any photo.
///
/// Distinct from `RatingPill`, which is the inline, review-count variant used on
/// the detail screens.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: AppPrimitives.stone900.withValues(alpha: 0.55),
        borderRadius: AppRadius.allPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.l10n.hotelRatingValue(rating),
            style: AppTypography.labelStrong(AppPrimitives.white),
          ),
          const SizedBox(width: AppSpacing.space1),
          const Icon(AppIcons.rating, size: 13, color: AppPrimitives.gold300),
        ],
      ),
    );
  }
}
