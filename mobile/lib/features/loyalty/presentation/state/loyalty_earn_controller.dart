import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/loyalty_operations.dart';
import 'loyalty_providers.dart';

/// The state of the one-shot "earn points" action.
///
/// Modelled as an explicit state machine (`ui_state.dart` — workflow features
/// model their states explicitly). The business *outcome* lives on
/// [EarnPointsResult.outcome]; this type is only the action's idle / loading /
/// done / failed.
sealed class EarnActionState {
  const EarnActionState();

  bool get isSubmitting => this is EarnSubmitting;

  EarnPointsRequest? get requestOrNull => switch (this) {
        EarnSubmitting(:final EarnPointsRequest request) => request,
        EarnDone(:final EarnPointsRequest request) => request,
        EarnFailed(:final EarnPointsRequest request) => request,
        _ => null,
      };

  EarnPointsResult? get resultOrNull =>
      this is EarnDone ? (this as EarnDone).result : null;

  Failure? get failureOrNull =>
      this is EarnFailed ? (this as EarnFailed).failure : null;
}

class EarnIdle extends EarnActionState {
  const EarnIdle();
}

class EarnSubmitting extends EarnActionState {
  const EarnSubmitting(this.request);
  final EarnPointsRequest request;
}

/// The backend resolved the earn. Terminal for a *successful* outcome
/// (earned / already earned) — a further submit for the same request is
/// ignored. A blocked outcome (not eligible, program off) is shown from here
/// and can be retried once the precondition changes.
class EarnDone extends EarnActionState {
  const EarnDone(this.request, this.result);
  final EarnPointsRequest request;
  final EarnPointsResult result;
}

/// An infrastructure `Failure` — not a business decline.
class EarnFailed extends EarnActionState {
  const EarnFailed(this.request, this.failure);
  final EarnPointsRequest request;
  final Failure failure;
}

/// Owns the earn-points action for a reservation.
///
/// Guarantees mirror [PaymentController] / [CheckoutController]:
/// * duplicate-submit is a no-op while submitting, or after a successful done;
/// * a stale async result is dropped when a newer [EarnPointsRequest]
///   superseded it, so an old reservation's result never overwrites a newer;
/// * the balance is **never** mutated locally — on success the account and
///   ledger providers are invalidated and re-read.
class LoyaltyEarnController extends Notifier<EarnActionState> {
  @override
  EarnActionState build() => const EarnIdle();

  Future<void> submit(String reservationId) async {
    final EarnPointsRequest request =
        EarnPointsRequest(reservationId: reservationId);
    final EarnActionState current = state;
    if (current is EarnSubmitting && current.request == request) return;
    if (current is EarnDone &&
        current.request == request &&
        current.result.outcome.isSuccess) {
      return;
    }

    state = EarnSubmitting(request);
    try {
      final LoyaltyContext ctx =
          await ref.read(loyaltyContextProvider(reservationId).future);
      final EarnPointsResult result =
          await ref.read(loyaltyRepositoryProvider).earn(request, ctx);
      if (_superseded(request)) return;
      state = EarnDone(request, result);
      if (result.outcome.isSuccess) {
        ref.invalidate(loyaltyAccountProvider(reservationId));
        ref.invalidate(loyaltyTransactionsProvider(reservationId));
      }
    } catch (error) {
      if (_superseded(request)) return;
      state = EarnFailed(request, ErrorMapper.toFailure(error));
    }
  }

  bool _superseded(EarnPointsRequest request) {
    final EarnActionState now = state;
    return now is EarnSubmitting && now.request != request;
  }

  void reset() => state = const EarnIdle();
}

final loyaltyEarnControllerProvider =
    NotifierProvider<LoyaltyEarnController, EarnActionState>(
  LoyaltyEarnController.new,
);
