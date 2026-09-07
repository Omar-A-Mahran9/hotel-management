import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the user's explicit locale override.
///
/// `null` means "follow the device locale" (resolved by `MaterialApp` against
/// `supportedLocales`). Setting a value forces Arabic or English regardless of
/// the device. Phase 0 keeps this in memory only; persistence is deferred with
/// the rest of the storage layer.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void set(Locale? locale) => state = locale;

  void useDeviceLocale() => state = null;
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
