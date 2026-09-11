import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// One row of a [BookingTimelineCard].
class BookingTimelineRow {
  const BookingTimelineRow({required this.title, this.subtitle, this.filled = false});

  final String title;
  final String? subtitle;

  /// A filled dot marks the row the guest's booking is currently "at" — the
  /// step already reached or in progress. Later rows show a hollow dot.
  final bool filled;
}

/// The "حالة الدفع" vertical stepper on the booking-detail screen (all six
/// `BOOKING_Detail_*` boards): a heading, then up to three dot-and-text rows.
/// The dot column is pinned LTR regardless of the app's reading direction —
/// Figma keeps the timeline's chronological axis fixed the same way a date
/// axis would be, independent of text direction.
class BookingTimelineCard extends StatelessWidget {
  const BookingTimelineCard({super.key, required this.rows});

  final List<BookingTimelineRow> rows;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppColorTokens c = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.bookingPaymentStatusHeading, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < rows.length; i++)
            Row(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rows[i].filled ? c.accentWarmFg : c.borderDefault,
                      ),
                    ),
                    if (i != rows.length - 1)
                      Container(width: 1, height: 34, color: c.borderDefault),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          rows[i].title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: rows[i].filled ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        if (rows[i].subtitle != null)
                          Text(rows[i].subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
