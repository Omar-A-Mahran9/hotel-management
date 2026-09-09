import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'app_icons.dart';

/// The real Figma imagery, addressed by *purpose* rather than by path.
///
/// Filenames keep the original Figma content hash (see
/// `md/mobile/Design/assets/manifest.json`) so every asset stays traceable to
/// the source. Nothing outside this file references an image path.
abstract final class AppImages {
  static const String _dir = 'assets/images';

  // ── Named slots (mapped from the Figma frames) ───────────────────────────

  /// Jeddah waterfront at night — the entry / welcome hero (Figma `01 · Entry`).
  static const String entryHero =
      '$_dir/11_d7f543b9397080a7e25c7302da8858468b895fc8.jpg';

  /// AlUla landscape — the flagship hotel hero ("فندق الواحة").
  static const String hotelHero =
      '$_dir/02_32407aee78875a7aafe46054f84a7e671bb98208.png';

  /// Warm room interior — the room-detail hero.
  static const String roomHero =
      '$_dir/04_89cb64d400bf6ecb804e4f2f7eadac4f30379a08.jpg';

  // ── The full pool, in manifest order ────────────────────────────────────

  static const List<String> all = <String>[
    '$_dir/01_1ce2fe86e1210b2d74639ff3901e2fca59e4a352.jpg',
    '$_dir/02_32407aee78875a7aafe46054f84a7e671bb98208.png',
    '$_dir/03_6d2ba4197a4e33f4a782a334b5ea126ebd57dd8e.png',
    '$_dir/04_89cb64d400bf6ecb804e4f2f7eadac4f30379a08.jpg',
    '$_dir/05_8d58e59e0091620d43dacd928315f92c1e0fadae.png',
    '$_dir/06_8f904f899d29b6c869ca90ffabbbc79854937da3.jpg',
    '$_dir/07_a50049dcb99cc4319992ca90beeab0cb2766d0a3.jpg',
    '$_dir/08_aa952c3af5525787e169a59be6585c8c5e0280ee.jpg',
    '$_dir/09_b5b189f11426f1d30a9282ec354450e0d27e1775.jpg',
    '$_dir/10_b91e06ad771c30cd6f033e63ace539dd7249068b.jpg',
    '$_dir/11_d7f543b9397080a7e25c7302da8858468b895fc8.jpg',
    '$_dir/12_e68b89d483817b715f597b101253fc757e57c4d5.jpg',
    '$_dir/13_e93d92b52ce843caefc6d823839aec1880d67a3f.png',
  ];

  /// Landscape-ish subset for hotel / room cards and heroes.
  static const List<String> scenic = <String>[
    '$_dir/02_32407aee78875a7aafe46054f84a7e671bb98208.png',
    '$_dir/04_89cb64d400bf6ecb804e4f2f7eadac4f30379a08.jpg',
    '$_dir/09_b5b189f11426f1d30a9282ec354450e0d27e1775.jpg',
    '$_dir/10_b91e06ad771c30cd6f033e63ace539dd7249068b.jpg',
    '$_dir/01_1ce2fe86e1210b2d74639ff3901e2fca59e4a352.jpg',
    '$_dir/07_a50049dcb99cc4319992ca90beeab0cb2766d0a3.jpg',
    '$_dir/12_e68b89d483817b715f597b101253fc757e57c4d5.jpg',
  ];

  /// Small room-gallery thumbnails.
  static const List<String> roomThumbs = <String>[
    '$_dir/03_6d2ba4197a4e33f4a782a334b5ea126ebd57dd8e.png',
    '$_dir/05_8d58e59e0091620d43dacd928315f92c1e0fadae.png',
    '$_dir/13_e93d92b52ce843caefc6d823839aec1880d67a3f.png',
    '$_dir/06_8f904f899d29b6c869ca90ffabbbc79854937da3.jpg',
    '$_dir/08_aa952c3af5525787e169a59be6585c8c5e0280ee.jpg',
  ];

  /// Deterministically pick an image from [pool] for a stable [seed] (a hotel
  /// or room id). The same seed always maps to the same asset.
  static String forSeed(String seed, {List<String>? pool}) {
    final List<String> options = pool ?? scenic;
    final int hash = seed.codeUnits.fold<int>(7, (int a, int c) => a * 31 + c);
    return options[hash.abs() % options.length];
  }
}

/// Renders a Figma image asset with rounded clipping, a sensible [BoxFit], and a
/// graceful branded fallback if the asset is missing / fails to decode.
///
/// Use [AppImage.seeded] for cards/heroes that don't have a real per-entity
/// image yet — it maps a stable id to a deterministic Figma photo instead of a
/// gradient placeholder.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppRadius.allMd,
    this.fallbackIcon = AppIcons.hotel,
  });

  AppImage.seeded({
    super.key,
    required String seed,
    List<String>? pool,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppRadius.allMd,
    this.fallbackIcon = AppIcons.hotel,
  }) : asset = AppImages.forSeed(seed, pool: pool);

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            _Fallback(width: width, height: height, icon: fallbackIcon),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.width, this.height, required this.icon});

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Figma renders unfilled image slots as a plain warm-grey box — match that
    // rather than a branded gradient.
    return Container(
      width: width,
      height: height,
      color: AppColors.bronze200.withValues(alpha: 0.45),
      child: Center(child: Icon(icon, size: 26, color: AppColors.ink400)),
    );
  }
}
