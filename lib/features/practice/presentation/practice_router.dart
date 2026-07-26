import 'package:go_router/go_router.dart';

import 'screens/practice_mode_screen.dart';
import 'screens/voice_practice_screen.dart';
import 'screens/recording_review_screen.dart';
import 'screens/analysis_result_screen.dart';
import 'screens/reference_track_screen.dart';

class PracticeRoutes {
  static const String practiceModes = '/practice/modes';
  static const String practice = '/practice';
  static const String recordingReview = '/practice/review';
  static const String analysisResult = '/practice/analysis';
  static const String referenceTrack = '/practice/upload';

  List<RouteBase> get routes => [
    GoRoute(
      path: practiceModes,
      name: 'practiceModes',
      builder: (context, state) => const PracticeModeScreen(),
    ),
    GoRoute(
      path: practice,
      name: 'practice',
      builder: (context, state) => const VoicePracticeScreen(),
    ),
    GoRoute(
      path: referenceTrack,
      name: 'referenceTrack',
      builder: (context, state) => const ReferenceTrackScreen(),
    ),
    GoRoute(
      path: recordingReview,
      name: 'recordingReview',
      builder: (context, state) {
        final audioPath = state.extra as String? ?? '';
        return RecordingReviewScreen(audioPath: audioPath);
      },
    ),
    GoRoute(
      path: analysisResult,
      name: 'analysisResult',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final audioPath = extra['audioPath'] as String? ?? '';
        final duration = extra['duration'] as Duration? ?? Duration.zero;
        final recordedAt = extra['recordedAt'] as DateTime? ?? DateTime.now();
        return AnalysisResultScreen(
          audioPath: audioPath,
          duration: duration,
          recordedAt: recordedAt,
        );
      },
    ),
  ];
}
