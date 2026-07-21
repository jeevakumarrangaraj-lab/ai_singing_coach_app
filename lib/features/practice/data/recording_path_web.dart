Future<String> createRecordingPath() async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'recording_$timestamp.wav';
}
