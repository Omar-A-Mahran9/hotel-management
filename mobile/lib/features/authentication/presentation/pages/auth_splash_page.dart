import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/loading_view.dart';

/// Shown while [AuthState.unknown] — the stored session is being restored. The
/// router replaces it with the entry screen or the home screen as soon as
/// restore resolves.
class AuthSplashPage extends StatelessWidget {
  const AuthSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: LoadingView(label: context.l10n.stateLoadingTitle)),
    );
  }
}
