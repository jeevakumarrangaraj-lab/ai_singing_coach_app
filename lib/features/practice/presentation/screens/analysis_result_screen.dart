import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/icon_position.dart';
import '../../../../core/widgets/responsive_page_background.dart';
import '../../../auth/presentation/widgets/auth_elevated_button.dart';
import '../../../auth/presentation/widgets/auth_secondary_button.dart';
import '../../../../common/widgets/app_back_button.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String audioPath;
  final Duration duration;
  final DateTime recordedAt;

  const AnalysisResultScreen({
    super.key,
    required this.audioPath,
    required this.duration,
    required this.recordedAt,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _getFileName() {
    return audioPath.split('/').last;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fileName = _getFileName();
    final formattedDuration = _formatDuration(duration);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ResponsivePageBackground(
            imagePath: 'assets/images/progress_bg.png',
            mobileAlignment: Alignment.center,
            wideAlignment: Alignment.bottomCenter,
            mobileOverlayAlpha: 0.22,
            wideOverlayAlpha: 0.14,
            maxContentWidth: 900,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryButtonGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryCoral.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Analysis Pending',
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'AI pitch analysis will be connected in the next phase.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.65),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recording Details',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildDetailRow(
                            context,
                            icon: Icons.audiotrack_rounded,
                            label: 'File Name',
                            value: fileName,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            icon: Icons.timer_rounded,
                            label: 'Duration',
                            value: formattedDuration,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            icon: Icons.calendar_today_rounded,
                            label: 'Recorded',
                            value: _formatDateTime(recordedAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: AuthSecondaryButton(
                            label: 'New Recording',
                            onPressed: () => context.go('/practice'),
                            icon: Icons.mic_rounded,
                            iconPosition: IconPosition.start,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AuthElevatedButton(
                            label: 'Back to Dashboard',
                            onPressed: () => context.go('/home'),
                            isLoading: false,
                            icon: Icons.home_rounded,
                            iconPosition: IconPosition.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // Back button on top of everything
          Positioned(
            top: 8,
            left: 8,
            child: AppBackButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryCoral.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primaryCoral, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
