import 'package:flutter/material.dart';

/// Type scale for the Guest App.
///
/// ## Font
///
/// **Tajawal** — the family the Figma explicitly specifies
/// (`font/family/arabic = Tajawal`). SIL OFL 1.1, `assets/fonts/OFL.txt`.
/// Tajawal is a humanist Arabic sans with a complete Latin set, so the one
/// family renders both the Arabic UI and the Latin "Hotel System" wordmark.
/// Bundled static weights: 300 / 400 / 500 / 700 / 800 (Flutter approximates
/// 600 from the neighbours).
///
/// ## Rules
///
/// * Widgets read text styles from `Theme.of(context).textTheme` (or the
///   helpers below) — never inline `TextStyle(fontFamily: ...)`.
/// * Figma headlines are heavy: display/headline/title styles are w700–w800.
/// * Arabic needs more leading than Latin — body styles use ~1.45 line height.
abstract final class AppTypography {
  /// The bundled family (see `pubspec.yaml`). Applied globally through
  /// [ThemeData.fontFamily] so it also reaches Material-internal text.
  static const String fontFamily = 'Tajawal';

  /// Weight tokens — named so screens/components don't sprinkle raw
  /// [FontWeight] values that drift from the design.
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  static TextStyle _base(
    double size,
    FontWeight weight, {
    double height = 1.3,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle primaryStyle(
      double size,
      FontWeight weight, {
      double height = 1.3,
    }) => _base(size, weight, height: height, color: primary);

    // Sizes + line heights match the original scale (so the font switch +
    // heavier weights don't reflow existing screens); only the weights move up
    // to the Figma's heavier feel.
    return TextTheme(
      // Display — the entry headline and other hero copy.
      displayLarge: primaryStyle(34, extraBold, height: 1.15),
      displayMedium: primaryStyle(32, extraBold, height: 1.15),
      displaySmall: primaryStyle(30, extraBold, height: 1.2),
      // Headline — screen headings ("أدخل رقم جوالك").
      headlineLarge: primaryStyle(26, bold, height: 1.2),
      headlineMedium: primaryStyle(24, bold, height: 1.25),
      headlineSmall: primaryStyle(20, bold, height: 1.3),
      // Title — app-bar title, section headers, card titles.
      titleLarge: primaryStyle(18, bold, height: 1.3),
      titleMedium: primaryStyle(16, bold, height: 1.3),
      titleSmall: primaryStyle(14, bold, height: 1.3),
      // Body — paragraph and supporting copy. Secondary tone for medium/small
      // matches the Figma's muted helper text.
      bodyLarge: primaryStyle(16, regular, height: 1.45),
      bodyMedium: _base(14, regular, height: 1.45, color: secondary),
      bodySmall: _base(12, regular, height: 1.4, color: secondary),
      // Label — buttons and pills.
      labelLarge: primaryStyle(14, bold, height: 1.2),
      labelMedium: _base(12, bold, height: 1.3, color: secondary),
      labelSmall: _base(11, semiBold, height: 1.3, color: secondary),
    );
  }

  /// Large tabular-figure number (room number, deposit amount, points balance).
  /// Colour is supplied by the caller (often white on the brown card).
  static TextStyle number(Color color, {double size = 40}) => _base(
    size,
    extraBold,
    height: 1.05,
    color: color,
  ).copyWith(fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]);

  /// Monospaced-digit style for reference codes / entry codes.
  static TextStyle code(Color color, {double size = 18}) => _base(
    size,
    bold,
    color: color,
    letterSpacing: 2,
  ).copyWith(fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]);

  /// Price / money style — bronze accent, heavy, tabular figures. Pair with
  /// `MoneyText`. Callers may override the colour for on-dark surfaces.
  static TextStyle price(Color color, {double size = 16}) => _base(
    size,
    bold,
    color: color,
  ).copyWith(fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]);
}
