import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/dashboard_music_decorations.dart';
import '../../domain/audio_video_preferences.dart';
import '../audio_video_controller.dart';

final microphonePermissionProvider = FutureProvider<PermissionStatus>((ref) {
  return Permission.microphone.status;
});

class AudioVideoSettingsScreen extends ConsumerStatefulWidget {
  const AudioVideoSettingsScreen({super.key});
  @override
  ConsumerState<AudioVideoSettingsScreen> createState() =>
      _AudioVideoSettingsScreenState();
}

class _AudioVideoSettingsScreenState
    extends ConsumerState<AudioVideoSettingsScreen> {
  // ── Theme helpers ───────────────────────────────────────────

  Color get _accent =>
      isDark ? const Color(0xFF12B5C1) : const Color(0xFF0B96A5);

  Color get _cardColor => isDark ? const Color(0xFF061E31) : cs.surface;

  Color get _borderColor => isDark
      ? cs.outline.withValues(alpha: 0.5)
      : cs.outlineVariant.withValues(alpha: 0.7);

  Color get _dividerColor => isDark
      ? cs.outline.withValues(alpha: 0.2)
      : cs.outlineVariant.withValues(alpha: 0.4);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  ColorScheme get cs => Theme.of(context).colorScheme;

  // ───────────────────────────────────────────────────────────
  //  BUILD
  // ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final prefs = ref.watch(audioVideoControllerProvider);
    final micPermissionAsync = ref.watch(microphonePermissionProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Background decorations ──
          Positioned.fill(
            child: const IgnorePointer(
              ignoring: true,
              child: DashboardMusicDecorations(animate: true),
            ),
          ),

          // ── Scrollable content ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // ── Back button ──
                              Semantics(
                                label: 'Back to Settings',
                                button: true,
                                child: Tooltip(
                                  message: 'Back',
                                  child: AppBackButton(
                                    onPressed: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/settings');
                                      }
                                    },
                                    showOnlyIfCanPop: false,
                                    iconColor: _accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Title ──
                              Center(
                                child: Text(
                                  'Audio & Video',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Section 1: Recording Type ──
                              _buildSectionCard(
                                title: 'Default Recording Type',
                                child: _buildRecordingTypeSegments(prefs),
                              ),
                              const SizedBox(height: 16),

                              // ── Section 2: Audio Quality ──
                              _buildSectionCard(
                                title: 'Audio Quality',
                                child: _buildAudioQualitySegments(prefs),
                              ),
                              const SizedBox(height: 16),

                              // ── Section 3: Recording Behaviour ──
                              _buildSectionCard(
                                title: 'Recording Behaviour',
                                child: Column(
                                  children: [
                                    _ToggleRow(
                                      label: 'Noise Reduction',
                                      value: prefs.noiseReduction,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              audioVideoControllerProvider
                                                  .notifier,
                                            )
                                            .setNoiseReduction(v);
                                        _showSnackBar(
                                          v
                                              ? 'Noise reduction enabled'
                                              : 'Noise reduction disabled',
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                    _sectionDivider(),
                                    _ToggleRow(
                                      label: 'Countdown before recording',
                                      value: prefs.countdownBeforeRecording,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              audioVideoControllerProvider
                                                  .notifier,
                                            )
                                            .setCountdownBeforeRecording(v);
                                        _showSnackBar(
                                          v
                                              ? 'Countdown enabled'
                                              : 'Countdown disabled',
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                    _sectionDivider(),
                                    _ToggleRow(
                                      label:
                                          'Auto-play recording after capture',
                                      value: prefs.autoPlayRecording,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              audioVideoControllerProvider
                                                  .notifier,
                                            )
                                            .setAutoPlayRecording(v);
                                        _showSnackBar(
                                          v
                                              ? 'Auto-play enabled'
                                              : 'Auto-play disabled',
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                    _sectionDivider(),
                                    _ToggleRow(
                                      label: 'Show headphones reminder',
                                      value: prefs.headphonesReminder,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              audioVideoControllerProvider
                                                  .notifier,
                                            )
                                            .setHeadphonesReminder(v);
                                        _showSnackBar(
                                          v
                                              ? 'Headphones reminder enabled'
                                              : 'Headphones reminder disabled',
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Section 4: Microphone Permission ──
                              _buildSectionCard(
                                title: 'Microphone Access',
                                child: _buildMicrophonePermissionTile(
                                  micPermissionAsync,
                                  textTheme,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  SECTION CARD
  // ───────────────────────────────────────────────────────────

  Widget _buildSectionCard({required String title, required Widget child}) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  RECORDING TYPE SEGMENTS
  // ───────────────────────────────────────────────────────────

  Widget _buildRecordingTypeSegments(AudioVideoPreferences prefs) {
    return Row(
      children: [
        Expanded(
          child: _SegmentedOption(
            label: RecordingType.label(RecordingType.audio),
            selected: prefs.defaultRecordingType == RecordingType.audio,
            onTap: () {
              ref
                  .read(audioVideoControllerProvider.notifier)
                  .setDefaultRecordingType(RecordingType.audio);
              _showSnackBar('Default recording type: Audio');
            },
            accent: _accent,
            isLeft: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentedOption(
            label: RecordingType.label(RecordingType.video),
            selected: prefs.defaultRecordingType == RecordingType.video,
            onTap: () {
              ref
                  .read(audioVideoControllerProvider.notifier)
                  .setDefaultRecordingType(RecordingType.video);
              _showSnackBar('Default recording type: Video');
            },
            accent: _accent,
            isLeft: false,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────
  //  AUDIO QUALITY SEGMENTS
  // ───────────────────────────────────────────────────────────

  Widget _buildAudioQualitySegments(AudioVideoPreferences prefs) {
    return Row(
      children: [
        Expanded(
          child: _SegmentedOption(
            label: AudioQuality.label(AudioQuality.standard),
            selected: prefs.audioQuality == AudioQuality.standard,
            onTap: () {
              ref
                  .read(audioVideoControllerProvider.notifier)
                  .setAudioQuality(AudioQuality.standard);
              _showSnackBar('Audio quality: Standard');
            },
            accent: _accent,
            isLeft: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentedOption(
            label: AudioQuality.label(AudioQuality.high),
            selected: prefs.audioQuality == AudioQuality.high,
            onTap: () {
              ref
                  .read(audioVideoControllerProvider.notifier)
                  .setAudioQuality(AudioQuality.high);
              _showSnackBar('Audio quality: High');
            },
            accent: _accent,
            isLeft: false,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────
  //  MICROPHONE PERMISSION TILE
  // ───────────────────────────────────────────────────────────

  Widget _buildMicrophonePermissionTile(
    AsyncValue<PermissionStatus> micPermissionAsync,
    TextTheme textTheme,
  ) {
    return micPermissionAsync.when(
      data: (status) {
        final isGranted =
            status == PermissionStatus.granted ||
            status == PermissionStatus.limited;
        return Semantics(
          label:
              'Microphone permission: ${isGranted ? "Granted" : "Not granted"}',
          child: InkWell(
            onTap: () => _requestMicrophonePermission(),
            borderRadius: BorderRadius.circular(14),
            hoverColor: cs.primary.withValues(alpha: 0.06),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isGranted ? Icons.mic_rounded : Icons.mic_off_rounded,
                    size: 24,
                    color: isGranted ? Colors.greenAccent : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGranted ? 'Microphone Access' : 'Microphone Access',
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isGranted ? 'Granted' : 'Not granted — tap to allow',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: isGranted ? Colors.greenAccent : _accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isGranted)
                    Icon(Icons.chevron_right_rounded, size: 22, color: _accent),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Could not check microphone permission',
          style: textTheme.bodySmall?.copyWith(color: cs.error),
        ),
      ),
    );
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      if (!mounted) return;

      if (status == PermissionStatus.granted) {
        _showSnackBar('Microphone access granted');
      } else if (status == PermissionStatus.permanentlyDenied) {
        _showOpenSettingsDialog();
      } else {
        _showSnackBar('Microphone access denied');
      }

      // Refresh the provider
      ref.invalidate(microphonePermissionProvider);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Could not request microphone permission');
      }
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Microphone Permission'),
        content: const Text(
          'Microphone permission has been permanently denied. '
          'Please enable it in your system settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(ctx).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  HELPERS
  // ───────────────────────────────────────────────────────────

  Widget _sectionDivider() {
    return Divider(height: 1, thickness: 1, color: _dividerColor);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────
//  TOGGLE ROW
// ─────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      toggled: value,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          hoverColor: cs.primary.withValues(alpha: 0.04),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  toggled: value,
                  child: SizedBox(
                    height: 32,
                    child: Switch.adaptive(
                      value: value,
                      onChanged: onChanged,
                      activeTrackColor: accent.withValues(alpha: 0.4),
                      activeThumbColor: accent,
                      inactiveThumbColor: cs.onSurfaceVariant,
                      inactiveTrackColor: cs.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SEGMENTED OPTION
// ─────────────────────────────────────────────────────────────

class _SegmentedOption extends StatelessWidget {
  const _SegmentedOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
    required this.isLeft,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: cs.primary.withValues(alpha: 0.04),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? accent : cs.outline.withValues(alpha: 0.5),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? accent : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
