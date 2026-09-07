import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/available_room.dart';
import '../discovery_l10n.dart';
import 'hotel_thumbnail.dart';

/// A room row in the available-rooms list (`16 · Stay dates & available
/// rooms`). Sold-out rooms are dimmed and carry a "not available" note; the
/// booking CTA is out of scope for this phase (it belongs to reservations).
class RoomSummaryCard extends StatelessWidget {
  const RoomSummaryCard({
    super.key,
    required this.room,
    required this.nights,
  });

  final AvailableRoom room;
  final int nights;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final Locale locale = Localizations.localeOf(context);
    final bool dim = !room.isAvailable;

    return Opacity(
      opacity: dim ? 0.55 : 1,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HotelThumbnail(
                  seed: room.roomType.id,
                  width: 72,
                  height: 72,
                  icon: Icons.king_bed_outlined,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        room.roomType.name.resolve(locale),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        room.roomType.description.resolve(locale),
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: <Widget>[
                _Spec(icon: Icons.person_outline, label: l10n.roomOccupancy(room.roomType.maxOccupancy)),
                _Spec(icon: Icons.king_bed_outlined, label: room.roomType.bedType.resolve(locale)),
                for (final amenity in room.roomType.amenities)
                  _Spec(icon: Icons.check, label: l10n.roomAmenityLabel(amenity)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                if (room.roomType.breakfastIncluded)
                  _Tag(label: l10n.roomBreakfastIncluded, tone: _TagTone.positive),
                if (room.roomType.breakfastIncluded) const SizedBox(width: AppSpacing.xxs),
                _Tag(
                  label: room.roomType.refundable
                      ? l10n.roomFreeCancellation
                      : l10n.roomNonRefundable,
                  tone: room.roomType.refundable ? _TagTone.positive : _TagTone.neutral,
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            if (dim)
              Text(
                l10n.roomSoldOut,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    l10n.pricePerNight(room.nightlyRate.amount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.extension<AppSemanticColors>()?.accent ??
                          AppColors.bronze500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.priceStayTotal(room.stayTotal(nights).amount),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: theme.colorScheme.outline),
        const SizedBox(width: 2),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

enum _TagTone { positive, neutral }

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.tone});

  final String label;
  final _TagTone tone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;
    final (Color fg, Color bg) = switch (tone) {
      _TagTone.positive => (semantic.success, semantic.successContainer),
      _TagTone.neutral => (theme.colorScheme.onSurface, theme.colorScheme.surfaceContainerHighest),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.allSm),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}
