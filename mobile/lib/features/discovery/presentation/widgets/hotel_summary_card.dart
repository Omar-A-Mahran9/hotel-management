import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/hotel_summary.dart';
import 'hotel_thumbnail.dart';
import 'rating_pill.dart';

/// A hotel card for the discover grid and the search-result list
/// (`02 · Discover & Book`). Lays out correctly in both text directions.
class HotelSummaryCard extends StatelessWidget {
  const HotelSummaryCard({
    super.key,
    required this.hotel,
    required this.onTap,
    this.layout = HotelCardLayout.row,
  });

  final HotelSummary hotel;
  final VoidCallback onTap;
  final HotelCardLayout layout;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      HotelCardLayout.row => _RowCard(hotel: hotel, onTap: onTap),
      HotelCardLayout.tile => _TileCard(hotel: hotel, onTap: onTap),
    };
  }
}

enum HotelCardLayout { row, tile }

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppSemanticColors semantic = Theme.of(context)
            .extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    return StatusPill(
      label: isAvailable ? l10n.hotelAvailable : l10n.hotelUnavailable,
      foreground: isAvailable ? semantic.success : Theme.of(context).colorScheme.error,
      background: isAvailable
          ? semantic.successContainer
          : AppColors.errorContainer,
      icon: isAvailable ? Icons.check_circle : Icons.pause_circle_filled,
    );
  }
}

class _PriceFrom extends StatelessWidget {
  const _PriceFrom({required this.hotel});

  final HotelSummary hotel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      context.l10n.priceFrom(hotel.nightlyRateFrom.amount),
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.extension<AppSemanticColors>()?.accent ?? AppColors.bronze500,
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.hotel, required this.onTap});

  final HotelSummary hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HotelThumbnail(seed: hotel.id, width: 84, height: 84),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hotel.name.resolve(locale),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  hotel.cityName.resolve(locale),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    _AvailabilityBadge(isAvailable: hotel.isAvailable),
                    const Spacer(),
                    _PriceFrom(hotel: hotel),
                  ],
                ),
                if (hotel.rating != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  RatingPill(rating: hotel.rating!, reviewCount: hotel.reviewCount),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileCard extends StatelessWidget {
  const _TileCard({required this.hotel, required this.onTap});

  final HotelSummary hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HotelThumbnail(
            seed: hotel.id,
            height: 104,
            width: double.infinity,
            borderRadius: AppRadius.allMd,
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hotel.name.resolve(locale),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(hotel.cityName.resolve(locale), style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                if (hotel.rating != null)
                  RatingPill(rating: hotel.rating!, reviewCount: hotel.reviewCount),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    _AvailabilityBadge(isAvailable: hotel.isAvailable),
                    const Spacer(),
                    _PriceFrom(hotel: hotel),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
