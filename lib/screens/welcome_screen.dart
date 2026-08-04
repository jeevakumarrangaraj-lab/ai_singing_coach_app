import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/tuno_gradient_button.dart';
import '../core/widgets/tuno_microphone_emblem.dart';
import '../core/widgets/tuno_music_background.dart';
import '../l10n/app_localizations.dart';

/// Welcome / landing screen shown to unauthenticated users.
///
/// Uses a native Flutter 1024×1536 design canvas scaled by [FittedBox].
/// All positions are in the canonical canvas coordinate system.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  static const double _canvasWidth = 1024.0;
  static const double _canvasHeight = 1536.0;
  static const double _designAspectRatio = _canvasWidth / _canvasHeight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<double>(
      begin: 14,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final l10n = AppLocalizations.of(context)!;

    // ── Foreground content (all existing widgets, unchanged) ──
    final Widget foregroundStack = SizedBox(
      width: _canvasWidth,
      height: _canvasHeight,
      child: Stack(
        children: [
          // ── Back arrow (reference: hit area 88×88, icon 48, #12B5C1) ──
          Positioned(
            left: 60,
            top: 75,
            child: SizedBox(
              width: 88,
              height: 88,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.tunoBackArrow,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── "Tuno" branding ──
          Positioned(
            left: 0,
            top: 105,
            width: _canvasWidth,
            child: Text(
              l10n.tuno,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 104,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                height: 1.0,
              ),
            ),
          ),

          // ── "AI SINGING COACH" subtitle ──
          Positioned(
            left: 0,
            top: 218,
            width: _canvasWidth,
            child: Text(
              l10n.aiSingingCoach,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w500,
                letterSpacing: 5.5,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),

          // ── Microphone emblem ──
          Positioned(
            left: 332,
            top: 334,
            child: Semantics(
              label: l10n.tunoLogoSemanticLabel,
              child: TunoMicrophoneEmblem(diameter: 360),
            ),
          ),

          // ── Main heading ──
          Positioned(
            left: 120,
            top: 758,
            width: 784,
            child: Text(
              l10n.yourPersonalAiCoach,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 75,
                fontWeight: FontWeight.w800,
                height: 1.13,
                color: cs.onSurface,
              ),
            ),
          ),

          // ── Tagline with gold separator dots ──
          Positioned(
            left: 0,
            top: 972,
            width: _canvasWidth,
            child: (() {
              const bullet = '\u2022';
              final parts = l10n.practiceImproveAchieve.split(' $bullet ');
              return Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurfaceVariant,
                  ),
                  children: [
                    for (int i = 0; i < parts.length; i++) ...[
                      TextSpan(text: parts[i]),
                      if (i < parts.length - 1)
                        TextSpan(
                          text: ' $bullet ',
                          style: TextStyle(color: AppColors.tunoGold),
                        ),
                    ],
                  ],
                ),
                textAlign: TextAlign.center,
              );
            }()),
          ),

          // ── "Get Started" button (reference dimensions + gradient) ──
          Positioned(
            left: 145,
            top: 1094,
            width: 734,
            height: 122,
            child: TunoGradientButton(
              label: l10n.getStarted,
              trailingIcon: Icons.arrow_forward_rounded,
              trailingIconColor: AppColors.tunoGoldPrimary,
              trailingIconSize: 42,
              onPressed: () {
                debugPrint('WELCOME: Get Started tapped');
                context.go('/signup');
              },
              fullWidth: true,
              height: 122,
              borderRadius: 61,
              semanticLabel: l10n.getStarted,
              labelFontSize: 42,
              labelFontWeight: FontWeight.w700,
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF008BA6),
                  Color(0xFF006D98),
                  Color(0xFF014B75),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),

          // ── "Login" outlined button (reference dimensions) ──
          Positioned(
            left: 145,
            top: 1248,
            width: 734,
            height: 114,
            child: SizedBox(
              width: 734,
              height: 114,
              child: OutlinedButton(
                onPressed: () {
                  debugPrint('WELCOME: Login tapped');
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(57),
                  ),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.tunoWelcomeOutlineDark
                        : AppColors.tunoWelcomeOutlineLight,
                    width: 1.5,
                  ),
                  padding: EdgeInsets.zero,
                  backgroundColor: isDark
                      ? AppColors.tunoWelcomeSurfaceDark
                      : AppColors.tunoWelcomeSurfaceLight,
                ),
                child: Text(
                  l10n.login,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.tunoWelcomeButtonLabelDark
                        : AppColors.tunoWelcomeButtonLabelLight,
                  ),
                ),
              ),
            ),
          ),

          // ── Page indicator dots ──
          Positioned(
            left: 0,
            top: 1430,
            width: _canvasWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(filled: true, color: cs.primary, size: 14),
                const SizedBox(width: 14),
                _dot(filled: false, color: cs.onSurfaceVariant, size: 11),
                const SizedBox(width: 14),
                _dot(filled: false, color: cs.onSurfaceVariant, size: 11),
              ],
            ),
          ),
        ],
      ),
    );

    // Entrance animation wrapper — always preserves the child
    final Widget animatedForeground = disableAnimations
        ? foregroundStack
        : FadeTransition(
            opacity: _fade,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: foregroundStack,
            ),
          );

    // Unified canvas: background + foreground share the same 1024×1536 space
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;

          final canvasWidth = math.min(
            availableWidth,
            availableHeight * _designAspectRatio,
          );

          final canvasHeight = canvasWidth / _designAspectRatio;

          return ColoredBox(
            color: theme.scaffoldBackgroundColor,
            child: Center(
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _canvasWidth,
                    height: _canvasHeight,
                    child: ClipRect(
                      child: TunoMusicBackground(
                        variant: TunoMusicBackgroundVariant.welcome,
                        child: animatedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dot({required bool filled, required Color color, double size = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : color.withValues(alpha: 0.35),
      ),
    );
  }
}
