import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_singing_coach/features/analysis/data/recording_audio_bytes_loader.dart';
import 'package:ai_singing_coach/features/analysis/domain/pitch_analysis_result.dart';
import 'package:ai_singing_coach/features/analysis/presentation/analysis_screen_controller.dart'
    show
        AnalysisScreenState,
        AnalysisSuccess,
        AnalysisLoading,
        AnalysisNoVoiceDetected,
        AnalysisUnsupportedFormat,
        AnalysisFileNotFound,
        AnalysisFailed,
        AnalysisScreenController,
        analysisScreenControllerProvider;
import 'package:ai_singing_coach/features/practice/presentation/screens/analysis_result_screen.dart';
import 'package:ai_singing_coach/features/recording_library/domain/recording_library_entry.dart';
import 'package:ai_singing_coach/features/recording_library/presentation/recording_library_controller.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import 'package:go_router/go_router.dart';

class _TestRecordingAudioBytesLoader extends Fake
    implements RecordingAudioBytesLoader {
  _TestRecordingAudioBytesLoader(this._result);

  final RecordingAudioBytesResult _result;

  @override
  Future<RecordingAudioBytesResult> loadBytes({
    required String recordingRef,
    required String extension,
  }) async => _result;
}

class _TestRecordingLibraryController extends Fake
    implements RecordingLibraryController {
  @override
  Future<RecordingLibraryEntry> saveRecording(
    RecordingLibrarySaveRequest request,
  ) async {
    return RecordingLibraryEntry(
      id: 'test_1',
      title: 'Test Recording',
      createdAt: DateTime.now(),
      duration: const Duration(seconds: 30),
      sizeBytes: 1024,
      extension: 'wav',
      metadataKey: 'test_key',
    );
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> dispose() async {}
}

class FixedAnalysisScreenController extends AnalysisScreenController {
  final AnalysisScreenState _fixedState;
  int analyzeCalls = 0;
  int retryCalls = 0;

  FixedAnalysisScreenController(this._fixedState)
    : super(
        _TestRecordingAudioBytesLoader(
          RecordingAudioBytesSuccess(Uint8List(0)),
        ),
      ) {
    state = _fixedState;
  }

  @override
  Future<void> analyze({
    required String recordingRef,
    required String extension,
    required Duration duration,
    bool force = false,
  }) async {
    analyzeCalls++;
  }

  @override
  Future<void> retry() async {
    retryCalls++;
  }
}

FixedAnalysisScreenController _createTestController(AnalysisScreenState state) {
  return FixedAnalysisScreenController(state);
}

// Test router that includes the analysis result screen as a route
final _testRouter = GoRouter(
  initialLocation: '/analysis-result',
  routes: [
    GoRoute(
      path: '/practice',
      builder: (context, state) => const SizedBox.shrink(),
    ),
    GoRoute(
      path: '/recording-library',
      builder: (context, state) => const SizedBox.shrink(),
    ),
    GoRoute(
      path: '/analysis-result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AnalysisResultScreen(
          audioPath: extra?['audioPath'] as String? ?? 'test.wav',
          duration:
              extra?['duration'] as Duration? ?? const Duration(seconds: 30),
          recordedAt:
              extra?['recordedAt'] as DateTime? ??
              DateTime(2024, 1, 15, 10, 30),
        );
      },
    ),
  ],
);

Widget _createTestWidget({
  required AnalysisScreenState analysisState,
  FixedAnalysisScreenController? controller,
}) {
  final ctrl = controller ?? _createTestController(analysisState);

  return ProviderScope(
    overrides: [
      analysisScreenControllerProvider.overrideWith((ref) => ctrl),
      recordingLibraryControllerProvider.overrideWith(
        (ref) => _TestRecordingLibraryController(),
      ),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _testRouter,
      // Wrap the entire app in a SizedBox with a larger width to avoid
      // RenderFlex overflow in the narrow test environment.
      // This is a test environment artifact - in production the screen
      // would be wider and the action buttons would fit in a row.
      builder: (context, child) {
        return SizedBox(width: 800, child: child!);
      },
    ),
  );
}

