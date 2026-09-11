import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/app/app.dart';
import 'package:hotel_guest_app/core/widgets/app_image.dart';
import 'package:hotel_guest_app/features/authentication/presentation/pages/auth_splash_page.dart';
import 'package:hotel_guest_app/features/authentication/presentation/pages/language_selection_page.dart';
import 'package:hotel_guest_app/features/authentication/presentation/state/auth_controller.dart';

import '../../support/auth_test_support.dart';

void main() {
  testWidgets('the branded splash holds on screen, then hands off to the flow',
      (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        ...authOverrides(languageChosen: false),
        splashMinDurationProvider.overrideWithValue(
          const Duration(milliseconds: 300),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const HotelGuestApp(),
      ),
    );
    await tester.pump();

    // The splash is up while the (held) session restore is in flight, showing
    // the real brand raster (not the vector fallback).
    expect(find.byType(AuthSplashPage), findsOneWidget);
    final Finder brandImage = find.byWidgetPredicate(
      (Widget w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == AppImages.brandMark,
    );
    expect(brandImage, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Once the hold elapses it moves on to the first-run language screen.
    expect(find.byType(AuthSplashPage), findsNothing);
    expect(find.byType(LanguageSelectionPage), findsOneWidget);
  });
}
