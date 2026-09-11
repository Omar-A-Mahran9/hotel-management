# Mobile — Entry splash & language selection (`01 · Entry`)

The first-run entry sequence:

```
splash (AuthSplashPage)  →  language (LanguageSelectionPage)  →  welcome (EntryWelcomePage)  →  discover …
```

> **Deferred auth** (`mobile-deferred-auth.md`): `welcome`'s CTA opens
> `/discover`, not sign-in. Browsing is public; the phone/OTP/profile surface is
> reached on demand from the "confirm" step of a booking (or the discover
> app-bar sign-in action).

## Screens

| Route | Widget | Notes |
|---|---|---|
| `/` | `AuthSplashPage` | Warm-brown brand lock-up shown while the stored session restores (`AuthState.unknown`). Now uses the real brand raster (`assets/brand/logo.png` via `BrandLogo(assetMark: true)` → `AppImages.brandMark`) and is **held for `splashMinDurationProvider`** (1.8s) so it is actually seen — restore is otherwise instant. |
| `/welcome/language` | `LanguageSelectionPage` | **New.** First-run language choice. |
| `/welcome` | `EntryWelcomePage` | Photo-forward promise screen. Its brand mark is now the real raster (`BrandLogo(assetMark: true)`) sitting on a small `oud700` "app-icon" chip — the raster is a knockout (paper-toned towers + gold spire), so it needs a dark backing on this light screen. |

### The brand raster

`assets/brand/logo.png` is a **knockout**: the towers are exactly `stone25`
(the paper background colour) and the "1" spire is `gold400`, on transparency.
It reads on a dark ground only. `BrandLogo(assetMark: true)` renders it and falls
back to the tintable vector `_BuildingMark` if the asset is missing (e.g. a build
that predates the `pubspec` `assets/brand/` entry — run `flutter pub get` +
rebuild). Splash: straight on the brown field. Welcome: on a brown chip. A
light-ground ("primary") version of the logo would let the chip go away.

`splashMinDurationProvider` (`auth_controller.dart`) is the minimum on-screen time
for the splash; `authOverrides` / `routing_test` override it to `Duration.zero`.
`AuthController.build` reads its deps synchronously and guards `state =` with a
disposed flag so a late restore never writes to a torn-down container.

## Language selection

* `lib/features/authentication/presentation/pages/language_selection_page.dart`
  — app-bar title (`اللغة`), a short heading + body, a two-row card
  (`العربية` / `English`), and a sticky `متابعة` CTA (`BottomActionBar`).
* **Arabic is the default.** `LocaleController.build()` now returns
  `SupportedLocales.arabic` (was `null` / device) — the splash, the language
  screen and the entry screen all render Arabic-first, matching the Figma.
  `العربية` is pre-selected and carries the `افتراضي` marker; the page also
  re-commits Arabic in `initState` if the locale is somehow `null`.
  `SupportedLocales.resolveLocale` falls back to Arabic too. Tests assert against
  English, so `authOverrides` overrides the locale controller back to
  device-driven (`DeviceLocaleController`); `pumpApp(locale: arabic)` still
  forces RTL where a test wants it.
* Tapping a row switches the app language **live** via `localeControllerProvider`
  (RTL ⇄ LTR flips immediately).
* `متابعة` calls `LanguageSelectionController.markSelected()` and routes to
  `/welcome`.

## Routing

`languageSelectedProvider`
(`lib/features/authentication/presentation/state/language_selection_controller.dart`)
is an in-memory `bool` — `false` until the guest confirms. While `false` the
router sends every unauthenticated location to `/welcome/language` first; once
`true` the entry flow applies (`splash → welcome → discover`, then browsing is
public — see `mobile-deferred-auth.md`). `AppRoutes.language` is part of
`AppRoutes.authSurface`, so an authenticated guest never sees it.

**Persistence is deferred** (Phase 0 storage layer, like the locale and
theme-mode controllers): the flag resets on a cold start, so the screen
reappears each launch until `core/storage/` lands. Tests bypass it via
`authOverrides(languageChosen: …)` / `pumpApp(languageChosen: …)`.
