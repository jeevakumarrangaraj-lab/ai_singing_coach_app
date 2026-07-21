import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/responsive_page_background.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsivePageBackground(
        imagePath: 'assets/images/welcome_bg.png',
        mobileAlignment: Alignment.center,
        wideAlignment: Alignment.bottomCenter,
        mobileOverlayAlpha: 0.24,
        wideOverlayAlpha: 0.14,
        maxContentWidth: 1200,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 420;
              final horizontal = isSmall ? 18.0 : 28.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: 18,
                ),
                child: FadeTransition(
                  opacity: _fade,
                  child: Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Tuno',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.95,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MicHeader(isSmall: isSmall),
                            const SizedBox(height: 12),
                            _FeatureGrid(isSmall: isSmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _BottomCta(isSmall: isSmall),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MicHeader extends StatelessWidget {
  const _MicHeader({required this.isSmall});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 44,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.mic_rounded, size: 55, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Train Your Voice with AI',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: isSmall ? 32 : 36,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Improve your pitch, melody, rhythm, and breathing.',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: isSmall ? 15 : 16,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.isSmall});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    const cards = [
      'AI Pitch Detection',
      'Melody Analysis',
      'Daily Practice',
      'Track Progress',
    ];

    final width = MediaQuery.of(context).size.width;
    final isVeryNarrow = width < 340;

    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: isVeryNarrow
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: cards
                    .map(
                      (label) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _FeatureCard(label: label),
                      ),
                    )
                    .toList(),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: cards
                    .map(
                      (label) => SizedBox(
                        width: (width - 48) / 2,
                        child: _FeatureCard(label: label),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.isSmall});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: isSmall ? 50 : 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => context.go('/signup'),
                  child: Text(
                    'Get Started',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Already have an account?',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Login',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryLight,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
