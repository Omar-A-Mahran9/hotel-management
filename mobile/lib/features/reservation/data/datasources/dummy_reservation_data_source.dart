import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/create_reservation_request.dart';
import '../../domain/entities/reservation_status.dart';
import '../models/reservation_models.dart';
import 'reservation_data_source.dart';

/// Deterministic, offline reservation source used while no guest-facing
/// reservation API contract is approved.
///
/// Guarantees required by the phase brief:
/// * no network, no timers, no randomness, no artificial delays;
/// * a reservation's id / reference / created-at are derived purely from the
///   request (via [CreateReservationRequest.idempotencyKey]) and the injected
///   [clock] — the same request always yields the same reservation;
/// * [create] is idempotent: a repeat of the same request returns the reservation
///   already made, it never makes a second one;
/// * a fresh reservation is `PENDING`, matching the backend state machine.
///
/// [failWith] is a test seam (mirrors `DummyHealthDataSource.error`) so the
/// error / recovery UI can be exercised without any real failure.
class DummyReservationDataSource
    implements ReservationDataSource, DummyDataSource {
  DummyReservationDataSource({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<String, ReservationModel> _byId = <String, ReservationModel>{};
  final Map<String, String> _idByKey = <String, String>{};

  /// When non-null, the next [create] / [fetchById] throws this instead.
  Object? failWith;

  @override
  Future<ReservationModel> create(CreateReservationRequest request) async {
    if (failWith != null) throw failWith!;

    final String existingId = _idByKey[request.idempotencyKey] ?? '';
    final ReservationModel? existing = _byId[existingId];
    if (existing != null) return existing;

    final int hash = _fnv1a(request.idempotencyKey);
    final String id = '${1000000 + (hash % 9000000)}';
    final String reference = _reference(hash);
    final DateTime now = _clock();

    final ReservationModel model = ReservationModel.fromJson(
      <String, Object?>{
        'id': id,
        'reference': reference,
        'hotel_id': request.hotelId,
        'room_type_id': request.roomTypeId,
        'room_id': request.roomId,
        'check_in': request.stay.checkIn.toIso8601String(),
        'check_out': request.stay.checkOut.toIso8601String(),
        'adults': request.party.adults,
        'children': request.party.children,
        'status': ReservationStatus.pending.wireValue,
        'price_snapshot': request.priceSnapshot.amount,
        'currency': request.priceSnapshot.currency,
        'created_at': now.toIso8601String(),
      },
      hotelName: request.hotelName,
      roomName: request.roomName,
      party: request.party,
    );

    _byId[id] = model;
    _idByKey[request.idempotencyKey] = id;
    return model;
  }

  @override
  Future<ReservationModel> fetchById(String id) async {
    if (failWith != null) throw failWith!;
    final ReservationModel? model = _byId[id];
    if (model == null) {
      throw NotFoundException('No reservation with id "$id"');
    }
    return model;
  }

  static int _fnv1a(String value) {
    int hash = 0x811c9dc5;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  static String _reference(int hash) {
    final String base = hash.toRadixString(36).toUpperCase().padLeft(6, '0');
    final String body = base.substring(base.length - 6);
    return 'RSV-${body.substring(0, 3)}-${body.substring(3)}';
  }
}
