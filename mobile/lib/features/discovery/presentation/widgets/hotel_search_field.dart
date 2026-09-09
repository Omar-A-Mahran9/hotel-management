import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icons.dart';

/// The rounded search field from `02 · Discover & Book` — a search icon, the
/// field, an optional clear button and an optional trailing filter/sort button.
///
/// On the discover screen it is read-only ([onTap] navigates to the search
/// screen); on the search screen it is a live [TextField].
class HotelSearchField extends StatelessWidget {
  const HotelSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.onClear,
    this.onFilterTap,
    this.filterBadgeCount = 0,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final int filterBadgeCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final bool hasText = (controller?.text ?? '').isNotEmpty;

    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            autofocus: autofocus,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.discoverSearchHint,
              prefixIcon: const Icon(AppIcons.search, size: 20),
              suffixIcon: hasText && onClear != null
                  ? IconButton(
                      icon: const Icon(AppIcons.close, size: 18),
                      tooltip: l10n.searchClearTooltip,
                      onPressed: onClear,
                    )
                  : null,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.allPill,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.allPill,
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.allPill,
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...<Widget>[
          const SizedBox(width: AppSpacing.xs),
          _FilterButton(count: filterBadgeCount, onTap: onFilterTap!),
        ],
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Tooltip(
      message: context.l10n.filterTitle,
      child: InkWell(
        borderRadius: AppRadius.allPill,
        onTap: onTap,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                AppIcons.filter,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
              if (count > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
