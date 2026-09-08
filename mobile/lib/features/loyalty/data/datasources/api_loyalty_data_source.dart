import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/loyalty_account.dart';
import '../../domain/entities/loyalty_operations.dart';
import '../../domain/entities/loyalty_transaction.dart';
import 'loyalty_data_source.dart';

/// API-backed loyalty source.
///
/// Kept a documented stub for Mobile Phase 10 (same pattern as
/// `ApiCheckoutDataSource`). The endpoints exist —
/// `GET  /api/v1/reservations/{reservation}/loyalty`               → LoyaltyAccountResource
/// `GET  /api/v1/reservations/{reservation}/loyalty/transactions`  → LoyaltyTransactionResource[]
/// `POST /api/v1/reservations/{reservation}/loyalty/earn`   (no body) → LoyaltyTransactionResource (201)
/// `POST /api/v1/reservations/{reservation}/loyalty/redeem` (`{points}`) → LoyaltyTransactionResource (201)
/// — but they are **staff/dashboard-scoped**: `LoyaltyController` resolves the
/// reservation through `ReservationService::findAccessibleBy($request->user(), …)`
/// and authorises with `LoyaltyPolicy` against the acting user's hotel access.
/// The controller docblock is explicit: *"guest authentication does not exist
/// in this MVP"*. The whole `/v1` surface is behind `auth:sanctum` staff
/// tokens.
///
/// Two things the guest client additionally needs that the current contract
/// does not give:
///
/// 1. a way to tell "just earned" (201, new) from "already earned" (the
///    idempotent replay also returns 201) — the guest UI must show a different
///    message for each. The future guest endpoint should return a `created`
///    flag, a distinct 200-vs-201, or a structured `outcome`.
/// 2. a structured business-outcome for the blocked cases. Today they all come
///    back as HTTP 422 with a message that embeds a machine reason
///    (`loyalty_program_inactive`, `reservation_not_completed:*`,
///    `insufficient_points_balance`, `already_redeemed_against_this_booking`, …).
///    The adapter here would parse that reason and map it to
///    [LoyaltyEarnOutcome] / [LoyaltyRedeemOutcome].
///
/// Wiring is sketched in comments; until an approved guest contract lands each
/// method raises [NotImplementedInPhaseException].
class ApiLoyaltyDataSource implements LoyaltyDataSource, RemoteDataSource {
  ApiLoyaltyDataSource(this._client);

  // Retained so wiring an approved endpoint stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'A guest-facing loyalty contract (guest identity resolved server-side + a '
      'structured earn/redeem outcome) is not approved yet';

  @override
  Future<LoyaltyAccount> fetchAccount(LoyaltyContext context) async {
    // final json = await _client.getJson(
    //   '/reservations/${context.reservationId}/loyalty');
    // return LoyaltyAccountModel(json['data'] as Map<String, Object?>).toEntity();
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<List<LoyaltyTransaction>> fetchTransactions(
    LoyaltyContext context,
  ) async {
    // final json = await _client.getJson(
    //   '/reservations/${context.reservationId}/loyalty/transactions');
    // return (json['data'] as List)
    //     .map((e) => LoyaltyTransactionModel(e as Map<String, Object?>).toEntity())
    //     .toList();
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<EarnPointsResult> earn(
    EarnPointsRequest request,
    LoyaltyContext context,
  ) async {
    // try {
    //   final json = await _client.postJson(
    //     '/reservations/${request.reservationId}/loyalty/earn');
    //   final tx = LoyaltyTransactionModel(json['data'] as Map).toEntity();
    //   return EarnPointsResult(
    //     outcome: /* created flag ? earned : alreadyEarned */,
    //     transaction: tx,
    //   );
    // } on <422 with reason> catch (e) {
    //   return EarnPointsResult(outcome: _earnOutcomeFromReason(e.reason));
    // }
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<RedeemPointsResult> redeem(
    RedeemPointsRequest request,
    LoyaltyContext context,
  ) async {
    // final body = RedeemLoyaltyPayload(request.points).toJson();
    // try {
    //   final json = await _client.postJson(
    //     '/reservations/${request.reservationId}/loyalty/redeem', body: body);
    //   return RedeemPointsResult(
    //     outcome: LoyaltyRedeemOutcome.redeemed,
    //     transaction: LoyaltyTransactionModel(json['data'] as Map).toEntity(),
    //   );
    // } on <422 with reason> catch (e) {
    //   return RedeemPointsResult(outcome: _redeemOutcomeFromReason(e.reason));
    // }
    throw const NotImplementedInPhaseException(_reason);
  }
}
