import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/supported_locales.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../state/login_flow_controller.dart';

/// `01 · Entry` — first run. A full-bleed hero photo fills the upper screen; a
/// rounded-top paper card carries the brand lock-up, the promise headline and a
/// single call to action. RTL-first (the Figma is Arabic).
class EntryWelcomePage extends ConsumerWidget {
  const EntryWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: const <Widget>[
                  AppImage(
                    asset: AppImages.entryHero,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.zero,
                  ),
                  // Soft fade into the card seam.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, 0.4),
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x00000000), Color(0x33000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.paper,
                borderRadius: AppRadius.topSheet,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _LanguageToggle(
                            currentLocale: locale,
                            onChanged: (Locale next) => ref
                                .read(localeControllerProvider.notifier)
                                .set(next),
                          ),
                          const Spacer(),
                          const Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerEnd,
                              child: BrandLogo(
                                markColor: AppColors.bronze500,
                                wordmarkColor: AppColors.ink900,
                                markSize: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.entryTagline,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.bronze500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.entryHeadline,
                        style: theme.textTheme.displaySmall?.copyWith(
                          height: 1.32,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.entrySubtext,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: l10n.entryStartAction,
                        onPressed: () {
                          ref
                              .read(loginFlowControllerProvider.notifier)
                              .reset();
                          context.goNamed(AppRoutes.signInName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small, discreet language switch. The Figma entry frame has no visible
/// toggle, but language switching is a first-class feature (`14 · Entry` has a
/// dedicated language screen that is not built yet) and the app must stay
/// switchable before sign-in — so it sits quietly opposite the logo.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.currentLocale, required this.onChanged});

  final Locale currentLocale;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isArabic = currentLocale.languageCode == 'ar';
    return Semantics(
      label: l10n.entryLanguageSwitchLabel,
      button: true,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
        onPressed: () => onChanged(
          isArabic ? SupportedLocales.english : SupportedLocales.arabic,
        ),
        child: Text(isArabic ? l10n.languageEnglish : l10n.languageArabic),
      ),
    );
  }
}
