import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n.dart';
import '../../core/widgets/hotel_app_bar.dart';
import '../../core/widgets/message_view.dart';
import '../foundation_home_page.dart';
import 'app_routes.dart';

/// The app's [GoRouter]. Kept behind a provider so feature modules can later
/// contribute routes and so tests can build a router with overridden deps.
final appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.foundation,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.foundation,
        name: AppRoutes.foundationName,
        builder: (BuildContext context, GoRouterState state) =>
            const FoundationHomePage(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: HotelAppBar(title: context.l10n.appName),
      body: ErrorView(
        title: context.l10n.stateErrorTitle,
        message: context.l10n.errorGeneric,
      ),
    ),
  );
});
