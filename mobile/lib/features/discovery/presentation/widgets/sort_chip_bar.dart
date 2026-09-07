import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/hotel_sort.dart';
import '../discovery_l10n.dart';

/// The quick-sort chip row under the search field (`02 · Discover & Book`).
/// Selecting a chip sets the [HotelSort]; "الأقرب" (nearest) is intentionally
/// absent — it needs the guest's location, which is a later phase.
class SortChipBar extends StatelessWidget {
  const SortChipBar({super.key, required this.selected, required this.onSelected});

  final HotelSort selected;
  final ValueChanged<HotelSort> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final HotelSort sort in HotelSort.values) ...<Widget>[
            ChoiceChip(
              label: Text(l10n.hotelSortLabel(sort)),
              selected: selected == sort,
              onSelected: (_) => onSelected(sort),
            ),
            if (sort != HotelSort.values.last)
              const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
