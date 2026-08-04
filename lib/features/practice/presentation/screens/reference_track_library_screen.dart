import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/fixed_back_button.dart';
import '../../../../core/widgets/tuno_music_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/reference_track.dart';
import '../../domain/reference_track_library_state.dart';
import '../../domain/reference_track_state.dart';
import '../reference_track_controller.dart';
import '../reference_track_library_controller.dart';

class ReferenceTrackLibraryScreen extends ConsumerStatefulWidget {
  const ReferenceTrackLibraryScreen({super.key});

  @override
  ConsumerState<ReferenceTrackLibraryScreen> createState() =>
      _ReferenceTrackLibraryScreenState();
}

class _ReferenceTrackLibraryScreenState
    extends ConsumerState<ReferenceTrackLibraryScreen> {
  bool _isBackInProgress = false;

  Future<void> _handleBackPressed() async {
    if (_isBackInProgress) return;
    _isBackInProgress = true;

    try {
      if (!context.mounted) return;
      context.pop();
    } finally {
      _isBackInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(referenceTrackLibraryProvider);
    final libraryController = ref.read(referenceTrackLibraryProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for successful track selection and add to library
    ref.listen<ReferenceTrackState>(referenceTrackProvider, (previous, next) {
      if (next is ReferenceTrackSelected) {
        // Only add if this is a genuine new selection (not a re-selection of the same track)
        final prevSelected = previous is ReferenceTrackSelected
            ? previous.track
            : null;
        if (prevSelected != next.track) {
          libraryController.addTrack(next.track);
        }
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: TunoMusicBackground(
        variant: TunoMusicBackgroundVariant.dashboard,
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        // Header with back button
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.referenceTrackLibraryTitle,
                                    style: textTheme.headlineLarge?.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.referenceTrackLibrarySubtitle,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Add Track button
                        FilledButton.icon(
                          onPressed: () => ref
                              .read(referenceTrackProvider.notifier)
                              .pickReferenceTrack(),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: Text(l10n.referenceTrackLibraryAddTrack),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Content based on state
                        _buildContent(
                          state,
                          libraryController,
                          textTheme,
                          cs,
                          l10n,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Fixed back button for web/desktop
              Positioned(
                top: 8,
                left: 8,
                child: FixedBackButton(
                  onPressed: _handleBackPressed,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    ReferenceTrackLibraryState state,
    ReferenceTrackLibraryController libraryController,
    TextTheme textTheme,
    ColorScheme cs,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return state.when(
      initial: () => _buildEmptyState(textTheme, cs, l10n, isDark),
      loading: () => _buildLoadingState(textTheme, cs, l10n),
      loaded: (tracks, selectedTrack) {
        if (tracks.isEmpty) {
          return _buildEmptyState(textTheme, cs, l10n, isDark);
        }
        return _buildTrackList(
          tracks,
          selectedTrack,
          libraryController,
          textTheme,
          cs,
          l10n,
          isDark,
        );
      },
      saving: (tracks, selectedTrack) {
        if (tracks.isEmpty) {
          return _buildEmptyState(textTheme, cs, l10n, isDark, isSaving: true);
        }
        return _buildTrackList(
          tracks,
          selectedTrack,
          libraryController,
          textTheme,
          cs,
          l10n,
          isDark,
          isSaving: true,
        );
      },
      error: (message, tracks, selectedTrack) => _buildErrorState(
        message,
        tracks,
        selectedTrack,
        libraryController,
        textTheme,
        cs,
        l10n,
        isDark,
      ),
    );
  }

  Widget _buildLoadingState(
    TextTheme textTheme,
    ColorScheme cs,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 16),
            Text(
              l10n.loadingLibrary,
              style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    TextTheme textTheme,
    ColorScheme cs,
    AppLocalizations l10n,
    bool isDark, {
    bool isSaving = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.music_off_rounded,
                size: 60,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.referenceTrackLibraryEmptyTitle,
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.referenceTrackLibraryEmptySubtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isSaving)
              CircularProgressIndicator(color: cs.primary)
            else
              FilledButton.icon(
                onPressed: () => ref
                    .read(referenceTrackProvider.notifier)
                    .pickReferenceTrack(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(l10n.referenceTrackLibraryAddTrack),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList(
    List<ReferenceTrack> tracks,
    ReferenceTrack? selectedTrack,
    ReferenceTrackLibraryController libraryController,
    TextTheme textTheme,
    ColorScheme cs,
    AppLocalizations l10n,
    bool isDark, {
    bool isSaving = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSaving)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.referenceTrackLibrarySaving,
                  style: textTheme.bodyMedium?.copyWith(color: cs.primary),
                ),
              ],
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tracks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final track = tracks[index];
            final isSelected = selectedTrack == track;
            return _TrackCard(
              track: track,
              isSelected: isSelected,
              onTap: () => libraryController.selectTrack(track),
              onUseTrack: () {
                libraryController.selectTrack(track);
                ref.read(referenceTrackProvider.notifier).selectTrack(track);
                context.go('/practice');
              },
              onRemove: () => libraryController.removeTrack(track),
              textTheme: textTheme,
              cs: cs,
              l10n: l10n,
              isDark: isDark,
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(
    String message,
    List<ReferenceTrack> tracks,
    ReferenceTrack? selectedTrack,
    ReferenceTrackLibraryController libraryController,
    TextTheme textTheme,
    ColorScheme cs,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: cs.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onErrorContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ref
                    .read(referenceTrackProvider.notifier)
                    .pickReferenceTrack(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (tracks.isNotEmpty)
          _buildTrackList(
            tracks,
            selectedTrack,
            libraryController,
            textTheme,
            cs,
            l10n,
            isDark,
          )
        else
          _buildEmptyState(textTheme, cs, l10n, isDark),
      ],
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
    required this.isSelected,
    required this.onTap,
    required this.onUseTrack,
    required this.onRemove,
    required this.textTheme,
    required this.cs,
    required this.l10n,
    required this.isDark,
  });

  final ReferenceTrack track;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onUseTrack;
  final VoidCallback onRemove;
  final TextTheme textTheme;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: l10n.referenceTrackLibraryTrackSelected(track.name),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
            color: isSelected
                ? cs.primaryContainer.withValues(alpha: 0.3)
                : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Music icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.audiotrack_rounded,
                        size: 28,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Track info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _InfoChip(
                                text: track.extension.toUpperCase(),
                                icon: Icons.description_rounded,
                                cs: cs,
                                textTheme: textTheme,
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                text: _formatFileSize(track.sizeBytes),
                                icon: Icons.data_usage_rounded,
                                cs: cs,
                                textTheme: textTheme,
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                text: DateFormat(
                                  'MMM d, y',
                                ).format(track.selectionTimestamp),
                                icon: Icons.calendar_today_rounded,
                                cs: cs,
                                textTheme: textTheme,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        IconButton(
                          onPressed: onRemove,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: cs.error,
                          ),
                          tooltip: l10n.referenceTrackLibraryRemove,
                          style: IconButton.styleFrom(
                            backgroundColor: cs.errorContainer,
                            foregroundColor: cs.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.text,
    required this.icon,
    required this.cs,
    required this.textTheme,
  });

  final String text;
  final IconData icon;
  final ColorScheme cs;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
