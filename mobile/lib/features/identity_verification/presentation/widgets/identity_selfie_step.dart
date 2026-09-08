import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';

/// Step 2 — attach a live selfie.
///
/// Same deterministic-placeholder capture as the document step: no camera
/// package, no image bytes retained. A live build swaps the capture button for
/// the platform camera and hands the bytes to the upload data source.
class IdentitySelfieStep extends StatefulWidget {
  const IdentitySelfieStep({
    super.key,
    required this.onSubmit,
    this.submitting = false,
  });

  final VoidCallback onSubmit;
  final bool submitting;

  @override
  State<IdentitySelfieStep> createState() => _IdentitySelfieStepState();
}

class _IdentitySelfieStepState extends State<IdentitySelfieStep> {
  bool _captured = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            children: <Widget>[
              Text(l10n.identitySelfieStepTitle,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.identitySelfieStepBody,
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Row(
                  children: <Widget>[
                    Icon(
                      _captured
                          ? Icons.check_circle_outline
                          : Icons.face_outlined,
                      color: _captured
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _captured
                            ? l10n.identitySelfieCapturedLabel
                            : l10n.identitySelfieCaptureCta,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.submitting
                          ? null
                          : () => setState(() => _captured = true),
                      child: Text(l10n.identitySelfieCaptureCta),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.xs,
            AppSpacing.pageGutter,
            AppSpacing.md,
          ),
          child: PrimaryButton(
            label: l10n.identitySelfieSubmitCta,
            isLoading: widget.submitting,
            onPressed:
                _captured && !widget.submitting ? widget.onSubmit : null,
          ),
        ),
      ],
    );
  }
}
