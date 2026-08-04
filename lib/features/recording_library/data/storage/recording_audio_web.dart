import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web audio helper.
///
/// On Web, the `record` package returns a temporary Blob/Object URL when a
/// recording stops. These URLs do NOT survive browser restarts, so before
/// persisting a recording we fetch the underlying bytes and store them in
/// IndexedDB. When playing back a library entry we recreate a fresh object
/// URL from the stored bytes for the current session.

/// Fetches the raw audio bytes behind a Blob/Object URL.
///
/// Returns null if the URL is invalid or the fetch fails.
Future<Uint8List?> fetchBlobUrlBytes(String blobUrl) async {
  try {
    final response = await web.window.fetch(blobUrl.toJS).toDart;
    if (!response.ok) {
      return null;
    }
    final arrayBuffer = await response.arrayBuffer().toDart;
    return arrayBuffer.toDart.asUint8List();
  } catch (e) {
    // Blob URLs are session-scoped; a stale URL simply yields no bytes.
    return null;
  }
}

/// Creates a temporary Blob/Object URL from [bytes] for session playback.
///
/// The returned URL is only valid for the current page session and should be
/// revoked when no longer needed.
Future<String?> createObjectUrlFromBytes(
  Uint8List bytes,
  String mimeType,
) async {
  try {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: mimeType),
    );
    return web.URL.createObjectURL(blob);
  } catch (e) {
    return null;
  }
}
