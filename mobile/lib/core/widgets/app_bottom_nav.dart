import 'package:flutter/material.dart';

import '../localization/l10n.dart';
import 'app_icons.dart';

/// The Figma's persistent four-tab bottom navigation, as a reusable component.
///
/// **Foundation only.** Three of the four destinations (bookings list, a global
/// services hub, account) do not exist as screens yet — see
/// `md/mobile/design-system.md` §"Bottom navigation". This widget provides the
/// visual + the destination model so a `StatefulShellRoute` can adopt it once
/// those screens are built, without re-deriving the styling. It never routes
/// anywhere itself; the host supplies [onSelected].
enum AppNavTab { home, bookings, services, account }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final AppNavTab current;
  final ValueChanged<AppNavTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return NavigationBar(
      selectedIndex: AppNavTab.values.indexOf(current),
      onDestinationSelected: (int i) => onSelected(AppNavTab.values[i]),
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: const Icon(AppIcons.navHomeOutline),
          selectedIcon: const Icon(AppIcons.navHome),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(AppIcons.navBookingsOutline),
          selectedIcon: const Icon(AppIcons.navBookings),
          label: l10n.navBookings,
        ),
        NavigationDestination(
          icon: const Icon(AppIcons.navServicesOutline),
          selectedIcon: const Icon(AppIcons.navServices),
          label: l10n.navServices,
        ),
        NavigationDestination(
          icon: const Icon(AppIcons.navAccountOutline),
          selectedIcon: const Icon(AppIcons.navAccount),
          label: l10n.navAccount,
        ),
      ],
    );
  }
}
