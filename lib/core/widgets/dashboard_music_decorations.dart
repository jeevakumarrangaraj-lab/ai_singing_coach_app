import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Reusable musical decoration overlay for the Tuno Dashboard background.
///
/// Draws thin flowing wave lines, teal music notes, metallic-gold four-point
/// sparkles, and subtle audio waveform curves — distributed across the entire
/// scrollable content height using normalized coordinates so proportions are
/// preserved on mobile and desktop.
///
/// When [animate] is true and the system has not disabled animations, all
/// decorative elements float gently:
///   - Upper waves: 8–16px horizontal, 3–6px vertical over 10–14 seconds.
///   - Lower waves: opposite horizontal direction, slightly different duration.
///   - Music notes: vertical 8–14px, horizontal 3–5px, rotation ±2°.
///   - Gold sparkles: scale 0.92→1.06, opacity 0.55→0.90 in 2.5–4s cycles.
///
/// Uses a single [AnimationController] with derived phase values per element.
/// Wrapped with [IgnorePointer] so all taps pass through to the content.
/// Respects [MediaQuery.disableAnimations].
///
/// Design colours:
///   - Base background: #030D1B (set externally via Scaffold)
///   - Wave lines: #087D91 with low opacity
///   - Music notes: gradient #087D91 → #07506C
///   - Gold sparkles: #FFF2A6 → #E3B94F → #A86D16
class DashboardMusicDecorations extends StatefulWidget {
  const DashboardMusicDecorations({super.key, this.animate = false});

  /// When true, decorative elements float gently with slow, subtle motion.
  final bool animate;

  @override
  State<DashboardMusicDecorations> createState() =>
      _DashboardMusicDecorationsState();

  static const Color _waveColor = Color(0xFF087D91);
  static const Color _noteStart = Color(0xFF087D91);
  static const Color _noteEnd = Color(0xFF07506C);
  static const Color _goldChampagne = Color(0xFFFFF2A6);
  static const Color _goldPrimary = Color(0xFFE3B94F);
  static const Color _goldDeep = Color(0xFFA86D16);
}

class _DashboardMusicDecorationsState extends State<DashboardMusicDecorations>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  // Derived phase tracks for different elements (populated when animate=true)
  double _animPhase = 0.0;
  // Store reduceMotion to avoid initState access
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final shouldAnimate = widget.animate && !reduceMotion;

    if (shouldAnimate && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 12),
      )..repeat();
      _controller!.addListener(_onAnimationTick);
    } else if (!shouldAnimate && _controller != null) {
      _controller!.removeListener(_onAnimationTick);
      _controller!.dispose();
      _controller = null;
      _animPhase = 0.0;
    }
    _reduceMotion = reduceMotion;
  }

  void _onAnimationTick() {
    if (_controller == null) return;
    _animPhase = _controller!.value;
    // Trigger repaint via setState (CustomPainter will use _animPhase)
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onAnimationTick);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion =
        _reduceMotion ?? MediaQuery.of(context).disableAnimations;
    final phase = _animPhase;

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _DashboardBackgroundPainter(
            isDark: isDark,
            reduceMotion: reduceMotion,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            animPhase: phase,
            animate: widget.animate && !reduceMotion,
          ),
        );
      },
    );
  }
}

/// Paints all dashboard background decorations proportional to the given
/// canvas size.  All Y positions use normalised coordinates (0.0 – 1.0) so
/// decorations distribute correctly regardless of scrollable content height.
class _DashboardBackgroundPainter extends CustomPainter {
  /// Overscan distance extending wave paths beyond the visible canvas.
  /// Must be larger than the maximum horizontal animation offset (±12px
  /// for upper waves, ±10px for lower waves). At 140px, this is ~10×
  /// the max offset, ensuring wave endpoints never become visible.
  static const double _overscan = 140.0;

  _DashboardBackgroundPainter({
    required this.isDark,
    required this.reduceMotion,
    required this.width,
    required this.height,
    this.animPhase = 0.0,
    this.animate = false,
  });

  final bool isDark;
  final bool reduceMotion;
  final double width;
  final double height;
  final double animPhase;
  final bool animate;

  // ── Paint helpers ──

  double get _canvasWidth => width;
  double get _canvasHeight => height;

  // Scale note/sparkle sizes relative to a 400px-wide reference.
  double get _sizeScale => (_canvasWidth / 400).clamp(0.55, 1.4);

