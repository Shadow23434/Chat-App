import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

Future<Duration?> getAudioDuration(String path) async {
  final player = AudioPlayer();
  await player.setSource(DeviceFileSource(path));
  final duration = await player.getDuration();
  await player.dispose();
  return duration;
}

Future<String> getTempAudioFilePath() async {
  final tempDir = await getTemporaryDirectory();
  return '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
}

String formatDuration(int seconds) {
  final min = (seconds ~/ 60).toString().padLeft(2, '0');
  final sec = (seconds % 60).toString().padLeft(2, '0');
  return '$min:$sec';
}
