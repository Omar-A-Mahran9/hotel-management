# Guest App — Design System (as implemented)

> **Token spec:** the canonical token values, text styles, elevations and
> component variant axes live in
> [`design-system-tokens.md`](design-system-tokens.md), extracted verbatim from
> `Design/Hotel Design System.fig`. This file describes what the Flutter theme
> **actually implements** after the Phase 11C alignment pass (2026-09-09); where
> the two disagree, the token spec wins.

The Figma file `mobile/Design/hotel_guest_app.fig` is the layout reference;
`Hotel Design System.fig` is the token/component source of truth. Material
widgets are implementation primitives only — where a Material default differs
visibly from the Figma, the component is customised.

---

## Typography — `core/theme/app_typography.dart`

**Font: Tajawal** for the whole UI (SIL OFL 1.1, `assets/fonts/OFL.txt`; weights
300/400/500/700/800). The spec's `font/family/latin = Inter` and
`font/family/mono = Google Sans Code` are **accepted deviations** — Latin copy
here is minimal and Tajawal carries a full Latin set plus tabular figures.

Weight tokens: `regular` 400 · `medium` 500 · `semiBold` → **700** (Tajawal has
no 600) · `bold` 700 · `extraBold` 800.

**No `letterSpacing`, anywhere** — Arabic is cursive; every style ships at 0
(design-system §6.4). Line-heights are the **Arabic** values (loose, to clear
diacritics).

`TextTheme` → Figma style (`design-system-tokens.md` §6.3):

| Slot | Figma | size / line-height / weight |
|---|---|---|
| displayLarge | display-xl | 44 / 56 / 800 |
| displayMedium | display-lg | 32 / 44 / 800 |
| displaySmall · headlineLarge | display | 28 / 40 / 800 |
| headlineMedium | title-lg | 24 / 36 / 700 |
| headlineSmall | title | 20 / 32 / 700 |
| titleLarge | headline | 18 / 28 / 700 |
| titleMedium | body-lg strong | 17 / 28 / 700 |
| titleSmall | body strong | 15 / 26 / 700 |
| bodyLarge | body-lg | 17 / 28 / 400 |
| bodyMedium | body | 15 / 26 / 400 (secondary) |
| bodySmall | body-sm | 14 / 24 / 400 (secondary) |
| labelLarge | body-sm strong | 14 / 22 / 700 |
| labelMedium | label | 13 / 20 / 500 |
| labelSmall | caption | 12 / 18 / 400 |

Non-`TextTheme` accessors: `AppTypography.bodyStrong / bodySmStrong / labelStrong
/ labelRegular(color)`; `AppTypography.brand(color, {size})` (the wordmark
lock-up); the `num*` ramp — `numDisplay 64 · numXl 30 · numLg 24 · numMd 17 ·
numSm 15 · numXs 12`, Tajawal + `FontFeature.tabularFigures()`, for room numbers,
amounts, codes and points. `AppTypography.price` is a thin wrapper over `numMd`.

Rule: read styles from `Theme.of(context).textTheme` or these helpers — never
inline `TextStyle(fontFamily: …)`.

---

## Colour — `core/theme/app_colors.dart`, `AppTheme`

Three layers, mirroring the Figma exactly:

1. **`AppPrimitives`** — the raw ramps verbatim from §2 (`oud` 50–900, `gold`
   25–900, `stone` 0–950, `ink`, state hues). Internal; widgets never touch it.
2. **`AppColorTokens`** — a `ThemeExtension` carrying every `color/*` semantic
   token (`bgCanvas`, `bgPrimary`, `textPrimary`, `borderFocus`,
   `{success,warning,error,info}{Fg,Bg,Border}`, `accentWarm*`, …) for **both**
   Light and Dark, resolved from §3. Widgets read it via **`context.colors.<token>`**.
3. **`AppColors` / `AppSemanticColors`** — legacy flat shims, every name
   re-pointed to the correct primitive; kept until the last read migrates.

