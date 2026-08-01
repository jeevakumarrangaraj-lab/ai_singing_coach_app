import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import '../../domain/reference_track_state.dart';
import '../reference_track_controller.dart';
import '../practice_router.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../common/utils/navigation_helpers.dart';
import '../../../../core/widgets/tuno_dashboard_background.dart';

class ReferenceTrackScreen extends ConsumerStatefulWidget {
  const ReferenceTrackScreen({super.key});

  @override
  ConsumerState<ReferenceTrackScreen> createState() =>
      _ReferenceTrackScreenState();
}

class _ReferenceTrackScreenState extends ConsumerState<ReferenceTrackScreen> {
  bool _isBackInProgress = false;

  Future<void> _handleBackPressed() async {
    if (_isBackInProgress) return;
    _isBackInProgress = true;

    try {
      if (!context.mounted) return;
      await navigateBackSafely(
        context,
        fallbackRoute: PracticeRoutes.practiceModes,
      );
    } finally {
      _isBackInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(referenceTrackProvider);
    final controller = ref.read(referenceTrackProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: TunoDashboardBackground(
        animate: true,
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          l10n.uploadReferenceSong,
                          style: textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.chooseSongToPractice,
                          style: textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 48),
                        _buildContent(state, controller, textTheme, cs),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Tooltip(
                  message: l10n.back,
                  child: AppBackButton(
                    onPressed: _handleBackPressed,
                    showOnlyIfCanPop: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    ReferenceTrackState state,
    ReferenceTrackController controller,
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    final isPicking = state.isPicking;

    if (state.isError) {
      return _buildErrorCard(state, controller, textTheme, cs);
    }

    if (state.isSelected) {
      return _buildSelectedCard(state, controller, textTheme, cs);
    }

    return _buildIdleCard(controller, textTheme, cs, isPicking);
  }

  Widget _buildIdleCard(
    ReferenceTrackController controller,
    TextTheme textTheme,
    ColorScheme cs,
    bool isPicking,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
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
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.audiotrack_rounded,
                  size: 72,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.chooseAudioFile,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.audioFileFormats,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: isPicking
                      ? null
                      : () => controller.pickReferenceTrack(),
                  icon: isPicking
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Icon(Icons.upload_file_rounded, size: 20),
                  label: Text(isPicking ? l10n.selecting : l10n.selectSong),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrivacyNote(textTheme, cs),
      ],
    );
  }

  Widget _buildSelectedCard(
    ReferenceTrackState state,
    ReferenceTrackController controller,
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final track = state.track!;

    return Column(
      children: [
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
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.audiotrack_rounded,
                        size: 24,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: cs.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  track.extension.toUpperCase(),
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatFileSize(track.sizeBytes),
                                style: textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.tertiary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: cs.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.privacyNote,
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.tertiary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.clearSelection(),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: Text(l10n.remove),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => controller.pickReferenceTrack(),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: Text(l10n.replaceSong),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrivacyNote(textTheme, cs),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.trackSelected,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(
    ReferenceTrackState state,
    ReferenceTrackController controller,
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Card(
          color: cs.surfaceContainerHighest,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: cs.error.withValues(alpha: 0.5), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded, size: 72, color: cs.error),
                const SizedBox(height: 24),
                Text(
                  l10n.couldNotSelectFile,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.errorCode == null
                      ? l10n.unexpectedError
                      : _errorMessage(context, state.errorCode!),
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => controller.pickReferenceTrack(),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(l10n.retry),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrivacyNote(textTheme, cs),
      ],
    );
  }

  Widget _buildPrivacyNote(TextTheme textTheme, ColorScheme cs) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.privacyNote,
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Maps [ReferenceTrackErrorCode] to the correct l10n error string.
  String _errorMessage(BuildContext context, ReferenceTrackErrorCode code) {
    final l10n = AppLocalizations.of(context)!;
    return switch (code) {
      ReferenceTrackErrorCode.unsupportedFormat =>
        l10n.referenceTrackUnsupportedFormat,
      ReferenceTrackErrorCode.fileTooLarge => l10n.referenceTrackFileTooLarge,
      ReferenceTrackErrorCode.unreadableFile =>
        l10n.referenceTrackUnreadableFile,
      ReferenceTrackErrorCode.missingPath => l10n.referenceTrackMissingPath,
      ReferenceTrackErrorCode.selectionFailed => l10n.couldNotSelectFile,
    };
  }
}
