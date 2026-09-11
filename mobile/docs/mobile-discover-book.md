# Mobile — Discover & Book (`02 · Discover & Book`)

Reproduces the `~/Documents/Discover & Book/` mockups (`HOME_Default`,
`HOME_if One hotel`, `SEARCH_Results_Default`, `HOTEL_Detail`, `BOOKING_Summary`)
plus an alignment pass on the intermediate screens against Figma boards `16`
(stay dates & available rooms) and `08` (room selection).

Design intent (caption): *"Browse the group, pick a room, review before paying.
Room locks the moment a booking starts (§9)."*

## Flow

```
/discover ──tap hotel──▶ /discover/hotel/:id ──احجز الآن──▶ /discover/hotel/:id/dates
        (Home)              (Hotel detail)                     (calendar, board 16)
                                                                     │ عرض الغرف المتاحة
                                                                     ▼
   /discover/hotel/:id/rooms ──عرض التفاصيل──▶ /discover/hotel/:id/rooms/:roomTypeId
     (available rooms, board 16)                  (room detail, board 08)
                                                        │ اختيار هذه الغرفة
                                                        ▼
                              /discover/hotel/:id/review  ──المتابعة للدفع──▶ /reservation/:id/payment
                                (BOOKING_Summary)          (guest → sign-in → back here first)
```

All of the above is browsable **without an account**; auth is requested only at
the booking-summary CTA (`docs/mobile-deferred-auth.md`).

## Screens

### Home — `discover_page.dart` + `discover_controller.dart`
- App bar: bold greeting + subtitle; a circular bell action; a `تسجيل الدخول`
  text action for guests / sign-out for signed-in guests (interim — the `حسابي`
  account screen owns this once it exists).
- `SortChipBar`: filled brown selected pill, outlined others. Only the 3 real
  sorts — **`الأقرب` (nearest) is deliberately omitted**: it needs geolocation, a
  later phase. Tapping a chip opens search with that sort.
- `إقامتك القادمة` (`UpcomingStayCard`) — shown **only when signed in** and
  `DiscoverView.upcomingStay != null`. Dummy data (`fetchUpcomingStay`); the real
  card will come from the reservations feature.
- Multi-hotel: `فنادق المجموعة` grid of `HotelSummaryCard(tile)` (image + rating
  badge overlay + name + city — no price/availability on the tile).
- **Single-hotel group** (`AppConfig.singleHotelGroup`,
  `--dart-define=SINGLE_HOTEL=true`): subtitle names the hotel, section is
  `استكشف الغرف`, body is that hotel's rooms as `RoomSummaryCard(showStayTotal:
  false)`.

### Search — `hotel_search_page.dart`
- App-bar title `فنادق المجموعة`; the `AppBottomNav` is shown (Home tab → `/discover`).
- Sort lives only in the chip bar (the app-bar sort sheet was removed).
- `HotelSummaryCard(row)`: name, city with a pin, "from" price, `متاحة` pill,
  image trailing. No rating pill (not in the mockup).

### Hotel detail — `hotel_detail_page.dart`
- Full-bleed hero, two `HeroCircleButton`s, a `HeroPhotoStrip` (`+N` from
  `hotel.photoCount`).
- Price + name + city sheet, `RatingPill` (`4.96 · 217 مراجعة`).
- Three `PropertyChip`s from the **entry room type** (`Hotel.entryRoom`, the
  cheapest bookable offering): area `م²`, `{n} نزيل`, bed type.
- Description, then three review bars — النظافة / التواصل / **الموقع**
  (`ReviewScores.location`, new).
- CTA `احجز الآن`; still routes to the calendar and resets the stay controllers.
- The amenities chip list was dropped here — amenities live on the room-detail
  screen (board 08).

### Booking summary — `room_selection_review_page.dart` (`تفاصيل الحجز`)
- Room card (thumb, name, `📍 hotel`, nightly price, `متاحة`).
- Dates card + `تعديل` → the calendar.
- **Inline** `بالغون` / `أطفال` steppers bound to `guestPartyControllerProvider`.
- `PriceBreakdownCard`: `قيمة الإقامة` (nightly × nights) + `رسوم الخدمة` +
  `الإجمالي`.
- CTA (signed in) `المتابعة للدفع` → creates the `PENDING` reservation and
  `pushReplacement`s straight to `/reservation/:id/payment`.
  CTA (guest) `سجّل الدخول لتأكيد الحجز` → sign-in, then back here.

**Service fee**: `kDesignMockServiceFee` (`booking_price.dart`) is a **design-only
placeholder** to reproduce the mockup's `رسوم الخدمة` row — a fixed value shown
only on the dummy path and labelled "estimate — the hotel confirms the final
amount". It is **not** a pricing rule and never enters business logic. Laravel is
authoritative; the API path shows no fee line.

**Selection re-pricing**: `RoomSelectionController._revalidate` now keeps the
selection when a party change still fits the room type (updates
`selection.party` in place); it drops the selection only on a date change or a
party that no longer fits. This is what lets the inline steppers work.

### Intermediate — boards 16 & 08
- `stay_dates_page.dart`: the guest-party row was removed (party is edited on the
  rooms screen / booking summary); the scrolling `StayRangeCalendar` +
  `عرض الغرف المتاحة` CTA stay.
- `available_rooms_page.dart`: unchanged structurally — the stay header card,
  sort trigger, room list and empty state already match board 16. (A full room
  filter sheet is still a future item.)
- `room_detail_page.dart`: hero + `HeroCircleButton` + `HeroPhotoStrip`; three
  `PropertyChip`s (area / `{n} نزيل` / bed); stay-context box with the stay
  total; amenities as a `·`-joined line (not chips); cancellation policy; CTA
  `اختيار هذه الغرفة` unchanged.

## Data additions

- `RoomTypeSummary.areaSqm` (`int?`), `ReviewScores.location` (`double`),
  `Hotel.entryRoom` (`RoomTypeSummary?`), `UpcomingStay` entity.
- `DiscoveryRepository.groupHotelCount()` / `hotelRooms(id)` / `upcomingStay()`
  (dummy implemented; `ApiDiscoveryDataSource` stubs them like the rest).
- `AppConfig.singleHotelGroup` (`SINGLE_HOTEL` define).
- `RoomSelection.copyWith({party})` + `RoomSelection.fits(party)`.

## Tests

`test/features/discovery/`: `discover_home_test.dart` (upcoming-stay visibility,
single-hotel variant), `booking_summary_test.dart` (price breakdown, inline
stepper keeps a fitting selection), plus the updated `discovery_pages_test`,
`discovery_selection_test`, `discovery_rtl_test`, `guest_browse_test`.
`test/features/reservation/`: `reservation_flow_test` / `_rtl` / `_theme` now
assert the booking-summary → payment path.
