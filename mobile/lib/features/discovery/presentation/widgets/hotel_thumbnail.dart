import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_icons.dart';

/// Hotel / room imagery for cards and list rows.
///
/// Backed by [AppImage.seeded]: a stable id ([seed]) maps deterministically to
/// one of the real Figma photos, so a hotel or room always shows the same
/// picture. (Per-entity image URLs from the API are a later concern; this keeps
/// the visuals real in the meantime instead of a gradient placeholder.)
class HotelThumbnail extends StatelessWidget {
  const HotelThumbnail({
    super.key,
    required this.seed,
    this.height,
    this.width,
    this.borderRadius,
    this.icon = AppIcons.hotel,
    this.pool,
  });

  final String seed;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final IconData icon;
  final List<String>? pool;

  @override
  Widget build(BuildContext context) {
    return AppImage.seeded(
      seed: seed,
      pool: pool ?? AppImages.scenic,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      fallbackIcon: icon,
    );
  }
}