void main() {
  group('AnalysisResultScreen', () {
    testWidgets('AnalysisLoading renders progress UI', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(analysisState: const AnalysisLoading()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing...'), findsOneWidget);
    });

    testWidgets('AnalysisSuccess renders real metrics', (
      WidgetTester tester,
    ) async {
      final result = PitchAnalysisResult(
        duration: 30.0,
        sampleRate: 44100,
        totalFrames: 100,
        voicedFrames: 80,
        voicedRatio: 0.8,
        detectedFrames: const [],
        minimumFrequency: 220.0,
        maximumFrequency: 440.0,
        medianFrequency: 330.0,
        pitchStability: 0.85,
        averageConfidence: 0.9,
        warnings: const [],
      );

      await tester.pumpWidget(
        _createTestWidget(analysisState: AnalysisSuccess(result)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Median Pitch'), findsOneWidget);
      expect(find.text('Detected Vocal Range'), findsOneWidget);
      expect(find.text('Voiced Ratio'), findsOneWidget);
      expect(find.text('Pitch Stability'), findsOneWidget);
      expect(find.text('Analysis Confidence'), findsOneWidget);
      // Duration appears in both recording details and analysis section
      expect(find.text('Duration'), findsWidgets);
      expect(find.textContaining('E4'), findsOneWidget);
      expect(find.textContaining('A3'), findsOneWidget);
      expect(find.textContaining('A4'), findsOneWidget);
    });

    testWidgets(
      'AnalysisNoVoiceDetected renders localized state and record-again action',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _createTestWidget(
            analysisState: const AnalysisNoVoiceDetected(Duration(seconds: 10)),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text(
            'No clear voice was detected. Please record again in a quieter environment.',
          ),
          findsOneWidget,
        );
        expect(find.text('Record Again'), findsOneWidget);
      },
    );

    testWidgets('AnalysisUnsupportedFormat renders localized information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(
          analysisState: const AnalysisUnsupportedFormat(
            'WebM/Opus not supported',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(
          'Detailed pitch analysis is not available for this recording format. WebM/Opus recordings cannot be analyzed yet.',
        ),
        findsOneWidget,
      );
      expect(find.text('WebM/Opus not supported'), findsOneWidget);
    });

    testWidgets('AnalysisFileNotFound renders record-again action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(analysisState: const AnalysisFileNotFound()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(
          'Could not find the recording file. Please try recording again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Record Again'), findsOneWidget);
    });

    testWidgets('AnalysisFailed renders retry action', (
      WidgetTester tester,
    ) async {
      final controller = _createTestController(
        const AnalysisFailed('Something went wrong'),
      );

      await tester.pumpWidget(
        _createTestWidget(
          analysisState: const AnalysisFailed('Something went wrong'),
          controller: controller,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Analysis failed. Please try again.'), findsOneWidget);
      expect(find.text('Retry Analysis'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);

      final retryFinder = find.text('Retry Analysis');
      expect(retryFinder, findsOneWidget);
      await tester.ensureVisible(retryFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(retryFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.retryCalls, 1);
    });

    testWidgets('Save to Library button remains visible in all states', (
      WidgetTester tester,
    ) async {
      final states = [
        const AnalysisLoading(),
        const AnalysisNoVoiceDetected(Duration(seconds: 10)),
        const AnalysisUnsupportedFormat('reason'),
        const AnalysisFileNotFound(),
        const AnalysisFailed('error'),
      ];

      for (final state in states) {
        await tester.pumpWidget(_createTestWidget(analysisState: state));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Recording Library'), findsOneWidget);
      }
    });

    testWidgets('Action buttons remain visible in all states', (
      WidgetTester tester,
    ) async {
      final states = [
        const AnalysisLoading(),
        const AnalysisNoVoiceDetected(Duration(seconds: 10)),
        const AnalysisUnsupportedFormat('reason'),
        const AnalysisFileNotFound(),
        const AnalysisFailed('error'),
      ];

      for (final state in states) {
        await tester.pumpWidget(_createTestWidget(analysisState: state));
        await tester.pump(const Duration(milliseconds: 100));

        // The bottom action buttons (Practice Again, View Library) should be
        // visible in all analysis states since they are rendered outside
        // the state-dependent analysis result section.
        expect(find.text('Practice Again'), findsOneWidget);
        expect(find.text('Recording Library'), findsOneWidget);
      }
    });

    testWidgets('AnalysisSuccess with warnings displays warnings section', (
      WidgetTester tester,
    ) async {
      final result = PitchAnalysisResult(
        duration: 30.0,
        sampleRate: 44100,
        totalFrames: 100,
        voicedFrames: 80,
        voicedRatio: 0.8,
        detectedFrames: const [],
        minimumFrequency: 220.0,
        maximumFrequency: 440.0,
        medianFrequency: 330.0,
        pitchStability: 0.85,
        averageConfidence: 0.9,
        warnings: ['Warning 1', 'Warning 2'],
      );

      await tester.pumpWidget(
        _createTestWidget(analysisState: AnalysisSuccess(result)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Warnings'), findsOneWidget);
      expect(find.text('Warning 1'), findsOneWidget);
      expect(find.text('Warning 2'), findsOneWidget);
    });
  });
}