The `ColorScheme` mirrors the subset Material's own widgets consume, light **and**
dark (the Figma fully specifies dark — it is a real theme now, not a guess).

---

## Spacing / radius / shadow

**Spacing** (`app_spacing.dart`) — 8pt grid: `space1 4 · space2 8 · space3 12 ·
space4 16 · space5 20 · space6 24 · space7 32 · space8 40 · space9 48 ·
space10 64`. `space1` (4) is the only half-step. Legacy `xxs…xxxl` +
`pageGutter 20 / cardPadding 16 / section 24 / bottomBar*` are aliases (values
unchanged).

**Radius** (`app_radius.dart`) — `xs 4 · sm 8 · md 14 · lg 20 · xl 24 · xxl 32 ·
full 999`. `input` = `md` (14), `card` = `lg` (**20**, was 18), `sheet` = `xxl`
(**32**, was 28), `pill` = `full`. `AppRadius.topSheet` = top-only sheet rounding.

**Shadow** (`app_shadows.dart`) — 4 elevations, colour near-black `#101517`,
opacity in the alpha byte (§7): `elevation1` resting card (0,1 / 2 / 4%) ·
`elevation2` sticky header/tab bar (0,2 / 4 / 4%) · `elevation3` FAB/popover/key
hero (0,4 / 8 / spread −2 / 5%) · `elevation4` bottom sheet — **casts upward**
(0,−4 / 24 / spread −4 / 12%). `card` → `elevation1`, `raised` → `elevation4`,
`none` for dark.

**Sizes** (`app_sizes.dart`) — `AppIconSizes` (button 18 / pill 14 / iconSm 16 /
icon 18 / badge 28 / badgeDense 24 / nav 24 / appBar 24) and `AppSizes`
(emptyStateTile 72, iconButton 44, button Small/Medium/Large 40/48/56).

---

## App bar — `core/widgets/hotel_app_bar.dart` + `AppBarTheme`

