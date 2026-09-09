import 'package:flutter/material.dart';

/// Centralised icon vocabulary for the Guest App.
///
/// The Figma icon set could not be exported from `hotel_guest_app.fig`, so the
/// app uses the **rounded** Material variants (visually the closest match to the
/// Figma's soft, geometric line icons) — mapped here by *meaning*, not by
/// Material name. Screens reference `AppIcons.bookings`, never `Icons.*`
/// directly, so the whole set can be re-pointed (or swapped for exported
/// vectors) in one file.
abstract final class AppIcons {
  // Navigation / chrome
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData backRtl = Icons.arrow_forward_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData chevron = Icons.chevron_right_rounded;
  static const IconData notifications = Icons.notifications_none_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData sort = Icons.swap_vert_rounded;

  // Bottom navigation
  static const IconData navHome = Icons.home_rounded;
  static const IconData navHomeOutline = Icons.home_outlined;
  static const IconData navBookings = Icons.confirmation_number_rounded;
  static const IconData navBookingsOutline = Icons.confirmation_number_outlined;
  static const IconData navServices = Icons.grid_view_rounded;
  static const IconData navServicesOutline = Icons.grid_view_outlined;
  static const IconData navAccount = Icons.person_rounded;
  static const IconData navAccountOutline = Icons.person_outline_rounded;

  // Status / feedback
  static const IconData success = Icons.check_circle_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData pending = Icons.hourglass_bottom_rounded;
  static const IconData locked = Icons.lock_outline_rounded;
  static const IconData time = Icons.schedule_rounded;

  // Domain
  static const IconData hotel = Icons.apartment_rounded;
  static const IconData room = Icons.king_bed_rounded;
  static const IconData location = Icons.place_rounded;
  static const IconData guests = Icons.person_outline_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData rating = Icons.star_rounded;
  static const IconData ratingOutline = Icons.star_outline_rounded;
  static const IconData payment = Icons.payments_rounded;
  static const IconData identity = Icons.badge_rounded;
  static const IconData key = Icons.vpn_key_rounded;
  static const IconData roomService = Icons.room_service_rounded;
  static const IconData cleaning = Icons.cleaning_services_rounded;
  static const IconData extendStay = Icons.more_time_rounded;
  static const IconData report = Icons.report_gmailerrorred_rounded;
  static const IconData checkout = Icons.logout_rounded;
  static const IconData invoice = Icons.receipt_long_rounded;
  static const IconData loyalty = Icons.card_giftcard_rounded;
  static const IconData review = Icons.rate_review_rounded;
  static const IconData camera = Icons.photo_camera_rounded;
  // Plain add/remove — the rounded variants are visually identical here and
  // several widget tests match on these exact glyphs.
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData language = Icons.language_rounded;
  static const IconData shield = Icons.verified_user_rounded;
  static const IconData refresh = Icons.refresh_rounded;

  /// Direction-aware back glyph.
  static IconData backFor(TextDirection direction) =>
      direction == TextDirection.rtl ? backRtl : back;
}