  // Normalised X range that stays within a centred 760px max-width.
  // At 400px wide, margins are ~5%; at 1400px wide, margins are larger.
  double get _leftMargin =>
      ((_canvasWidth - 760) / _canvasWidth).clamp(0.04, 0.18);
  double get _rightMargin => 1.0 - _leftMargin;

  // Colour helpers with opacity baked in.
  // Light theme uses a deeper teal/cyan and keeps opacities high enough to be
  // clearly visible without competing with content.  Dark theme is unchanged.
  Color _wavePaintColor(double opacity) {
    final base = isDark
        ? DashboardMusicDecorations._waveColor
        : const Color(0xFF0B7185);
    return base.withValues(alpha: (isDark ? opacity : opacity).clamp(0.0, 1.0));
  }

  Color _notePaintColor(double opacity) {
    final base = isDark
        ? DashboardMusicDecorations._noteStart
        : const Color(0xFF168FA0);
    return base.withValues(
      alpha: (isDark ? opacity : opacity * 1.15).clamp(0.0, 1.0),
    );
  }

  Color _noteStrokeColor(double opacity) {
    final base = isDark
        ? DashboardMusicDecorations._noteEnd
        : const Color(0xFF0B7185);
    return base.withValues(
      alpha: (isDark ? opacity * 1.2 : opacity * 0.9).clamp(0.0, 1.0),
    );
  }

  // ── Animation phase helpers ──

  /// Upper wave horizontal offset: 8–16px sin wave.
  double get _waveHOffset =>
      animate ? math.sin(animPhase * 2 * math.pi) * 12.0 : 0.0;

  /// Upper wave vertical offset: 3–6px sin wave with phase shift.
  double get _waveVOffset =>
      animate ? math.sin(animPhase * 2 * math.pi + 1.2) * 4.5 : 0.0;

  /// Lower waves move in opposite horizontal direction.
  double get _lowerWaveHOffset =>
      animate ? math.sin(animPhase * 2 * math.pi * 0.85 + 0.5) * -10.0 : 0.0;

  /// Note vertical offset for index i: 8–14px with per-index phase.
  double _noteVOffset(int index) {
    if (!animate) return 0.0;
    return math.sin(
          animPhase * 2 * math.pi * (0.7 + index * 0.12) + index * 1.7,
        ) *
        (8.0 + (index % 3) * 2.0);
  }

  /// Note horizontal offset for index i: 3–5px.
  double _noteHOffset(int index) {
    if (!animate) return 0.0;
    return math.sin(
          animPhase * 2 * math.pi * (0.5 + index * 0.09) + index * 2.3,
        ) *
        (3.0 + (index % 2) * 1.5);
  }

  /// Note rotation offset for index i: -2° to +2° (~ -0.035 to 0.035 rad).
  double _noteRotationOffset(int index) {
    if (!animate) return 0.0;
    return math.sin(
          animPhase * 2 * math.pi * (0.6 + index * 0.15) + index * 0.9,
        ) *
        0.035;
  }

  /// Sparkle scale: 0.92 → 1.06 over ~3s cycle (use animPhase * 3.0 for 4s @12s).
  double _sparkleScale(int index) {
    if (!animate) return 1.0;
    // Cycle every 3 seconds of the 12s animation → phase multiplier of 4.0
    final t =
        (math.sin(
              (animPhase * 2 * math.pi * 4.0 + index * 1.3) % (math.pi * 2),
            ) +
            1.0) /
        2.0; // 0..1
    return 0.92 + t * 0.14; // 0.92 → 1.06
  }

  /// Sparkle opacity: 0.55 → 0.90.
  double _sparkleOpacity(int index) {
    if (!animate) return 1.0;
    final t =
        (math.sin(
              (animPhase * 2 * math.pi * 3.5 + index * 2.1) % (math.pi * 2),
            ) +
            1.0) /
        2.0;
    return 0.55 + t * 0.35;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (reduceMotion) {
      // When system animations are disabled, draw only the most subtle
      // static wave lines — no notes, sparkles, or waveforms.
      _drawFlowingWaves(canvas, opacity: 0.06);
      return;
    }

    _drawFlowingWaves(canvas, opacity: isDark ? 0.12 : 0.20);
    _drawMusicNotes(canvas);
    _drawGoldSparkles(canvas);
    _drawWaveformCurves(canvas);
  }

  // ─────────────────────────────────────────────────────────────
  //  1. FLOWING WAVE LINES
  // ─────────────────────────────────────────────────────────────

  /// Y-normalised positions for wave bands.
  static const _waveBands = <double>[
    0.04, // header region
    0.14, // greeting region
    0.32, // around practice card
    0.52, // between sections
    0.72, // lower region
    0.90, // above bottom nav
  ];

