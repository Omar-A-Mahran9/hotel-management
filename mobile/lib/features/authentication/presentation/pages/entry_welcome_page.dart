import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/supported_locales.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../state/login_flow_controller.dart';

/// `01 · Entry` — first run. Establishes the promise: book, verify and enter
/// from the phone. A hero panel with a bottom sheet carrying the brand, the
/// headline and a single call to action, plus a language switch (SRS §3.1).
class EntryWelcomePage extends ConsumerWidget {
  const EntryWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.brown900,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                // Placeholder hero. No bundled image assets in this phase
                // (mirrors Phase 0's system-font decision) — a branded photo
                // drops in here later without touching layout.
                const _HeroBackdrop(),
                SafeArea(
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: _LanguageSwitch(
                        currentLocale: locale,
                        onChanged: (Locale next) => ref
                            .read(localeControllerProvider.notifier)
                            .set(next),
                      ),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.apartment_rounded,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(l10n.appName, style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.entryTagline, style: theme.textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.entryHeadline,
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.entrySubtext, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: l10n.entryStartAction,
                      onPressed: () {
                        ref.read(loginFlowControllerProvider.notifier).reset();
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
    );
  }
}

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF1B2A4A),
            Color(0xFF223A63),
            AppColors.brown900,
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({
    required this.currentLocale,
    required this.onChanged,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isArabic = currentLocale.languageCode == 'ar';
    return Semantics(
      label: l10n.entryLanguageSwitchLabel,
      button: true,
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: AppColors.white),
        onPressed: () => onChanged(
          isArabic ? SupportedLocales.english : SupportedLocales.arabic,
        ),
        icon: const Icon(Icons.language, size: 18),
        label: Text(isArabic ? l10n.languageEnglish : l10n.languageArabic),
      ),
    );
  }
}
