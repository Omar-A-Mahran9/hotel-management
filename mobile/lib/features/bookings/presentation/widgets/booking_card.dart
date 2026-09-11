import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/stay_date_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../reservation/domain/entities/reservation.dart';
import 'booking_status_pill.dart';

/// One row in the Bookings list (`BOOKINGS_List_Current.png` /
/// `BOOKINGS_List_Past.png`): hotel name, dates, a coarse status pill, the
/// price and a thumbnail.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.reservation, this.onTap});

  final Reservation reservation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final String dateRange = formatStayDateRange(locale, reservation.stay);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  reservation.hotelName.resolve(locale),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: <Widget>[
                    Text(dateRange, style: theme.textTheme.bodySmall),
                    if (reservation.hotelCity != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        AppIcons.location,
                        size: 14,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        reservation.hotelCity!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    BookingStatusPill(status: reservation.status),
                    const SizedBox(width: AppSpacing.sm),
                    MoneyText(reservation.priceSnapshot.amount),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppImage.network(
            url: reservation.hotelImageUrl,
            width: 64,
            height: 64,
            borderRadius: AppRadius.allMd,
          ),
        ],
      ),
    );
  }
}
