import 'package:flutter/material.dart';

/// Raw colour tokens for the Hotel Guest App.
///
/// These are the only place literal colours are allowed. Widgets consume them
/// through [ThemeData]/[AppColorScheme], never directly, so light/dark and
/// future re-branding stay centralised (md/mobile/architecture.md §9,
/// md/mobile/coding_rules.md §8).
abstract final class AppColors {
  // Brand — warm brown, taken from the Guest App design references.
  static const Color brown900 = Color(0xFF2E2018);
  static const Color brown700 = Color(0xFF4A3427);
  static const Color brown500 = Color(0xFF5B4034);
  static const Color brown300 = Color(0xFF8A6F5E);

  // Accent — bronze/gold used for prices and ratings.
  static const Color bronze500 = Color(0xFFA9793F);
  static const Color bronze200 = Color(0xFFE7D6BF);

  // Neutrals — warm paper background and near-black warm text.
  static const Color ink900 = Color(0xFF1F1A17);
  static const Color ink600 = Color(0xFF6F655E);
  static const Color ink400 = Color(0xFF9C938C);
  static const Color paper = Color(0xFFF7F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFE8E2D9);

  // Dark theme neutrals.
  static const Color darkBackground = Color(0xFF16120F);
  static const Color darkSurface = Color(0xFF211B17);
  static const Color darkHairline = Color(0xFF3A322B);
  static const Color darkInk = Color(0xFFF3EEE8);

  // Semantic — success / warning / error / info, with soft container tints.
  static const Color success = Color(0xFF3E8E5A);
  static const Color successContainer = Color(0xFFE7F1EA);
  static const Color warning = Color(0xFFB4802A);
  static const Color warningContainer = Color(0xFFFBF3E3);
  static const Color error = Color(0xFFB3352F);
  static const Color errorContainer = Color(0xFFFBEAEA);
  static const Color info = Color(0xFF3A6C99);
  static const Color infoContainer = Color(0xFFE8F0F6);

  static const Color white = Color(0xFFFFFFFF);
}

/// Semantic colours that are not expressible through [ColorScheme] but are still
/// part of the design system. Attached to [ThemeData] via [ThemeExtension] so
/// widgets read them from the theme rather than importing [AppColors].
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.accent,
    required this.hairline,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;
  final Color accent;
  final Color hairline;

  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.success,
    successContainer: AppColors.successContainer,
    warning: AppColors.warning,
    warningContainer: AppColors.warningContainer,
    info: AppColors.info,
    infoContainer: AppColors.infoContainer,
    accent: AppColors.bronze500,
    hairline: AppColors.hairline,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF6FB98C),
    successContainer: Color(0xFF23352B),
    warning: Color(0xFFD9A85C),
    warningContainer: Color(0xFF3A2F1D),
    info: Color(0xFF7FA9CE),
    infoContainer: Color(0xFF1E2C38),
    accent: AppColors.bronze200,
    hairline: AppColors.darkHairline,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? accent,
    Color? hairline,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      accent: accent ?? this.accent,
      hairline: hairline ?? this.hairline,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
    );
  }
}
