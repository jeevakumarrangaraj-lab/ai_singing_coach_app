# VoicePracticeScreen Fix Plan

## Progress

- [x] Analyze all relevant files
- [x] Plan approved with adjustments

## Implementation Steps

1. [ ] **Edit 1** — Update imports: remove `app_colors.dart`, `responsive_page_background.dart`
2. [ ] **Edit 2** — Replace state variables: remove `_isStartupInProgress`, `_isMicrophonePressed`, `_lastIsRecording`; rename `_isMicrophoneBusy` → `_isBusy`
3. [ ] **Edit 3** — Update `initState`: remove `_isStartupInProgress = false`
4. [ ] **Edit 4** — Update `didChangeDependencies`: use state directly, remove `_lastIsRecording`
5. [ ] **Edit 5** — Rewrite `build` method: remove `ResponsivePageBackground`, use `colorScheme.surface`, Tooltip on back button
6. [ ] **Edit 6** — Rewrite `_buildRecordingUI`: remove `AppColors` refs, use `colorScheme`
7. [ ] **Edit 7** — Replace `_handleMicrophoneTap` with unified stop handler
8. [ ] **Edit 8** — Rewrite `_buildMicrophoneButton` with monochrome theme colors
9. [ ] **Edit 9** — Update `_handleStartRecording`: merge into `_isBusy`
10. [ ] **Edit 10** — Update `_buildTimerDisplay`: use `colorScheme` instead of `AppColors`
11. [ ] **Edit 11** — Update `_buildActionButtons`: fix `isDisabled`, use `colorScheme`
12. [ ] **Edit 12** — Replace error/success cards with monochrome `Card` widgets

## Post-Implementation

- [x] Run `dart format lib/features/practice/presentation/screens/voice_practice_screen.dart`
- [x] Run `flutter analyze lib/features/practice/presentation/screens/voice_practice_screen.dart` — 1 info-level lint (use_build_context_synchronously, already guarded by mounted check — acceptable)
- [x] Run `flutter build web --no-pub --no-tree-shake-icons` — ✅ Build succeeded

