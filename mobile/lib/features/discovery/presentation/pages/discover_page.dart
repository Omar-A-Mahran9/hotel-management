import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/bottom_nav_navigation.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/presentation/ui_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../authentication/presentation/state/auth_controller.dart';
import '../../domain/entities/hotel_sort.dart';
import '../state/discover_controller.dart';
import '../state/hotel_search_controller.dart';
import '../widgets/hotel_search_field.dart';
import '../widgets/hotel_summary_card.dart';
import '../widgets/room_summary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/sort_chip_bar.dart';
import '../widgets/upcoming_stay_card.dart';

/// `HOME_Default` / `HOME_if One hotel` — the authenticated **and** guest
/// landing. Greeting header + a read-only search entry + quick-sort chips, then
/// (signed in) the `إقامتك القادمة` card and either the group hotel grid or,
/// for a single-hotel group, the `استكشف الغرف` room list.
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
    final bool isSignedIn = ref.watch(authControllerProvider).map(
          unknown: () => false,
          unauthenticated: () => false,
          awaitingProfile: (_) => true,
          authenticated: (_) => true,
          sessionExpired: () => false,
        );

    final DiscoverView? view = discover.valueOrNull;
    final String? soleHotelName =
        view?.soleHotel?.name.resolve(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(
        // Default kToolbarHeight (56) clips the two-line greeting; sized to
        // fit title + subtitle plus the notification circle comfortably
        // (`HOME_Default`).
        toolbarHeight: 92,
        titleSpacing: AppSpacing.pageGutter,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              view?.greetingName == null
                  ? l10n.discoverGreeting
                  : l10n.discoverGreetingNamed(view!.greetingName!),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              soleHotelName == null
                  ? l10n.discoverSubtitle
                  : l10n.discoverSubtitleHotel(soleHotelName),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          if (!isSignedIn)
            TextButton(
              onPressed: () => context.goNamed(AppRoutes.signInName),
              child: Text(l10n.discoverSignIn),
            ),
          // Disabled, not silently tappable: there is no notifications
          // screen/route yet (mobile/docs — tracked as a gap, not built here).
          _CircleAction(
            icon: AppIcons.notifications,
            tooltip: l10n.discoverNotificationsTooltip,
            onPressed: null,
          ),
          const SizedBox(width: AppSpacing.xs),
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
                trailingIcon: AppIcons.filter,
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
              if (view?.upcomingStay != null) ...<Widget>[
                SectionHeader(
                  title: l10n.discoverUpcomingStay,
                  onSeeAll: () => context.pushNamed(
                    AppRoutes.reservationDetailName,
                    pathParameters: <String, String>{
                      'reservationId': view!.upcomingStay!.reservationId,
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                UpcomingStayCard(
                  stay: view!.upcomingStay!,
                  onTap: () => context.pushNamed(
                    AppRoutes.reservationDetailName,
                    pathParameters: <String, String>{
                      'reservationId': view.upcomingStay!.reservationId,
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _Listings(
                state: discoverUiState(discover),
                onRetry: () =>
                    ref.read(discoverControllerProvider.notifier).refresh(),
                onOpenHotel: (String id) => _openHotel(context, id),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.home,
        onSelected: (AppNavTab tab) => goToNavTab(context, tab),
      ),
    );
  }
}

class _Listings extends StatelessWidget {
  const _Listings({
    required this.state,
    required this.onRetry,
    required this.onOpenHotel,
  });

  final UiState<DiscoverView> state;
  final VoidCallback onRetry;
  final ValueChanged<String> onOpenHotel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return UiStateView<DiscoverView>(
      state: state,
      onRetry: onRetry,
      emptyTitle: l10n.discoverEmptyTitle,
      emptyMessage: l10n.discoverEmptyBody,
      skeleton: const _FeaturedHotelsSkeleton(),
      onSuccess: (DiscoverView view) {
        if (view.isSingleHotel) {
          final String hotelId = view.soleHotel!.id;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionHeader(
                title: l10n.discoverExploreRooms,
                onSeeAll: () => onOpenHotel(hotelId),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final room in view.soleHotelRooms) ...<Widget>[
                RoomSummaryCard(
                  room: room,
                  nights: 1,
                  selected: false,
                  showStayTotal: false,
                  onViewDetails: () => onOpenHotel(hotelId),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionHeader(
              title: l10n.discoverFeaturedSection,
              onSeeAll: () => context.pushNamed(AppRoutes.hotelSearchName),
            ),
            const SizedBox(height: AppSpacing.xs),
            // `فنادق المجموعة` (`02 · Discover & Book`) is a horizontal
            // carousel, not a wrapping grid — the group commonly runs more
            // hotels than fit one row, and Figma scrolls rather than stacks.
            // A plain horizontal Row in a SingleChildScrollView (not
            // ListView.builder) self-sizes to the tile's intrinsic height.
            //
            // Ranking order is pinned left-to-right regardless of app
            // language: `HOME_Default.png` and the `hotel_guest_app.fig`
            // board both show the rank-1 hotel (`فندق الواحة`) on the left
            // and rank-2 (`فندق المرسى`) on the right, in the *same* Arabic/
            // RTL frame — i.e. this carousel does not mirror for RTL (like
            // the design system's own "numerals/prices stay LTR" rule,
            // `design-system-tokens.md` §8). Left as an ordinary Row it would
            // auto-mirror under RTL Directionality and show rank-1 on the
            // right instead, so the ordering axis is pinned to LTR while each
            // card's own text keeps the real app [Directionality].
            //
            // The scroll container itself must share that LTR pin, not just
            // the Row: a [SingleChildScrollView] resolves its own "start"
            // edge (where the unscrolled position rests) from the ambient
            // Directionality too. Pinning only the Row left the ScrollView
            // resting at the RTL "start" (the right edge) while the content
            // it scrolls is LTR-ordered — with more than 2 hotels (the real
            // dummy data has 4) that stranded the first, highest-ranked
            // cards off-screen at rest.
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                final double w = (c.maxWidth - AppSpacing.md) / 2;
                final TextDirection cardTextDirection = Directionality.of(context);
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (int i = 0; i < view.featuredHotels.length; i++) ...<Widget>[
                          SizedBox(
                            width: w,
                            child: Directionality(
                              textDirection: cardTextDirection,
                              child: HotelSummaryCard(
                                hotel: view.featuredHotels[i],
                                layout: HotelCardLayout.tile,
                                onTap: () => onOpenHotel(view.featuredHotels[i].id),
                              ),
                            ),
                          ),
                          if (i != view.featuredHotels.length - 1)
                            const SizedBox(width: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Loading placeholder for the `فنادق المجموعة` carousel — two tile-shaped
/// skeletons, matching the real row's proportions instead of a spinner
/// (`lib/core/widgets/skeleton.dart`).
class _FeaturedHotelsSkeleton extends StatelessWidget {
  const _FeaturedHotelsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double w = (c.maxWidth - AppSpacing.md) / 2;
          Widget tile() => SizedBox(
                width: w,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SkeletonImage(
                        width: double.infinity,
                        height: 128,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.card),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.xs,
                          AppSpacing.sm,
                          AppSpacing.sm,
                        ),
                        child: SkeletonText(lines: 2, lineHeight: 14),
                      ),
                    ],
                  ),
                ),
              );
          return Row(
            children: <Widget>[
              tile(),
              const SizedBox(width: AppSpacing.md),
              tile(),
            ],
          );
        },
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColorTokens c = context.colors;
    return Center(
      child: Material(
        color: c.bgSurface,
        shape: CircleBorder(side: BorderSide(color: c.borderDefault)),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: Icon(icon, size: 20),
          tooltip: tooltip,
          onPressed: onPressed,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
