import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/tuno_dashboard_background.dart';
import '../../../../core/widgets/metallic_gold_border.dart';
import '../../../../core/widgets/tuno_card.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/recording_library_entry.dart';
import '../../domain/recording_library_error_code.dart';
import '../../domain/recording_library_state.dart';
import 'package:ai_singing_coach/features/recording_library/recording_library_providers.dart';

class RecordingLibraryScreen extends ConsumerStatefulWidget {
  const RecordingLibraryScreen({super.key});

  @override
  ConsumerState<RecordingLibraryScreen> createState() =>
      _RecordingLibraryScreenState();
}

class _RecordingLibraryScreenState
    extends ConsumerState<RecordingLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  RecordingLibraryFilter _currentFilter = RecordingLibraryFilter.all;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(recordingLibraryControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TunoDashboardBackground(
      animate: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(l10n, cs, textTheme),
                            const SizedBox(height: 32),
                            _buildSearchAndFilter(l10n, cs, textTheme, isDark),
                            const SizedBox(height: 24),
                            _buildContent(state, l10n, cs, textTheme, isDark),
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
      ),
    );
  }

  Widget _buildHeader(
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: l10n.back,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(14),
              hoverColor: cs.onSurface.withValues(alpha: 0.06),
              focusColor: cs.onSurface.withValues(alpha: 0.10),
              splashColor: cs.onSurface.withValues(alpha: 0.12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 24,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recordingLibrary,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.yourSavedPracticeRecordings,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'More options',
          icon: Icon(Icons.more_vert_rounded, size: 24, color: cs.onSurface),
          onSelected: (value) => _handleOverflowAction(value, l10n),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'clearLibrary',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep_rounded, size: 20, color: cs.error),
                  const SizedBox(width: 12),
                  Text(l10n.clearLibrary),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchRecordings,
            prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
            filled: true,
            fillColor: isDark
                ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                : cs.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: cs.onSurfaceVariant),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildFilterChip(
              l10n.filterAll,
              RecordingLibraryFilter.all,
              cs,
              textTheme,
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              l10n.filterFavorites,
              RecordingLibraryFilter.favorites,
              cs,
              textTheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    RecordingLibraryFilter filter,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    final isSelected = _currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _currentFilter = filter),
      labelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? Colors.white : cs.onSurfaceVariant,
      ),
      selectedColor: cs.primary,
      backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      side: BorderSide(
        color: isSelected ? cs.primary : cs.outlineVariant,
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  Widget _buildContent(
    RecordingLibraryState state,
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
  ) {
    return state.when(
      initial: () => _buildLoadingState(l10n, cs, textTheme),
      loading: () => _buildLoadingState(l10n, cs, textTheme),
      loaded: (recordings) =>
          _buildLoadedState(recordings, l10n, cs, textTheme, isDark),
      saving: (currentRecordings) => _buildLoadedState(
        currentRecordings,
        l10n,
        cs,
        textTheme,
        isDark,
        isSaving: true,
      ),
      error: (code, currentRecordings, failedOperation) => _buildErrorState(
        code,
        currentRecordings,
        l10n,
        cs,
        textTheme,
        isDark,
      ),
    );
  }

  Widget _buildLoadingState(
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme textTheme,
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
              l10n.saving,
              style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    List<RecordingLibraryEntry> recordings,
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark, {
    bool isSaving = false,
  }) {
    final filteredRecordings = _filterRecordings(recordings);

    if (filteredRecordings.isEmpty) {
      return _buildEmptyState(l10n, cs, textTheme, isDark);
    }

    return Column(
      children: [
        if (isSaving)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.saving,
                  style: textTheme.bodyMedium?.copyWith(color: cs.primary),
                ),
              ],
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredRecordings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _RecordingCard(
            entry: filteredRecordings[index],
            onTap: () => _playRecording(filteredRecordings[index]),
            onRename: () => _renameRecording(filteredRecordings[index]),
            onToggleFavorite: () => _toggleFavorite(filteredRecordings[index]),
            onDelete: () => _deleteRecording(filteredRecordings[index]),
            l10n: l10n,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  List<RecordingLibraryEntry> _filterRecordings(
    List<RecordingLibraryEntry> recordings,
  ) {
    var filtered = recordings;

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((r) => r.title.toLowerCase().contains(query))
          .toList();
    }

    if (_currentFilter == RecordingLibraryFilter.favorites) {
      filtered = filtered.where((r) => r.isFavorite).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.music_off_rounded,
                  size: 40,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noRecordingsYet,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.completePracticeToSaveFirst,
                style: textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _GradientCTAButton(
                onPressed: () => context.push('/practice/modes'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.startPractice,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    RecordingLibraryErrorCode code,
    List<RecordingLibraryEntry> currentRecordings,
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
  ) {
    if (currentRecordings.isNotEmpty) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: cs.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getErrorMessage(code, l10n),
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onErrorContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => ref
                      .read(recordingLibraryControllerProvider.notifier)
                      .refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLoadedState(currentRecordings, l10n, cs, textTheme, isDark),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: cs.onErrorContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.errorLoadingRecordings,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _getErrorMessage(code, l10n),
                style: textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _GradientCTAButton(
                onPressed: () => ref
                    .read(recordingLibraryControllerProvider.notifier)
                    .refresh(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.retry,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(
    RecordingLibraryErrorCode code,
    AppLocalizations l10n,
  ) {
    switch (code) {
      case RecordingLibraryErrorCode.quotaExceeded:
        return 'Storage quota exceeded. Please free up space and try again.';
      case RecordingLibraryErrorCode.storageUnavailable:
        return 'Storage is unavailable. Please try again later.';
      case RecordingLibraryErrorCode.notFound:
        return 'The requested recording was not found.';
      case RecordingLibraryErrorCode.cancelled:
        return 'The operation was cancelled.';
      case RecordingLibraryErrorCode.platformError:
        return 'An unexpected platform error occurred. Please try again.';
      case RecordingLibraryErrorCode.invalidData:
        return 'Invalid data provided. Please try again.';
      case RecordingLibraryErrorCode.disposed:
        return 'The operation could not be completed. Please try again.';
    }
  }

  void _handleOverflowAction(String action, AppLocalizations l10n) {
    switch (action) {
      case 'clearLibrary':
        _showClearLibraryDialog(l10n);
        break;
    }
  }

  void _showClearLibraryDialog(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearLibraryConfirmation),
        content: Text(l10n.clearLibraryConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(recordingLibraryControllerProvider.notifier)
                  .clearLibrary();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _playRecording(RecordingLibraryEntry entry) {
    ref
        .read(recordingLibraryControllerProvider.notifier)
        .loadRecordingBytes(entry.id)
        .then((bytes) {
          if (bytes != null && mounted) {
            // Navigate to review screen with audio bytes
            context.push(
              '/practice/review',
              extra: {'audioBytes': bytes, 'entry': entry},
            );
          }
        });
  }

  void _renameRecording(RecordingLibraryEntry entry) {
    final controller = TextEditingController(text: entry.title);
    final cs = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameRecording),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Recording name',
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != entry.title) {
                Navigator.of(context).pop();
                ref
                    .read(recordingLibraryControllerProvider.notifier)
                    .renameRecording(entry.id, newTitle);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(RecordingLibraryEntry entry) {
    ref
        .read(recordingLibraryControllerProvider.notifier)
        .toggleFavorite(entry.id);
  }

  void _deleteRecording(RecordingLibraryEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmation),
        content: Text(l10n.deleteConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(recordingLibraryControllerProvider.notifier)
                  .deleteRecording(entry.id);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

enum RecordingLibraryFilter { all, favorites }

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({
    required this.entry,
    required this.onTap,
    required this.onRename,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.l10n,
    required this.isDark,
  });

  final RecordingLibraryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MetallicGoldBorder(
      borderRadius: BorderRadius.circular(16),
      padding: 1.0,
      gradientOpacity: 0.6,
      child: TunoCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        goldAccent: entry.isFavorite,
        child: Row(
          children: [
            _buildPlayButton(cs),
            const SizedBox(width: 16),
            Expanded(child: _buildInfo(textTheme, cs)),
            _buildFavoriteIndicator(cs),
            _buildMoreMenu(context, cs, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(ColorScheme cs) {
    return Semantics(
      button: true,
      label: l10n.playRecording,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 24,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(TextTheme textTheme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${l10n.recordedOn} ${_formatDate(entry.createdAt)}',
              style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Icon(Icons.timer_rounded, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '${l10n.duration} ${_formatDuration(entry.duration)}',
              style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        if (entry.analysisStatus != AnalysisStatus.none) ...[
          const SizedBox(height: 4),
          _buildAnalysisStatus(textTheme, cs),
        ],
        if (entry.referenceTrackName != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 14,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.referenceTrack(entry.referenceTrackName!),
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisStatus(TextTheme textTheme, ColorScheme cs) {
    Color statusColor;
    String statusText;

    switch (entry.analysisStatus) {
      case AnalysisStatus.pending:
        statusColor = cs.primary;
        statusText = l10n.analysisPending;
        break;
      case AnalysisStatus.completed:
        statusColor = Colors.green;
        statusText = l10n.analysisCompleted;
        break;
      case AnalysisStatus.failed:
        statusColor = cs.error;
        statusText = l10n.analysisFailed;
        break;
      default:
        statusColor = cs.onSurfaceVariant;
        statusText = l10n.analysisNone;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$statusText${entry.analysisScore != null ? ' • ${l10n.analysisScore(entry.analysisScore!.toStringAsFixed(1))}' : ''}',
          style: textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteIndicator(ColorScheme cs) {
    return Semantics(
      button: true,
      label: entry.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onToggleFavorite,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.isFavorite
                  ? const Color(0xFFFFF2A6).withValues(alpha: 0.2)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: entry.isFavorite
                  ? Border.all(color: const Color(0xFFE3B94F), width: 1.5)
                  : null,
            ),
            child: Icon(
              entry.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              size: 20,
              color: entry.isFavorite
                  ? const Color(0xFFE3B94F)
                  : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenu(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurfaceVariant),
      onSelected: (value) {
        switch (value) {
          case 'play':
            onTap();
            break;
          case 'rename':
            onRename();
            break;
          case 'favorite':
            onToggleFavorite();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'play',
          child: Row(
            children: [
              Icon(Icons.play_arrow_rounded, size: 20, color: cs.onSurface),
              const SizedBox(width: 12),
              Text(l10n.playRecording),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 20, color: cs.onSurface),
              const SizedBox(width: 12),
              Text(l10n.renameRecording),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                entry.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 20,
                color: cs.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                entry.isFavorite
                    ? l10n.removeFromFavorites
                    : l10n.addToFavorites,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 20, color: cs.error),
              const SizedBox(width: 12),
              Text(l10n.deleteRecording, style: TextStyle(color: cs.error)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _GradientCTAButton extends StatefulWidget {
  const _GradientCTAButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_GradientCTAButton> createState() => _GradientCTAButtonState();
}

class _GradientCTAButtonState extends State<_GradientCTAButton> {
  bool _hovered = false;
  bool _focused = false;

  static const _ctaGradient = LinearGradient(
    colors: [Color(0xFF008BA6), Color(0xFF006D98), Color(0xFF014B75)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.52, 1.0],
  );

  static const _goldBorderGradient = LinearGradient(
    colors: [
      Color(0xFFFFF2A6),
      Color(0xFFE3B94F),
      Color(0xFFA86D16),
      Color(0xFFF4D675),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final shadowColor = _hovered || _focused
        ? const Color(0xFF12B5C1).withValues(alpha: 0.35)
        : const Color(0xFF0069A0).withValues(alpha: 0.25);

    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _ctaGradient,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: _hovered || _focused ? 16 : 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _goldBorderGradient,
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        gradient: _ctaGradient,
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withValues(alpha: 0.18),
                  highlightColor: Colors.white.withValues(alpha: 0.10),
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  child: Center(child: widget.child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
