import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Destructive action button — the solid red pill from the Figma cancel flows
/// (`تأكيد الإلغاء` on "إلغاء الحجز؟" / "إلغاء الطلب").
///
/// This is the reusable **visual** component only. It carries no cancellation
/// business logic — callers wire [onPressed] to their existing controller.
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
        disabledForegroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(54),
        textStyle: Theme.of(context).textTheme.labelLarge,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allPill),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
  }
}
