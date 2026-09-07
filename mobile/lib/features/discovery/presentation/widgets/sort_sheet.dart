import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/hotel_sort.dart';
import '../discovery_l10n.dart';
import 'sheet_scaffold.dart';

/// `15 · Search, filters & sort` — "ترتيب النتائج". Returns the chosen
/// [HotelSort], or `null` if dismissed.
Future<HotelSort?> showSortSheet(
  BuildContext context, {
  required HotelSort current,
}) {
  return showModalBottomSheet<HotelSort>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) => _SortSheet(current: current),
  );
}

class _SortSheet extends StatefulWidget {
  const _SortSheet({required this.current});

  final HotelSort current;

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late HotelSort _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SheetScaffold(
      title: l10n.sortTitle,
      body: <Widget>[
        InfoBanner(tone: InfoBannerTone.info, title: l10n.sortHint),
        const SizedBox(height: AppSpacing.md),
        RadioGroup<HotelSort>(
          groupValue: _selected,
          onChanged: (HotelSort? value) =>
              setState(() => _selected = value ?? _selected),
          child: Column(
            children: <Widget>[
              for (final HotelSort sort in HotelSort.values)
                RadioListTile<HotelSort>(
                  value: sort,
                  title: Text(l10n.hotelSortLabel(sort)),
                  secondary:
                      _selected == sort ? Text(l10n.sortActiveTag) : null,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ],
      footer: PrimaryButton(
        label: l10n.sortApply,
        onPressed: () => Navigator.of(context).pop(_selected),
      ),
    );
  }
}
