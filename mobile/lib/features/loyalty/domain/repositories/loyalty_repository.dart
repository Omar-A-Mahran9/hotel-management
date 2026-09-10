import '../entities/loyalty_account.dart';
import '../entities/loyalty_operations.dart';
import '../entities/loyalty_transaction.dart';

/// The loyalty contract the presentation layer depends on
/// (mobile/docs/architecture.md §4). Which data source fulfils it (dummy vs the
/// future guest loyalty API) is a DI decision, exactly as in
/// `CheckoutRepository` / `PaymentRepository`.
///
/// Infrastructure errors are thrown as a `Failure` (mapped by the impl).
/// **Business** outcomes (not eligible, already earned, insufficient points, …)
/// are returned as an outcome on [EarnPointsResult] / [RedeemPointsResult] —
/// never a false success, never a local balance mutation.
///
/// The backend stays authoritative for eligibility, the balance and the
/// ledger; the app only ever displays what it reads back.
abstract interface class LoyaltyRepository {
  /// The guest's loyalty account (balance cache + program-active flag).
  Future<LoyaltyAccount> account(LoyaltyContext context);

  /// The guest's loyalty ledger, newest first.
  Future<List<LoyaltyTransaction>> transactions(LoyaltyContext context);

  /// Accrues points for a completed reservation. Idempotent.
  Future<EarnPointsResult> earn(EarnPointsRequest request, LoyaltyContext context);

  /// Redeems points against an eligible booking. Idempotent for the same
  /// amount.
  Future<RedeemPointsResult> redeem(
    RedeemPointsRequest request,
    LoyaltyContext context,
  );
}
