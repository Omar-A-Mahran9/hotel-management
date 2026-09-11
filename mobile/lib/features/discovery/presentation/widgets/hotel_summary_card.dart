import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/hotel_summary.dart';
import 'hotel_thumbnail.dart';
import 'rating_badge.dart';

/// A hotel card for the discover grid (`tile`, `HOME_Default`) and the
/// search-result list (`row`, `SEARCH_Results_Default`). Lays out in both text
/// directions.
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

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColorTokens c = context.colors;
    return StatusPill(
      label: isAvailable ? l10n.hotelAvailable : l10n.hotelUnavailable,
      foreground: isAvailable ? c.successFg : c.errorFg,
      background: isAvailable ? c.successBg : c.errorBg,
      icon: isAvailable ? AppIcons.shieldCheck : AppIcons.close,
    );
  }
}

/// `SEARCH_Results_Default` row: name, city with a pin, price and the `متاحة`
/// pill, with the image on the trailing edge.
class _RowCard extends StatelessWidget {
  const _RowCard({required this.hotel, required this.onTap});

  final HotelSummary hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final AppColorTokens c = context.colors;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(AppIcons.location, size: 13, color: c.textSecondary),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        hotel.cityName.resolve(locale),
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                MoneyText(
                  hotel.nightlyRateFrom.amount,
                  markSize: 13,
                  semanticsLabel: context.l10n.priceFrom(
                    hotel.nightlyRateFrom.amount,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _AvailabilityPill(isAvailable: hotel.isAvailable),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          HotelThumbnail(imageUrl: hotel.coverUrl, width: 92, height: 92),
        ],
      ),
    );
  }
}

/// `HOME_Default` grid tile: photo with the rating badge overlaid, then the
/// name and city. No price / availability — the mockup keeps the tile clean.
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
          Stack(
            children: <Widget>[
              HotelThumbnail(
                imageUrl: hotel.coverUrl,
                height: 116,
                width: double.infinity,
                borderRadius: AppRadius.allMd,
              ),
              if (hotel.rating != null)
                PositionedDirectional(
                  top: AppSpacing.xs,
                  start: AppSpacing.xs,
                  child: RatingBadge(rating: hotel.rating!),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hotel.name.resolve(locale),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hotel.cityName.resolve(locale),
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
