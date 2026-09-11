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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../state/language_selection_controller.dart';

/// `01 · Entry` — the first-run language screen, shown after the splash and
/// before the entry welcome screen.
///
/// Arabic is the default: it is pre-selected and marked "افتراضي", and the whole
/// screen renders in Arabic on first run (the app has no stored preference yet).
/// Tapping a row switches the app language live; "متابعة" confirms the choice
/// and continues to the entry screen.
class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  @override
  void initState() {
    super.initState();
    // No preference stored yet → commit to Arabic so this screen (and the entry
    // screen after it) render Arabic-first, matching the design.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(localeControllerProvider) == null) {
        ref
            .read(localeControllerProvider.notifier)
            .set(SupportedLocales.arabic);
      }
    });
  }

  void _select(Locale locale) =>
      ref.read(localeControllerProvider.notifier).set(locale);

  void _continue() {
    ref.read(languageSelectedProvider.notifier).markSelected();
    context.goNamed(AppRoutes.welcomeName);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final String selected =
        (ref.watch(localeControllerProvider) ?? SupportedLocales.arabic)
            .languageCode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: HotelAppBar(title: l10n.languageScreenTitle),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.lg,
              AppSpacing.pageGutter,
              AppSpacing.lg,
            ),
            children: <Widget>[
              Text(
                l10n.languageScreenHeading,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.languageScreenBody,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard.list(
                child: Column(
                  children: <Widget>[
                    _LanguageOption(
                      label: l10n.languageArabic,
                      selected: selected == 'ar',
                      tag: l10n.languageDefaultTag,
                      onTap: () => _select(SupportedLocales.arabic),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                      color: context.colors.borderDefault,
                    ),
                    _LanguageOption(
                      label: l10n.languageEnglish,
                      selected: selected == 'en',
                      onTap: () => _select(SupportedLocales.english),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar.actions(
          primary: PrimaryButton(
            label: l10n.commonContinue,
            onPressed: _continue,
          ),
        ),
      ),
    );
  }
}

/// One selectable language row inside the card: a globe glyph, the language name
/// (written in that language), an optional "افتراضي" marker, and a check on the
/// active row.
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tag,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColorTokens c = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? c.bgPrimarySubtle : c.bgSubtle,
                borderRadius: AppRadius.allSm,
              ),
              child: Icon(
                AppIcons.language,
                size: 18,
                color: selected ? c.textAccent : c.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label, style: theme.textTheme.titleSmall),
            ),
            if (tag != null) ...<Widget>[
              Text(tag!, style: theme.textTheme.labelMedium),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (selected)
              Icon(AppIcons.success, size: AppSpacing.lg, color: c.textAccent)
            else
              const SizedBox(width: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
