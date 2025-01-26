import 'dart:io';

import 'package:flutter/material.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/services/downloads_service.dart';
import 'package:offline_tube/services/navigation_service.dart';
import 'package:path_provider/path_provider.dart';

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  final int seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  } else {
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
}

String cutText({
  required int size,
  required String text,
}) {
  return text.length < size ? text : '${text.substring(0, size)}...';
}

Future<void> deleteDownload(String videoId) async {
  final dir = await getTemporaryDirectory();
  final filePath = '${dir.path}/temp_audio_$videoId';
  final file = File(filePath);

  if (file.existsSync()) {
    try {
      file.deleteSync();
    } catch (_) {
      debugPrint('Could not delete file temp_audio_$videoId');
    }
  }
}

Future<String?> downLoadToTemp(
  String videoId, {
  DownloadingProgress? progress,
}) async {
  return await youtubeService.downloadAudioToTemp(
    videoId,
    progress: progress,
  );
}

String formatCount(int count) {
  if (count >= 1000000000) {
    return '${(count / 1000000000).toStringAsFixed(2)}B';
  } else if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(2)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(2)}K';
  } else {
    return count.toString();
  }
}

void showSnackBar({required String text, bool isError = true}) {
  ScaffoldMessenger.of(currentContext!).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2),
      backgroundColor: isError ? null : Colors.green,
    ),
  );
}

final currentContext = NavigationService.navigatorKey.currentContext;
double width = MediaQuery.of(currentContext!).size.width;
