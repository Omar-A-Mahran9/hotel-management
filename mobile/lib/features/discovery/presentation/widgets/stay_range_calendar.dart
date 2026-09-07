import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/stay_range.dart';

/// An inline month-by-month range calendar (`16 · Stay dates & available
/// rooms`). Deliberately small: [monthCount] months forward from [firstDay],
/// range selection driven entirely by [onSelectDay] taps.
///
/// All day / month / weekday text comes from [MaterialLocalizations], so it
/// renders in Arabic and lays out right-to-left with no extra work.
class StayRangeCalendar extends StatelessWidget {
  const StayRangeCalendar({
    super.key,
    required this.firstDay,
    required this.checkIn,
    required this.checkOut,
    required this.onSelectDay,
    this.monthCount = 4,
  });

  final DateTime firstDay;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final ValueChanged<DateTime> onSelectDay;
  final int monthCount;

  @override
  Widget build(BuildContext context) {
    final DateTime start = DateTime(firstDay.year, firstDay.month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _WeekdayHeader(),
        const SizedBox(height: AppSpacing.xs),
        for (int i = 0; i < monthCount; i++) ...<Widget>[
          _MonthGrid(
            month: DateTime(start.year, start.month + i),
            firstSelectableDay: dateOnly(firstDay),
            checkIn: checkIn,
            checkOut: checkOut,
            onSelectDay: onSelectDay,
          ),
          if (i != monthCount - 1) const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

List<int> _weekdayOrder(BuildContext context) {
  final int first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  return <int>[for (int i = 0; i < 7; i++) (first + i) % 7];
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        for (final int weekday in _weekdayOrder(context))
          Expanded(
            child: Center(
              child: Text(
                ml.narrowWeekdays[weekday],
                style: theme.textTheme.labelMedium,
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.firstSelectableDay,
    required this.checkIn,
    required this.checkOut,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime firstSelectableDay;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final List<int> order = _weekdayOrder(context);
    final int firstWeekday = DateTime(month.year, month.month).weekday % 7;
    final int leadingBlanks = order.indexOf(firstWeekday);

    final List<Widget> cells = <Widget>[
      for (int i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (int day = 1; day <= daysInMonth; day++)
        _DayCell(
          date: DateTime(month.year, month.month, day),
          firstSelectableDay: firstSelectableDay,
          checkIn: checkIn,
          checkOut: checkOut,
          onSelectDay: onSelectDay,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ml.formatMonthYear(month),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: cells,
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.firstSelectableDay,
    required this.checkIn,
    required this.checkOut,
    required this.onSelectDay,
  });

  final DateTime date;
  final DateTime firstSelectableDay;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final ValueChanged<DateTime> onSelectDay;

  bool get _isDisabled => date.isBefore(firstSelectableDay);
  bool _isSame(DateTime? other) => other != null && DateUtils.isSameDay(date, other);
  bool get _inRange =>
      checkIn != null &&
      checkOut != null &&
      date.isAfter(checkIn!) &&
      date.isBefore(checkOut!);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final bool isEndpoint = _isSame(checkIn) || _isSame(checkOut);

    final Color? background = isEndpoint
        ? theme.colorScheme.primary
        : _inRange
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : null;
    final Color foreground = isEndpoint
        ? theme.colorScheme.onPrimary
        : _isDisabled
            ? theme.disabledColor
            : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: background ?? Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.allSm),
        child: InkWell(
          borderRadius: AppRadius.allSm,
          onTap: _isDisabled ? null : () => onSelectDay(date),
          child: Semantics(
            selected: isEndpoint,
            label: ml.formatFullDate(date),
            child: Center(
              child: Text(
                ml.formatDecimal(date.day),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: isEndpoint ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