Flat, background-aware (`surfaceTintColor` + `shadowColor` +
`scrolledUnderElevation` all transparent/0), **centred title**, directional back
glyph: `arrow_back` in LTR, `arrow_forward` in RTL (the Figma's `→`). Consistent
`kToolbarHeight`, `iconTheme` on-surface.

`HotelAppBar(title:, actions:, leading:, centerTitle: true)` — pass
`centerTitle: false` for a custom title layout (the Discover greeting stack does
this).

---

## Buttons

| Component | File | Look |
|---|---|---|
| `PrimaryButton` | `primary_button.dart` | filled brown, full-width pill (radius 999), heavy label, `ButtonSpinner` while `isLoading` |
| `SecondaryButton` | `secondary_button.dart` | **paper/cream fill + hairline border**, pill, on-surface text — *not* a coloured-outline Material button |
| `DangerButton` | `danger_button.dart` | solid red pill (`context.colors.bgDestructive`) — the Figma cancel actions (`تأكيد الإلغاء`). **Visual only**, no cancellation logic |

Styling lives in `filledButtonTheme` / `outlinedButtonTheme` (pill, `labelLarge`,
disabled → `bgDisabled`/`textDisabled`). All three take an optional
`size: AppButtonSize.{small,medium,large}` (40 / 48 / 56, the Figma `Button` Size
axis); the standing full-width height is 52. Hover/Pressed/Focused are Material
state overlays; Loading is `isLoading`. `ButtonSpinner` (`button_spinner.dart`)
is the shared 20px spinner.

---

## Card — `core/widgets/app_card.dart`

`AppCard({ style: AppCardStyle.… })` — the Figma `Card` component's Style axis:

| style | look |
|---|---|
| `elevated` | `bgSurface` + `elevation1`, no border |
| `outlined` | `bgSurface` + 1px `borderDefault` + `elevation1` — the default |
| `subtle` | flat `bgSubtle`, no border/shadow — nested / secondary cards |
| `inverse` | flat `bgInverse` (brown) — loyalty balance, digital-key hero; children use `context.colors.textOnInverse` |

Radius `AppRadius.allCard` (20). `AppCard.list` = zero padding for containers
that draw their own row insets + dividers. `onTap` adds an ink response. The
legacy `border` / `shadow` booleans still work when no `style` is given.

---

## Icon button — `core/widgets/app_icon_button.dart`

`AppIconButton({ icon, onPressed, style, selected, tooltip })` — the Figma
`Icon Button` (44×44, `AppRadius.allInput`). `style` = `surface` (bordered chip
on a light surface) or `dark` (translucent scrim chip on a photo/dark ground);
`selected: true` is the component's Selected state (filled `bgPrimary`).

---

## Section header — `core/widgets/section_header.dart`

`SectionHeader({ title, action, onAction })` — a `titleMedium` section title with
an optional trailing text action ("عرض الكل"). Figma `Section Header`.

---

## List row — `core/widgets/app_list_row.dart`

`AppListRow({ label, value, style })` — a label/value line for invoice / folio /
payment summaries. Figma `List Row` Style axis: `regular` · `muted` (both muted) ·
`total` (heavier, for the grand-total line). `value` is any widget (`Text`,
`MoneyText`).

---

## Toggle

No dedicated widget yet — `switchTheme` in `AppTheme` styles Material's `Switch`
to the Figma `Toggle` (track-on `bgPrimary`, thumb white, track-off
`borderStrong`, disabled `bgDisabled`).

---

## Info banner — `core/widgets/info_banner.dart`

The canonical Figma pattern for **success / error / warning / info** notices and
result-screen headers.

* Tinted container (`context.colors.{tone}Bg`), `AppRadius.allLg`.
* Leading **icon badge** — a filled circle in `{tone}Border` (opaque, not an
  alpha tint), glyph in `{tone}Fg`. Warning is a genuine alert glyph, not a clock.
* Coloured title (`titleSmall` in `{tone}Fg`), `textPrimary` body, optional
  `child` slot for result-screen detail (a reference code, a summary row).
* `dense: true` for inline use in lists. Also carries the `Toast` tones.

---

## Status pill — `core/widgets/status_pill.dart`

Pill shape, `AppTypography.labelStrong`, `AppIconSizes.pill` leading icon, `h/v`
= `space3 / space1` (12 / 4, on-grid). Colours passed in — status-pill widgets
pass `context.colors.{tone}Fg` / `{tone}Bg` from the design-system state tokens.

---

## Empty / error / message states — `core/widgets/message_view.dart`

`MessageView` — icon in a soft circular badge, title, optional body, **up to two
stacked actions** (primary + secondary), matching the Figma empty states
(`لا توجد غرف متاحة …` → `تغيير التاريخ` + `تعديل عدد الضيوف`).

`EmptyView` / `ErrorView` presets add default icon/colour and expose the same
two-action API. `UiStateView` uses them for the empty/error branches.

---

## Loading / skeleton — `core/widgets/skeleton.dart`

Reusable shimmer blocks (no third-party dependency; one `AnimationController`
per `Skeleton` scope):

`SkeletonBox` · `SkeletonText` · `SkeletonImage` · `SkeletonCard` ·
`SkeletonListCards` · `SkeletonRoomList`.

`UiStateView` gained an optional `skeleton:` widget that replaces the centred
spinner. **Not yet wired into screens** — screens opt in as they are migrated
(11B). Widget tests that pump a screen showing a skeleton must use
`tester.pump(duration)` rather than `pumpAndSettle()` (infinite shimmer).

---

## Currency — `core/widgets/money_text.dart`

`MoneyText(amount)` renders **⟨Saudi Riyal mark⟩ + amount** (Figma form), not
`SAR 945`:

* `RiyalMark` — a vector reconstruction of the Saudi Riyal symbol (no reliable
  cross-platform glyph exists), sized to the surrounding text, theme-aware.
* Thousands grouped; tabular figures; `AppTypography.numMd` styling; RTL/LTR
  ordering handled.
* `MoneyText.plain(context, amount)` → `"SAR 945"` for `String`-only contexts
  (semantics, snackbars).

**Presentation only** — never rounds, converts, or invents a rate; `amount` is
the backend value verbatim. Price call sites migrate to `MoneyText` in 11B.

---

## Icons — `core/widgets/app_icons.dart`

The Figma icon set was not exported. `AppIcons` maps every icon the app needs by
**meaning** (`AppIcons.bookings`, `AppIcons.key`, …) to the **rounded** Material
variants — closest to the Figma's soft geometric line icons — so the whole set
can be re-pointed (or swapped for exported vectors) in one file. Screens
reference `AppIcons.*`, not `Icons.*`.

`AppIcons.add` / `remove` stay the plain glyphs (visually identical here, and
matched by widget tests).

---

## Brand logo — `core/widgets/brand_logo.dart`

The "Hotel System" lock-up. The mark is **not** in the exported assets, so it is
reconstructed as a vector (`_BuildingMark` — central pointed tower flanked by two
blocks with an arched doorway). `BrandLogo(variant:)`:

* `horizontal` — mark + wordmark (auth screens, entry card)
* `stacked` — mark over centred wordmark + optional tagline (splash)
* `markOnly`

Colour defaults to the bronze accent; splash passes white.

---

## Images — `core/widgets/app_image.dart`

The 13 real Figma photos live in `assets/images/`, filenames keep the original
Figma content hash (traceable to `mobile/Design/assets/manifest.json`).
Nothing references an image path directly.

* `AppImages` — named slots (`entryHero`, `hotelHero`, `roomHero`), pools
  (`scenic`, `roomThumbs`, `all`), and `AppImages.forSeed(id, pool:)` for a
  deterministic id → asset mapping.
* `AppImage(asset:)` / `AppImage.seeded(seed:)` — rounded clip, `BoxFit`,
  graceful branded fallback if an asset fails to decode.
* `HotelThumbnail` now delegates to `AppImage.seeded` (same public API) — a hotel
  or room always shows the same real photo instead of a gradient placeholder.

Per-entity image URLs from the API are a later concern.

---

## OTP field — `authentication/.../otp_code_field.dart`

Figma dimensions: 48×56 boxes, `AppRadius.allInput` (14), fixed 8px gaps,
`FittedBox` scale-down on very narrow screens. Error state = light-red
**filled** boxes (`errorContainer`) with red border + red digits. Logic
unchanged; still one hidden `TextField` for paste / SMS autofill.

---

## Pills / chips — `ChipThemeData`

`ChoiceChip` / `FilterChip` are themed centrally, overriding Material's grey:
selected = brown fill + `onPrimary` label (no checkmark); unselected = surface
fill + hairline; `StadiumBorder`; `labelLarge` weight; `h/v` = `12 / 8`.

---

## Guest stepper — `discovery/.../guest_stepper.dart`

Circular tinted −/+ buttons (primary tint when enabled, muted when at a bound)
flanking the value in a bordered 52×40 field. Increment/decrement behaviour
unchanged; still `IconButton` with `Icons.add` / `Icons.remove`.

---

## Rating — `reviews/.../rating_selector.dart`

Routed through `AppIcons.rating` / `AppIcons.ratingOutline` (filled/outline
star — closest available; the Figma's flower-star glyph needs an exported
asset). Active colour = bronze accent. Rules unchanged.

---

## Bottom action bar — `core/widgets/bottom_action_bar.dart`

Reusable sticky footer: one `SafeArea`, `pageGutter` sides, `bottomBarTop` /
`bottomBarBottom` rhythm, primary + optional secondary/note stacked, soft top
shadow (`floating: true`). **Component only this phase** — screens adopt it in
11B (they currently each re-derive this).

---

## Bottom navigation — `core/widgets/app_bottom_nav.dart`

The Figma's persistent four-tab bar (`الرئيسية / حجوزاتي / الخدمات / حسابي`),
styled via `navigationBarTheme` (64 tall, transparent indicator, always-show
labels, primary tint when selected).

**Built as of Mobile Phase 11** (`docs/mobile-phase-11-bookings-account.md`) — all four
destinations are real screens:

| Tab | Destination screen | Status |
|---|---|---|
| الرئيسية (Home) | `DiscoverPage` | exists |
| حجوزاتي (Bookings) | `BookingsListPage` — الحالية/القادمة/السابقة pills | exists |
| الخدمات (Services) | `StayHomePage` — the current-stay hub (`STAY_Home.png`) | exists |
| حسابي (Account) | `AccountHomePage` — loyalty, trusted-guest, preferences, privacy/support, sign-out | exists |

The router is still a flat `GoRouter` — each tab is its own top-level
`GoRoute` (`/discover`, `/bookings`, `/services`, `/account`), and every root
page mounts `AppBottomNav` with `goToNavTab()` (`app/router/bottom_nav_navigation.dart`)
switching between them. No `StatefulShellRoute`: revisit only if tab-state
preservation becomes a real requirement (see the phase-11 doc's "Not built").
`navComingSoon` is retired from the bottom nav. Sign-out moved from the
Discover app bar into `حسابي` as planned.

---

## Deferred components

Spec components (`design-system-tokens.md` §9) not yet built as distinct widgets
— existing widgets or themes cover them for now:

| Spec component | Covered by / plan |
|---|---|
| Toggle (widget) | `switchTheme` styles Material `Switch`; a wrapper lands with the Account screens |
| Filter Chip vs Choice Chip | one `chipTheme` covers both |
| List Item {None/Chevron/Toggle/Value} | build with the Account screens |
| Rating Badge / Rating Row | `rating_pill` / `rating_selector` re-pointed to `accentWarm*`; generic versions later |
| Property Chip · Thumbnail Row · Scrim widget · Logo Placeholder (Avatar) | as screens need them |
| Toast (dedicated) | `snackBarTheme` + `InfoBanner` (which now also carries the Toast tones) |
| Button Tertiary | themed `TextButton` |
| **Available Room Card `Limited`** | needs a domain `isLimited` / `remainingCount` field on `AvailableRoom` + dummy source + API contract — a data change, not a token change |

---

## `content/*` → ARB mapping

The Figma `Content` collection is bilingual sample/label copy. Most keys already
exist in `lib/core/localization/arb/app_{en,ar}.arb` under feature prefixes — do
**not** duplicate. The mapping (selected):

| `content/*` | ARB key(s) |
|---|---|
| `content/app/{name,tagline}` | `appName`, `appTagline` — **kept as "Hotel System"** (the token's "نُزُل / Nuzul" is a product-naming question, not adopted) |
| `content/nav/{home,bookings,services,account}` | `navHome` / `navBookings` / `navServices` / `navAccount` (exact) |
| `content/action/{continue,back,retry,pay,viewAll,…}` | `commonContinue` / `commonBack` / `actionRetry` / `paymentPayNowCta` / `commonSeeAll` / … (feature-prefixed) |
| `content/status/pending` | `reservationStatusPending`, `serviceStatusRequested` |
| `content/status/verified` | `reservationStatusVerified`, `identityStatus*Approved` |
| `content/status/inReview` | `identityStatusPendingManualReview`, `reviewStatusPending` |
| `content/status/checkedIn` | `reservationStatusCheckedIn` |
| **`content/status/confirmed`** = "مؤكد" | **new** — `reservationStatusConfirmed` (added; `ReservationStatus` has no `confirmed` member — a guest-facing umbrella label) |
| `content/pay/*` · `content/verify/*` · `content/key/*` · `content/checkout/*` | `payment*` · `identity*` · `digitalAccess*` · `checkout*` |
| `content/unit/currency` (`﷼`) | drawn by `RiyalMark`, no string key |
