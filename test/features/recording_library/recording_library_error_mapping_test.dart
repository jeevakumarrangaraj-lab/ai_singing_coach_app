import 'package:flutter_test/flutter_test.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';
import 'package:ai_singing_coach/l10n/app_localizations_en.dart';
import 'package:ai_singing_coach/l10n/app_localizations_hi.dart';
import 'package:ai_singing_coach/l10n/app_localizations_ta.dart';
import 'package:ai_singing_coach/features/recording_library/domain/recording_library_error_code.dart';
import 'package:ai_singing_coach/features/recording_library/data/recording_library_repository.dart';

void main() {
  group('Recording Library Error Code Mapping Tests', () {
    final en = AppLocalizationsEn();
    final hi = AppLocalizationsHi();
    final ta = AppLocalizationsTa();

    String mapErrorCode(
      RecordingLibraryErrorCode? code,
      AppLocalizations l10n, {
      bool isUnexpected = false,
    }) {
      if (isUnexpected) {
        return l10n.unexpectedError;
      }
      if (code != null) {
        switch (code) {
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
      return l10n.unexpectedError;
    }

    test('Quota-exceeded error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.quotaExceeded, en),
        en.recordingSaveQuotaExceeded,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.quotaExceeded, hi),
        hi.recordingSaveQuotaExceeded,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.quotaExceeded, ta),
        ta.recordingSaveQuotaExceeded,
      );
      expect(en.recordingSaveQuotaExceeded.isNotEmpty, isTrue);
      expect(hi.recordingSaveQuotaExceeded.isNotEmpty, isTrue);
      expect(ta.recordingSaveQuotaExceeded.isNotEmpty, isTrue);
    });

    test('Storage-unavailable error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.storageUnavailable, en),
        en.recordingSaveStorageUnavailable,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.storageUnavailable, hi),
        hi.recordingSaveStorageUnavailable,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.storageUnavailable, ta),
        ta.recordingSaveStorageUnavailable,
      );
      expect(en.recordingSaveStorageUnavailable.isNotEmpty, isTrue);
      expect(hi.recordingSaveStorageUnavailable.isNotEmpty, isTrue);
      expect(ta.recordingSaveStorageUnavailable.isNotEmpty, isTrue);
    });

    test('Not-found (missing file) error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.notFound, en),
        en.recordingSaveNotFound,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.notFound, hi),
        hi.recordingSaveNotFound,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.notFound, ta),
        ta.recordingSaveNotFound,
      );
      expect(en.recordingSaveNotFound.isNotEmpty, isTrue);
      expect(hi.recordingSaveNotFound.isNotEmpty, isTrue);
      expect(ta.recordingSaveNotFound.isNotEmpty, isTrue);
    });

    test('Cancelled error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.cancelled, en),
        en.recordingSaveCancelled,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.cancelled, hi),
        hi.recordingSaveCancelled,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.cancelled, ta),
        ta.recordingSaveCancelled,
      );
    });

    test('Platform error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.platformError, en),
        en.recordingSavePlatformError,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.platformError, hi),
        hi.recordingSavePlatformError,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.platformError, ta),
        ta.recordingSavePlatformError,
      );
    });

    test('Invalid data error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.invalidData, en),
        en.recordingSaveInvalidData,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.invalidData, hi),
        hi.recordingSaveInvalidData,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.invalidData, ta),
        ta.recordingSaveInvalidData,
      );
    });

    test('Disposed error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.disposed, en),
        en.recordingSaveDisposed,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.disposed, hi),
        hi.recordingSaveDisposed,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.disposed, ta),
        ta.recordingSaveDisposed,
      );
    });

    test('Permission denied error maps correctly for EN, HI, TA', () {
      expect(
        mapErrorCode(RecordingLibraryErrorCode.permissionDenied, en),
        en.recordingSavePermissionDenied,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.permissionDenied, hi),
        hi.recordingSavePermissionDenied,
      );
      expect(
        mapErrorCode(RecordingLibraryErrorCode.permissionDenied, ta),
        ta.recordingSavePermissionDenied,
      );
      expect(en.recordingSavePermissionDenied.isNotEmpty, isTrue);
      expect(hi.recordingSavePermissionDenied.isNotEmpty, isTrue);
      expect(ta.recordingSavePermissionDenied.isNotEmpty, isTrue);
    });

    test('Unexpected/unknown error maps to unexpectedError for EN, HI, TA', () {
      expect(mapErrorCode(null, en, isUnexpected: true), en.unexpectedError);
      expect(mapErrorCode(null, hi, isUnexpected: true), hi.unexpectedError);
      expect(mapErrorCode(null, ta, isUnexpected: true), ta.unexpectedError);
    });

    test(
      'Persistence warning & session-only messages exist and are localized',
      () {
        expect(en.recordingSavedToLibrary.isNotEmpty, isTrue);
        expect(hi.recordingSavedToLibrary.isNotEmpty, isTrue);
        expect(ta.recordingSavedToLibrary.isNotEmpty, isTrue);

        expect(en.webPersistenceWarning.isNotEmpty, isTrue);
        expect(hi.webPersistenceWarning.isNotEmpty, isTrue);
        expect(ta.webPersistenceWarning.isNotEmpty, isTrue);

        expect(en.recordingSessionOnly.isNotEmpty, isTrue);
        expect(hi.recordingSessionOnly.isNotEmpty, isTrue);
        expect(ta.recordingSessionOnly.isNotEmpty, isTrue);
      },
    );

    test(
      'RecordingLibraryException carries typed error code and original error',
      () {
        const ex = RecordingLibraryException(
          RecordingLibraryErrorCode.quotaExceeded,
          'Quota exceeded message',
        );
        expect(ex.code, RecordingLibraryErrorCode.quotaExceeded);
        expect(ex.message, 'Quota exceeded message');
        expect(
          ex.toString(),
          contains('RecordingLibraryErrorCode.quotaExceeded'),
        );
      },
    );
  });
}
