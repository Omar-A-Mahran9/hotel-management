import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder hotel imagery. This phase ships no bundled photos (same decision
/// as Phase 0/1); a deterministic warm gradient keyed off the hotel id keeps
/// cards visually distinct until real images arrive.
class HotelThumbnail extends StatelessWidget {
  const HotelThumbnail({
    super.key,
    required this.seed,
    this.height,
    this.width,
    this.borderRadius,
    this.icon = Icons.apartment_rounded,
  });

  final String seed;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final IconData icon;

  static const List<List<Color>> _palettes = <List<Color>>[
    <Color>[Color(0xFF3B2A1E), Color(0xFF6E4B32)],
    <Color>[Color(0xFF2E3B4E), Color(0xFF4C6377)],
    <Color>[Color(0xFF4A3B2A), Color(0xFF7C6142)],
    <Color>[Color(0xFF33403A), Color(0xFF57736A)],
    <Color>[Color(0xFF402C33), Color(0xFF6E4C57)],
  ];

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = _palettes[seed.hashCode.abs() % _palettes.length];
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette,
          ),
        ),
        child: Center(
          child: Icon(icon, color: AppColors.white.withValues(alpha: 0.55), size: 28),
        ),
      ),
    );
  }
}
