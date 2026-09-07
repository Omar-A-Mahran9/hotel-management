import 'package:flutter/foundation.dart';

/// Strips any time component, keeping the local calendar day.
DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// A confirmed check-in / check-out pair (`16 · Stay dates & available rooms`).
///
/// Both dates are calendar days (no time component). This is a plain value that
/// later phases (reservations, availability API) consume — it carries no booking
/// policy such as a minimum stay or an advance-booking window, none of which the
/// design defines.
@immutable
class StayRange {
  StayRange({required DateTime checkIn, required DateTime checkOut})
      : checkIn = dateOnly(checkIn),
        checkOut = dateOnly(checkOut);

  final DateTime checkIn;
  final DateTime checkOut;

  /// Number of nights between the two dates. Always `>= 1` for a valid range.
  int get nights => checkOut.difference(checkIn).inDays;

  @override
  bool operator ==(Object other) =>
      other is StayRange &&
      other.checkIn == checkIn &&
      other.checkOut == checkOut;

  @override
  int get hashCode => Object.hash(checkIn, checkOut);

  @override
  String toString() =>
      'StayRange(${checkIn.toIso8601String()} → ${checkOut.toIso8601String()})';
}
