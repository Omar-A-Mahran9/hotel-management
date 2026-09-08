import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/time/clock.dart';
import '../../data/datasources/api_identity_verification_data_source.dart';
import '../../data/datasources/dummy_identity_verification_data_source.dart';
import '../../data/datasources/identity_verification_data_source.dart';
import '../../data/repositories/identity_verification_repository_impl.dart';
import '../../domain/repositories/identity_verification_repository.dart';

/// Selects the identity-verification data source by configuration — the UI
/// never sees this choice, mirroring `reservationDataSourceProvider`.
///
/// The dummy source is kept alive for the whole app session so a session
/// advanced here can be re-read by the result / reservation screens.
final identityVerificationDataSourceProvider =
    Provider<IdentityVerificationDataSource>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return config.useDummyData
      ? DummyIdentityVerificationDataSource(clock: ref.watch(clockProvider))
      : ApiIdentityVerificationDataSource(ref.watch(apiClientProvider));
});

final identityVerificationRepositoryProvider =
    Provider<IdentityVerificationRepository>(
  (Ref ref) => IdentityVerificationRepositoryImpl(
    ref.watch(identityVerificationDataSourceProvider),
  ),
);
