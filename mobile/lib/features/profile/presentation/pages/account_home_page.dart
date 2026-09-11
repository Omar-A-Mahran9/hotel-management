import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/bottom_nav_navigation.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/settings_row.dart';
import '../../../authentication/presentation/state/auth_controller.dart';
import '../../../bookings/domain/bookings_filter.dart';
import '../../../bookings/presentation/state/bookings_providers.dart';
import '../state/account_providers.dart';
import '../state/account_summary.dart';

/// `PROFILE_Home.png` — the "حسابي" bottom-nav root: the loyalty card,
/// trusted-guest status, and quick links, ending with sign-out (moved here
/// from `DiscoverPage`'s app bar per `docs/design-system.md`).
class AccountHomePage extends ConsumerWidget {
  const AccountHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<AccountSummary> async = ref.watch(accountSummaryProvider);

    return Scaffold(
      appBar: HotelAppBar(title: l10n.accountTitle, automaticallyImplyLeading: false),
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
              onAction: () {
                ref.invalidate(accountSummaryProvider);
                ref.invalidate(bookingsListProvider);
              },
            );
          },
          data: (AccountSummary summary) => _Body(summary: summary),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.account,
        onSelected: (AppNavTab tab) => goToNavTab(context, tab),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.summary});

  final AccountSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final Locale locale = Localizations.localeOf(context);
    final AppColorTokens c = context.colors;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      children: <Widget>[
        AppCard(
          style: AppCardStyle.inverse,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.accountLoyaltyProgramTitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.textOnInverse.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${summary.loyalty.pointsBalance} ${l10n.accountLoyaltyPointsSuffix}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: c.textOnInverse),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.accountLoyaltyDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.textOnInverse.withValues(alpha: 0.85),
                    ),
              ),
              if (summary.nightlyRate != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      l10n.accountLoyaltyPerNightLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: c.textOnInverse.withValues(alpha: 0.7),
                          ),
                    ),
                    MoneyText(
                      summary.nightlyRate!.amount,
                      color: c.textOnInverse,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (summary.trustedGuest) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          InfoBanner(
            tone: InfoBannerTone.warning,
            title: l10n.accountTrustedGuestTitle,
            message: l10n.accountTrustedGuestBody,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppCard(
          style: AppCardStyle.outlined,
          child: Column(
            children: <Widget>[
              SettingsRow(
                icon: AppIcons.invoice,
                label: l10n.accountPreviousStaysLabel,
                value: '${summary.previousStaysCount}',
                onTap: () {
                  ref.read(bookingsFilterProvider.notifier).state =
                      BookingsFilter.past;
                  context.goNamed(AppRoutes.bookingsName);
                },
              ),
              const Divider(height: AppSpacing.lg),
              SettingsRow(
                icon: AppIcons.edit,
                label: l10n.accountPreferencesLabel,
                value: summary.preferredRoomName?.resolve(locale) ??
                    l10n.accountPreferencesEmpty,
              ),
              const Divider(height: AppSpacing.lg),
              SettingsRow(
                icon: AppIcons.privacy,
                label: l10n.accountPrivacyLabel,
                onTap: () => _comingSoon(context, l10n),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          style: AppCardStyle.outlined,
          child: SettingsRow(
            icon: AppIcons.support,
            label: l10n.accountHelpSupportLabel,
            onTap: () => _comingSoon(context, l10n),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          style: AppCardStyle.outlined,
          child: SettingsRow(
            icon: AppIcons.logout,
            label: l10n.authSignOut,
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  void _comingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.navComingSoon)));
  }
}
