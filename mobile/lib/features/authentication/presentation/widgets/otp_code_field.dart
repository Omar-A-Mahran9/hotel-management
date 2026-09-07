import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// The six-box one-time-code input from `09 · Authentication`.
///
/// One real [TextField] captures the digits (so paste and OS SMS autofill keep
/// working); the boxes above are a presentation of its value. Always laid out
/// left-to-right. When [hasError] the boxes take the error colour, matching the
/// reference's red state.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.length,
    required this.controller,
    this.enabled = true,
    this.hasError = false,
    this.autofocus = true,
    this.onCompleted,
  });

  final int length;
  final TextEditingController controller;
  final bool enabled;
  final bool hasError;
  final bool autofocus;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
    if (widget.controller.text.length == widget.length) {
      widget.onCompleted?.call(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String value = widget.controller.text;
    final Color borderColor =
        widget.hasError ? theme.colorScheme.error : theme.colorScheme.outline;
    final Color textColor =
        widget.hasError ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List<Widget>.generate(widget.length, (int i) {
                final bool filled = i < value.length;
                return Container(
                  width: 44,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.allMd,
                    border: Border.all(
                      color: borderColor,
                      width: filled ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    filled ? value[i] : '',
                    style: theme.textTheme.headlineSmall?.copyWith(color: textColor),
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
