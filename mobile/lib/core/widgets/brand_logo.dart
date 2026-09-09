import 'package:flutter/material.dart';

import '../localization/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// How the brand lock-up is arranged.
enum BrandLogoVariant {
  /// Mark + wordmark on one line (the entry card).
  horizontal,

  /// Mark above a centred wordmark + tagline (the splash).
  stacked,

  /// The building mark only.
  markOnly,
}

/// The "Hotel System" brand lock-up.
///
/// The Figma logo is a line-art three-tower mark with a peaked centre spire
/// beside/above the "Hotel System" wordmark (`إقامة بلا أوراق` tagline on the
/// splash). No asset was exported, so the mark is reconstructed as a vector
/// ([_BuildingMark]).
///
/// On the **splash** the whole lock-up is white on brown; on the **entry card**
/// the mark is bronze and the wordmark is dark ink — hence the separate
/// [markColor] / [wordmarkColor].
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.variant = BrandLogoVariant.horizontal,
    this.markColor,
    this.wordmarkColor,
    this.markSize = 30,
    this.showTagline = false,
    this.taglineColor,
  });

  final BrandLogoVariant variant;

  /// Mark colour. Defaults to the bronze accent.
  final Color? markColor;

  /// Wordmark colour. Defaults to [markColor].
  final Color? wordmarkColor;

  final double markSize;
  final bool showTagline;
  final Color? taglineColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final Color mc =
        markColor ??
        theme.extension<AppSemanticColors>()?.accent ??
        AppColors.bronze500;
    final Color wc = wordmarkColor ?? mc;
    final Color tc = taglineColor ?? wc.withValues(alpha: 0.7);

    final Widget mark = _BuildingMark(size: markSize, color: mc);

    switch (variant) {
      case BrandLogoVariant.markOnly:
        return mark;

      case BrandLogoVariant.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            mark,
            SizedBox(width: markSize * 0.42),
            Text(
              l10n.appName,
              style: AppTypography.price(
                wc,
                size: markSize * 0.66,
              ).copyWith(letterSpacing: 0.2),
            ),
          ],
        );

      case BrandLogoVariant.stacked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _BuildingMark(size: markSize * 1.7, color: mc),
            SizedBox(height: markSize * 0.55),
            Text(
              l10n.appName,
              style: AppTypography.price(
                wc,
                size: markSize * 0.72,
              ).copyWith(letterSpacing: 0.3),
            ),
            if (showTagline) ...<Widget>[
              SizedBox(height: markSize * 0.22),
              Text(
                l10n.entryTagline,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: markSize * 0.42,
                  fontWeight: AppTypography.medium,
                  letterSpacing: 0.4,
                  color: tc,
                ),
              ),
            ],
          ],
        );
    }
  }
}

/// Line-art brand mark: three towers, the centre one taller with a peaked spire
/// and a short vertical accent — a faithful reconstruction of the Figma glyph.
class _BuildingMark extends StatelessWidget {
  const _BuildingMark({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // The mark is wider than tall (~1.15:1).
    return CustomPaint(
      size: Size(size * 1.15, size),
      painter: _MarkPainter(color),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color);

  final Color color;

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.color != color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double sw = h * 0.085;

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final double base = h * 0.94;

    // Left tower — shorter, flat top.
    _rect(canvas, stroke, w * 0.02, h * 0.50, w * 0.26, base);
    // Right tower — shortest, flat top.
    _rect(canvas, stroke, w * 0.72, h * 0.56, w * 0.98, base);

    // Centre tower — tallest, with a peaked spire.
    final Path centre = Path()
      ..moveTo(w * 0.33, base)
      ..lineTo(w * 0.33, h * 0.30)
      ..lineTo(w * 0.50, h * 0.06)
      ..lineTo(w * 0.67, h * 0.30)
      ..lineTo(w * 0.67, base);
    canvas.drawPath(centre, stroke);

    // Short vertical accent inside the centre tower (the "spire").
    canvas.drawLine(Offset(w * 0.50, base), Offset(w * 0.50, h * 0.44), stroke);
  }

  void _rect(Canvas c, Paint p, double l, double t, double r, double b) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(l, t, r, b),
        Radius.circular(p.strokeWidth * 0.4),
      ),
      p,
    );
  }
}
