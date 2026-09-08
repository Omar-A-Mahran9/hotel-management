import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/identity_document.dart';
import '../identity_verification_l10n.dart';

/// Step 1 — choose a document type and attach a photo of the ID.
///
/// The "capture" here is a deterministic placeholder ([CapturedImage.dummy]) —
/// no camera/file-picker package is pulled in for this phase and no real image
/// bytes are held. A live build would swap the capture button for the provider
/// SDK / platform picker and hand the bytes straight to the upload data source.
class IdentityDocumentStep extends StatefulWidget {
  const IdentityDocumentStep({
    super.key,
    required this.onSubmit,
    this.submitting = false,
    this.retryBanner,
  });

  final void Function(IdentityDocumentType type) onSubmit;
  final bool submitting;
  final Widget? retryBanner;

  @override
  State<IdentityDocumentStep> createState() => _IdentityDocumentStepState();
}

class _IdentityDocumentStepState extends State<IdentityDocumentStep> {
  IdentityDocumentType _type = IdentityDocumentType.passport;
  bool _captured = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final bool canSubmit =
        _captured && !widget.submitting;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            children: <Widget>[
              if (widget.retryBanner != null) ...<Widget>[
                widget.retryBanner!,
                const SizedBox(height: AppSpacing.md),
              ],
              Text(l10n.identityDocumentStepTitle,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.identityDocumentStepBody,
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.identityDocumentTypeLabel,
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: <Widget>[
                  for (final IdentityDocumentType t
                      in IdentityDocumentType.values)
                    ChoiceChip(
                      label: Text(l10n.identityDocumentTypeLabelFor(t)),
                      selected: _type == t,
                      onSelected: widget.submitting
                          ? null
                          : (_) => setState(() => _type = t),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Row(
                  children: <Widget>[
                    Icon(
                      _captured
                          ? Icons.check_circle_outline
                          : Icons.badge_outlined,
                      color: _captured
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _captured
                            ? l10n.identityDocumentCapturedLabel
                            : l10n.identityDocumentCaptureCta,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.submitting
                          ? null
                          : () => setState(() => _captured = true),
                      child: Text(l10n.identityDocumentCaptureCta),
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
            label: l10n.identityDocumentSubmitCta,
            isLoading: widget.submitting,
            onPressed: canSubmit ? () => widget.onSubmit(_type) : null,
          ),
        ),
      ],
    );
  }
}
