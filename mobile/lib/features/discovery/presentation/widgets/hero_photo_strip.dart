import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'hotel_thumbnail.dart';

/// The overlapping thumbnail row that straddles the lower edge of a hero image
/// (`HOTEL_Detail`, `08 · تفاصيل الغرفة`). The last tile shows `+N` for the
/// remaining photos.
///
/// [galleryUrls] are the hotel's real gallery photo URLs
/// (`PublicHotelResource.gallery[].url`), in display order. A tile beyond
/// the number of real URLs on hand (fewer photos than [visible]) shows the
/// branded placeholder — never a stock/seeded photo.
class HeroPhotoStrip extends StatelessWidget {
  const HeroPhotoStrip({
    super.key,
    required this.galleryUrls,
    required this.totalPhotos,
    this.visible = 3,
  });

  final List<String> galleryUrls;
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
                imageUrl: i < galleryUrls.length ? galleryUrls[i] : null,
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
