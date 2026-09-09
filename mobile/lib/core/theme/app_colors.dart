import 'package:flutter/material.dart';

/// Raw colour tokens for the Hotel Guest App.
///
/// These are the only place literal colours are allowed. Widgets consume them
/// through [ThemeData]/[AppColorScheme], never directly, so light/dark and
/// future re-branding stay centralised (md/mobile/architecture.md §9,
/// md/mobile/coding_rules.md §8).
abstract final class AppColors {
  // Brand — warm "oud" brown. Sampled from the rendered Figma boards
  // (`mobile/design/*.png`): the primary CTA, the splash ground, the digital-key
  // card, the selected chip and the price text all render at #513425.
  static const Color brown900 = Color(0xFF3E2A1E); // deep / pressed
  static const Color brown700 = Color(0xFF513425); // primary action, splash
  static const Color brown500 = Color(0xFF6A4636); // hover / lighter fill
  static const Color brown300 = Color(0xFF9A7C68); // muted brown

  // Accent — bronze/gold. Figma variable `color/accent/warm` = sand/400
  // (#C6A15B) for fills & strokes only; a darker tone carries gold text
  // (`color/accent/warm-fg`, ~4.97:1 on white).
  static const Color bronze500 = Color(0xFF9C7238); // gold-toned text
  static const Color bronze400 = Color(0xFFC6A15B); // stars / accent fills
  static const Color bronze200 = Color(0xFFE7D8BD); // warm-sand surface

  // Neutrals — warm off-white ground, warm near-black text. Sampled:
  // canvas #FCFAF7, text #1D1A16, secondary #847E72, hairline #E5E0D7.
  static const Color ink900 = Color(0xFF1D1A16);
  static const Color ink600 = Color(0xFF847E72);
  static const Color ink400 = Color(0xFFA8A093);
  static const Color paper = Color(0xFFFCFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFE5E0D7);

  // Dark theme neutrals.
  static const Color darkBackground = Color(0xFF16120F);
  static const Color darkSurface = Color(0xFF211B17);
  static const Color darkHairline = Color(0xFF3A322B);
  static const Color darkInk = Color(0xFFF3EEE8);

  // Semantic — success / warning / error / info, with soft container tints.
  // Foregrounds & backgrounds sampled from the rendered Figma banners/pills.
  static const Color success = Color(0xFF256349);
  static const Color successContainer = Color(0xFFEAF3EF);
  static const Color warning = Color(0xFF9C6F2A);
  static const Color warningContainer = Color(0xFFF9F1E4);
  static const Color error = Color(0xFFA33A3A);
  static const Color errorContainer = Color(0xFFFAEBEB);
  static const Color info = Color(0xFF4E7C90);
  static const Color infoContainer = Color(0xFFEAF1F5);

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
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
    );
  }
}
