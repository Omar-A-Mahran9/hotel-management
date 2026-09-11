import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';

/// Shown while [AuthState.unknown] — the stored session is being restored. The
/// router replaces it with the entry screen or the home screen as soon as
/// restore resolves.
///
/// Figma `14 · Entry` (frame 1): a full-bleed warm-brown field with the brand
/// lock-up — mark, "Hotel System" wordmark and the `إقامة بلا أوراق` tagline —
/// optically centred (sitting a little above the true middle). No spinner.
class AuthSplashPage extends StatelessWidget {
  const AuthSplashPage({super.key});

  /// The splash's warm "oud" brown (`oud/700` = `color/bg/primary`, light). The
  /// splash renders before the themed surface is ready, so it references the
  /// primitive directly and commits to a single fixed look.
  static const Color _background = AppPrimitives.oud700;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _background,
      ),
      child: const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Align(
            alignment: Alignment(0, -0.12),
            child: BrandLogo(
              variant: BrandLogoVariant.stacked,
              assetMark: true,
              wordmarkColor: AppPrimitives.white,
              taglineColor: AppPrimitives.gold200,
              markSize: 34,
              showTagline: true,
            ),
          ),
        ),
      ),
    );
  }
}
