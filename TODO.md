# TODO — Improve Light Theme visibility of Tuno music decorations

## Steps
- [ ] 1. Edit `lib/core/widgets/tuno_music_background.dart` light-theme branches
  - [ ] Welcome waves color (`_welcomeWaveColor`) → darker teal
  - [ ] Welcome notes gradient alpha (light ~0.38)
  - [ ] `_drawLargeMusicNote` fill-paint preservation fix
  - [ ] Welcome sparkles glow alpha (light 0.16)
  - [ ] Welcome bottom curves (light 0.10–0.16, darker teal)
  - [ ] Signup top waves alpha (light 0.14–0.22)
  - [ ] Signup top notes alpha (light ~0.32)
  - [ ] Signup bottom waves alpha (light 0.10–0.16)
  - [ ] Signup wave/note colors → darker teal
  - [ ] Login waves alpha (light 0.18–0.22)
  - [ ] Login notes alpha (light ~0.34)
  - [ ] Login wave/note colors → darker teal
  - [ ] Staff-line / wave / note helpers (light darker + more visible)
  - [ ] HomeMusicBackgroundPainter light values (notes, sparkles, glow dots, EQ, waveform)
- [ ] 2. Edit `lib/core/widgets/dashboard_music_decorations.dart` light-theme branches
  - [ ] Wave / note color helper multipliers (light more visible)
  - [ ] Base wave opacity for light
  - [ ] Waveform curve base opacity for light
  - [ ] Gold sparkle opacities for light
- [ ] 3. Run `dart format lib/core/widgets/tuno_music_background.dart`
- [ ] 4. Run `flutter analyze lib/core/widgets/tuno_music_background.dart`
- [ ] 5. Run `flutter analyze`
- [ ] 6. Run `flutter build web --no-pub --no-tree-shake-icons`
- [ ] 7. Report exact light-theme colors/opacity changes

