import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/time/clock.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../../reservation/presentation/state/reservation_detail_provider.dart';
import '../../data/datasources/api_loyalty_data_source.dart';
import '../../data/datasources/dummy_loyalty_data_source.dart';
import '../../data/datasources/loyalty_data_source.dart';
import '../../data/repositories/loyalty_repository_impl.dart';
import '../../domain/entities/loyalty_account.dart';
import '../../domain/entities/loyalty_operations.dart';
import '../../domain/entities/loyalty_transaction.dart';
import '../../domain/repositories/loyalty_repository.dart';

/// One dummy instance holds the guest's account + ledger for the whole session,
/// so an earn/redeem done here is reflected by later reads. Kept alive.
final _dummyLoyaltyProvider = Provider<DummyLoyaltyDataSource>(
  (Ref ref) => DummyLoyaltyDataSource(clock: ref.watch(clockProvider)),
);

/// Selects the loyalty data source by configuration — the UI never sees this
/// choice, mirroring `checkoutDataSourceProvider`.
final loyaltyDataSourceProvider = Provider<LoyaltyDataSource>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return config.useDummyData
      ? ref.watch(_dummyLoyaltyProvider)
      : ApiLoyaltyDataSource(ref.watch(apiClientProvider));
});

final loyaltyRepositoryProvider = Provider<LoyaltyRepository>(
  (Ref ref) => LoyaltyRepositoryImpl(ref.watch(loyaltyDataSourceProvider)),
);

/// The loyalty context seeded from the authoritative reservation the guest
/// already holds. The real API needs none of this.
final loyaltyContextProvider = FutureProvider.autoDispose
    .family<LoyaltyContext, String>((Ref ref, String reservationId) async {
  final Reservation r =
      await ref.watch(reservationDetailProvider(reservationId).future);
  return LoyaltyContext.forReservation(r);
});

/// The guest's loyalty account (balance cache + program-active flag).
final loyaltyAccountProvider = FutureProvider.autoDispose
    .family<LoyaltyAccount, String>((Ref ref, String reservationId) async {
  final LoyaltyContext ctx =
      await ref.watch(loyaltyContextProvider(reservationId).future);
  return ref.watch(loyaltyRepositoryProvider).account(ctx);
});

/// The guest's loyalty ledger, newest first.
final loyaltyTransactionsProvider = FutureProvider.autoDispose
    .family<List<LoyaltyTransaction>, String>((Ref ref, String reservationId) async {
  final LoyaltyContext ctx =
      await ref.watch(loyaltyContextProvider(reservationId).future);
  return ref.watch(loyaltyRepositoryProvider).transactions(ctx);
});
