import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../domain/entities/payment.dart';
import 'payment_status_pill.dart';

/// The reservation reference / hotel / stay dates / amount / payment-status
/// recap shown on the payment review and result screens. Amount and currency
/// come from the authoritative [Reservation] price snapshot (mirrored by
/// [payment]); nothing is shown that the backend has not confirmed.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.reservation,
    required this.payment,
  });

  final Reservation reservation;
  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final Locale locale = Localizations.localeOf(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Row(
            label: l10n.paymentReservationLabel,
            value: reservation.reference,
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: l10n.reviewHotelLabel,
            value: reservation.hotelName.resolve(locale),
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: l10n.reviewCheckInLabel,
            value: ml.formatFullDate(reservation.stay.checkIn),
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: l10n.reviewCheckOutLabel,
            value: ml.formatFullDate(reservation.stay.checkOut),
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.paymentStatusFieldLabel,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              PaymentStatusPill(status: payment.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.paymentAmountLabel,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                l10n.moneyAmount(
                  reservation.priceSnapshot.currency,
                  reservation.priceSnapshot.amount,
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.extension<AppSemanticColors>()?.accent ??
                      AppColors.bronze500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 110,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}
