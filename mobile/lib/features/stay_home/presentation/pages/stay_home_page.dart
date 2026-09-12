import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/bottom_nav_navigation.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/stay_date_format.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../checkout/presentation/state/checkout_providers.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../../stay_services/domain/entities/hotel_service.dart';
import '../../../stay_services/presentation/state/stay_services_providers.dart';
import '../state/stay_home_providers.dart';

/// `STAY_Home.png` — the "الخدمات" bottom-nav root: the guest's real
/// current-stay hub, not a placeholder. Room/hotel card, quick-action tiles
/// resolved against the hotel's real service catalogue, and the live folio
/// outstanding total.
class StayHomePage extends ConsumerWidget {
  const StayHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<Reservation?> async = ref.watch(currentStayProvider);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(l10n.stayHomeTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => Center(child: LoadingView(label: l10n.stateLoadingTitle)),
          error: (Object error, StackTrace _) {
            final failure = ErrorMapper.toFailure(error);
            return MessageView(
              icon: AppIcons.warning,
              title: l10n.stateErrorTitle,
              message: failure.localizedMessage(l10n),
              actionLabel: l10n.actionRetry,
              onAction: () => ref.invalidate(currentStayProvider),
            );
          },
          data: (Reservation? stay) => stay == null
              ? MessageView(
                  icon: AppIcons.navServicesOutline,
                  title: l10n.stayHomeNoActiveStayTitle,
                  message: l10n.stayHomeNoActiveStayBody,
                )
              : _Body(reservation: stay),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.services,
        onSelected: (AppNavTab tab) => goToNavTab(context, tab),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final Locale locale = Localizations.localeOf(context);
    final AppColorTokens c = context.colors;
    final AsyncValue<ServiceCatalogue> catalogue =
        ref.watch(serviceCatalogueProvider(reservation.hotelId));
    final AsyncValue<int> outstanding = ref
        .watch(folioProvider(reservation.id))
        .whenData((folio) => folio.outstandingTotal.amount);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      children: <Widget>[
        AppCard(
          style: AppCardStyle.inverse,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.stayHomeRoomLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: c.textOnInverse.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      reservation.roomNumber ?? '—',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: c.textOnInverse,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    reservation.hotelName.resolve(locale),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: c.textOnInverse,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    formatStayDateRange(locale, reservation.stay),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.textOnInverse.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.stayHomeServicesHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.pushNamed(
                AppRoutes.stayServicesName,
                pathParameters: <String, String>{'reservationId': reservation.id},
              ),
              child: Text(l10n.commonSeeAll),
            ),
          ],
        ),
        catalogue.when(
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (ServiceCatalogue value) => _QuickActionsGrid(
            reservation: reservation,
            catalogue: value,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          style: AppCardStyle.outlined,
          child: Row(
            children: <Widget>[
              MoneyText(outstanding.valueOrNull ?? 0),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(l10n.stayHomeExtraCharges, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      l10n.stayHomeExtraChargesNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.reservation, required this.catalogue});

  final Reservation reservation;
  final ServiceCatalogue catalogue;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final HotelService? cleaning = findServiceByKeyword(catalogue, 'cleaning');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: <Widget>[
        _ActionTile(
          icon: AppIcons.roomService,
          label: l10n.stayHomeRoomService,
          onTap: () => context.pushNamed(
            AppRoutes.stayServicesName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        _ActionTile(
          icon: AppIcons.cleaning,
          label: l10n.stayHomeRoomCleaning,
          onTap: cleaning == null
              ? null
              : () => context.pushNamed(
                    AppRoutes.serviceDetailName,
                    pathParameters: <String, String>{
                      'reservationId': reservation.id,
                      'serviceId': cleaning.id,
                    },
                  ),
        ),
        _ActionTile(
          icon: AppIcons.extendStay,
          label: l10n.stayHomeExtendStay,
          onTap: () => context.pushNamed(
            AppRoutes.extendStayName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
        _ActionTile(
          icon: AppIcons.report,
          label: l10n.stayHomeReportProblem,
          onTap: () => context.pushNamed(
            AppRoutes.reportProblemName,
            pathParameters: <String, String>{'reservationId': reservation.id},
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      style: AppCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.bgSubtle,
              borderRadius: AppRadius.allMd,
            ),
            child: Icon(icon, size: 20, color: context.colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
