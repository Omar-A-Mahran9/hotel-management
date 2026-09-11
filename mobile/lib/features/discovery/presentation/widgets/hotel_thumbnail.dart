import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_icons.dart';

/// Hotel / room imagery for cards, heroes and list rows.
///
/// Backed by [AppImage.network]: [imageUrl] is the real `logo_url` /
/// `cover_url` / gallery `url` the backend returned for this hotel/room —
/// `null` (no photo on file, e.g. rooms, which have no media field in the
/// guest API yet) always renders the branded placeholder, never a stock or
/// seeded photo (mobile/docs — real-API mode must never fake per-entity
/// imagery). A network failure degrades to the same placeholder.
class HotelThumbnail extends StatelessWidget {
  const HotelThumbnail({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius,
    this.icon = AppIcons.hotel,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppImage.network(
      url: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      fallbackIcon: icon,
    );
  }
}
