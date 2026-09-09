import 'package:flutter/material.dart';

import 'app_icons.dart';

/// Standard app bar for the Guest App.
///
/// Figma app bars are flat, background-aware (no Material surface tint or
/// scroll elevation), with a **centred title** and a plain directional back
/// affordance — `←` in LTR, `→` in RTL (matching the Figma Arabic frames).
/// The visual defaults live in [ThemeData.appBarTheme]; this widget pins the
/// back glyph and keeps a single import for screens.
class HotelAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HotelAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final bool canPop = route?.canPop ?? false;
    final Widget? resolvedLeading =
        leading ??
        (automaticallyImplyLeading && canPop
            ? const _DirectionalBackButton()
            : null);

    return AppBar(
      title: Text(title, overflow: TextOverflow.ellipsis),
      centerTitle: centerTitle,
      actions: actions,
      leading: resolvedLeading,
      automaticallyImplyLeading: false,
    );
  }
}

/// Back button whose glyph follows the reading direction: `arrow_back` in LTR,
/// `arrow_forward` in RTL — so the Arabic layout shows the Figma's `→`.
class _DirectionalBackButton extends StatelessWidget {
  const _DirectionalBackButton();

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return IconButton(
      icon: Icon(AppIcons.backFor(rtl ? TextDirection.rtl : TextDirection.ltr)),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
