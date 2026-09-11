import 'package:flutter/foundation.dart';

import 'localized_text.dart';
import 'money.dart';

/// The guest's next confirmed stay, shown as the `إقامتك القادمة` card at the top
/// of the Home screen (`HOME_Default` mockup).
///
/// This is a display snapshot only. The authoritative reservation lives in the
/// reservations feature / Laravel; the discovery dummy layer supplies one so the
/// Home card can be built. `reservationId` links the card to its reservation
/// screen.
@immutable
class UpcomingStay {
  const UpcomingStay({
    required this.reservationId,
    required this.roomName,
    required this.hotelName,
    required this.cityName,
    required this.nightlyRate,
    required this.isAvailable,
  });

  final String reservationId;
  final LocalizedText roomName;
  final LocalizedText hotelName;
  final LocalizedText cityName;
  final Money nightlyRate;

  /// Whether the stay is still active/holdable — drives the `متاحة` pill.
  final bool isAvailable;

  @override
  bool operator ==(Object other) =>
      other is UpcomingStay &&
      other.reservationId == reservationId &&
      other.roomName == roomName &&
      other.hotelName == hotelName &&
      other.cityName == cityName &&
      other.nightlyRate == nightlyRate &&
      other.isAvailable == isAvailable;

  @override
  int get hashCode => Object.hash(
        reservationId,
        roomName,
        hotelName,
        cityName,
        nightlyRate,
        isAvailable,
      );
}
