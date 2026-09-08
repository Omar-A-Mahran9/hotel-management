import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_app/app/router/app_router.dart';
import 'package:hotel_guest_app/core/localization/generated/app_localizations.dart';
import 'package:hotel_guest_app/features/reviews/data/datasources/dummy_review_data_source.dart';
import 'package:hotel_guest_app/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:hotel_guest_app/features/reviews/presentation/state/review_providers.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/create_reservation_request.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation.dart';
import 'package:hotel_guest_app/features/reservation/domain/entities/reservation_status.dart';
import 'package:hotel_guest_app/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:hotel_guest_app/features/reservation/presentation/state/reservation_providers.dart';

import '../../support/auth_test_support.dart';
import '../../support/pump_app.dart';
import '../payment/payment_test_support.dart';
import '../reviews/reviews_test_support.dart' show reviewScenarioId;

final DateTime _now = DateTime(2026, 9, 8, 11);

class _ReservationRepo implements ReservationRepository {
  _ReservationRepo(this.status);
  final ReservationStatus status;
  @override
  Future<Reservation> create(CreateReservationRequest request) async =>
      fakeReservation(status: status);
  @override
  Future<Reservation> getById(String id) async =>
      fakeReservation(id: id, status: status);
}

Future<AppLocalizations> _l10n(String code) =>
    AppLocalizations.delegate.load(Locale(code));

Future<void> _open(
  WidgetTester tester,
  String id, {
  required ReservationStatus status,
}) async {
  final ds = DummyReviewDataSource(clock: () => _now);
  final c = await pumpApp(
    tester,
    bootSession: completeSession(),
    extraOverrides: <Override>[
      reviewDataSourceProvider.overrideWithValue(ds),
      reviewRepositoryProvider.overrideWithValue(ReviewRepositoryImpl(ds)),
      reservationRepositoryProvider.overrideWithValue(_ReservationRepo(status)),
    ],
  );
  c.read(appRouterProvider).go('/reservation/$id');
  await tester.pumpAndSettle();
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    await tester.drag(
        find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('a completed stay shows the loyalty + review CTAs', (tester) async {
    final en = await _l10n('en');
    final id = reviewScenarioId(DummyReviewScenario.noReviewThenPending);
    await _open(tester, id, status: ReservationStatus.checkedOut);
    await _scrollToBottom(tester);

    expect(find.text(en.reservationLoyaltyCta), findsOneWidget);
    expect(find.text(en.reservationReviewCta), findsOneWidget);
    // The Phase 5–9 CTAs are still present.
    expect(find.text(en.reservationPayCta), findsOneWidget);
    expect(find.text(en.reservationCheckoutCta), findsOneWidget);
  });

  testWidgets('an in-progress stay shows none of the completed-stay CTAs',
      (tester) async {
    final en = await _l10n('en');
    final id = reviewScenarioId(DummyReviewScenario.noReviewThenPending);
    await _open(tester, id, status: ReservationStatus.checkedIn);
    await _scrollToBottom(tester);

    expect(find.text(en.reservationLoyaltyCta), findsNothing);
    expect(find.text(en.reservationReviewCta), findsNothing);
    // But the earlier CTAs remain.
    expect(find.text(en.reservationCheckoutCta), findsOneWidget);
  });

  testWidgets('an already-reviewed completed stay shows "view your review"',
      (tester) async {
    final en = await _l10n('en');
    final id = reviewScenarioId(DummyReviewScenario.alreadyReviewedPending);
    await _open(tester, id, status: ReservationStatus.checkedOut);
    await _scrollToBottom(tester);

    expect(find.text(en.reservationViewReviewCta), findsOneWidget);
    expect(find.text(en.reservationReviewCta), findsNothing);
  });
}
