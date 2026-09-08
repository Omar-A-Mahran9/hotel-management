import '../../../../core/data/data_source.dart';
import '../../domain/entities/identity_verification_request.dart';
import '../../domain/entities/identity_verification_session.dart';
import '../../domain/entities/identity_verification_status.dart';
import '../models/identity_verification_models.dart';
import 'identity_verification_data_source.dart';

/// A deterministic match scenario, chosen purely from the reservation id so the
/// same reservation always behaves the same way. No randomness, no time-derived
/// branching.
enum DummyVerificationScenario {
  /// `AUTO_APPROVED` on the first selfie.
  autoApprove,

  /// `PENDING_MANUAL_REVIEW` — a staff member decides.
  manualReview,

  /// `RETRY_ALLOWED` on the first attempt; `AUTO_APPROVED` on the second.
  retryThenApprove,

  /// `STAFF_REJECTED` on the first attempt (a completed rejecting review);
  /// `PENDING_MANUAL_REVIEW` on a further attempt.
  rejectThenReview,
}

/// Deterministic, offline identity-verification source used while no
/// guest-facing contract is approved.
///
/// Guarantees required by the phase brief:
/// * no network, no timers, no randomness, no artificial delays;
/// * the resolved status is a pure function of the reservation id (via
///   [scenarioFor]) and the attempt count;
/// * the session walks the approved state machine
///   (`NOT_STARTED → DOCUMENT_UPLOADED → SELFIE_CAPTURED →
///   MATCHING_IN_PROGRESS → …`) — no state is invented;
/// * it never holds image bytes: submissions carry only a [CapturedImage]
///   descriptor, which is not stored or logged here.
///
/// [failWith] is a test seam (mirrors `DummyReservationDataSource.failWith`).
class DummyIdentityVerificationDataSource
    implements IdentityVerificationDataSource, DummyDataSource {
  DummyIdentityVerificationDataSource({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<String, IdentityVerificationSession> _sessions =
      <String, IdentityVerificationSession>{};

  /// When non-null, the next call throws this instead.
  Object? failWith;

  /// The deterministic scenario for a reservation id.
  static DummyVerificationScenario scenarioFor(String reservationId) {
    switch (_fnv1a(reservationId) % 4) {
      case 0:
        return DummyVerificationScenario.autoApprove;
      case 1:
        return DummyVerificationScenario.manualReview;
      case 2:
        return DummyVerificationScenario.retryThenApprove;
      default:
        return DummyVerificationScenario.rejectThenReview;
    }
  }

  IdentityVerificationSession _current(String reservationId) =>
      _sessions[reservationId] ??
      IdentityVerificationSession.notStarted(reservationId);

  IdentityVerificationSessionModel _model(IdentityVerificationSession s) {
    return IdentityVerificationSessionModel.fromJson(<String, Object?>{
      'reservation_id': s.reservationId,
      'status': s.status.wireValue,
      'attempts': s.attempts,
      'latest_outcome': switch (s.latestOutcome) {
        IdentityMatchOutcome.match => 'match',
        IdentityMatchOutcome.noMatch => 'no_match',
        IdentityMatchOutcome.inconclusive => 'inconclusive',
        IdentityMatchOutcome.unknown => null,
      },
      'decided_at': s.decidedAt?.toIso8601String(),
    });
  }

  @override
  Future<IdentityVerificationSessionModel> fetchStatus(
    String reservationId,
  ) async {
    if (failWith != null) throw failWith!;
    return _model(_current(reservationId));
  }

  @override
  Future<IdentityVerificationSessionModel> submitDocument(
    SubmitIdentityDocumentRequest request,
  ) async {
    if (failWith != null) throw failWith!;

    final IdentityVerificationSession current = _current(request.reservationId);
    if (!current.needsDocument &&
        current.status != IdentityVerificationStatus.documentUploaded) {
      // Nothing to do from here (already past the document step) — return the
      // current state rather than an invalid transition.
      return _model(current);
    }

    final IdentityVerificationSession next = current.copyWith(
      status: IdentityVerificationStatus.documentUploaded,
    );
    _sessions[request.reservationId] = next;
    return _model(next);
  }

  @override
  Future<IdentityVerificationSessionModel> submitSelfie(
    SubmitSelfieRequest request,
  ) async {
    if (failWith != null) throw failWith!;

    final IdentityVerificationSession current = _current(request.reservationId);
    if (current.status != IdentityVerificationStatus.documentUploaded &&
        current.status != IdentityVerificationStatus.selfieCaptured) {
      // A repeat submit from an already-resolved state is a no-op — the guest
      // must go through `retry` to start a fresh attempt.
      return _model(current);
    }

    final int attempts = current.attempts + 1;
    final IdentityVerificationStatus resolved =
        _resolve(request.reservationId, attempts);
    final IdentityVerificationSession next = current.copyWith(
      status: resolved,
      attempts: attempts,
      latestOutcome: _outcomeFor(resolved),
      decidedAt: resolved.isApproved ||
              resolved == IdentityVerificationStatus.staffRejected
          ? _clock()
          : null,
    );
    _sessions[request.reservationId] = next;
    return _model(next);
  }

  IdentityVerificationStatus _resolve(String reservationId, int attempts) {
    return switch (scenarioFor(reservationId)) {
      DummyVerificationScenario.autoApprove =>
        IdentityVerificationStatus.autoApproved,
      DummyVerificationScenario.manualReview =>
        IdentityVerificationStatus.pendingManualReview,
      DummyVerificationScenario.retryThenApprove => attempts <= 1
          ? IdentityVerificationStatus.retryAllowed
          : IdentityVerificationStatus.autoApproved,
      DummyVerificationScenario.rejectThenReview => attempts <= 1
          ? IdentityVerificationStatus.staffRejected
          : IdentityVerificationStatus.pendingManualReview,
    };
  }

  static IdentityMatchOutcome _outcomeFor(IdentityVerificationStatus status) =>
      switch (status) {
        IdentityVerificationStatus.autoApproved ||
        IdentityVerificationStatus.staffApproved =>
          IdentityMatchOutcome.match,
        IdentityVerificationStatus.retryAllowed ||
        IdentityVerificationStatus.staffRejected =>
          IdentityMatchOutcome.noMatch,
        IdentityVerificationStatus.pendingManualReview =>
          IdentityMatchOutcome.inconclusive,
        _ => IdentityMatchOutcome.unknown,
      };

  static int _fnv1a(String value) {
    int hash = 0x811c9dc5;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
