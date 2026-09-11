import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';

import '../../support/pump_app.dart';

void main() {
  testWidgets('renders the promise headline and the single call to action',
      (WidgetTester tester) async {
    await pumpApp(tester);
    final AppLocalizations en = await tester.l10n();

    expect(find.text(en.entryHeadline), findsOneWidget);
    expect(find.text(en.entrySubtext), findsOneWidget);
    expect(find.text(en.entryStartAction), findsOneWidget);
  });

  testWidgets('the entry screen shows a single call to action and no chrome',
      (WidgetTester tester) async {
    await pumpApp(tester);
    final AppLocalizations en = await tester.l10n();

    // `01 · Entry` is photo-forward: no eyebrow tagline, no language toggle.
    expect(find.text(en.entryTagline), findsNothing);
    expect(find.text(en.languageArabic), findsNothing);
    expect(find.text(en.languageEnglish), findsNothing);
  });

  testWidgets('the call to action opens discovery, not sign-in (deferred auth)',
      (WidgetTester tester) async {
    await pumpApp(tester);
    final AppLocalizations en = await tester.l10n();

    await tester.tap(find.text(en.entryStartAction));
    await tester.pumpAndSettle();

    expect(find.text(en.authPhoneHeading), findsNothing);
    expect(find.text(en.discoverSubtitle), findsOneWidget);
    // A guest gets a sign-in entry point in the discover app bar.
    expect(find.widgetWithText(TextButton, en.discoverSignIn), findsOneWidget);
  });

  testWidgets('the entry headline follows the active locale direction',
      (WidgetTester tester) async {
    await pumpApp(tester);
    final AppLocalizations en = await tester.l10n();

    expect(
      Directionality.of(tester.element(find.text(en.entryHeadline))),
      TextDirection.ltr,
    );
  });
}
