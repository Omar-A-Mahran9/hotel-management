import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/hotel_service.dart';

/// One row in the catalogue list (`11 · Services & requests` screen 1): an
/// icon, the service name, a small secondary line (estimate / price) and a
/// chevron. Icon is a design-system Material glyph chosen from the service id —
/// no image assets.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final HotelService service;
  final VoidCallback onTap;

  static IconData iconFor(String serviceId) {
    // Stable per id, from the small set the design uses.
    const List<IconData> icons = <IconData>[
      Icons.cleaning_services_outlined,
      Icons.room_service_outlined,
      Icons.local_laundry_service_outlined,
      Icons.dry_cleaning_outlined,
      Icons.build_outlined,
      Icons.local_taxi_outlined,
      Icons.bedroom_parent_outlined,
    ];
    int hash = 0;
    for (final int u in serviceId.codeUnits) {
      hash = (hash * 31 + u) & 0x7fffffff;
    }
    return icons[hash % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);

    final String secondary = service.price.amount == 0
        ? (service.estimatedMinutes != null
            ? '${l10n.serviceFreeLabel} · ${l10n.serviceEstimatedMinutes(service.estimatedMinutes!)}'
            : l10n.serviceFreeLabel)
        : l10n.pricePerNight(service.price.amount).replaceAll(' / night', '');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(iconFor(service.id),
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(service.name.resolve(locale),
                      style: theme.textTheme.bodyLarge),
                  Text(secondary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: service.price.amount == 0
                            ? (theme.extension<AppSemanticColors>()?.success ??
                                AppColors.success)
                            : theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
