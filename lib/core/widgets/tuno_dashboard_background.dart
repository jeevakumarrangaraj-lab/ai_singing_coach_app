import 'package:flutter/material.dart';

import 'dashboard_music_decorations.dart';

/// Shared background widget that reproduces the Dashboard background
/// exactly — the single source of truth for all authenticated Tuno screens.
///
/// Features:
/// - Base dark navy (#030D1B) set via Scaffold backgroundColor
/// - Flowing teal/cyan music waves
/// - Musical-note styling (single + beamed pairs)
/// - Metallic-gold four-point sparkles
/// - Audio waveform curves
/// - All tap events pass through to [child] via [IgnorePointer]
/// - Responsive: uses the same canonical coordinate system as [DashboardMusicDecorations]
/// - Scales uniformly with BoxFit.contain logic (built into [DashboardMusicDecorations])
/// - Centered on large screens, clipped safely
///
/// Usage:
/// ```dart
/// TunoDashboardBackground(
///   child: myScreenContent,
/// )
/// ```
class TunoDashboardBackground extends StatelessWidget {
  const TunoDashboardBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Decorative layer (non-interactive) ──
        // Reproduces the Dashboard background exactly.
        // IgnorePointer ensures taps pass through to the content.
        Positioned.fill(
          child: const IgnorePointer(
            ignoring: true,
            child: DashboardMusicDecorations(),
          ),
        ),
        // ── Foreground content (fully interactive) ──
        child,
      ],
    );
  }
}
