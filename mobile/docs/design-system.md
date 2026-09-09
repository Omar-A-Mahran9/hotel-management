# Guest App — Design System (Phase 11A)

The Figma file `md/mobile/Design/hotel_guest_app.fig` is the **primary visual
source of truth**. Material widgets are implementation primitives only — where a
Material default differs visibly from the Figma, the component is customised.

This document describes what Phase 11A ("Global Design System Reconstruction")
actually implements. Individual screens are polished in later phases; after 11A
they already move toward the Figma because they consume the corrected theme and
shared widgets.

---

## Typography — `core/theme/app_typography.dart`

**Font: Tajawal** — the family the Figma specifies (`font/family/arabic =
Tajawal`). SIL OFL 1.1, `assets/fonts/OFL.txt`. Static weights bundled:
300 / 400 / 500 / 700 / 800 (`assets/fonts/Tajawal-*.ttf`). Humanist Arabic sans
with a complete Latin set — one family for the Arabic UI and the Latin
"Hotel System" wordmark.

Applied globally via `ThemeData.fontFamily` so it also reaches Material-internal
text. (Phase 11A shipped Cairo; 11B corrected it to the Figma-specified Tajawal.)

Weight tokens: `regular` 400 · `medium` 500 · `semiBold` 600 · `bold` 700 ·
`extraBold` 800.

Scale (`TextTheme`) — sizes/line-heights match the previous scale so the font
switch doesn't reflow screens; **weights moved up** to the Figma's heavier feel:

| Role | Size | Weight | Use |
|---|---|---|---|
| displayLarge/Medium/Small | 34 / 32 / 30 | 800 | entry headline, hero copy |
| headlineLarge/Medium/Small | 26 / 24 / 20 | 700 | screen headings |
| titleLarge/Medium/Small | 18 / 16 / 14 | 700 | app-bar title, section headers, card titles |
| bodyLarge/Medium/Small | 16 / 14 / 12 | 400 | paragraph + helper copy (medium/small use the secondary colour) |
| labelLarge/Medium/Small | 14 / 12 / 11 | 700 / 700 / 600 | buttons, pills |

Extra helpers (not part of `TextTheme`):

* `AppTypography.number(color, size)` — large tabular-figure number (room
  number, deposit amount, points balance).
* `AppTypography.code(color, size)` — spaced tabular digits for reference /
  entry codes.
* `AppTypography.price(color, size)` — bronze, heavy, tabular; pair with
  `MoneyText`.

Rule: read styles from `Theme.of(context).textTheme` or these helpers — never
inline `TextStyle(fontFamily: …)`.

---

## Colour — `core/theme/app_colors.dart`, `AppTheme`

Palette verified against the Figma; values were already close and are unchanged:

| Token | Value | Role |
|---|---|---|
| `brown700` | `#4A3427` | primary (buttons, links) — light |
| `brown900` | `#2E2018` | splash / entry backdrop |
| `bronze500` / `bronze200` | `#A9793F` / `#E7D6BF` | accent — prices, ratings, logo |
| `paper` | `#F7F4EF` | scaffold background — light |
| `surface` | `#FFFFFF` | cards, sheets, inputs |
| `hairline` | `#E8E2D9` | outline / dividers |
| success / warning / error / info | see file | semantic — with soft `*Container` tints |

`AppSemanticColors` (theme extension) carries `success/warning/info` +
containers, `accent`, `hairline` for both light and dark.

`ColorScheme` adds `outlineVariant` for skeletons / muted separators.

Dark theme is implemented but **Figma is light-only** — dark values are a
sensible guess, not a spec; don't invest there.

---

## Spacing / radius / shadow

**Spacing** (`app_spacing.dart`) — 4pt grid: `xxs 4 · xs 8 · sm 12 · md 16 ·
lg 20 · xl 24 · xxl 32 · xxxl 48`. `pageGutter 20`, `cardPadding 16`,
`section 24`, `bottomBarTop 12`, `bottomBarBottom 16`.

**Radius** (`app_radius.dart`) — `sm 8 · md 12 · input 14 · lg 16 · card 18 ·
xl 20 · sheet 28 · pill 999`. `AppRadius.topSheet` = top-only sheet rounding.

**Shadow** (`app_shadows.dart`) — warm-tinted (toward brown), not neutral black:
`AppShadows.card` (resting surfaces), `AppShadows.raised` (bottom bars / sheets,
casts upward), `AppShadows.none` (dark theme).

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
| `PrimaryButton` | `primary_button.dart` | filled brown, full-width pill, ~52 tall, heavy label, spinner while `isLoading` |
| `SecondaryButton` | `secondary_button.dart` | **paper/cream fill + hairline border**, pill, on-surface text — *not* a coloured-outline Material button |
| `DangerButton` | `danger_button.dart` | solid red pill — the Figma cancel actions (`تأكيد الإلغاء`). **Visual only**, no cancellation logic |

Styling lives in `filledButtonTheme` / `outlinedButtonTheme`; `SecondaryButton`
rides the outlined theme (cream `backgroundColor`, hairline `side`).

---

## Card — `core/widgets/app_card.dart`

White/`surface`, `AppRadius.allCard` (18), soft warm shadow, **borderless by
default** (Figma cards have no border). Opt in with `border: true` for
list-container cards that show a hairline. `AppCard.list` = zero padding for
containers that draw their own row insets + dividers. `onTap` adds an ink
response.

---

## Info banner — `core/widgets/info_banner.dart`

The canonical Figma pattern for **success / error / warning / info** notices and
result-screen headers.

* Tinted container (`AppSemanticColors` container colours), `AppRadius.allLg`.
* Leading **icon badge** — a filled circle tinted to the tone, `check_circle` /
  `error` / `warning_amber` / `info`. Warning is a genuine alert glyph, not a
  clock.
* Bold coloured title (`titleSmall`), on-surface body, optional `child` slot for
  result-screen detail (a reference code, a summary row).
* `dense: true` for inline use in lists.

---

## Status pill — `core/widgets/status_pill.dart`

Pill shape, `labelMedium` bold, small leading icon, `h/v` = `12 / 5`. Colours
passed in from semantic tokens (`متاحة`, `مؤكد`, `قيد الانتظار`).

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
* Thousands grouped; tabular figures; `AppTypography.price` styling; RTL/LTR
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
Figma content hash (traceable to `md/mobile/Design/assets/manifest.json`).
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

**Foundation only.** Three destinations don't exist as screens yet:

| Tab | Destination screen | Status |
|---|---|---|
| الرئيسية (Home) | `DiscoverPage` | exists |
| حجوزاتي (Bookings) | a bookings list with الحالية/القادمة/السابقة tabs | **missing** |
| الخدمات (Services) | a *global* services hub (current one is reservation-scoped) | **missing** |
| حسابي (Account) | account + sub-pages (بياناتي / تفضيلاتي / الخصوصية / المساعدة / تسجيل الخروج) | **missing** |

Because the router is a flat `GoRouter` and the other pages don't exist, no
`StatefulShellRoute` is wired yet. `AppBottomNav` is mounted on `DiscoverPage`
in display-only mode: "Home" is current; tapping another tab shows a
"coming in a later update" snackbar (`navComingSoon`) rather than routing to a
placeholder. Sign-out temporarily stays in the Discover app bar until the
account screen exists.

Next phase: build the three screens, then adopt `StatefulShellRoute` with
`AppBottomNav` and move sign-out into `حسابي`.
