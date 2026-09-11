import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/presentation/ui_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/widgets/hotel_app_bar.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/availability_request.dart';
import '../../domain/entities/availability_result.dart';
import '../../domain/entities/available_room.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/room_selection.dart';
import '../../domain/entities/stay_range.dart';
import '../discovery_l10n.dart';
import '../state/guest_party_controller.dart';
import '../state/hotel_detail_provider.dart';
import '../state/room_availability_controller.dart';
import '../state/room_selection_controller.dart';
import '../state/stay_dates_controller.dart';
import '../widgets/hero_circle_button.dart';
import '../widgets/hero_photo_strip.dart';
import '../widgets/hotel_thumbnail.dart';
import '../widgets/property_chip.dart';
import '../../../../core/widgets/app_icons.dart';

/// `08 · Room selection & stay actions` (screen 1) — one room type in full, with
/// the stay context, amenities, cancellation summary and a single
/// "Select this room" CTA. Selecting sets the [RoomSelection] and returns to the
/// list; nothing is booked.
class RoomDetailPage extends ConsumerWidget {
  const RoomDetailPage({
    super.key,
    required this.hotelId,
    required this.roomTypeId,
  });

  final String hotelId;
  final String roomTypeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final DateTime today = ref.today();
    final StayRange? stay = ref
        .watch(stayDatesControllerProvider)
        .rangeAgainst(today);
    final party = ref.watch(guestPartyControllerProvider);
    final RoomAvailabilityState availability = ref.watch(
      roomAvailabilityControllerProvider,
    );
    final AsyncValue<Hotel> hotelAsync = ref.watch(
      hotelDetailProvider(hotelId),
    );
    final RoomSelection? selection = ref.watch(roomSelectionControllerProvider);

    final AvailableRoom? room = switch (availability.result) {
      UiSuccess<AvailabilityResult>(:final AvailabilityResult data) =>
        data.rooms
            .where((AvailableRoom r) => r.roomType.id == roomTypeId)
            .firstOrNull,
      _ => null,
    };

    if (stay == null || room == null || hotelAsync.value == null) {
      return Scaffold(
        appBar: HotelAppBar(title: l10n.roomDetailsTitle),
        body: MessageView(
          icon: AppIcons.room,
          title: l10n.reviewNoSelectionTitle,
          message: l10n.roomsNoResultsBody,
          actionLabel: l10n.reviewBackToRooms,
          onAction: () => context.pop(),
        ),
      );
    }

    final Hotel hotel = hotelAsync.value!;
    final AvailabilityRequest request = AvailabilityRequest(
      hotelId: hotelId,
      stay: stay,
      party: party,
    );
    final bool isSelected =
        selection != null &&
        selection.matches(request) &&
        selection.roomTypeId == roomTypeId;

    void select() {
      ref
          .read(roomSelectionControllerProvider.notifier)
          .select(
            RoomSelection.fromAvailableRoom(
              room: room,
              hotelId: hotel.id,
              hotelName: hotel.name,
              stay: stay,
              party: party,
            ),
          );
      context.pop();
    }

    void deselect() {
      ref.read(roomSelectionControllerProvider.notifier).clear();
      context.pop();
    }

    return Scaffold(
      body: _Body(room: room, stay: stay),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.pageGutter),
        child: isSelected
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  PrimaryButton(
                    label: l10n.roomSelected,
                    icon: AppIcons.check,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SecondaryButton(
                    label: l10n.roomRemoveSelection,
                    onPressed: deselect,
                  ),
                ],
              )
            : PrimaryButton(
                label: room.isAvailable
                    ? l10n.roomSelectThisRoom
                    : l10n.roomSoldOut,
                onPressed: room.isAvailable ? select : null,
              ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.room, required this.stay});

  final AvailableRoom room;
  final StayRange stay;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final AppColorTokens c = context.colors;
    final type = room.roomType;

    final List<String> amenities = <String>[
      if (type.breakfastIncluded) l10n.roomBreakfastIncluded,
      for (final amenity in type.amenities) l10n.roomAmenityLabel(amenity),
    ];

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                HotelThumbnail(
                  seed: type.id,
                  width: double.infinity,
                  height: 280,
                  borderRadius: BorderRadius.zero,
                  icon: AppIcons.bed,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: HeroCircleButton(
                        icon: AppIcons.backRtl,
                        tooltip: l10n.commonBack,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: AppSpacing.pageGutter,
                  bottom: -32,
                  child: HeroPhotoStrip(seed: type.id, totalPhotos: 12),
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
                    room.nightlyRate.amount,
                    suffix: l10n.priceNightSuffix,
                    semanticsLabel: l10n.pricePerNight(room.nightlyRate.amount),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      type.name.resolve(locale),
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  if (type.areaSqm != null)
                    PropertyChip(
                      icon: AppIcons.area,
                      label: l10n.roomAreaSqm(type.areaSqm!),
                    ),
                  PropertyChip(
                    icon: AppIcons.guests,
                    label: l10n.hotelGuestCount(type.maxOccupancy),
                  ),
                  PropertyChip(
                    icon: AppIcons.bed,
                    label: type.bedType.resolve(locale),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: c.bgSubtle,
                  borderRadius: AppRadius.allMd,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${l10n.stayDatesSelectedRange(ml.formatMediumDate(stay.checkIn), ml.formatMediumDate(stay.checkOut))} · ${l10n.stayNights(stay.nights)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.priceStayTotal(room.stayTotal(stay.nights).amount),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: c.textAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.roomDetailAmenitiesHeading,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                type.description.resolve(locale),
                style: theme.textTheme.bodyMedium,
              ),
              if (amenities.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  amenities.join('  ·  '),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: c.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.roomDetailCancellationHeading,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                type.refundable
                    ? l10n.roomPolicyRefundable
                    : l10n.roomPolicyNonRefundable,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
