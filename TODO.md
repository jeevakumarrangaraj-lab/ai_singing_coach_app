# TODO: Fix Onboarding Completion Navigation

## Steps

- [x] 1. Add `markCompleted()` to `OnboardingCompletionController` (synchronous)
- [x] 2. Convert `OnboardingReviewStep` to `ConsumerStatefulWidget` with `_isSubmitting` guard
- [x] 3. In `OnboardingReviewStep` onPressed:
  - [x] Guard: if `_isSubmitting || state.isLoading` return
  - [x] Set `_isSubmitting = true`
  - [x] Call `completeOnboarding()`
  - [x] If success → `markCompleted()` + `context.go('/home')`
  - [x] If failure → `_isSubmitting = false`, stay, show error SnackBar
  - [x] Check `if (!mounted) return;` after each await
- [x] 4. In `onboarding_screen.dart`: Remove duplicate Finish button on Step 5, keep Back button
- [x] 5. In `splash_screen.dart`: Remove forced `/home`, navigate to `/welcome` and let GoRouter decide
- [x] 6. In `app_router.dart`: Refactor to `_buildRouter(Ref ref)` to ensure fresh state reads
- [x] 7. Run `dart format .` (1 file formatted)
- [x] 8. Run `flutter analyze` (0 errors, 18 pre-existing info-level only)
- [x] 9. Run `flutter build web --no-pub --no-tree-shake-icons` (in progress)
- [ ] 10. Report exact reason /home redirects back

