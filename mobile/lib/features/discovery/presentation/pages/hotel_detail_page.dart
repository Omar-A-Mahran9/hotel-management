import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../widgets/photo_viewer_page.dart';
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

class _Body extends ConsumerWidget {
  const _Body({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final AppColorTokens c = context.colors;
    final s = hotel.summary;
    final entry = hotel.entryRoom;

    // The photo the hero currently shows: `galleryUrls`, falling back to the
    // cover when the hotel has no gallery on file — swapped by tapping a
    // thumbnail below, opened full-screen by tapping the hero itself.
    final List<String> photos = hotel.galleryUrls.isNotEmpty
        ? hotel.galleryUrls
        : (hotel.coverUrl != null ? <String>[hotel.coverUrl!] : <String>[]);
    final int selectedPhoto = ref.watch(heroPhotoIndexProvider(hotel.id));
    final String? heroUrl = photos.isEmpty
        ? null
        : photos[selectedPhoto.clamp(0, photos.length - 1)];

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .push<void>(PhotoViewerPage.route(heroUrl)),
                  child: HotelThumbnail(
                    imageUrl: heroUrl,
                    width: double.infinity,
                    height: 300,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                // The rounded cream "lip" that reads as the content panel's
                // top edge cutting into the hero photo (`HOTEL_Detail`).
                // Sized to the sheet radius so the corner cut-outs still show
                // hero imagery behind them, matching the reference.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: AppRadius.sheet,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.bgCanvas,
                      borderRadius: AppRadius.topSheet,
                    ),
                  ),
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
                          icon: AppIcons.backFor(Directionality.of(context)),
                          tooltip: l10n.commonBack,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        // Undefined product behaviour (see AppIcons.sparkle) —
                        // kept as a visible, tappable placeholder rather than
                        // invented business logic, matching the discover
                        // page's own notification-bell placeholder.
                        HeroCircleButton(
                          icon: AppIcons.sparkle,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -32,
                  child: Align(
                    alignment: Alignment.center,
                    child: HeroPhotoStrip(
                      galleryUrls: photos,
                      totalPhotos: hotel.photoCount,
                      selectedIndex: selectedPhoto,
                      onSelect: (int i) => ref
                          .read(heroPhotoIndexProvider(hotel.id).notifier)
                          .state = i,
                    ),
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
                  const Spacer(),
                  MoneyText(
                    s.nightlyRateFrom.amount,
                    suffix: l10n.priceNightSuffix,
                    semanticsLabel: l10n.priceFrom(s.nightlyRateFrom.amount),
                  ),
                ],
              ),
              if (s.rating != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Center(
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: c.textSecondary,
                ),
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
    final AppColorTokens c = context.colors;
    // Always one decimal place (`5.0`, not `5`) — `hotelRatingValue` trims
    // trailing zeros, which is right for the `4.96`-style rating pill but not
    // for these always-one-decimal review bars (`HOTEL_Detail`).
    final NumberFormat scoreFormat = NumberFormat('0.0', context.l10n.localeName);
    return Row(
      children: <Widget>[
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: c.textLabel),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.allXs,
            child: LinearProgressIndicator(
              value: (value / 5).clamp(0, 1),
              minHeight: 8,
              backgroundColor: c.bgSubtle,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          scoreFormat.format(value),
          style: theme.textTheme.labelLarge?.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}
