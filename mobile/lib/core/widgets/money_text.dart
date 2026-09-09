import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Centralised currency presentation.
///
/// The Figma renders money as **⟨Saudi Riyal mark⟩ + amount** (e.g. `450 ﷼`),
/// not the sentence form `SAR 450`. The Saudi Riyal symbol has no reliable
/// cross-platform glyph, so it is drawn as a small vector ([RiyalMark]) sized to
/// the surrounding text — a faithful reconstruction that stays crisp at every
/// size and in both themes.
///
/// This is presentation only. It never rounds, converts, or invents a rate —
/// [amount] is whatever the backend returned (minor-unit-free integer SAR).
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.style,
    this.color,
    this.markSize,
    this.semanticsLabel,
    this.suffix,
  });

  /// The amount in whole Saudi Riyals, exactly as the backend provides it.
  final num amount;

  /// Overrides the default price text style ([AppTypography.price]).
  final TextStyle? style;

  /// Overrides both the text and mark colour.
  final Color? color;

  /// Mark height; defaults to the resolved font size.
  final double? markSize;

  final String? semanticsLabel;

  /// Optional trailing label in a muted style — e.g. "/ night", "total".
  final String? suffix;

  static String _digits(BuildContext context, num value) {
    // Group thousands with a comma; keep Western digits (the app's `intl` CLDR
    // data formats `ar` with Western digits too, so prices stay consistent
    // with other numeric UI). Digit *shape* localisation, if wanted, belongs
    // in one place later.
    final String raw = value.toString();
    final List<String> parts = raw.split('.');
    final String intPart = parts.first;
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) out.write(',');
      out.write(intPart[i]);
    }
    if (parts.length > 1) out.write('.${parts[1]}');
    return out.toString();
  }

  /// Plain-text form for places that need a `String` (tooltips, semantics,
  /// `SnackBar`s), where the drawn [RiyalMark] can't be used: `"SAR 945"`.
  static String plain(BuildContext context, num amount) =>
      'SAR ${_digits(context, amount)}';

  @override
  Widget build(BuildContext context) {
    final TextStyle resolved =
        (style ?? AppTypography.price(_defaultColor(context))).copyWith(
          color: color,
        );
    final double size = markSize ?? resolved.fontSize ?? 16;
    final Color markColor = color ?? resolved.color ?? _defaultColor(context);
    final String text = _digits(context, amount);

    final TextStyle numberStyle = resolved.copyWith(
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final Color muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Semantics(
      label: semanticsLabel ??
          'SAR $text${suffix == null ? '' : ' $suffix'}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(text, style: numberStyle),
            const SizedBox(width: 3),
            RiyalMark(size: size * 0.92, color: markColor),
            if (suffix != null) ...<Widget>[
              const SizedBox(width: 4),
              Text(
                suffix!,
                style: (style ?? numberStyle).copyWith(
                  color: muted,
                  fontWeight: AppTypography.regular,
                  fontSize: (resolved.fontSize ?? 16) * 0.82,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _defaultColor(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>()?.accent ??
      AppColors.bronze500;
}

/// The Saudi Riyal currency mark, drawn to [size] (roughly a capital-letter
/// height). A geometric reconstruction: the reh-derived hook with the two
/// parallel base strokes of the modern symbol.
class RiyalMark extends StatelessWidget {
  const RiyalMark({super.key, this.size = 16, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c =
        color ??
        Theme.of(context).extension<AppSemanticColors>()?.accent ??
        AppColors.bronze500;
    return CustomPaint(
      size: Size(size * 1.02, size),
      painter: _RiyalPainter(c),
    );
  }
}

class _RiyalPainter extends CustomPainter {
  const _RiyalPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // The hook (a reh-like curve): down the right side, sweeping left at the
    // bottom.
    final Path hook = Path()
      ..moveTo(w * 0.82, h * 0.08)
      ..lineTo(w * 0.82, h * 0.46)
      ..cubicTo(w * 0.82, h * 0.78, w * 0.58, h * 0.92, w * 0.16, h * 0.92);
    canvas.drawPath(hook, stroke);

    // A short lead-in stroke at the top left, angled like the symbol's crown.
    canvas.drawLine(
      Offset(w * 0.30, h * 0.20),
      Offset(w * 0.62, h * 0.06),
      stroke,
    );

    // Two parallel base strokes.
    final Paint bar = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.06, h * 0.52),
      Offset(w * 0.46, h * 0.52),
      bar,
    );
    canvas.drawLine(
      Offset(w * 0.06, h * 0.70),
      Offset(w * 0.40, h * 0.70),
      bar,
    );
  }

  @override
  bool shouldRepaint(_RiyalPainter oldDelegate) => oldDelegate.color != color;
}
