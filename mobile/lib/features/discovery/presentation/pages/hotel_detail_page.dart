import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../reservation/presentation/state/create_reservation_controller.dart';
import '../../domain/entities/hotel.dart';
import '../discovery_l10n.dart';
import '../state/guest_party_controller.dart';
import '../state/hotel_detail_provider.dart';
import '../state/room_availability_controller.dart';
import '../state/room_selection_controller.dart';
import '../state/stay_dates_controller.dart';
import '../widgets/hotel_thumbnail.dart';
import '../widgets/rating_pill.dart';

/// `02 · Discover & Book` (screen 3) — hotel detail. Shows the information the
/// design presents and a single CTA to choose stay dates. It does not create a
/// reservation or take payment — those are later phases.
class HotelDetailPage extends ConsumerWidget {
  const HotelDetailPage({super.key, required this.hotelId});

  final String hotelId;

  void _startDateSelection(BuildContext context, WidgetRef ref) {
    // A fresh stay selection for this hotel.
    ref.read(createReservationControllerProvider.notifier).reset();
    ref.read(roomSelectionControllerProvider.notifier).clear();
    ref.read(stayDatesControllerProvider.notifier).clear();
    ref.read(guestPartyControllerProvider.notifier).reset();
    ref.read(roomAvailabilityControllerProvider.notifier).reset();
    context.pushNamed(
      AppRoutes.stayDatesName,
      pathParameters: <String, String>{'hotelId': hotelId},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<Hotel> hotel = ref.watch(hotelDetailProvider(hotelId));

    return hotel.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: Center(child: LoadingView(label: l10n.stateLoadingTitle)),
      ),
      error: (Object error, StackTrace _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ErrorView(
            title: l10n.stateErrorTitle,
            message: ErrorMapper.toFailure(error).localizedMessage(l10n),
            actionLabel: l10n.commonBack,
            onAction: () => context.pop(),
          ),
        ),
      ),
      data: (Hotel data) => Scaffold(
        body: _HotelDetailBody(hotel: data),
        bottomNavigationBar: _DetailBottomBar(
          enabled: data.summary.isAvailable,
          onSelectDates: () => _startDateSelection(context, ref),
        ),
      ),
    );
  }
}

class _HotelDetailBody extends StatelessWidget {
  const _HotelDetailBody({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final s = hotel.summary;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          flexibleSpace: FlexibleSpaceBar(
            background: HotelThumbnail(
              seed: hotel.id,
              width: double.infinity,
              height: 240,
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          sliver: SliverList.list(
            children: <Widget>[
              Text(s.name.resolve(locale), style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(s.cityName.resolve(locale), style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  if (s.rating != null)
                    Flexible(
                      child: RatingPill(
                        rating: s.rating!,
                        reviewCount: s.reviewCount,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    l10n.priceFrom(s.nightlyRateFrom.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.extension<AppSemanticColors>()?.accent ??
                          AppColors.bronze500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${l10n.hotelRoomTypeCount(hotel.roomTypeCount)} · ${l10n.hotelPhotoCount(hotel.photoCount)}',
                style: theme.textTheme.bodySmall,
              ),
              const Divider(height: AppSpacing.xl),
              Text(hotel.description.resolve(locale), style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.hotelDetailAmenities, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  for (final amenity in hotel.amenities)
                    Chip(label: Text(l10n.hotelAmenityLabel(amenity))),
                ],
              ),
              if (hotel.reviewScores != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.hotelDetailReviews, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                _ScoreBar(
                  label: l10n.hotelReviewCleanliness,
                  value: hotel.reviewScores!.cleanliness,
                ),
                const SizedBox(height: AppSpacing.xs),
                _ScoreBar(
                  label: l10n.hotelReviewCommunication,
                  value: hotel.reviewScores!.communication,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        SizedBox(width: 96, child: Text(label, style: theme.textTheme.bodyMedium)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 5).clamp(0, 1),
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          context.l10n.hotelRatingValue(value),
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}

/// The pinned "select dates" CTA, kept out of the scroll body.
class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar({required this.enabled, required this.onSelectDates});

  final bool enabled;
  final VoidCallback onSelectDates;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.pageGutter),
      child: PrimaryButton(
        label: context.l10n.hotelSelectDates,
        onPressed: enabled ? onSelectDates : null,
      ),
    );
  }
}
