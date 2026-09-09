import 'package:flutter/material.dart';

/// Elevation tokens. The Figma design language uses soft, low-contrast shadows
/// tinted warm (toward the brand brown) on the warm paper background — never
/// Material's default neutral-black drop shadows.
abstract final class AppShadows {
  /// Warm shadow tint — a very transparent brown rather than pure black.
  static const Color _tint = Color(0x14382A20);
  static const Color _tintStrong = Color(0x1F2E2018);

  /// Resting surface (cards, list containers, search field).
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: _tint, blurRadius: 18, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A382A20), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Raised surface (bottom action bars, bottom sheets, sticky headers).
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(color: _tintStrong, blurRadius: 28, offset: Offset(0, -6)),
  ];

  /// No shadow — for dark theme where the surface separates by colour.
  static const List<BoxShadow> none = <BoxShadow>[];
}
