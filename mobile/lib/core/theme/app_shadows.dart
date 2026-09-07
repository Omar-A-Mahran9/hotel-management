import 'package:flutter/material.dart';

/// Elevation tokens. The design language uses soft, low-contrast shadows on a
/// warm background — not Material's default black drop shadows.
abstract final class AppShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];
}
