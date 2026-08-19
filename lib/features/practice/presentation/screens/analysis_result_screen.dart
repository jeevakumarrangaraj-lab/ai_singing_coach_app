import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/tuno_dashboard_background.dart'
    show TunoDashboardBackground;
import '../../../analysis/domain/note_converter.dart';
import '../../../analysis/domain/pitch_analysis_result.dart';
import '../../../analysis/presentation/analysis_screen_controller.dart'
    show
        AnalysisSuccess,
        AnalysisLoading,
        AnalysisIdle,
        AnalysisNoVoiceDetected,
        AnalysisUnsupportedFormat,
        AnalysisFileNotFound,
        AnalysisFailed,
        analysisScreenControllerProvider;
import '../../../recording_library/data/recording_library_repository.dart';
import '../../../recording_library/data/storage/recording_audio.dart';
import '../../../recording_library/domain/recording_library_entry.dart';
import '../../../recording_library/domain/recording_library_error_code.dart';
import '../../../recording_library/presentation/recording_library_controller.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  final String audioPath;
  final Duration duration;
  final DateTime recordedAt;

  const AnalysisResultScreen({
    super.key,
    required this.audioPath,
    required this.duration,
    required this.recordedAt,
  });

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  bool _isSaving = false;
  bool _hasSaved = false;
  bool _isSessionOnly = false;
  RecordingLibraryErrorCode? _saveErrorCode;
  bool _hasUnexpectedError = false;
  bool _analysisStarted = false;

  @override
  void initState() {
    super.initState();
    _saveToLibrary();
    // Start analysis after the first frame to ensure provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_analysisStarted) {
        _startAnalysis();
      }
    });
  }

  void _startAnalysis() {
    if (_analysisStarted) return;
    _analysisStarted = true;

    // Determine file extension from the path
    final extension = widget.audioPath.split('.').last.toLowerCase();

    ref
        .read(analysisScreenControllerProvider.notifier)
        .analyze(
          recordingRef: widget.audioPath,
          extension: extension,
          duration: widget.duration,
        );
  }

  Future<void> _saveToLibrary() async {
    if (_isSaving || _hasSaved) return;
    setState(() {
      _isSaving = true;
      _saveErrorCode = null;
      _hasUnexpectedError = false;
    });

    try {
      Uint8List? audioBytes;
      String? temporaryPath;

      if (kIsWeb) {
        // On web, the audioPath is a blob URL. Fetch the bytes.
        audioBytes = await fetchBlobUrlBytes(widget.audioPath);
        if (audioBytes == null || audioBytes.isEmpty) {
          // Fall back to just recording the URL for session use.
          // Web persistence is limited: the recording will be usable
          // during the current session but NOT after browser restart.
          if (mounted) {
            setState(() {
              _isSaving = false;
              _hasSaved = true;
              _isSessionOnly = true;
            });
          }
          return;
        }
      } else {
        // On native, the audioPath is a file path.
        temporaryPath = widget.audioPath;
      }

      // Determine file extension from the path.
      final extension = widget.audioPath.split('.').last.toLowerCase();
      final validExt =
          ['wav', 'opus', 'mp3', 'ogg', 'm4a', 'webm'].contains(extension)
          ? extension
          : 'wav';

      // Build a user-friendly title from the date/time.
      final now = DateTime.now();
      final title =
          'Recording ${now.day.toString().padLeft(2, '0')}'
          '/${now.month.toString().padLeft(2, '0')}'
          '/${now.year} ${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      final request = RecordingLibrarySaveRequest(
        temporaryPath: temporaryPath,
        audioBytes: audioBytes,
        title: title,
        duration: widget.duration,
        sizeBytes: temporaryPath != null
            ? 0 // Will be resolved by storage
            : (audioBytes?.lengthInBytes ?? 0),
        extension: validExt,
      );

      await ref
          .read(recordingLibraryControllerProvider.notifier)
          .saveRecording(request);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasSaved = true;
          _isSessionOnly = false;
        });
      }
    } on RecordingLibraryException catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveErrorCode = e.code;
          _hasUnexpectedError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveErrorCode = null;
          _hasUnexpectedError = true;
        });
      }
    }
  }

  String? _getErrorMessage(AppLocalizations l10n) {
    if (_hasUnexpectedError) {
      return l10n.unexpectedError;
    }
    if (_saveErrorCode != null) {
      switch (_saveErrorCode!) {
        case RecordingLibraryErrorCode.quotaExceeded:
          return l10n.recordingSaveQuotaExceeded;
        case RecordingLibraryErrorCode.storageUnavailable:
          return l10n.recordingSaveStorageUnavailable;
        case RecordingLibraryErrorCode.notFound:
          return l10n.recordingSaveNotFound;
        case RecordingLibraryErrorCode.cancelled:
          return l10n.recordingSaveCancelled;
        case RecordingLibraryErrorCode.platformError:
          return l10n.recordingSavePlatformError;
        case RecordingLibraryErrorCode.invalidData:
          return l10n.recordingSaveInvalidData;
        case RecordingLibraryErrorCode.disposed:
          return l10n.recordingSaveDisposed;
        case RecordingLibraryErrorCode.permissionDenied:
          return l10n.recordingSavePermissionDenied;
      }
    }
    return null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getFileName() {
    return widget.audioPath.split('/').last;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool get _hasValidData {
    final fileName = _getFileName();
    return widget.audioPath.isNotEmpty &&
        fileName.isNotEmpty &&
        widget.duration > Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final fileName = _getFileName();
    final formattedDuration = _formatDuration(widget.duration);

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
                      child: _isSaving
                          ? Padding(
                              padding: const EdgeInsets.all(30),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: cs.primary,
                              ),
                            )
                          : Icon(
                              _hasSaved
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_actions_rounded,
                              size: 60,
                              color: _hasSaved ? Colors.green : cs.primary,
                            ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      _hasSaved ? l10n.recordingSaved : l10n.analysisPending,
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
                        _hasSaved
                            ? (_isSessionOnly
                                  ? l10n.recordingSessionOnly
                                  : l10n.recordingSavedToLibrary)
                            : (_isSaving
                                  ? l10n.saving
                                  : l10n.aiAnalysisComingSoon),
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Error message
                    if (_getErrorMessage(l10n) != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getErrorMessage(l10n)!,
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onErrorContainer,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Web persistence warning
                    if (kIsWeb && _hasSaved && !_isSessionOnly) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.webPersistenceWarning,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

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
                                value: _formatDateTime(widget.recordedAt),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pitch Analysis Result
                    _buildAnalysisResultSection(context, ref, l10n),

                    const SizedBox(height: 32),

                    // Action buttons
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const minWidthForRow = 400.0;
                        final useRowLayout =
                            constraints.maxWidth >= minWidthForRow;

                        final practiceAgainButton = Tooltip(
                          message: l10n.practiceAgain,
                          child: FilledButton(
                            onPressed: () => context.go('/practice'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mic_rounded, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    l10n.practiceAgain,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        final viewLibraryButton = Tooltip(
                          message: l10n.recordingLibrary,
                          child: OutlinedButton(
                            onPressed: () => context.push('/recording-library'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              side: BorderSide(color: cs.outline, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.library_music_rounded, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    l10n.recordingLibrary,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                              Expanded(child: viewLibraryButton),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            practiceAgainButton,
                            const SizedBox(height: 12),
                            viewLibraryButton,
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

  Widget _buildAnalysisResultSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final state = ref.watch(analysisScreenControllerProvider);

    return switch (state) {
      AnalysisIdle() => const SizedBox.shrink(),
      AnalysisLoading() => _buildLoadingState(context, l10n),
      AnalysisSuccess(:final result) => _buildSuccessState(
        context,
        l10n,
        result,
      ),
      AnalysisNoVoiceDetected(:final duration) => _buildNoVoiceDetectedState(
        context,
        l10n,
        duration,
      ),
      AnalysisUnsupportedFormat(:final reason) => _buildUnsupportedFormatState(
        context,
        l10n,
        reason,
      ),
      AnalysisFileNotFound() => _buildFileNotFoundState(context, l10n),
      AnalysisFailed(:final message) => _buildFailedState(
        context,
        l10n,
        message,
      ),
    };
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              l10n.analysisPending,
              style: textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    AppLocalizations l10n,
    PitchAnalysisResult result,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final medianNote = result.medianFrequency != null
        ? NoteConverter.frequencyToNote(result.medianFrequency!)
        : null;
    final minNote = result.minimumFrequency != null
        ? NoteConverter.frequencyToNote(result.minimumFrequency!)
        : null;
    final maxNote = result.maximumFrequency != null
        ? NoteConverter.frequencyToNote(result.maximumFrequency!)
        : null;

    final durationSeconds = result.duration;
    final formattedDuration = _formatDurationSeconds(durationSeconds);

    return Card(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.analysisStatus,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            _buildMetricRow(
              context,
              icon: Icons.music_note_rounded,
              label: l10n.medianPitch,
              value: medianNote != null
                  ? '${medianNote.displayName} (${result.medianFrequency!.toStringAsFixed(1)} Hz)'
                  : l10n.analysisNone,
            ),
            const SizedBox(height: 16),

            _buildMetricRow(
              context,
              icon: Icons.arrow_upward_rounded,
              label: l10n.detectedVocalRange,
              value: minNote != null && maxNote != null
                  ? '${minNote.displayName} - ${maxNote.displayName} '
                        '(${result.minimumFrequency!.toStringAsFixed(1)} - ${result.maximumFrequency!.toStringAsFixed(1)} Hz)'
                  : l10n.analysisNone,
            ),
            const SizedBox(height: 16),

            _buildMetricRow(
              context,
              icon: Icons.waves_rounded,
              label: l10n.voicedRatio,
              value: '${(result.voicedRatio * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),

            _buildMetricRow(
              context,
              icon: Icons.straighten_rounded,
              label: l10n.pitchStability,
              value: '${(result.pitchStability * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),

            _buildMetricRow(
              context,
              icon: Icons.psychology_rounded,
              label: l10n.analysisConfidence,
              value: '${(result.averageConfidence * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),

            _buildMetricRow(
              context,
              icon: Icons.timer_rounded,
              label: l10n.duration,
              value: formattedDuration,
            ),

            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildWarningsSection(context, l10n, result.warnings),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoVoiceDetectedState(
    BuildContext context,
    AppLocalizations l10n,
    Duration duration,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_off_rounded, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.pitchAnalysisNoVoiceDetected,
              style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/practice'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.recordAgain,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedFormatState(
    BuildContext context,
    AppLocalizations l10n,
    String reason,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: cs.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.pitchAnalysisUnsupportedFormat,
                    style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant, width: 1),
              ),
              child: Text(
                reason,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileNotFoundState(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(
              l10n.pitchAnalysisFileNotFound,
              style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/practice'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.recordAgain,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(
              l10n.pitchAnalysisFailed,
              style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  ref.read(analysisScreenControllerProvider.notifier).retry(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.retryAnalysis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
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

  Widget _buildWarningsSection(
    BuildContext context,
    AppLocalizations l10n,
    List<String> warnings,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: cs.tertiary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warnings',
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              ...warnings.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    w,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDurationSeconds(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
