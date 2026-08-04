import 'dart:typed_data';

/// Native (Android/iOS/Desktop) audio helper.
///
/// Native recordings live on the filesystem and are referenced by path,
/// so blob fetching / object-URL creation are not applicable here.

/// Not applicable on native; returns null.
Future<Uint8List?> fetchBlobUrlBytes(String blobUrl) async => null;

/// Not applicable on native; returns null.
Future<String?> createObjectUrlFromBytes(
  Uint8List bytes,
  String mimeType,
) async => null;
