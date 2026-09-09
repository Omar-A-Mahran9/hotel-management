import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Centralised icon vocabulary for the Guest App.
///
/// The Figma uses the **Iconsax** set ("Hicon / Bold" and "Hicon / Linear" in
/// the `.fig` component tree — e.g. `Hicon / Bold / Home 1`, `… / Ticket 1`,
/// `… / Category`, `… / Profile 1`, `… / Star 1`, `… / Shield Tick`,
/// `… / Danger Triangle`, `… / Information Circle`). `iconsax_plus` bundles that
/// exact set as a font, in a Bold and a Linear (outline) weight.
///
/// Screens reference `AppIcons.<meaning>` — never `IconsaxPlus*` or `Icons.*`
/// directly — so the whole vocabulary can be re-pointed in one file. Bottom-nav
/// destinations get a Linear (unselected) + Bold (selected) pair.
abstract final class AppIcons {
  // ── Navigation / chrome ────────────────────────────────────────────────
  static const IconData back = IconsaxPlusLinear.arrow_left_2;
  static const IconData backRtl = IconsaxPlusLinear.arrow_right_3;
  static const IconData close = IconsaxPlusLinear.close_circle;
  static const IconData chevron = IconsaxPlusLinear.arrow_right_3;
  static const IconData chevronRtl = IconsaxPlusLinear.arrow_left_2;
  static const IconData notifications = IconsaxPlusLinear.notification;
  static const IconData search = IconsaxPlusLinear.search_normal_1;
  static const IconData filter = IconsaxPlusLinear.candle_2;
  static const IconData sort = IconsaxPlusLinear.sort;
  static const IconData edit = IconsaxPlusLinear.edit_2;

  // ── Bottom navigation (Linear = unselected, Bold = selected) ───────────
  static const IconData navHome = IconsaxPlusBold.home_2;
  static const IconData navHomeOutline = IconsaxPlusLinear.home_2;
  static const IconData navBookings = IconsaxPlusBold.ticket_star;
  static const IconData navBookingsOutline = IconsaxPlusLinear.ticket_star;
  static const IconData navServices = IconsaxPlusBold.category_2;
  static const IconData navServicesOutline = IconsaxPlusLinear.category_2;
  static const IconData navAccount = IconsaxPlusBold.profile_circle;
  static const IconData navAccountOutline = IconsaxPlusLinear.profile_circle;

  // ── Status / feedback ─────────────────────────────────────────────────
  static const IconData success = IconsaxPlusBold.tick_circle;
  static const IconData check = IconsaxPlusLinear.tick_square;
  static const IconData error = IconsaxPlusBold.danger;
  static const IconData warning = IconsaxPlusBold.warning_2;
  static const IconData info = IconsaxPlusBold.info_circle;
  static const IconData infoOutline = IconsaxPlusLinear.info_circle;
  static const IconData pending = IconsaxPlusLinear.clock;
  static const IconData locked = IconsaxPlusLinear.lock_1;
  static const IconData time = IconsaxPlusLinear.clock_1;
  static const IconData shieldCheck = IconsaxPlusBold.shield_tick;

  // ── Domain ────────────────────────────────────────────────────────────
  static const IconData hotel = IconsaxPlusLinear.buildings_2;
  static const IconData room = IconsaxPlusLinear.building_3;
  static const IconData bed = IconsaxPlusLinear.building_3;
  static const IconData location = IconsaxPlusLinear.location;
  static const IconData guests = IconsaxPlusLinear.profile;
  static const IconData area = IconsaxPlusLinear.maximize_3;
  static const IconData wifi = IconsaxPlusLinear.wifi;
  static const IconData calendar = IconsaxPlusLinear.calendar_2;
  static const IconData rating = IconsaxPlusBold.star_1;
  static const IconData ratingOutline = IconsaxPlusLinear.star_1;
  static const IconData payment = IconsaxPlusLinear.card;
  static const IconData wallet = IconsaxPlusLinear.wallet_3;
  static const IconData identity = IconsaxPlusLinear.personalcard;
  static const IconData key = IconsaxPlusBold.key_square;
  static const IconData roomService = IconsaxPlusLinear.coffee;
  static const IconData cleaning = IconsaxPlusLinear.broom;
  static const IconData extendStay = IconsaxPlusLinear.calendar_edit;
  static const IconData report = IconsaxPlusLinear.messages_2;
  static const IconData checkout = IconsaxPlusLinear.logout;
  static const IconData invoice = IconsaxPlusLinear.receipt_text;
  static const IconData loyalty = IconsaxPlusLinear.medal_star;
  static const IconData review = IconsaxPlusLinear.star_1;
  static const IconData camera = IconsaxPlusBold.camera;
  static const IconData gallery = IconsaxPlusLinear.gallery;
  static const IconData language = IconsaxPlusLinear.global;
  static const IconData shield = IconsaxPlusBold.shield_tick;
  static const IconData refresh = IconsaxPlusLinear.refresh;
  static const IconData support = IconsaxPlusLinear.messages_2;
  static const IconData privacy = IconsaxPlusLinear.lock_1;
  static const IconData help = IconsaxPlusLinear.message_question;
  static const IconData logout = IconsaxPlusLinear.logout;
  static const IconData phone = IconsaxPlusLinear.call;

  // Report-a-problem categories.
  static const IconData climate = IconsaxPlusLinear.wind_2;
  static const IconData plumbing = IconsaxPlusLinear.drop;
  static const IconData electrical = IconsaxPlusLinear.flash_1;
  static const IconData noise = IconsaxPlusLinear.volume_high;

  // Plain add/remove for the guest stepper — the Figma stepper uses a bare
  // hairline +/−. Kept as Material glyphs (also matched by two widget tests).
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;

  /// Direction-aware back glyph — `←` in LTR, `→` in RTL (the Figma Arabic
  /// frames show `→`).
  static IconData backFor(TextDirection direction) =>
      direction == TextDirection.rtl ? backRtl : back;

  /// Direction-aware forward/disclosure chevron.
  static IconData chevronFor(TextDirection direction) =>
      direction == TextDirection.rtl ? chevronRtl : chevron;
}
