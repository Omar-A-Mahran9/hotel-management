import 'package:flutter/foundation.dart';

import '../../../discovery/domain/entities/guest_party.dart';
import '../../../discovery/domain/entities/localized_text.dart';
import '../../../discovery/domain/entities/money.dart';
import '../../../discovery/domain/entities/stay_range.dart';
import 'reservation_status.dart';

/// A reservation as the guest app knows it.
///
/// Mirrors the fields of the Laravel `ReservationResource` the guest surface
/// needs (`id`, `hotel_id`, `room_type_id`, `room_id`, `check_in`, `check_out`,
/// `status`, `price_snapshot`, `created_at`). Laravel remains authoritative for
/// the status and the price (mobile/docs/architecture.md §6); the app never
/// transitions the status itself.
///
/// [hotelName] / [roomName] are display snapshots carried from the create
/// request so the confirmation screen renders without another round-trip.
///
/// [hotelCity] / [hotelImageUrl] mirror the guest reservation resource's
/// `hotel.city` / `hotel.cover_url` (present once the hotel is eager-loaded).
/// [roomNumber] mirrors `room.room_number` — the physically allocated room,
/// set once one is assigned / at check-in. [nightlyRate] mirrors
/// `room_type.base_price` — the authoritative nightly rate Extend Stay prices
/// from and the Account screen's loyalty-card "per night" figure reads.
@immutable
class Reservation {
  const Reservation({
    required this.id,
    required this.reference,
    required this.hotelId,
    required this.hotelName,
    required this.roomTypeId,
    required this.roomName,
    required this.stay,
    required this.party,
    required this.status,
    required this.priceSnapshot,
    required this.createdAt,
    this.roomId,
    this.hotelCity,
    this.hotelImageUrl,
    this.roomNumber,
    this.nightlyRate,
    this.cancelledAt,
  });

  /// The backend primary key (as a string at the mobile boundary).
  final String id;

  /// A human-facing confirmation code shown to the guest.
  final String reference;

  final String hotelId;
  final LocalizedText hotelName;
  final String roomTypeId;
  final LocalizedText roomName;
  final String? roomId;
  final StayRange stay;
  final GuestParty party;
  final ReservationStatus status;

  /// The authoritative total the backend recorded for this reservation.
  final Money priceSnapshot;
  final DateTime createdAt;

  final String? hotelCity;
  final String? hotelImageUrl;
  final String? roomNumber;
  final Money? nightlyRate;

  /// Mirrors the resource's `cancelled_at` — set only once the reservation is
  /// actually cancelled.
  final DateTime? cancelledAt;

  int get nights => stay.nights;

  @override
  bool operator ==(Object other) =>
      other is Reservation &&
      other.id == id &&
      other.reference == reference &&
      other.hotelId == hotelId &&
      other.hotelName == hotelName &&
      other.roomTypeId == roomTypeId &&
      other.roomName == roomName &&
      other.roomId == roomId &&
      other.stay == stay &&
      other.party == party &&
      other.status == status &&
      other.priceSnapshot == priceSnapshot &&
      other.createdAt == createdAt &&
      other.hotelCity == hotelCity &&
      other.hotelImageUrl == hotelImageUrl &&
      other.roomNumber == roomNumber &&
      other.nightlyRate == nightlyRate &&
      other.cancelledAt == cancelledAt;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        id,
        reference,
        hotelId,
        hotelName,
        roomTypeId,
        roomName,
        roomId,
        stay,
        party,
        status,
        priceSnapshot,
        createdAt,
        hotelCity,
        hotelImageUrl,
        roomNumber,
        nightlyRate,
        cancelledAt,
      ]);

  @override
  String toString() => 'Reservation($reference, ${status.wireValue})';
}
