import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/loyalty_account.dart';
import '../../../../core/widgets/app_icons.dart';

/// The brown points-balance card (`14 · Entry, loyalty & completion`). Shows the
/// **backend** balance and the group-wide copy — no tier, no rate, no
/// conversion (none exist in the MVP).
class LoyaltyBalanceCard extends StatelessWidget {
  const LoyaltyBalanceCard({super.key, required this.account});

  final LoyaltyAccount account;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brown700,
        borderRadius: AppRadius.allLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.loyaltyBalanceLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.bronze200,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.loyaltyPointsValue(account.pointsBalance),
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(AppIcons.guests, size: 15, color: AppColors.bronze200),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  l10n.loyaltyGroupWideNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.bronze200,
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
