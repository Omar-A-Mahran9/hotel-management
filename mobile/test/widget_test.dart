import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/app/app.dart';
import 'package:hotel_guest_app/core/di/core_providers.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/core/widgets/primary_button.dart';

import 'support/test_config.dart';

void main() {
  testWidgets('app root boots to the foundation screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[appConfigProvider.overrideWithValue(testConfig)],
        child: const HotelGuestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    // English is the fallback locale in the test environment.
    final AppLocalizations en = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    expect(find.text(en.foundationScreenTitle), findsOneWidget);

    // The design-system primitives render (scroll the last card into view).
    await tester.scrollUntilVisible(find.byType(PrimaryButton), 250);
    expect(find.byType(PrimaryButton), findsWidgets);
  });

  testWidgets('backend health slice resolves through the dummy data source',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[appConfigProvider.overrideWithValue(testConfig)],
        child: const HotelGuestApp(),
      ),
    );
    await tester.pumpAndSettle();

    final AppLocalizations en = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    expect(find.text(en.backendStatusOk), findsOneWidget);
  });
}
