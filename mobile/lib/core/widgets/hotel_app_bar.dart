import 'package:flutter/material.dart';

/// Standard app bar for the Guest App. Thin wrapper over [AppBar] that pins the
/// design-system styling (from [AppBarTheme]) and keeps a single import for
/// screens. Title text is provided by the caller.
class HotelAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HotelAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
    );
  }
}
