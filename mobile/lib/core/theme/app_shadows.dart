import 'package:flutter/material.dart';

/// Elevation tokens. The Figma design language is minimal: *"a 1px border
/// separates better than a shadow in a minimal UI"* (`.fig` DS note). Shadows
/// are barely-there and warm-tinted (toward the brand brown) — never Material's
/// neutral-black drop shadows. Cards pair a hairline border with [card].
abstract final class AppShadows {
  static const Color _tint = Color(0x0F3A241A); // ~6% warm brown
  static const Color _tintRaised = Color(0x14000000);

  /// Resting surface (cards, list containers, search field). Whisper-soft.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: _tint, blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Raised surface (sticky bottom action bar, bottom sheet, sticky header).
  /// Casts upward so content reads as sliding under it.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(color: _tintRaised, blurRadius: 24, offset: Offset(0, -8)),
  ];

  /// No shadow — dark theme, where surfaces separate by colour.
  static const List<BoxShadow> none = <BoxShadow>[];
}
