import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/entities/available_room.dart';
import '../discovery_l10n.dart';
import 'hotel_thumbnail.dart';
import '../../../../core/widgets/app_icons.dart';

/// A room row in the available-rooms list (`16 · Stay dates & available
/// rooms`): thumbnail, name + description, two spec lines, status/policy pills,
/// a divider, then "View details" and the price block.
///
/// Selection happens on the room-detail screen, not here — a selected room is
/// marked with a brown border and a "Selected" pill. Sold-out rooms are dimmed,
/// carry a red "not available" pill and disable the action.
class RoomSummaryCard extends StatelessWidget {
  const RoomSummaryCard({
    super.key,
    required this.room,
    required this.nights,
    required this.selected,
    required this.onViewDetails,
    this.showStayTotal = true,
  });

  final AvailableRoom room;
  final int nights;
  final bool selected;
  final VoidCallback onViewDetails;

  /// Whether to show the "× N nights" stay total under the nightly rate. Off on
  /// the single-hotel Home list where no dates are chosen yet.
  final bool showStayTotal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final Locale locale = Localizations.localeOf(context);
    final AppColorTokens colors = context.colors;
    final bool soldOut = !room.isAvailable;

    final List<String> specs1 = <String>[
      l10n.roomOccupancy(room.roomType.maxOccupancy),
      room.roomType.bedType.resolve(locale),
    ];
    final List<String> specs2 = <String>[
      for (final amenity in room.roomType.amenities)
        l10n.roomAmenityLabel(amenity),
      if (room.roomType.breakfastIncluded) l10n.amenityBreakfast,
    ];

    return Opacity(
      opacity: soldOut ? 0.6 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.allLg,
          border: selected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          onTap: soldOut ? null : onViewDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                room.roomType.name.resolve(locale),
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            if (selected) ...<Widget>[
                              const SizedBox(width: AppSpacing.xs),
                              _Pill(
                                label: l10n.roomSelected,
                                foreground: theme.colorScheme.onPrimary,
                                background: theme.colorScheme.primary,
                                icon: AppIcons.check,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          room.roomType.description.resolve(locale),
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          specs1.join('  ·  '),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (specs2.isNotEmpty)
                          Text(
                            specs2.join('  ·  '),
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  HotelThumbnail(
                    seed: room.roomType.id,
                    width: 84,
                    height: 84,
                    icon: AppIcons.bed,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: <Widget>[
                  if (soldOut)
                    _Pill(
                      label: l10n.roomSoldOut,
                      foreground: colors.errorFg,
                      background: colors.errorBg,
                      icon: AppIcons.close,
                    )
                  else
                    _Pill(
                      label: l10n.hotelAvailable,
                      foreground: colors.successFg,
                      background: colors.successBg,
                      icon: AppIcons.shieldCheck,
                    ),
                  if (room.roomType.refundable)
                    _Pill(
                      label: l10n.roomFreeCancellation,
                      foreground: theme.colorScheme.onSurface,
                      background: theme.colorScheme.surfaceContainerHighest,
                    ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // Price leads (trailing edge in the reference), the action
                  // sits opposite it.
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MoneyText(
                          room.nightlyRate.amount,
                          suffix: l10n.priceNightSuffix,
                          semanticsLabel: l10n.pricePerNight(
                            room.nightlyRate.amount,
                          ),
                        ),
                        if (showStayTotal)
                          Text(
                            '${l10n.priceStayTotal(room.stayTotal(nights).amount)} ${l10n.roomStayTotalLabel(nights)}',
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: soldOut ? null : onViewDetails,
                    style: _compactButtonStyle,
                    child: Text(
                      soldOut ? l10n.roomSoldOut : l10n.roomViewDetails,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The design-system pill buttons stretch full-width by default; the room card
/// needs a content-sized button inside a row.
final ButtonStyle _compactButtonStyle = ButtonStyle(
  minimumSize: WidgetStateProperty.all(const Size(0, 44)),
  padding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  ),
);

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.allPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: AppSpacing.space1),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
