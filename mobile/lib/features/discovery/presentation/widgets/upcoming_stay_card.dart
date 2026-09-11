import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/upcoming_stay.dart';
import 'hotel_thumbnail.dart';

/// The `إقامتك القادمة` card at the top of the Home screen (`HOME_Default`).
class UpcomingStayCard extends StatelessWidget {
  const UpcomingStayCard({super.key, required this.stay, required this.onTap});

  final UpcomingStay stay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
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
                  stay.roomName.resolve(locale),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space1),
                Row(
                  children: <Widget>[
                    Icon(AppIcons.location, size: 13, color: c.textSecondary),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${stay.hotelName.resolve(locale)} · ${stay.cityName.resolve(locale)}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    MoneyText(
                      stay.nightlyRate.amount,
                      suffix: l10n.priceNightSuffix,
                      markSize: 13,
                    ),
                    const Spacer(),
                    if (stay.isAvailable)
                      StatusPill(
                        label: l10n.hotelAvailable,
                        foreground: c.successFg,
                        background: c.successBg,
                        icon: AppIcons.shieldCheck,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          HotelThumbnail(seed: stay.reservationId, width: 76, height: 76),
        ],
      ),
    );
  }
}
