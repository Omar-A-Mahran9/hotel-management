import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] for the Guest App from the design
/// tokens (`mobile/docs/design-system-tokens.md`). Single source of truth for
/// visual styling — widgets must not define their own colours or text styles.
///
/// Colour comes from [AppColorTokens] (registered as a [ThemeExtension] and read
/// via `context.colors`); the [ColorScheme] mirrors the subset Material's own
/// widgets consume. Both modes are fully specified in the Figma.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final AppColorTokens c = AppColorTokens.of(brightness);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.bgPrimary,
      onPrimary: c.textOnPrimary,
      secondary: c.accentWarm,
      onSecondary: isDark ? AppPrimitives.stone900 : AppPrimitives.white,
      surface: c.bgSurface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.bgSubtle,
      error: c.errorFg,
      onError: AppPrimitives.white,
      errorContainer: c.errorBg,
      onErrorContainer: c.errorFg,
      outline: c.borderDefault,
      outlineVariant: c.bgSubtle,
    );

    final TextTheme textTheme = AppTypography.textTheme(
      c.textPrimary,
      c.textSecondary,
    );

    /// Secondary-button fill — a cream/raised surface, not a coloured outline.
    final Color secondaryFill = isDark ? c.bgSurfaceRaised : c.bgCanvas;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bgCanvas,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      extensions: <ThemeExtension<dynamic>>[
        c,
        isDark ? AppSemanticColors.dark : AppSemanticColors.light,
      ],

      // ── App bar ──────────────────────────────────────────────────────────
      // Flat, background-aware, centred title, no Material tint/elevation.
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgCanvas,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        foregroundColor: c.textPrimary,
        iconTheme: IconThemeData(
          color: c.textPrimary,
          size: AppIconSizes.appBar,
        ),
      ),

      // ── Cards ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: c.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allCard),
      ),

      dividerTheme: DividerThemeData(
        color: c.borderDefault,
        thickness: 1,
        space: AppSpacing.space4,
      ),

      // ── Inputs ───────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.allInput,
          borderSide: BorderSide(color: c.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.allInput,
          borderSide: BorderSide(color: c.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allInput,
          borderSide: BorderSide(color: c.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allInput,
          borderSide: BorderSide(color: c.errorFg),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allInput,
          borderSide: BorderSide(color: c.errorFg, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textPlaceholder),
        labelStyle: textTheme.bodyMedium,
      ),

      // ── Buttons ──────────────────────────────────────────────────────────
      // Full-width pill CTAs (radius 999, Figma `Button` component). The
      // composed widgets (PrimaryButton / SecondaryButton / DangerButton) take a
      // `size` for the Small 40 / Medium 48 / Large 56 axis; 52 is the standing
      // full-width height.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.bgPrimary,
          foregroundColor: c.textOnPrimary,
          disabledBackgroundColor: c.bgDisabled,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allPill),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          backgroundColor: secondaryFill,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: c.borderDefault),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allPill),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textAccent,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Chips ────────────────────────────────────────────────────────────
      // Brown-filled when selected, cream pill with a hairline when not.
      chipTheme: ChipThemeData(
        backgroundColor: c.bgSurface,
        selectedColor: c.bgPrimary,
        checkmarkColor: c.textOnPrimary,
        showCheckmark: false,
        side: BorderSide(color: c.borderDefault),
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelLarge?.copyWith(color: c.textPrimary),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: c.textOnPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Toggle (Figma `Toggle` component) ────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          if (s.contains(WidgetState.disabled)) return c.textDisabled;
          return AppPrimitives.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          if (s.contains(WidgetState.disabled)) return c.bgDisabled;
          if (s.contains(WidgetState.selected)) return c.bgPrimary;
          return c.borderStrong;
        }),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),

      // ── Bottom sheets ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bgSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.bgSurface,
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.topSheet),
      ),

      // ── Bottom navigation (Figma's persistent 4-tab bar) ─────────────────
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: c.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: AppIconSizes.nav,
            color: selected ? c.bgPrimary : c.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          final bool selected = s.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? c.bgPrimary : c.textSecondary,
            fontWeight: selected ? AppTypography.bold : AppTypography.medium,
          );
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.bgInverse,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: c.textOnInverse,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.bgPrimary),
    );
  }
}
