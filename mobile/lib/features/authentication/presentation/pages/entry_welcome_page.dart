import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../state/login_flow_controller.dart';

/// `01 · Entry` — first run. A single full-bleed hero photo fills the whole
/// screen; its lower third fades into the paper ground so the brand mark, the
/// promise headline and a single call to action read directly on the image.
/// RTL-first (the Figma is Arabic).
class EntryWelcomePage extends ConsumerWidget {
  const EntryWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    const Color paper = AppColors.paper;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: paper,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const AppImage(
              asset: AppImages.entryHero,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.zero,
            ),
            // The photo dissolves into the paper ground over its lower half so
            // the content sits on a calm, near-solid field while the top of the
            // frame stays a clean photograph.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    paper.withValues(alpha: 0),
                    paper.withValues(alpha: 0),
                    paper,
                  ],
                  stops: const <double>[0.0, 0.36, 0.82],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
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
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: BrandLogo(
                          variant: BrandLogoVariant.markOnly,
                          markColor: AppColors.bronze500,
                          markSize: 30,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
