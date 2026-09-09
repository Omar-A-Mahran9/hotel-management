import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/access_grant.dart';
import '../../../../core/widgets/app_icons.dart';

/// The brown room-number + entry-code card from `04 · Check in & Stay`.
///
/// SECURITY: renders the credential **only** when the grant is active
/// ([AccessGrant.visibleCredential]); the value is never logged and never
/// persisted. When the mode is not a PIN code, or no room number is available,
/// the corresponding row is simply omitted rather than faked.
class AccessCredentialCard extends StatelessWidget {
  const AccessCredentialCard({super.key, required this.grant});

  final AccessGrant grant;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final String? code = grant.visibleCredential;

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
          if (grant.roomNumber != null) ...<Widget>[
            Text(
              l10n.accessRoomNumberLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.bronze200,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              grant.roomNumber!,
              style: theme.textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            const Divider(height: AppSpacing.xl, color: AppColors.brown500),
          ],
          if (code != null) ...<Widget>[
            Text(
              l10n.accessEntryCodeLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.bronze200,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              code.split('').join(' '),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (grant.expiresAt != null)
            Row(
              children: <Widget>[
                const Icon(AppIcons.time, size: 15, color: AppColors.bronze200),
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    l10n.accessExpiresLabel(
                      ml.formatMediumDate(grant.expiresAt!),
                    ),
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
