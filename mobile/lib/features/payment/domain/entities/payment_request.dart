import 'package:flutter/foundation.dart';

import '../../../discovery/domain/entities/money.dart';
import '../../../reservation/domain/entities/reservation.dart';

/// Everything the mobile app can supply to request a deposit hold on a
/// reservation.
///
/// The approved backend `POST /api/v1/reservations/{reservation}/payment/hold`
/// (`StorePaymentHoldRequest`) takes `amount` (decimal string) and an optional
/// `currency`; the idempotency key travels as the `Idempotency-Key` HTTP
/// header, never a body field. That endpoint is **staff/dashboard-scoped** — it
/// authorises against the caller's hotel access via `PaymentPolicy` and there
/// is no guest-facing payment contract — so this request only carries what the
/// guest app knows: the [reservationId] and the [amount] captured from the
/// authoritative reservation price snapshot.
///
/// No card data, CVV, PIN or provider credential is ever part of this request:
/// the MVP dummy provider needs none, and a real integration would collect
/// those through the provider's own SDK/redirect, never through our API body
/// (md/mobile/architecture.md §8).
@immutable
class PaymentHoldRequest {
  const PaymentHoldRequest({
    required this.reservationId,
    required this.amount,
  });

  /// Builds the hold request from an authoritative [Reservation]: the hold is
  /// for the reservation's recorded price snapshot, in its currency.
  factory PaymentHoldRequest.forReservation(Reservation reservation) {
    return PaymentHoldRequest(
      reservationId: reservation.id,
      amount: reservation.priceSnapshot,
    );
  }

  final String reservationId;
  final Money amount;

  /// The `amount` body field: a decimal string with two fractional digits, the
  /// shape `StorePaymentHoldRequest` validates (`/^\d{1,10}(\.\d{1,2})?$/`).
  String get amountWire => amount.amount.toStringAsFixed(2);

  /// The `currency` body field: a 3-letter ISO-style code.
  String get currencyWire => amount.currency;

  /// A stable idempotency key for this exact request — used as the
  /// `Idempotency-Key` header and to dedupe repeated submits. No time
  /// component, no randomness, so a widget rebuild yields the identical key.
  String get idempotencyKey => <String>[
        'pay',
        reservationId,
        amount.amount.toString(),
        amount.currency,
      ].join(':');

  @override
  bool operator ==(Object other) =>
      other is PaymentHoldRequest &&
      other.reservationId == reservationId &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(reservationId, amount);

  @override
  String toString() => 'PaymentHoldRequest($idempotencyKey)';
}