  void _drawFlowingWaves(Canvas canvas, {required double opacity}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.0;

    for (final bandY in _waveBands) {
      final baseY = bandY * _canvasHeight;

      // 3 parallel waves per band, staggered slightly
      for (int i = 0; i < 3; i++) {
        final alpha = opacity * (0.5 + i * 0.25);
        paint.color = _wavePaintColor(alpha);
        paint.strokeWidth = 1.0 + i * 0.3;

        final yOffset = i * 12.0 * _sizeScale;
        final path = Path();

        // Use overscan so wave paths extend far beyond the visible canvas.
        // This prevents the horizontal animation from exposing path endpoints.
        final x0 = _leftMargin * _canvasWidth - _overscan;
        final xEnd = _rightMargin * _canvasWidth + _overscan;
        final waveWidth = xEnd - x0;
        final amp = (6.0 + i * 2.0) * _sizeScale;
        final freq = 2.5 + i * 0.3;
        final phaseShift = i * 0.8;

        // Apply animation offsets: upper bands (early in list) use waveH/VOffset,
        // lower bands use lowerWaveHOffset.
        final isUpper = bandY < 0.5;
        final hOff = isUpper ? _waveHOffset : _lowerWaveHOffset;
        final vOff = isUpper ? _waveVOffset : _waveVOffset * -0.6;

        // Apply uniform horizontal offset to the entire path so the wave
        // shifts as a rigid unit — no tapering that would expose endpoints.
        path.moveTo(x0 + hOff, baseY + yOffset + vOff);
        for (double x = x0; x <= xEnd; x += 4) {
          final t = (x - x0) / waveWidth;
          final y =
              baseY +
              yOffset +
              vOff +
              amp * math.sin((t * freq * 2 * math.pi) + phaseShift);
          path.lineTo(x + hOff, y);
        }
        canvas.drawPath(path, paint);

        // Second harmonic even more subtle
        if (i == 1) {
          final paint2 = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 0.8
            ..color = _wavePaintColor(alpha * 0.5);

          final path2 = Path();
          path2.moveTo(
            x0 + 20 + hOff * 0.5,
            baseY + yOffset + 6 * _sizeScale + vOff * 0.5,
          );
          for (double x = x0 + 20; x <= xEnd - 10; x += 4) {
            final t = (x - x0 - 20) / (waveWidth - 30);
            final y =
                baseY +
                yOffset +
                6 * _sizeScale +
                vOff * 0.5 +
                amp *
                    0.5 *
                    math.sin((t * freq * 2 * math.pi * 1.7) + phaseShift + 1.2);
            path2.lineTo(x + hOff * 0.5, y);
          }
          canvas.drawPath(path2, paint2);
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  2. MUSIC NOTES
  // ─────────────────────────────────────────────────────────────

  /// Normalised positions for notes: (xNorm, yNorm, sizeScale, rotation, isPaired).
  static const _notePlacements = <(double, double, double, double, bool)>[
    (0.08, 0.02, 0.90, -0.15, false), // header left
    (0.82, 0.07, 1.00, 0.10, false), // header right
    (0.12, 0.20, 0.85, 0.12, false), // greeting left
    (0.78, 0.30, 1.05, -0.08, true), // above practice card right (paired)
    (0.10, 0.42, 0.80, 0.18, false), // practice card left
    (0.85, 0.50, 0.95, -0.12, false), // between sections right
    (0.15, 0.58, 0.75, -0.06, true), // progress section left (paired)
    (0.80, 0.68, 0.88, 0.14, false), // lower right
    (0.08, 0.80, 0.78, -0.10, false), // lower left
    (0.84, 0.88, 0.82, 0.08, false), // above bottom nav right
  ];

  void _drawMusicNotes(Canvas canvas) {
    for (int idx = 0; idx < _notePlacements.length; idx++) {
      final (xNorm, yNorm, noteScale, rotation, isPaired) =
          _notePlacements[idx];
      final x = xNorm * _canvasWidth + _noteHOffset(idx) * _sizeScale;
      final y = yNorm * _canvasHeight + _noteVOffset(idx) * _sizeScale;
      final sz = 36.0 * _sizeScale * noteScale;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation + _noteRotationOffset(idx));

      if (isPaired) {
        _drawBeamedNotePair(canvas, sz);
      } else {
        _drawSingleNote(canvas, sz);
      }

      canvas.restore();
    }
  }

  void _drawSingleNote(Canvas canvas, double size) {
    final headW = size * 0.50;
    final headH = size * 0.32;
    final stemH = size * 0.55;
    final flagW = size * 0.38;
    final flagH = size * 0.28;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = _notePaintColor(0.30);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * _sizeScale
      ..strokeCap = StrokeCap.round
      ..color = _noteStrokeColor(0.40);

    // Note head (tilted ellipse)
    final headRect = Rect.fromCenter(
      center: Offset(-size * 0.06, size * 0.16),
      width: headW,
      height: headH,
    );
    final headPath = Path()..addOval(headRect);
    canvas.drawPath(headPath, fill);
    canvas.drawPath(headPath, stroke);

    // Stem
    final stemX = headRect.right * 0.82;
    final stemTop = -stemH * 0.65;
    final stemBottom = headRect.center.dy + headH * 0.30;
    canvas.drawLine(Offset(stemX, stemBottom), Offset(stemX, stemTop), stroke);

    // Flag (eighth-note curve)
    final flagPath = Path()
      ..moveTo(stemX, stemTop)
      ..cubicTo(
        stemX + flagW * 0.7,
        stemTop + flagH * 0.2,
        stemX + flagW * 0.95,
        stemTop + flagH * 0.7,
        stemX + flagW * 0.5,
        stemTop + flagH,
      )
      ..cubicTo(
        stemX + flagW * 0.25,
        stemTop + flagH * 0.7,
        stemX + flagW * 0.18,
        stemTop + flagH * 0.25,
        stemX.toDouble(),
        stemTop + flagH * 0.12,
      )
      ..close();
    canvas.drawPath(flagPath, fill);
    canvas.drawPath(flagPath, stroke);
  }

  void _drawBeamedNotePair(Canvas canvas, double size) {
    final spacing = size * 0.72;
    final headW = size * 0.45;
    final headH = size * 0.28;
    final stemH = size * 0.55;
    final beamH = size * 0.06;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = _notePaintColor(0.25);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * _sizeScale
      ..strokeCap = StrokeCap.round
      ..color = _noteStrokeColor(0.35);

    for (int i = 0; i < 2; i++) {
      final cx = i * spacing;
      final headRect = Rect.fromCenter(
        center: Offset(cx - size * 0.04, size * 0.14),
        width: headW,
        height: headH,
      );
      final headPath = Path()..addOval(headRect);
      canvas.drawPath(headPath, fill);
      canvas.drawPath(headPath, stroke);

      final sX = headRect.right * 0.78;
      final sTop = -stemH * 0.60;
      final sBottom = headRect.center.dy + headH * 0.30;
      canvas.drawLine(Offset(sX, sBottom), Offset(sX, sTop), stroke);
    }

    // Beam
    final leftStemX = 0.0;
    final rightStemX = spacing;
    final beamTop = -stemH * 0.60;
    final beamBottom = beamTop + beamH;
    final beamPath = Path()
      ..moveTo(leftStemX, beamTop)
      ..lineTo(rightStemX, beamTop)
      ..lineTo(rightStemX, beamBottom)
      ..lineTo(leftStemX, beamBottom)
      ..close();
    canvas.drawPath(beamPath, fill);
    canvas.drawPath(beamPath, stroke);
  }

  // ─────────────────────────────────────────────────────────────
  //  3. GOLD FOUR-POINT SPARKLES
  // ─────────────────────────────────────────────────────────────

  static const _sparklePlacements = <(double, double, double)>[
    (0.88, 0.04, 1.0), // header right
    (0.14, 0.15, 0.9), // greeting left
    (0.72, 0.35, 1.1), // practice card right
    (0.20, 0.48, 0.8), // between sections left
    (0.82, 0.62, 1.0), // lower right
    (0.12, 0.75, 0.7), // lower left
    (0.86, 0.92, 0.9), // above bottom nav right
  ];

  void _drawGoldSparkles(Canvas canvas) {
    for (int idx = 0; idx < _sparklePlacements.length; idx++) {
      final (xNorm, yNorm, szScale) = _sparklePlacements[idx];
      final x = xNorm * _canvasWidth;
      final y = yNorm * _canvasHeight;
      final baseSz = 20.0 * _sizeScale * szScale;
      final scale = _sparkleScale(idx);
      final sz = baseSz * scale;
      _drawFourPointSparkle(
        canvas,
        Offset(x, y),
        sz,
        opacity: _sparkleOpacity(idx),
      );
    }
  }

  void _drawFourPointSparkle(
    Canvas canvas,
    Offset center,
    double size, {
    double opacity = 1.0,
  }) {
    final halfSize = size / 2;
    final innerRadius = size * 0.18;

    // Subtle glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = DashboardMusicDecorations._goldDeep.withValues(
        alpha: ((isDark ? 0.15 : 0.14) * opacity).clamp(0.0, 1.0),
      );
    canvas.drawCircle(center, halfSize * 0.55, glowPaint);

    // Four arms
    final armPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = DashboardMusicDecorations._goldPrimary.withValues(
        alpha: ((isDark ? 0.55 : 0.50) * opacity).clamp(0.0, 1.0),
      );

    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = DashboardMusicDecorations._goldChampagne.withValues(
        alpha: ((isDark ? 0.45 : 0.42) * opacity).clamp(0.0, 1.0),
      );

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      // Outer diamond
      final armPath = Path()
        ..moveTo(
          center.dx + cosA * innerRadius - sinA * innerRadius * 0.35,
          center.dy + sinA * innerRadius + cosA * innerRadius * 0.35,
        )
        ..lineTo(center.dx + cosA * halfSize, center.dy + sinA * halfSize)
        ..lineTo(
          center.dx + cosA * innerRadius + sinA * innerRadius * 0.35,
          center.dy + sinA * innerRadius - cosA * innerRadius * 0.35,
        )
        ..close();
      canvas.drawPath(armPath, armPaint);

      // Inner highlight
      final hlPath = Path()
        ..moveTo(
          center.dx + cosA * innerRadius * 1.2 - sinA * innerRadius * 0.2,
          center.dy + sinA * innerRadius * 1.2 + cosA * innerRadius * 0.2,
        )
        ..lineTo(
          center.dx + cosA * halfSize * 0.6,
          center.dy + sinA * halfSize * 0.6,
        )
        ..lineTo(
          center.dx + cosA * innerRadius * 1.2 + sinA * innerRadius * 0.2,
          center.dy + sinA * innerRadius * 1.2 - cosA * innerRadius * 0.2,
        )
        ..close();
      canvas.drawPath(hlPath, highlightPaint);
    }

    // Deep gold centre
    final deepPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = DashboardMusicDecorations._goldDeep.withValues(
        alpha: ((isDark ? 0.45 : 0.40) * opacity).clamp(0.0, 1.0),
      );
    canvas.drawCircle(center, innerRadius * 0.4, deepPaint);

    // Bright centre dot
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = DashboardMusicDecorations._goldChampagne.withValues(
        alpha: ((isDark ? 0.70 : 0.60) * opacity).clamp(0.0, 1.0),
      );
    canvas.drawCircle(center, innerRadius * 0.22, dotPaint);
  }

  // ─────────────────────────────────────────────────────────────
  //  4. AUDIO WAVEFORM CURVES
  // ─────────────────────────────────────────────────────────────

  static const _waveformBands = <double>[
    0.10, // greeting area
    0.38, // practice card area
    0.65, // lower area
  ];

  void _drawWaveformCurves(Canvas canvas) {
    for (final bandY in _waveformBands) {
      final baseY = bandY * _canvasHeight;
      final xCenter = _canvasWidth * 0.50;
      final w = (_rightMargin - _leftMargin) * _canvasWidth * 0.60;
      final xStart = xCenter - w / 2;
      final amp = (10.0 + bandY * 8.0) * _sizeScale;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.2 * _sizeScale
        ..color = _wavePaintColor(isDark ? 0.06 : 0.12);

      // Sine wave
      final path = Path();
      path.moveTo(xStart, baseY);
      for (double x = 0; x <= w; x += 3) {
        final t = x / w;
        final y = baseY + amp * math.sin(t * 4 * math.pi);
        path.lineTo(xStart + x, y);
      }
      canvas.drawPath(path, paint);

      // Second slightly offset wave
      final paint2 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.8 * _sizeScale
        ..color = _wavePaintColor(isDark ? 0.04 : 0.08);

      final path2 = Path();
      const offset = 8.0;
      path2.moveTo(xStart + offset, baseY + 4 * _sizeScale);
      for (double x = 0; x <= w - offset * 2; x += 3) {
        final t = x / (w - offset * 2);
        final y =
            baseY +
            4 * _sizeScale +
            amp * 0.6 * math.sin(t * 5 * math.pi + 0.8);
        path2.lineTo(xStart + offset + x, y);
      }
      canvas.drawPath(path2, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardBackgroundPainter oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.isDark != isDark ||
        oldDelegate.reduceMotion != reduceMotion ||
        oldDelegate.animPhase != animPhase ||
        oldDelegate.animate != animate;
  }
}
