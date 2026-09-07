import 'package:flutter/widgets.dart';

/// The locales the Guest App ships. Arabic is listed first because it is the
/// primary market locale; [resolveLocale] still honours the device preference.
abstract final class SupportedLocales {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  static const List<Locale> all = <Locale>[arabic, english];

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';

  /// Chooses a supported locale for a device preference list, falling back to
  /// English when nothing matches.
  static Locale resolveLocale(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (deviceLocale == null) return english;
    for (final Locale locale in supported) {
      if (locale.languageCode == deviceLocale.languageCode) return locale;
    }
    return english;
  }
}
