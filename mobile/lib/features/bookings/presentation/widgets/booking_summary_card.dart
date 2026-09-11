import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../reservation/domain/entities/reservation.dart';
import 'booking_status_pill.dart';

import '../../../../core/time/stay_date_format.dart';

/// The top hotel/dates/status/price block shared by every
/// `BOOKING_Detail_*.png` state.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final String dateRange = formatStayDateRange(locale, reservation.stay);

    return AppCard(
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
                    Text(
                      reservation.hotelName.resolve(locale),
                      style: theme.textTheme.titleMedium,
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
                          Text(reservation.hotelCity!, style: theme.textTheme.bodySmall),
                        ],
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
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              BookingStatusPill(status: reservation.status),
              const Spacer(),
              MoneyText(reservation.priceSnapshot.amount, style: theme.textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
