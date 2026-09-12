// Data-transfer models for the reservation feature.
//
// `ReservationModel` mirrors the Laravel `ReservationResource` shape (id,
// hotel_id, room_type_id, room_id, check_in, check_out, status, price_snapshot,
// created_at). `ReservationCreatePayload.toJson` mirrors the documented
// `StoreReservationRequest` fields. Display-only snapshots (hotel/room names)
// travel alongside the wire model, not inside it.

import '../../../discovery/domain/entities/guest_party.dart';
import '../../../discovery/domain/entities/localized_text.dart';
import '../../../discovery/domain/entities/money.dart';
import '../../../discovery/domain/entities/stay_range.dart';
import '../../domain/entities/create_reservation_request.dart';
import '../../domain/entities/extend_stay.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';

typedef Json = Map<String, Object?>;

String _isoDate(DateTime date) =>
    DateTime(date.year, date.month, date.day).toIso8601String();

/// The request body for `POST /api/v1/reservations`, as far as the documented
/// contract goes. `guest_id` is represented by `guest_reference` until the
/// guest-auth contract exposes a numeric id; `hotel_id` / `status` /
/// `price_snapshot` are backend-derived and deliberately absent.
class ReservationCreatePayload {
  const ReservationCreatePayload({
    required this.roomTypeId,
    required this.roomId,
    required this.guestReference,
    required this.checkIn,
    required this.checkOut,
  });

  factory ReservationCreatePayload.fromRequest(CreateReservationRequest r) =>
      ReservationCreatePayload(
        roomTypeId: r.roomTypeId,
        roomId: r.roomId,
        guestReference: r.guestReference,
        checkIn: r.stay.checkIn,
        checkOut: r.stay.checkOut,
      );

  final String roomTypeId;
  final String? roomId;
  final String guestReference;
  final DateTime checkIn;
  final DateTime checkOut;

  Json toJson() => <String, Object?>{
        'room_type_id': roomTypeId,
        'room_id': roomId,
        'guest_reference': guestReference,
        'check_in': _isoDate(checkIn),
        'check_out': _isoDate(checkOut),
      };
}

/// Parsed `ReservationResource` plus the display snapshots the create request
/// carried through.
class ReservationModel {
  const ReservationModel({
    required this.id,
    required this.reference,
    required this.hotelId,
    required this.roomTypeId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.status,
    required this.priceSnapshot,
    required this.createdAt,
    required this.hotelName,
    required this.roomName,
    this.hotelCity,
    this.hotelImageUrl,
    this.roomNumber,
    this.nightlyRate,
    this.cancelledAt,
  });

  factory ReservationModel.fromJson(
    Json json, {
    required LocalizedText hotelName,
    required LocalizedText roomName,
    required GuestParty party,
  }) {
    final Json? hotel = json['hotel'] as Json?;
    final Json? roomType = json['room_type'] as Json?;
    final Json? room = json['room'] as Json?;
    final String currency = (json['currency'] as String?) ?? Money.fallbackCurrency;

    return ReservationModel(
      id: '${json['id']}',
      reference: (json['reference'] as String?) ?? 'RSV-${json['id']}',
      hotelId: '${json['hotel_id']}',
      roomTypeId: '${json['room_type_id']}',
      roomId: json['room_id'] == null ? null : '${json['room_id']}',
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      adults: (json['adults'] as num?)?.toInt() ?? party.adults,
      children: (json['children'] as num?)?.toInt() ?? party.children,
      status: ReservationStatus.fromWire((json['status'] as String?) ?? 'pending'),
      priceSnapshot: Money(
        amount: _priceAmount(json['price_snapshot']),
        currency: currency,
      ),
      createdAt: DateTime.parse(
        (json['created_at'] as String?) ??
            DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
      ),
      hotelName: hotelName,
      roomName: roomName,
      hotelCity: hotel?['city'] as String?,
      hotelImageUrl: hotel?['cover_url'] as String?,
      roomNumber: room?['room_number'] as String?,
      nightlyRate: roomType?['base_price'] == null
          ? null
          : Money(amount: _priceAmount(roomType!['base_price']), currency: currency),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
    );
  }

  final String id;
  final String reference;
  final String hotelId;
  final String roomTypeId;
  final String? roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final ReservationStatus status;
  final Money priceSnapshot;
  final DateTime createdAt;
  final LocalizedText hotelName;
  final LocalizedText roomName;
  final String? hotelCity;
  final String? hotelImageUrl;
  final String? roomNumber;
  final Money? nightlyRate;
  final DateTime? cancelledAt;

  Reservation toEntity() => Reservation(
        id: id,
        reference: reference,
        hotelId: hotelId,
        hotelName: hotelName,
        roomTypeId: roomTypeId,
        roomName: roomName,
        roomId: roomId,
        stay: StayRange(checkIn: checkIn, checkOut: checkOut),
        party: GuestParty(adults: adults, children: children),
        status: status,
        priceSnapshot: priceSnapshot,
        createdAt: createdAt,
        hotelCity: hotelCity,
        hotelImageUrl: hotelImageUrl,
        roomNumber: roomNumber,
        nightlyRate: nightlyRate,
        cancelledAt: cancelledAt,
      );

  /// The Laravel resource serialises `price_snapshot` as a `decimal:2` string
  /// (e.g. `"945.00"`). The app's [Money] is whole currency units.
  static int _priceAmount(Object? raw) {
    if (raw is num) return raw.round();
    if (raw is String) return (double.tryParse(raw) ?? 0).round();
    return 0;
  }
}

/// Parsed `{ reservation, extension, folio }` composite response from
/// `POST .../extend`. Only the fields the UI needs are kept — the full
/// [ReservationModel] is parsed separately by the caller from the same JSON.
class ExtendStayResultModel {
  const ExtendStayResultModel({
    required this.reservationId,
    required this.newCheckOut,
    required this.nightsAdded,
    required this.amount,
    required this.outstandingTotal,
  });

  factory ExtendStayResultModel.fromJson(Json json) {
    final Json extension = (json['extension'] as Json?) ?? const <String, Object?>{};
    final Json folio = (json['folio'] as Json?) ?? const <String, Object?>{};
    final Json totals = (folio['totals'] as Json?) ?? const <String, Object?>{};
    final String currency = (extension['currency'] as String?) ??
        (folio['currency'] as String?) ??
        Money.fallbackCurrency;

    return ExtendStayResultModel(
      reservationId: '${extension['reservation_id']}',
      newCheckOut: DateTime.parse(extension['new_check_out'] as String),
      nightsAdded: (extension['nights_added'] as num?)?.toInt() ?? 0,
      amount: Money(
        amount: ReservationModel._priceAmount(extension['amount']),
        currency: currency,
      ),
      outstandingTotal: Money(
        amount: ReservationModel._priceAmount(totals['outstanding_total']),
        currency: currency,
      ),
    );
  }

  final String reservationId;
  final DateTime newCheckOut;
  final int nightsAdded;
  final Money amount;
  final Money outstandingTotal;

  ExtendStayResult toEntity() => ExtendStayResult(
        reservationId: reservationId,
        newCheckOut: newCheckOut,
        nightsAdded: nightsAdded,
        amount: amount,
        outstandingTotal: outstandingTotal,
      );
}
