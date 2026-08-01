import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/tuno_dashboard_background.dart';

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
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getFileName() {
    return audioPath.split('/').last;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool get _hasValidData {
    final fileName = _getFileName();
    return audioPath.isNotEmpty &&
        fileName.isNotEmpty &&
        duration > Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final fileName = _getFileName();
    final formattedDuration = _formatDuration(duration);

    return Scaffold(
      backgroundColor: cs.surface,
      body: TunoDashboardBackground(
        animate: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Tooltip(
                        message: l10n.back,
                        child: Semantics(
                          button: true,
                          label: l10n.back,
                          child: AppBackButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/practice');
                              }
                            },
                            showOnlyIfCanPop: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.pending_actions_rounded,
                        size: 60,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      l10n.analysisPending,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Status message
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: cs.outlineVariant, width: 1),
                      ),
                      child: Text(
                        l10n.aiAnalysisComingSoon,
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Recording Details Card
                    Card(
                      color: cs.surfaceContainerHighest,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(color: cs.outlineVariant, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recordingDetails,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (!_hasValidData) ...[
                              // Invalid data state
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: cs.errorContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cs.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: cs.error,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        l10n.unableToLoadDetails,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: cs.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              _buildDetailRow(
                                context,
                                icon: Icons.audiotrack_rounded,
                                label: l10n.fileName,
                                value: fileName,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                context,
                                icon: Icons.timer_rounded,
                                label: l10n.duration,
                                value: formattedDuration,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                context,
                                icon: Icons.calendar_today_rounded,
                                label: l10n.recorded,
                                value: _formatDateTime(recordedAt),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const minWidthForRow = 480.0;
                        final useRowLayout =
                            constraints.maxWidth >= minWidthForRow;

                        final practiceAgainButton = Tooltip(
                          message: l10n.practiceAgain,
                          child: FilledButton(
                            onPressed: () => context.go('/practice'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mic_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.practiceAgain,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        final backToReviewButton = Tooltip(
                          message: l10n.backToReview,
                          child: OutlinedButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/practice');
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              side: BorderSide(color: cs.outline, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.backToReview,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        if (useRowLayout) {
                          return Row(
                            children: [
                              Expanded(child: practiceAgainButton),
                              const SizedBox(width: 16),
                              Expanded(child: backToReviewButton),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: practiceAgainButton,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: backToReviewButton,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: cs.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface,
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
