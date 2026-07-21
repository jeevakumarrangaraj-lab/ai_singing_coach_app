import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/enums/icon_position.dart';
import '../features/auth/presentation/widgets/auth_elevated_button.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/responsive_page_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Tuno',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: ResponsivePageBackground(
        imagePath: 'assets/images/dashboard_bg.png',
        mobileAlignment: Alignment.center,
        wideAlignment: Alignment.bottomCenter,
        mobileOverlayAlpha: 0.24,
        wideOverlayAlpha: 0.14,
        maxContentWidth: 1200,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Singer 👋',
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to improve your voice today?',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 28),
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryButtonGradient,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          size: 55,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Start Voice Practice',
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Record your voice and receive instant feedback.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthElevatedButton(
                        label: 'Start Practice',
                        onPressed: () {
                          context.push('/practice');
                        },
                        isLoading: false,
                        icon: Icons.fiber_manual_record_rounded,
                        iconPosition: IconPosition.start,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Your Progress',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        title: 'Practice',
                        value: '0 min',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ProgressCard(
                        title: 'Streak',
                        value: '0 days',
                        icon: Icons.local_fire_department_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryCoral, size: 30),
          const SizedBox(height: 18),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
