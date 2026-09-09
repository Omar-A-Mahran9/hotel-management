import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icons.dart';

/// The "★ 4.96" rating chip from the hotel cards and detail header.
class RatingPill extends StatelessWidget {
  const RatingPill({super.key, required this.rating, this.reviewCount});

  final double rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.bronze200.withValues(alpha: 0.45),
        borderRadius: AppRadius.allPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(AppIcons.rating, size: 14, color: AppColors.bronze400),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              reviewCount == null
                  ? l10n.hotelRatingValue(rating)
                  : '${l10n.hotelRatingValue(rating)} · ${l10n.hotelReviewCount(reviewCount!)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.bronze500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
