# Splash White Screen Diagnostic & Fix

## Steps

- [x] STEP 1 — Capture complete error
      **ROOT CAUSE:** `_SplashScreenState` uses `SingleTickerProviderStateMixin` but creates TWO
      `AnimationController` instances (`_entranceController`, `_exitController`).
      Assertion error at `ticker_provider.dart:327` causes white screen.

- [ ] STEP 2 — Edit `splash_screen.dart`:
  - [x] a. Change `SingleTickerProviderStateMixin` → `TickerProviderStateMixin`
  - [ ] b. Fix `Future.wait<dynamic>` + `results[1] as User?` → typed independent futures
  - [ ] c. Read `disableAnimations` BEFORE any `await`, pass to methods
  - [ ] d. Add `debugPrint('ACTIVE TUNO SPLASH BUILD');` in `build()`
  - [ ] e. Temporarily simplify build body to text-only Scaffold for diagnosis

- [ ] STEP 3 — Run `flutter run -d chrome`, confirm text-only Splash renders

- [ ] STEP 4 — Restore original Splash UI (logo, animations, fade-out)

- [ ] STEP 5 — Run final verification:
  - [ ] `dart format .`
  - [ ] `flutter analyze`
  - [ ] `flutter build web --no-tree-shake-icons`
  - [ ] `flutter run -d chrome` → confirm dark bg, centered logo, no white screen

