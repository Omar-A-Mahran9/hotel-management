/// Spacing scale (4pt grid). Use these instead of literal `EdgeInsets` values so
/// vertical rhythm stays consistent across screens.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Default horizontal page padding for phone layouts.
  static const double pageGutter = 20;

  /// Default inner padding for [AppCard] / surface containers.
  static const double cardPadding = 16;

  /// Vertical gap between stacked sections on a screen.
  static const double section = 24;

  /// Space above a sticky bottom action bar's content and below its buttons
  /// (added on top of the safe-area inset). See `BottomActionBar`.
  static const double bottomBarTop = 12;
  static const double bottomBarBottom = 16;
}
