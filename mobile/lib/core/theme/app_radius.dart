import 'package:flutter/widgets.dart';

/// Corner-radius tokens.
///
/// `pill` is used for primary/secondary/danger buttons and filter chips.
/// `card` is the default surface radius. `sheet` is the top radius on bottom
/// sheets and the entry-screen bottom panel.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double input = 14;
  static const double lg = 16;
  static const double card = 18;
  static const double xl = 20;
  static const double sheet = 28;
  static const double pill = 999;

  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius allInput = BorderRadius.all(Radius.circular(input));
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius allCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius allXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius allPill = BorderRadius.all(Radius.circular(pill));

  /// Top-only rounding for bottom sheets / raised panels.
  static const BorderRadius topSheet = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
