import 'package:flutter/foundation.dart';

/// A price in a single currency.
///
/// The Guest App design references only ever show whole-number amounts with the
/// Saudi Riyal mark, so [amount] is a whole currency unit. Formatting for the
/// user (the "﷼" / "SAR" mark and the "/ night" suffix) is done through
/// localization, never here — this type only carries the value.
@immutable
class Money {
  const Money({required this.amount, this.currency = 'SAR'});

  final int amount;
  final String currency;

  Money operator *(int factor) => Money(amount: amount * factor, currency: currency);

  @override
  bool operator ==(Object other) =>
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => 'Money($amount $currency)';
}
