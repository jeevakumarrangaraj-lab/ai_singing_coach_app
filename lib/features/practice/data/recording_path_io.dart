import 'dart:io';

Future<String> createRecordingPath() async {
  final directory = Directory.systemTemp;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${directory.path}/recording_$timestamp.wav';
}
