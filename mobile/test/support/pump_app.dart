import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/app/app.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/core/localization/locale_controller.dart';
import 'package:hotel_guest_app/core/localization/supported_locales.dart';
import 'package:hotel_guest_app/features/authentication/domain/entities/guest_profile.dart';

import 'auth_test_support.dart';

/// Pumps the whole app with authentication overrides and settles the startup
/// redirect. Returns the container so a test can drive controllers directly.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  AuthSession? bootSession,
  Locale? locale,
  Duration resendCooldown = Duration.zero,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: authOverrides(
      bootSession: bootSession,
      resendCooldown: resendCooldown,
    ),
  );
  addTearDown(container.dispose);

  if (locale != null) {
    container.read(localeControllerProvider.notifier).set(locale);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const HotelGuestApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

extension L10nFinder on WidgetTester {
  Future<AppLocalizations> l10n([String code = 'en']) =>
      AppLocalizations.delegate.load(Locale(code));
}

const Locale arabic = SupportedLocales.arabic;
