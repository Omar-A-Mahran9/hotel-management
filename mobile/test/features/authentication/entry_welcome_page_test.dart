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
    expect(find.text(en.entryTagline), findsOneWidget);
    expect(find.text(en.entryStartAction), findsOneWidget);
  });

  testWidgets('the call to action opens the phone sign-in screen',
      (WidgetTester tester) async {
    await pumpApp(tester);
    final AppLocalizations en = await tester.l10n();

    await tester.tap(find.text(en.entryStartAction));
    await tester.pumpAndSettle();

    expect(find.text(en.authPhoneHeading), findsOneWidget);
  });

  testWidgets('the language switch flips the entry screen to Arabic RTL',
      (WidgetTester tester) async {
    await pumpApp(tester);
    final AppLocalizations en = await tester.l10n();
    final AppLocalizations ar = await tester.l10n('ar');

    expect(
      Directionality.of(tester.element(find.text(en.entryHeadline))),
      TextDirection.ltr,
    );

    await tester.tap(find.text(en.languageArabic));
    await tester.pumpAndSettle();

    expect(find.text(ar.entryHeadline), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(ar.entryHeadline))),
      TextDirection.rtl,
    );
  });
}
