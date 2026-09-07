import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale for the Guest App.
///
/// Phase 0 ships no bundled font files (no network during setup), so the scale
/// is defined on weights/sizes and falls back to the platform UI font. A branded
/// family (e.g. a Cairo/Tajawal pairing that renders Arabic well) can be dropped
/// into `pubspec.yaml` later and wired here via [fontFamily] without touching
/// widgets.
abstract final class AppTypography {
  static const String? fontFamily = null;

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle base(double size, FontWeight weight, {double height = 1.3, Color? color}) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? primary,
      );
    }

    return TextTheme(
      displaySmall: base(30, FontWeight.w700, height: 1.2),
      headlineMedium: base(24, FontWeight.w700, height: 1.25),
      headlineSmall: base(20, FontWeight.w600),
      titleLarge: base(18, FontWeight.w600),
      titleMedium: base(16, FontWeight.w600),
      titleSmall: base(14, FontWeight.w600),
      bodyLarge: base(16, FontWeight.w400, height: 1.45),
      bodyMedium: base(14, FontWeight.w400, height: 1.45, color: secondary),
      bodySmall: base(12, FontWeight.w400, height: 1.4, color: secondary),
      labelLarge: base(14, FontWeight.w600),
      labelMedium: base(12, FontWeight.w600, color: secondary),
    );
  }

  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.bronze500,
  );
}
