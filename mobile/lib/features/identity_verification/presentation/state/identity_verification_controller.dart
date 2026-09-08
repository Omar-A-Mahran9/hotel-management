import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/identity_document.dart';
import '../../domain/entities/identity_verification_request.dart';
import '../../domain/entities/identity_verification_session.dart';
import 'identity_verification_providers.dart';

/// What the verification flow is doing right now, on top of the authoritative
/// [IdentityVerificationSession] status (`ui_state.dart` — workflow features
/// model their states explicitly).
enum IdentityFlowPhase {
  /// Fetching the initial session status.
  loading,

  /// Idle — showing whatever step the session status calls for.
  ready,

  /// An ID-document upload is in flight.
  submittingDocument,

  /// A selfie upload + match is in flight.
  submittingSelfie,

  /// The last action failed with an infrastructure error (not a business
  /// decline). [IdentityVerificationState.failure] carries the safe message.
  failed,
}

@immutable
class IdentityVerificationState {
  const IdentityVerificationState({
    required this.phase,
    this.session,
    this.failure,
  });

  const IdentityVerificationState.loading()
      : phase = IdentityFlowPhase.loading,
        session = null,
        failure = null;

  final IdentityFlowPhase phase;
  final IdentityVerificationSession? session;
  final Failure? failure;

  bool get isBusy =>
      phase == IdentityFlowPhase.loading ||
      phase == IdentityFlowPhase.submittingDocument ||
      phase == IdentityFlowPhase.submittingSelfie;

  bool get isSubmittingDocument =>
      phase == IdentityFlowPhase.submittingDocument;
  bool get isSubmittingSelfie => phase == IdentityFlowPhase.submittingSelfie;
  bool get hasFailure => phase == IdentityFlowPhase.failed && failure != null;

  IdentityVerificationState copyWith({
    IdentityFlowPhase? phase,
    IdentityVerificationSession? session,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return IdentityVerificationState(
      phase: phase ?? this.phase,
      session: session ?? this.session,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is IdentityVerificationState &&
      other.phase == phase &&
      other.session == session &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(phase, session, failure);
}

/// Owns the identity-verification flow for one reservation.
///
/// A `.family` per reservation id, so a session for reservation A can never be
/// overwritten by a late async result addressed to reservation B — that
/// isolation is structural. Within one reservation, a monotonic [_token] guards
/// against a stale result from a superseded action, and [IdentityVerificationState.isBusy]
/// blocks duplicate submits while one is in flight.
///
/// The controller never transitions the session itself: it only reflects what
/// the repository returns, and never claims approval before that.
class IdentityVerificationController
    extends FamilyNotifier<IdentityVerificationState, String> {
  late String _reservationId;
  int _token = 0;

  @override
  IdentityVerificationState build(String arg) {
    _reservationId = arg;
    _token += 1;
    _load(_token);
    return const IdentityVerificationState.loading();
  }

  Future<void> _load(int token) async {
    try {
      final IdentityVerificationSession session = await ref
          .read(identityVerificationRepositoryProvider)
          .statusFor(_reservationId);
      if (_stale(token)) return;
      state = IdentityVerificationState(
        phase: IdentityFlowPhase.ready,
        session: session,
      );
    } catch (error) {
      if (_stale(token)) return;
      state = IdentityVerificationState(
        phase: IdentityFlowPhase.failed,
        session: state.session,
        failure: ErrorMapper.toFailure(error),
      );
    }
  }

  /// Re-fetches the session status (e.g. while awaiting a manual review, or to
  /// recover from a load failure).
  Future<void> refresh() async {
    if (state.isBusy) return;
    final int token = ++_token;
    state = state.copyWith(phase: IdentityFlowPhase.loading, clearFailure: true);
    await _load(token);
  }

  /// Submits an ID document. Also serves as the "try again" step from a
  /// retryable state (`RETRY_ALLOWED` / `STAFF_REJECTED`) — that is the
  /// approved state-machine edge, not a separate call.
  Future<void> submitDocument(
    IdentityDocumentType type, {
    CapturedImage image = CapturedImage.dummy,
  }) async {
    if (state.isBusy) return;
    final int token = ++_token;
    state = state.copyWith(
      phase: IdentityFlowPhase.submittingDocument,
      clearFailure: true,
    );
    await _run(
      token,
      () => ref.read(identityVerificationRepositoryProvider).submitDocument(
            SubmitIdentityDocumentRequest(
              reservationId: _reservationId,
              type: type,
              image: image,
            ),
          ),
    );
  }

  /// Submits the selfie and lets the backend resolve the match.
  Future<void> submitSelfie({CapturedImage image = CapturedImage.dummy}) async {
    if (state.isBusy) return;
    final IdentityVerificationSession? session = state.session;
    if (session == null || !session.needsSelfie) return;

    final int token = ++_token;
    state = state.copyWith(
      phase: IdentityFlowPhase.submittingSelfie,
      clearFailure: true,
    );
    await _run(
      token,
      () => ref.read(identityVerificationRepositoryProvider).submitSelfie(
            SubmitSelfieRequest(reservationId: _reservationId, image: image),
          ),
    );
  }

  Future<void> _run(
    int token,
    Future<IdentityVerificationSession> Function() action,
  ) async {
    try {
      final IdentityVerificationSession session = await action();
      if (_stale(token)) return;
      state = IdentityVerificationState(
        phase: IdentityFlowPhase.ready,
        session: session,
      );
    } catch (error) {
      if (_stale(token)) return;
      state = IdentityVerificationState(
        phase: IdentityFlowPhase.failed,
        session: state.session,
        failure: ErrorMapper.toFailure(error),
      );
    }
  }

  bool _stale(int token) => token != _token;
}

final identityVerificationControllerProvider = NotifierProvider.family<
    IdentityVerificationController, IdentityVerificationState, String>(
  IdentityVerificationController.new,
);
