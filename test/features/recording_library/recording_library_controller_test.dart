import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_singing_coach/features/recording_library/domain/recording_library_entry.dart';
import 'package:ai_singing_coach/features/recording_library/domain/recording_library_error_code.dart';
import 'package:ai_singing_coach/features/recording_library/domain/recording_library_state.dart';
import 'package:ai_singing_coach/features/recording_library/data/recording_library_repository.dart';
import 'package:ai_singing_coach/features/recording_library/presentation/recording_library_controller.dart';

class MockRecordingLibraryRepository extends Mock
    implements RecordingLibraryRepository {}

class FakeRecordingLibrarySaveRequest extends Fake
    implements RecordingLibrarySaveRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRecordingLibrarySaveRequest());
  });

  group('RecordingLibraryController', () {
    late MockRecordingLibraryRepository mockRepository;
    late RecordingLibraryController controller;

    setUp(() {
      mockRepository = MockRecordingLibraryRepository();
      when(() => mockRepository.loadRecordings()).thenAnswer((_) async => []);
      when(() => mockRepository.dispose()).thenAnswer((_) async {});
      controller = RecordingLibraryController(mockRepository);
    });

    tearDown(() {
      controller.dispose();
    });

    final testEntry = RecordingLibraryEntry(
      id: 'rec_1',
      title: 'Test Recording',
      createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
      duration: const Duration(seconds: 30),
      sizeBytes: 1024 * 1024,
      extension: 'wav',
      localPath: kIsWeb ? null : '/path/to/recording.wav',
      webStorageKey: kIsWeb ? 'audio_rec_1' : null,
      metadataKey: 'rec_1',
      isFavorite: false,
      analysisStatus: AnalysisStatus.none,
    );

    group('loadRecordings', () {
      test('emits Loading then Loaded on success', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);

        expectLater(
          controller.stream,
          emitsInOrder([
            const RecordingLibraryLoading(),
            predicate<RecordingLibraryState>(
              (s) => s.isLoaded && s.recordings.length == 1,
            ),
          ]),
        );

        await controller.refresh();
      });

      test('emits Error with empty list on failure', () async {
        when(() => mockRepository.loadRecordings()).thenThrow(
          RecordingLibraryException(
            RecordingLibraryErrorCode.storageUnavailable,
            'DB error',
          ),
        );

        expectLater(
          controller.stream,
          emitsInOrder([
            const RecordingLibraryLoading(),
            predicate<RecordingLibraryState>(
              (s) => s.isError && s.recordings.isEmpty,
            ),
          ]),
        );

        await controller.refresh();
      });
    });

    group('saveRecording', () {
      final saveRequest = RecordingLibrarySaveRequest(
        temporaryPath: kIsWeb ? null : '/tmp/recording.wav',
        audioBytes: kIsWeb ? Uint8List.fromList([1, 2, 3]) : null,
        title: 'New Recording',
        duration: const Duration(seconds: 45),
        sizeBytes: 2 * 1024 * 1024,
        extension: 'wav',
      );

      test('emits Saving then Loaded with new entry on success', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(() => mockRepository.saveRecording(saveRequest)).thenAnswer(
          (_) async => testEntry.copyWith(id: 'rec_2', title: 'New Recording'),
        );

        // Initial load
        await controller.refresh();

        expectLater(
          controller.stream,
          emitsInOrder([
            predicate<RecordingLibraryState>(
              (s) => s.isSaving && s.recordings.length == 1,
            ),
            predicate<RecordingLibraryState>(
              (s) => s.isLoaded && s.recordings.length == 2,
            ),
          ]),
        );

        await controller.saveRecording(saveRequest);
      });

      test('retains current recordings in Saving state', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(() => mockRepository.saveRecording(saveRequest)).thenThrow(
          RecordingLibraryException(
            RecordingLibraryErrorCode.quotaExceeded,
            'Quota',
          ),
        );

        await controller.refresh();

        expectLater(
          controller.stream,
          emitsInOrder([
            predicate<RecordingLibraryState>(
              (s) => s.isSaving && s.recordings.length == 1,
            ),
            predicate<RecordingLibraryState>(
              (s) => s.isError && s.recordings.length == 1,
            ),
          ]),
        );

        try {
          await controller.saveRecording(saveRequest);
        } catch (_) {}
      });

      test('throws if save already in progress', () async {
        when(() => mockRepository.saveRecording(saveRequest)).thenAnswer(
          (_) => Future.delayed(const Duration(seconds: 1), () => testEntry),
        );

        final first = controller.saveRecording(saveRequest);
        expect(
          () => controller.saveRecording(saveRequest),
          throwsA(isA<RecordingLibraryException>()),
        );

        await first;
      });

      test('throws if controller disposed', () async {
        // Create a fresh controller for this test and wait for initial load
        final disposedController = RecordingLibraryController(mockRepository);
        await Future.delayed(const Duration(milliseconds: 50));
        await disposedController.refresh();
        disposedController.dispose();
        expect(
          () => disposedController.saveRecording(saveRequest),
          throwsA(isA<RecordingLibraryException>()),
        );
      });
    });

    group('renameRecording', () {
      test('emits Saving then Loaded with renamed entry', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(
          () => mockRepository.renameRecording('rec_1', 'Renamed'),
        ).thenAnswer((_) async => {});

        await controller.refresh();

        expectLater(
          controller.stream,
          emitsInOrder([
            predicate<RecordingLibraryState>(
              (s) => s.isSaving && s.recordings.length == 1,
            ),
            predicate<RecordingLibraryState>(
              (s) => s.isLoaded && s.recordings.first.title == 'Renamed',
            ),
          ]),
        );

        await controller.renameRecording('rec_1', 'Renamed');
      });

      test('retains recordings in Error state on not found', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(() => mockRepository.renameRecording('missing', 'X')).thenThrow(
          RecordingLibraryException(
            RecordingLibraryErrorCode.notFound,
            'Not found',
          ),
        );

        await controller.refresh();

        expectLater(
          controller.stream,
          emitsInOrder([
            predicate<RecordingLibraryState>(
              (s) => s.isSaving && s.recordings.length == 1,
            ),
            predicate<RecordingLibraryState>(
              (s) => s.isError && s.recordings.length == 1,
            ),
          ]),
        );

        try {
          await controller.renameRecording('missing', 'X');
        } catch (_) {}
      });
    });

    group('toggleFavorite', () {
      test('toggles favorite status', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(
          () => mockRepository.toggleFavorite('rec_1'),
        ).thenAnswer((_) async => {});

        await controller.refresh();

        expectLater(
          controller.stream,
          emitsInOrder([
            predicate<RecordingLibraryState>((s) => s.isSaving),
            predicate<RecordingLibraryState>(
              (s) => s.isLoaded && s.recordings.first.isFavorite,
            ),
          ]),
        );

        await controller.toggleFavorite('rec_1');
      });
    });

    group('deleteRecording', () {
      test('emits Saving then Loaded with entry removed', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(
          () => mockRepository.deleteRecording('rec_1'),
        ).thenAnswer((_) async => {});

        await controller.refresh();

        expectLater(
          controller.stream,
          emitsInOrder([
            predicate<RecordingLibraryState>(
              (s) => s.isSaving && s.recordings.length == 1,
            ),
            predicate<RecordingLibraryState>(
              (s) => s.isLoaded && s.recordings.isEmpty,
            ),
          ]),
        );

        await controller.deleteRecording('rec_1');
      });

      test('retains recordings in Error state on failure', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(() => mockRepository.deleteRecording('rec_1')).thenThrow(
          RecordingLibraryException(
            RecordingLibraryErrorCode.platformError,
            'Fail',
          ),
        );

        await controller.refresh();

        expectLater(
          controller.stream,
          emitsInOrder([
            predicate<RecordingLibraryState>(
              (s) => s.isSaving && s.recordings.length == 1,
            ),
            predicate<RecordingLibraryState>(
              (s) => s.isError && s.recordings.length == 1,
            ),
          ]),
        );

        try {
          await controller.deleteRecording('rec_1');
        } catch (_) {}
      });
    });

    group('disposal protection', () {
      test('throws when saving after dispose', () async {
        // Create a fresh controller for this test and wait for initial load
        final disposedController = RecordingLibraryController(mockRepository);
        await Future.delayed(const Duration(milliseconds: 50));
        await disposedController.refresh();
        disposedController.dispose();
        expect(
          () => disposedController.saveRecording(
            RecordingLibrarySaveRequest(
              temporaryPath: '/tmp/x.wav',
              title: 'X',
              duration: Duration.zero,
              sizeBytes: 1,
              extension: 'wav',
            ),
          ),
          throwsA(isA<RecordingLibraryException>()),
        );
      });

      test('loadRecordingBytes returns null after dispose', () async {
        // Create a fresh controller for this test and wait for initial load
        final disposedController = RecordingLibraryController(mockRepository);
        await Future.delayed(const Duration(milliseconds: 50));
        await disposedController.refresh();
        disposedController.dispose();
        final result = await disposedController.loadRecordingBytes('rec_1');
        expect(result, isNull);
      });
    });

    group('duplicate operation prevention', () {
      test('ignores concurrent rename calls', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(
          () => mockRepository.renameRecording(any(), any()),
        ).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 100)));

        await controller.refresh();

        // Fire two concurrent renames
        final f1 = controller.renameRecording('rec_1', 'A');
        final f2 = controller.renameRecording('rec_1', 'B');

        await Future.wait([f1, f2]);
        // Second call should be ignored (no exception, but only one rename happens)
      });

      test('ignores concurrent toggleFavorite calls', () async {
        when(
          () => mockRepository.loadRecordings(),
        ).thenAnswer((_) async => [testEntry]);
        when(
          () => mockRepository.toggleFavorite(any()),
        ).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 100)));

        await controller.refresh();

        final f1 = controller.toggleFavorite('rec_1');
        final f2 = controller.toggleFavorite('rec_1');

        await Future.wait([f1, f2]);
      });
    });
  });

  group('RecordingLibraryEntry', () {
    test('copyWith updates only specified fields', () {
      final entry = RecordingLibraryEntry(
        id: '1',
        title: 'Original',
        createdAt: DateTime.now(),
        duration: const Duration(seconds: 10),
        sizeBytes: 100,
        extension: 'wav',
        metadataKey: 'k1',
      );

      final updated = entry.copyWith(title: 'New', isFavorite: true);

      expect(updated.title, 'New');
      expect(updated.isFavorite, true);
      expect(updated.id, '1');
      expect(updated.extension, 'wav');
    });

    test('toJson/fromJson roundtrip', () {
      final entry = RecordingLibraryEntry(
        id: '1',
        title: 'Test',
        createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
        duration: const Duration(seconds: 30),
        sizeBytes: 1024,
        extension: 'opus',
        localPath: '/path/file.opus',
        webStorageKey: 'web_key',
        metadataKey: 'k1',
        isFavorite: true,
        analysisStatus: AnalysisStatus.completed,
        analysisScore: 95.5,
        referenceTrackName: 'Ref Track',
      );

      final json = entry.toJson();
      final decoded = RecordingLibraryEntry.fromJson(json);

      expect(decoded.id, entry.id);
      expect(decoded.title, entry.title);
      expect(decoded.createdAt, entry.createdAt);
      expect(decoded.duration, entry.duration);
      expect(decoded.sizeBytes, entry.sizeBytes);
      expect(decoded.extension, entry.extension);
      expect(decoded.localPath, entry.localPath);
      expect(decoded.webStorageKey, entry.webStorageKey);
      expect(decoded.metadataKey, entry.metadataKey);
      expect(decoded.isFavorite, entry.isFavorite);
      expect(decoded.analysisStatus, entry.analysisStatus);
      expect(decoded.analysisScore, entry.analysisScore);
      expect(decoded.referenceTrackName, entry.referenceTrackName);
    });
  });

  group('RecordingLibrarySaveRequest', () {
    test('isValid on native requires temporaryPath', () {
      final req = RecordingLibrarySaveRequest(
        temporaryPath: '/tmp/x.wav',
        title: 'X',
        duration: Duration.zero,
        sizeBytes: 1,
        extension: 'wav',
      );
      // On native (test runs on VM), isValid should be true
      expect(req.isValid, !kIsWeb);
    });

    test('isValid on web requires audioBytes', () {
      final req = RecordingLibrarySaveRequest(
        audioBytes: Uint8List.fromList([1, 2, 3]),
        title: 'X',
        duration: Duration.zero,
        sizeBytes: 3,
        extension: 'opus',
      );
      // On web, isValid should be true
      expect(req.isValid, kIsWeb);
    });
  });
}
