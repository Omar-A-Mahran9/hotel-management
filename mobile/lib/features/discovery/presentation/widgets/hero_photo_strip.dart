import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_image.dart';
import 'hotel_thumbnail.dart';

/// The overlapping thumbnail row that straddles the lower edge of a hero image
/// (`HOTEL_Detail`, `08 · تفاصيل الغرفة`). The last tile shows `+N` for the
/// remaining photos.
class HeroPhotoStrip extends StatelessWidget {
  const HeroPhotoStrip({
    super.key,
    required this.seed,
    required this.totalPhotos,
    this.visible = 3,
  });

  final String seed;
  final int totalPhotos;
  final int visible;

  @override
  Widget build(BuildContext context) {
    final AppColorTokens c = context.colors;
    final int shown = totalPhotos < visible ? totalPhotos : visible;
    final int overflow = totalPhotos - shown;

    return SizedBox(
      height: 64,
      child: Row(
        children: <Widget>[
          if (overflow > 0) ...<Widget>[
            _Tile(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.bgInverse,
                  borderRadius: AppRadius.allMd,
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: AppTypography.labelStrong(c.textOnInverse),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          for (int i = 0; i < shown; i++) ...<Widget>[
            _Tile(
              child: HotelThumbnail(
                seed: '$seed-photo-$i',
                pool: AppImages.roomThumbs,
                width: 64,
                height: 64,
                borderRadius: AppRadius.allMd,
              ),
            ),
            if (i != shown - 1) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: AppRadius.allMd,
        border: Border.all(color: AppPrimitives.white, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
