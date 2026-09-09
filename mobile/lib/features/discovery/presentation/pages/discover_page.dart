import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../authentication/presentation/state/auth_controller.dart';
import '../../domain/entities/hotel_sort.dart';
import '../state/discover_controller.dart';
import '../state/hotel_search_controller.dart';
import '../widgets/hotel_search_field.dart';
import '../widgets/hotel_summary_card.dart';
import '../widgets/sort_chip_bar.dart';

/// `02 · Discover & Book` — the authenticated landing. Greeting, a read-only
/// search entry, the quick-sort chips and the curated hotel list. Tapping a
/// card opens the hotel detail; the search field opens the search screen.
///
/// The reference's "upcoming stay" block and bottom navigation belong to later
/// phases (reservations / account) and are intentionally not built here.
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  void _openHotel(BuildContext context, String hotelId) {
    context.pushNamed(
      AppRoutes.hotelDetailName,
      pathParameters: <String, String>{'hotelId': hotelId},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<DiscoverView> discover =
        ref.watch(discoverControllerProvider);
    final HotelSort chipSort = ref.watch(
      hotelSearchControllerProvider.select((HotelSearchState s) => s.sort),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.pageGutter,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              discover.valueOrNull?.greetingName == null
                  ? l10n.discoverGreeting
                  : l10n.discoverGreetingNamed(discover.value!.greetingName!),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(l10n.discoverSubtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(AppIcons.notifications),
            tooltip: l10n.discoverNotificationsTooltip,
            onPressed: () {},
          ),
          // Sign-out stays here until the "حسابي" account screen exists
          // (see md/mobile/design-system.md §"Bottom navigation").
          IconButton(
            icon: const Icon(AppIcons.checkout),
            tooltip: l10n.authSignOut,
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(discoverControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            children: <Widget>[
              HotelSearchField(
                readOnly: true,
                onTap: () => context.pushNamed(AppRoutes.hotelSearchName),
              ),
              const SizedBox(height: AppSpacing.md),
              SortChipBar(
                selected: chipSort,
                onSelected: (HotelSort sort) {
                  ref.read(hotelSearchControllerProvider.notifier).setSort(sort);
                  context.pushNamed(AppRoutes.hotelSearchName);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      l10n.discoverFeaturedSection,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed(AppRoutes.hotelSearchName),
                    child: Text(l10n.commonSeeAll),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              UiStateView<DiscoverView>(
                state: discoverUiState(discover),
                onRetry: () =>
                    ref.read(discoverControllerProvider.notifier).refresh(),
                emptyTitle: l10n.discoverEmptyTitle,
                emptyMessage: l10n.discoverEmptyBody,
                onSuccess: (DiscoverView view) => LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    final double w = (c.maxWidth - AppSpacing.md) / 2;
                    return Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: <Widget>[
                        for (final hotel in view.featuredHotels)
                          SizedBox(
                            width: w,
                            child: HotelSummaryCard(
                              hotel: hotel,
                              layout: HotelCardLayout.tile,
                              onTap: () => _openHotel(context, hotel.id),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Foundation: the persistent Figma bottom nav. "Home" is this screen; the
      // other three destinations are not built yet (see
      // md/mobile/design-system.md) — tapping them explains that rather than
      // routing to a placeholder.
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.home,
        onSelected: (AppNavTab tab) {
          if (tab == AppNavTab.home) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.navComingSoon)));
        },
      ),
    );
  }
}
