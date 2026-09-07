import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/theme/app_colors.dart';
import 'package:hotel_guest_app/core/theme/app_theme.dart';

void main() {
  test('light and dark themes are Material 3 and carry semantic colours', () {
    final ThemeData light = AppTheme.light;
    final ThemeData dark = AppTheme.dark;

    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);

    expect(light.extension<AppSemanticColors>(), isNotNull);
    expect(dark.extension<AppSemanticColors>(), isNotNull);
  });

  test('button and input theming is centralised', () {
    final ThemeData light = AppTheme.light;
    expect(light.filledButtonTheme.style, isNotNull);
    expect(light.outlinedButtonTheme.style, isNotNull);
    expect(light.inputDecorationTheme.filled, isTrue);
  });
}
