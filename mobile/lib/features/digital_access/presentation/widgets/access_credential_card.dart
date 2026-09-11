import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../domain/entities/access_grant.dart';

/// The brown room-number + entry-code card from `04 · Check in & Stay`. Built on
/// the `Card` component's `inverse` style.
///
/// SECURITY: renders the credential **only** when the grant is active
/// ([AccessGrant.visibleCredential]); the value is never logged and never
/// persisted. When the mode is not a PIN code, or no room number is available,
/// the corresponding row is simply omitted rather than faked.
class AccessCredentialCard extends StatelessWidget {
  const AccessCredentialCard({super.key, required this.grant, this.roomNumber});

  final AccessGrant grant;

  /// The reservation's authoritative allocated room number
  /// (`Reservation.roomNumber`), when known — preferred over
  /// [AccessGrant.roomNumber], which the API data source leaves `null`
  /// (documented gap; the dummy source is the only one that ever sets it).
  final String? roomNumber;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppColorTokens c = context.colors;
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final String? code = grant.visibleCredential;
    final String? shownRoomNumber = roomNumber ?? grant.roomNumber;

    final TextStyle? labelStyle =
        theme.textTheme.bodySmall?.copyWith(color: c.accentWarm);

    return AppCard(
      style: AppCardStyle.inverse,
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (shownRoomNumber != null) ...<Widget>[
            Text(l10n.accessRoomNumberLabel, style: labelStyle),
            const SizedBox(height: AppSpacing.space1),
            Text(
              shownRoomNumber,
              style: theme.textTheme.displaySmall?.copyWith(
                color: c.textOnInverse,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            Divider(
              height: AppSpacing.space6,
              color: c.borderOnInverse.withValues(alpha: 0.2),
            ),
          ],
          if (code != null) ...<Widget>[
            Text(l10n.accessEntryCodeLabel, style: labelStyle),
            const SizedBox(height: AppSpacing.space2),
            Text(
              code.split('').join(' '),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: c.textOnInverse,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
          ],
          if (grant.expiresAt != null)
            Row(
              children: <Widget>[
                Icon(AppIcons.time, size: 15, color: c.accentWarm),
                const SizedBox(width: AppSpacing.space1),
                Flexible(
                  child: Text(
                    l10n.accessExpiresLabel(
                      ml.formatMediumDate(grant.expiresAt!),
                    ),
                    style: labelStyle,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
