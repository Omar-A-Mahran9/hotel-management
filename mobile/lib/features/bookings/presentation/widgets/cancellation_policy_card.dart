import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// The "سياسة الإلغاء" card shown on every `BOOKING_Detail_*` state — static
/// policy copy (the MVP has no per-reservation cancellation-fee rule; see
/// `ReservationService`'s own note that cancellation penalties are not yet
/// implemented, so "free within the window" is the accurate, not invented,
/// policy).
class CancellationPolicyCard extends StatelessWidget {
  const CancellationPolicyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.bookingCancellationPolicyHeading,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.bookingCancellationPolicyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
