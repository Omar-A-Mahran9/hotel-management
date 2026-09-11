import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/core_providers.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/room_selection.dart';

/// A **design-only** placeholder for the `رسوم الخدمة` line in the booking-summary
/// price breakdown (`BOOKING_Summary` mockup).
///
/// This is NOT a pricing rule and never enters business logic: the mockup shows
/// a `رسوم الخدمة` row, so the dummy path shows a fixed, clearly-labelled
/// estimate to reproduce the layout. Laravel is the authoritative source for the
/// final amount; the API path shows no fee line (`null`).
const Money kDesignMockServiceFee = Money(amount: 45);

/// Service fee shown on the booking summary. Design-only mock on the dummy path;
/// `null` on the real API path until the backend supplies it.
final bookingServiceFeeProvider = Provider<Money?>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return config.useDummyData ? kDesignMockServiceFee : null;
});

/// The price rows shown on the booking summary. Pure presentation arithmetic
/// over values the app already holds — no taxes/rules invented here.
@immutable
class BookingPriceBreakdown {
  const BookingPriceBreakdown({
    required this.roomSubtotal,
    required this.serviceFee,
    required this.total,
  });

  factory BookingPriceBreakdown.of(
    RoomSelection selection, {
    Money? serviceFee,
  }) {
    final Money subtotal = selection.stayTotal;
    final int total = subtotal.amount + (serviceFee?.amount ?? 0);
    return BookingPriceBreakdown(
      roomSubtotal: subtotal,
      serviceFee: serviceFee,
      total: Money(amount: total, currency: subtotal.currency),
    );
  }

  final Money roomSubtotal;
  final Money? serviceFee;
  final Money total;
}
