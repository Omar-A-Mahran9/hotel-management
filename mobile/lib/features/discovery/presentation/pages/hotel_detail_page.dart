import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure_l10n.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/hotel.dart';
import '../state/guest_party_controller.dart';
import '../state/hotel_detail_provider.dart';
import '../state/room_availability_controller.dart';
import '../state/room_selection_controller.dart';
import '../state/stay_dates_controller.dart';
import '../widgets/hero_circle_button.dart';
import '../widgets/hero_photo_strip.dart';
import '../widgets/hotel_thumbnail.dart';
import '../widgets/property_chip.dart';
import '../widgets/rating_pill.dart';
import '../../../reservation/presentation/state/create_reservation_controller.dart';

/// `HOTEL_Detail` — a full-bleed hero, a floating photo strip, the price/name
/// sheet, a rating pill, the entry-room spec chips, the description, the review
/// score bars, and a single `احجز الآن` CTA. Creating a reservation and payment
/// are later steps.
class HotelDetailPage extends ConsumerWidget {
  const HotelDetailPage({super.key, required this.hotelId});

  final String hotelId;

  void _startBooking(BuildContext context, WidgetRef ref) {
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
        body: _Body(hotel: data),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(AppSpacing.pageGutter),
          child: PrimaryButton(
            label: l10n.hotelBookNow,
            onPressed: data.summary.isAvailable
                ? () => _startBooking(context, ref)
                : null,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final AppColorTokens c = context.colors;
    final s = hotel.summary;
    final entry = hotel.entryRoom;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                HotelThumbnail(
                  imageUrl: hotel.coverUrl,
                  width: double.infinity,
                  height: 300,
                  borderRadius: BorderRadius.zero,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        HeroCircleButton(
                          icon: AppIcons.backRtl,
                          tooltip: l10n.commonBack,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        HeroCircleButton(
                          icon: AppIcons.chevron,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: AppSpacing.pageGutter,
                  bottom: -32,
                  child: HeroPhotoStrip(
                    galleryUrls: hotel.galleryUrls,
                    totalPhotos: hotel.photoCount,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            48,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MoneyText(
                    s.nightlyRateFrom.amount,
                    suffix: l10n.priceNightSuffix,
                    semanticsLabel: l10n.priceFrom(s.nightlyRateFrom.amount),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          s.name.resolve(locale),
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.cityName.resolve(locale),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (s.rating != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: RatingPill(
                    rating: s.rating!,
                    reviewCount: s.reviewCount,
                  ),
                ),
              ],
              if (entry != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    if (entry.areaSqm != null)
                      PropertyChip(
                        icon: AppIcons.area,
                        label: l10n.roomAreaSqm(entry.areaSqm!),
                      ),
                    PropertyChip(
                      icon: AppIcons.guests,
                      label: l10n.hotelGuestCount(entry.maxOccupancy),
                    ),
                    PropertyChip(
                      icon: AppIcons.bed,
                      label: entry.bedType.resolve(locale),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                hotel.description.resolve(locale),
                style: theme.textTheme.bodyLarge,
              ),
              if (hotel.reviewScores != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.hotelDetailReviews, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _ScoreBar(
                  label: l10n.hotelReviewCleanliness,
                  value: hotel.reviewScores!.cleanliness,
                ),
                const SizedBox(height: AppSpacing.xs),
                _ScoreBar(
                  label: l10n.hotelReviewCommunication,
                  value: hotel.reviewScores!.communication,
                ),
                const SizedBox(height: AppSpacing.xs),
                _ScoreBar(
                  label: l10n.hotelReviewLocation,
                  value: hotel.reviewScores!.location,
                ),
              ],
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
        SizedBox(
          width: 96,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.allXs,
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
